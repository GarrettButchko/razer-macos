//
//  RazerHardwareBridge.swift
//  RazerMacOS
//
//  Created by Garrett Butchko.
//

import Foundation
import LoggingKit

public struct DiscoveredRazerDevice: Sendable {
    public let productId: UInt16
    public let internalDeviceId: Int32
    public let usbDevicePtr: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?
}

public final class RazerHardwareBridge: @unchecked Sendable {
    public static let shared = RazerHardwareBridge()

    private var activeDevices: RazerDevices = RazerDevices(devices: nil, size: 0)
    private let lock = NSLock()

    private init() {}

    deinit {
        closeDevices()
    }

    public func scanDevices() -> [DiscoveredRazerDevice] {
        lock.lock()
        defer { lock.unlock() }

        if activeDevices.devices != nil && activeDevices.size > 0 {
            closeAllRazerDevices(activeDevices)
            activeDevices = RazerDevices(devices: nil, size: 0)
        }

        activeDevices = getAllRazerDevices()
        var discovered: [DiscoveredRazerDevice] = []

        guard let devicesPtr = activeDevices.devices, activeDevices.size > 0 else {
            return []
        }

        for i in 0..<Int(activeDevices.size) {
            let dev = devicesPtr[i]
            discovered.append(DiscoveredRazerDevice(
                productId: dev.productId,
                internalDeviceId: dev.internalDeviceId,
                usbDevicePtr: dev.usbDevice
            ))
        }

        return discovered
    }

    public func closeDevices() {
        lock.lock()
        defer { lock.unlock() }

        if activeDevices.devices != nil && activeDevices.size > 0 {
            closeAllRazerDevices(activeDevices)
            activeDevices = RazerDevices(devices: nil, size: 0)
        }
    }

    // MARK: - Lighting Effects

    public func applyStatic(usbDev: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?, type: RazerDeviceType, color: RGBColor) {
        guard let dev = usbDev else { return }
        var buf: [Int8] = [Int8(bitPattern: color.red), Int8(bitPattern: color.green), Int8(bitPattern: color.blue)]
        buf.withUnsafeMutableBufferPointer { ptr in
            guard let base = ptr.baseAddress else { return }
            switch type {
            case .keyboard, .blade:
                razer_attr_write_mode_static(dev, base, 3)
            case .mouse:
                razer_attr_write_logo_mode_static(dev, base, 3)
                razer_attr_write_scroll_mode_static(dev, base, 3)
                razer_attr_write_left_mode_static(dev, base, 3)
                razer_attr_write_right_mode_static(dev, base, 3)
            case .mousemat:
                razer_mouse_mat_attr_write_mode_static(dev, base, 3)
            case .headphone:
                razer_headphone_attr_write_mode_static(dev, base, 3)
            case .accessory, .egpu:
                razer_accessory_attr_write_mode_static(dev, base, 3)
            case .other:
                razer_attr_write_mode_static(dev, base, 3)
            }
        }
    }

    public func applyBreathing(usbDev: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?, type: RazerDeviceType, color1: RGBColor, color2: RGBColor?) {
        guard let dev = usbDev else { return }
        if let color2 = color2 {
            var buf: [Int8] = [
                Int8(bitPattern: color1.red), Int8(bitPattern: color1.green), Int8(bitPattern: color1.blue),
                Int8(bitPattern: color2.red), Int8(bitPattern: color2.green), Int8(bitPattern: color2.blue)
            ]
            buf.withUnsafeMutableBufferPointer { ptr in
                guard let base = ptr.baseAddress else { return }
                switch type {
                case .mouse:
                    razer_attr_write_logo_mode_breath(dev, base, 6)
                    razer_attr_write_scroll_mode_breath(dev, base, 6)
                case .mousemat:
                    razer_mouse_mat_attr_write_mode_breath(dev, base, 6)
                case .headphone:
                    razer_headphone_attr_write_mode_breath(dev, base, 6)
                case .accessory, .egpu:
                    razer_accessory_attr_write_mode_breath(dev, base, 6)
                default:
                    razer_attr_write_mode_breath(dev, base, 6)
                }
            }
        } else {
            var buf: [Int8] = [Int8(bitPattern: color1.red), Int8(bitPattern: color1.green), Int8(bitPattern: color1.blue)]
            buf.withUnsafeMutableBufferPointer { ptr in
                guard let base = ptr.baseAddress else { return }
                switch type {
                case .mouse:
                    razer_attr_write_logo_mode_breath(dev, base, 3)
                    razer_attr_write_scroll_mode_breath(dev, base, 3)
                case .mousemat:
                    razer_mouse_mat_attr_write_mode_breath(dev, base, 3)
                case .headphone:
                    razer_headphone_attr_write_mode_breath(dev, base, 3)
                case .accessory, .egpu:
                    razer_accessory_attr_write_mode_breath(dev, base, 3)
                default:
                    razer_attr_write_mode_breath(dev, base, 3)
                }
            }
        }
    }

    public func applySpectrum(usbDev: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?, type: RazerDeviceType) {
        guard let dev = usbDev else { return }
        var dummy: [Int8] = [0]
        dummy.withUnsafeMutableBufferPointer { ptr in
            guard let base = ptr.baseAddress else { return }
            switch type {
            case .keyboard, .blade:
                razer_attr_write_mode_spectrum(dev, base, 0)
            case .mouse:
                razer_attr_write_logo_mode_spectrum(dev, base, 0)
                razer_attr_write_scroll_mode_spectrum(dev, base, 0)
                razer_attr_write_left_mode_spectrum(dev, base, 0)
                razer_attr_write_right_mode_spectrum(dev, base, 0)
            case .mousemat:
                razer_mouse_mat_attr_write_mode_spectrum(dev, base, 0)
            case .headphone:
                razer_headphone_attr_write_mode_spectrum(dev, base, 0)
            case .accessory, .egpu:
                razer_accessory_attr_write_mode_spectrum(dev, base, 0)
            case .other:
                razer_attr_write_mode_spectrum(dev, base, 0)
            }
        }
    }

