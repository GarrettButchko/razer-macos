//
//  RazerDeviceManager.swift
//  RazerMacOS
//
//  Created by Garrett Butchko.
//

import SwiftUI
import LoggingKit

public struct AppLogItem: Identifiable, Sendable {
    public let id = UUID()
    public let timestamp = Date()
    public let level: LogLevel
    public let message: String
}

@Observable
@MainActor
public final class RazerDeviceManager {
    public var devices: [RazerDeviceModel] = []
    public var selectedDeviceId: String?
    public var isScanning: Bool = false
    public var demoModeEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(demoModeEnabled, forKey: "demoModeEnabled")
            refreshDevices()
        }
    }
    public var autoRefreshInterval: Double = 5.0
    public var syncAllDevices: Bool = false

    // Live Logs
    public var logs: [AppLogItem] = []

    // Hardware handles mapping: device.id -> DiscoveredRazerDevice
    private var hardwareHandles: [String: DiscoveredRazerDevice] = [:]
    private var scanTimer: Timer?

    public init() {
        self.demoModeEnabled = UserDefaults.standard.bool(forKey: "demoModeEnabled")

        // Hook LoggingKit handler to feed UI log feed
        AppLogger.logHandler = { [weak self] level, msg in
            Task { @MainActor in
                self?.appendLog(level: level, message: msg)
            }
        }

        AppLogger.info("Razer macOS Engine initialized.", tag: "Engine")
        refreshDevices()
        startPeriodicTimer()
    }

    public var selectedDevice: RazerDeviceModel? {
        if let id = selectedDeviceId, let dev = devices.first(where: { $0.id == id }) {
            return dev
        }
        return devices.first
    }

    public func appendLog(level: LogLevel, message: String) {
        logs.append(AppLogItem(level: level, message: message))
        if logs.count > 500 {
            logs.removeFirst(logs.count - 500)
        }
    }

    public func refreshDevices() {
        isScanning = true
        AppLogger.info("Scanning USB bus for connected Razer peripherals...", tag: "USB")

        Task {
            let discovered = RazerHardwareBridge.shared.scanDevices()

            await MainActor.run {
                var newDevices: [RazerDeviceModel] = []
                self.hardwareHandles.removeAll()

                for raw in discovered {
                    let catalog = RazerDeviceCatalog.shared
                    let def = catalog.definition(for: raw.productId)
                    let name = def?.name ?? catalog.name(for: raw.productId)
                    let type = def?.mainType ?? catalog.type(for: raw.productId)
                    let maxDpi = def?.maxDpi ?? 16000

                    let model = RazerDeviceModel(
                        productId: raw.productId,
                        name: name,
                        type: type,
                        isConnected: true,
                        isSimulated: false,
                        maxDpi: maxDpi,
                        internalDeviceId: raw.internalDeviceId
                    )

                    // Read battery if wireless mouse
                    if type == .mouse {
                        if let bat = RazerHardwareBridge.shared.getBattery(usbDev: raw.usbDevicePtr) {
                            model.batteryLevel = bat.level
                            model.isCharging = bat.isCharging
                        }
                    }

                    newDevices.append(model)
                    self.hardwareHandles[model.id] = raw
                }

                if newDevices.isEmpty {
                    AppLogger.info("No physical Razer devices detected on USB ports.", tag: "USB")
                    if self.demoModeEnabled {
                        AppLogger.info("Preview / Demo mode active: loading simulated peripherals.", tag: "Engine")
                        newDevices.append(contentsOf: self.createSimulatedDevices())
                    }
                } else {
                    AppLogger.success("Discovered \(newDevices.count) Razer hardware device(s).", tag: "USB")
                }

                self.devices = newDevices
                if self.selectedDeviceId == nil || !self.devices.contains(where: { $0.id == self.selectedDeviceId }) {
                    self.selectedDeviceId = self.devices.first?.id
                }
                self.isScanning = false
            }
        }
    }

    // MARK: - Hardware Control Actions

    public func toggleLightingPower(for device: RazerDeviceModel) {
        let targets = syncAllDevices ? devices : [device]
        let willTurnOn = device.currentMode == .off || device.brightness <= 0
        for dev in targets {
            if willTurnOn {
                let targetMode = dev.previousMode ?? .staticColor
                dev.currentMode = targetMode == .off ? .staticColor : targetMode
                if dev.brightness <= 0 {
                    dev.brightness = 100
                    applyHardwareBrightness(for: dev, brightness: 100)
                }
                applyHardwareLightingMode(for: dev, mode: dev.currentMode)
            } else {
                dev.previousMode = dev.currentMode
                dev.currentMode = .off
                applyHardwareLightingMode(for: dev, mode: .off)
            }
        }
        AppLogger.info("Toggled Chroma power (\(willTurnOn ? "ON" : "OFF")) for \(syncAllDevices ? "all devices" : device.name)", tag: "Chroma")
    }

    public func setLightingMode(for device: RazerDeviceModel, mode: LightingEffectMode) {
        let targets = syncAllDevices ? devices : [device]
        for dev in targets {
            dev.currentMode = mode
            if mode != .off {
                dev.previousMode = mode
            }
            applyHardwareLightingMode(for: dev, mode: mode)
        }
        AppLogger.info("Set lighting mode '\(mode.rawValue)' on \(syncAllDevices ? "all devices" : device.name)", tag: "Chroma")
    }

    public func setPrimaryColor(for device: RazerDeviceModel, color: RGBColor) {
        let targets = syncAllDevices ? devices : [device]
        for dev in targets {
            dev.primaryColor = color
            if dev.currentMode == .staticColor {
                applyHardwareLightingMode(for: dev, mode: .staticColor)
            } else if dev.currentMode == .breathe {
                applyHardwareLightingMode(for: dev, mode: .breathe)
            } else if dev.currentMode == .reactive {
                applyHardwareLightingMode(for: dev, mode: .reactive)
            }
        }
        AppLogger.info("Updated primary Chroma RGB (\(color.red), \(color.green), \(color.blue)) on \(syncAllDevices ? "all devices" : device.name)", tag: "Chroma")
    }

    public func setSecondaryColor(for device: RazerDeviceModel, color: RGBColor) {
        let targets = syncAllDevices ? devices : [device]
        for dev in targets {
            dev.secondaryColor = color
            if dev.currentMode == .breathe {
                applyHardwareLightingMode(for: dev, mode: .breathe)
            }
        }
        AppLogger.info("Updated secondary Chroma RGB (\(color.red), \(color.green), \(color.blue)) on \(syncAllDevices ? "all devices" : device.name)", tag: "Chroma")
    }

    public func setWaveDirection(for device: RazerDeviceModel, direction: WaveDirection) {
        let targets = syncAllDevices ? devices : [device]
        for dev in targets {
            dev.waveDirection = direction
            if dev.currentMode == .wave {
                applyHardwareLightingMode(for: dev, mode: .wave)
            }
        }
        AppLogger.info("Updated wave direction '\(direction.title)' on \(syncAllDevices ? "all devices" : device.name)", tag: "Chroma")
    }

    public func setEffectSpeed(for device: RazerDeviceModel, speed: Double) {
        let targets = syncAllDevices ? devices : [device]
        for dev in targets {
            dev.effectSpeed = speed
            if dev.currentMode == .wave {
                applyHardwareLightingMode(for: dev, mode: .wave)
            } else if dev.currentMode == .reactive {
                applyHardwareLightingMode(for: dev, mode: .reactive)
            }
        }
        AppLogger.info("Updated effect speed (\(speed)x) on \(syncAllDevices ? "all devices" : device.name)", tag: "Chroma")
    }

    public func setBrightness(for device: RazerDeviceModel, brightness: Double) {
        let targets = syncAllDevices ? devices : [device]
        for dev in targets {
            dev.brightness = brightness
            applyHardwareBrightness(for: dev, brightness: brightness)
        }
        AppLogger.info("Brightness set to \(Int(brightness))% on \(syncAllDevices ? "all devices" : device.name)", tag: "Chroma")
    }

    public func setDpi(for device: RazerDeviceModel, dpi: Int) {
        let clamped = max(100, min(device.maxDpi, dpi))
        device.dpi = clamped
        AppLogger.info("DPI sensitivity set to \(clamped) DPI on \(device.name)", tag: "Sensor")

        guard !device.isSimulated, let raw = hardwareHandles[device.id] else { return }
        RazerHardwareBridge.shared.setDpi(usbDev: raw.usbDevicePtr, dpi: clamped)
    }

    public func setPollingRate(for device: RazerDeviceModel, rate: Int) {
        device.pollingRate = rate
        AppLogger.info("Polling rate set to \(rate)Hz on \(device.name)", tag: "USB")

        guard !device.isSimulated, let raw = hardwareHandles[device.id] else { return }
        RazerHardwareBridge.shared.setPollRate(usbDev: raw.usbDevicePtr, rate: rate)
    }

    // MARK: - Private Hardware Helpers

    private func applyHardwareLightingMode(for device: RazerDeviceModel, mode: LightingEffectMode) {
        guard !device.isSimulated, let raw = hardwareHandles[device.id] else { return }

        switch mode {
        case .staticColor:
            RazerHardwareBridge.shared.applyStatic(usbDev: raw.usbDevicePtr, type: device.type, color: device.primaryColor)
        case .breathe:
            RazerHardwareBridge.shared.applyBreathing(usbDev: raw.usbDevicePtr, type: device.type, color1: device.primaryColor, color2: device.secondaryColor)
        case .spectrum:
            RazerHardwareBridge.shared.applySpectrum(usbDev: raw.usbDevicePtr, type: device.type)
        case .wave:
            RazerHardwareBridge.shared.applyWave(usbDev: raw.usbDevicePtr, type: device.type, direction: device.waveDirection, speed: Int(device.effectSpeed))
        case .reactive:
            RazerHardwareBridge.shared.applyReactive(usbDev: raw.usbDevicePtr, type: device.type, color: device.primaryColor, speed: Int(device.effectSpeed))
        case .starlight, .off:
            RazerHardwareBridge.shared.applyNone(usbDev: raw.usbDevicePtr, type: device.type)
        }
    }

    private func applyHardwareBrightness(for device: RazerDeviceModel, brightness: Double) {
        guard !device.isSimulated, let raw = hardwareHandles[device.id] else { return }
        RazerHardwareBridge.shared.setBrightness(usbDev: raw.usbDevicePtr, type: device.type, brightnessPercent: brightness)
    }

    // MARK: - Simulation

    private func createSimulatedDevices() -> [RazerDeviceModel] {
        return [
            RazerDeviceModel(
                productId: 0x0084,
                name: "Razer DeathAdder V2 (Simulated)",
                type: .mouse,
                isConnected: true,
                isSimulated: true,
                batteryLevel: 88,
                isCharging: false,
                dpi: 1600,
                maxDpi: 20000,
                pollingRate: 1000,
                brightness: 100.0,
                currentMode: .wave,
                primaryColor: .razerGreen
            ),
            RazerDeviceModel(
                productId: 0x0228,
                name: "Razer BlackWidow Elite (Simulated)",
                type: .keyboard,
                isConnected: true,
                isSimulated: true,
                brightness: 80.0,
                currentMode: .staticColor,
                primaryColor: .razerGreen
            ),
            RazerDeviceModel(
                productId: 0x0075,
                name: "Razer Firefly V2 (Simulated)",
                type: .mousemat,
                isConnected: true,
                isSimulated: true,
                brightness: 90.0,
                currentMode: .spectrum
            )
        ]
    }

    private func startPeriodicTimer() {
        scanTimer = Timer.scheduledTimer(withTimeInterval: autoRefreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.pollBatteryLevels()
            }
        }
    }

    private func pollBatteryLevels() {
        for dev in devices where !dev.isSimulated && dev.type == .mouse {
            if let raw = hardwareHandles[dev.id], let bat = RazerHardwareBridge.shared.getBattery(usbDev: raw.usbDevicePtr) {
                if dev.batteryLevel != bat.level || dev.isCharging != bat.isCharging {
                    dev.batteryLevel = bat.level
                    dev.isCharging = bat.isCharging
                    AppLogger.debug("Battery update for \(dev.name): \(bat.level)% (Charging: \(bat.isCharging))", tag: "Power")
                }
            }
        }
    }
}