    public func applyWave(usbDev: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?, type: RazerDeviceType, direction: WaveDirection, speed: Int) {
        guard let dev = usbDev else { return }
        let dirStr = direction == .leftToRight ? "1" : "2"
        dirStr.withCString { cStr in
            switch type {
            case .mouse:
                razer_attr_write_logo_mode_wave(dev, cStr, 0)
                razer_attr_write_scroll_mode_wave(dev, cStr, 0)
            case .mousemat:
                razer_mouse_mat_attr_write_mode_wave(dev, cStr, 0)
            case .headphone:
                razer_headphone_attr_write_mode_wave(dev, cStr, 0, Int32(speed))
            case .accessory, .egpu:
                razer_accessory_attr_write_mode_wave(dev, cStr, 0, Int32(speed))
            default:
                razer_attr_write_mode_wave(dev, cStr, 0, Int32(speed))
            }
        }
    }

    public func applyReactive(usbDev: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?, type: RazerDeviceType, color: RGBColor, speed: Int) {
        guard let dev = usbDev else { return }
        var buf: [Int8] = [
            Int8(bitPattern: UInt8(max(1, min(4, speed)))),
            Int8(bitPattern: color.red),
            Int8(bitPattern: color.green),
            Int8(bitPattern: color.blue)
        ]
        buf.withUnsafeMutableBufferPointer { ptr in
            guard let base = ptr.baseAddress else { return }
            if type == .mouse {
                razer_attr_write_logo_mode_reactive(dev, base, 4)
                razer_attr_write_scroll_mode_reactive(dev, base, 4)
            } else {
                razer_attr_write_mode_reactive(dev, base, 4)
            }
        }
    }

    public func applyNone(usbDev: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?, type: RazerDeviceType) {
        guard let dev = usbDev else { return }
        var dummy: [Int8] = [0]
        dummy.withUnsafeMutableBufferPointer { ptr in
            guard let base = ptr.baseAddress else { return }
            switch type {
            case .keyboard, .blade:
                razer_attr_write_mode_none(dev, base, 0)
            case .mouse:
                razer_attr_write_logo_mode_none(dev, base, 0)
                razer_attr_write_scroll_mode_none(dev, base, 0)
                razer_attr_write_left_mode_none(dev, base, 0)
                razer_attr_write_right_mode_none(dev, base, 0)
            case .mousemat:
                razer_mouse_mat_attr_write_mode_none(dev, base, 0)
            case .headphone:
                razer_headphone_attr_write_mode_none(dev, base, 0)
            case .accessory, .egpu:
                razer_accessory_attr_write_mode_none(dev, base, 0)
            case .other:
                razer_attr_write_mode_none(dev, base, 0)
            }
        }
    }

    // MARK: - Performance & Configuration

    public func setBrightness(usbDev: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?, type: RazerDeviceType, brightnessPercent: Double) {
        guard let dev = usbDev else { return }
        // The underlying driver functions (razer_chroma_standard_set_led_brightness,
        // razer_chroma_extended_matrix_brightness, etc.) take a 0-100 percentage value
        // and multiply by 2.55 internally. Scale 0-100% to 0-40 (which maps linearly to 0-100 for the hardware).
        let clampedPercent = max(0.0, min(100.0, brightnessPercent))
        let scaledPercent: Double = clampedPercent == 0 ? 0 : (clampedPercent / 100.0) * 40.0
        let rawBrightness = UInt16(round(scaledPercent))

        switch type {
        case .mouse:
            let mouseBrightness = UInt8(rawBrightness)
            razer_attr_write_logo_led_brightness(dev, mouseBrightness)
            razer_attr_write_scroll_led_brightness(dev, mouseBrightness)
            razer_attr_write_left_led_brightness(dev, mouseBrightness)
            razer_attr_write_right_led_brightness(dev, mouseBrightness)
            razer_attr_write_matrix_brightness(dev, mouseBrightness)
        case .mousemat:
            razer_mouse_mat_attr_write_set_brightness(dev, rawBrightness, 1)
        case .accessory, .egpu:
            razer_accessory_attr_write_set_brightness(dev, rawBrightness, 1)
        default:
            razer_attr_write_set_brightness(dev, rawBrightness, 1)
        }
    }

    public func setDpi(usbDev: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?, dpi: Int) {
        guard let dev = usbDev else { return }
        razer_attr_write_dpi(dev, UInt16(dpi), UInt16(dpi))
    }

    public func setPollRate(usbDev: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?, rate: Int) {
        guard let dev = usbDev else { return }
        razer_attr_write_poll_rate(dev, UInt16(rate))
    }

    public func getBattery(usbDev: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?) -> (level: Int, isCharging: Bool)? {
        guard let dev = usbDev else { return nil }

        var batBuf = [CChar](repeating: 0, count: 8)
        razer_attr_read_get_battery(dev, &batBuf)
        let batStr = String(cString: batBuf).trimmingCharacters(in: .whitespacesAndNewlines)
        guard let val = Double(batStr), val > 0 else { return nil }
        let level = max(0, min(100, Int((val * 100.0) / 255.0)))

        var chargeBuf = [CChar](repeating: 0, count: 4)
        razer_attr_read_is_charging(dev, &chargeBuf)
        let isCharging = (Int(String(cString: chargeBuf).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0) != 0

        return (level, isCharging)
    }
}
