//
//  RazerDeviceModel.swift
//  RazerMacOS
//
//  Created by Garrett Butchko.
//

import SwiftUI

public enum RazerDeviceType: String, CaseIterable, Identifiable, Codable, Sendable {
    case keyboard = "keyboard"
    case mouse = "mouse"
    case mousemat = "mousemat"
    case headphone = "headphone"
    case egpu = "egpu"
    case blade = "blade"
    case accessory = "accessory"
    case other = "other"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .keyboard: return "Keyboard"
        case .mouse: return "Mouse"
        case .mousemat: return "Mouse Mat"
        case .headphone: return "Headset / Stand"
        case .egpu: return "eGPU"
        case .blade: return "Blade Laptop"
        case .accessory: return "Accessory"
        case .other: return "Peripheral"
        }
    }

    public var iconName: String {
        switch self {
        case .keyboard: return "keyboard"
        case .mouse: return "computermouse"
        case .mousemat: return "rectangle.fill"
        case .headphone: return "headphones"
        case .egpu: return "display.trianglebadge.exclamationmark"
        case .blade: return "laptopcomputer"
        case .accessory: return "cable.connector"
        case .other: return "sparkles"
        }
    }
}

public enum LightingEffectMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case staticColor = "Static"
    case breathe = "Breathing"
    case spectrum = "Spectrum Cycle"
    case wave = "Wave"
    case reactive = "Reactive"
    case starlight = "Starlight"
    case off = "Off"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .staticColor: return "paintbrush.fill"
        case .breathe: return "lungs.fill"
        case .spectrum: return "rainbow"
        case .wave: return "water.waves"
        case .reactive: return "bolt.fill"
        case .starlight: return "sparkles"
        case .off: return "moon.fill"
        }
    }

    public var description: String {
        switch self {
        case .staticColor: return "Solid illuminated color"
        case .breathe: return "Pulsing color transition"
        case .spectrum: return "Seamless rainbow loop"
        case .wave: return "Flowing RGB spectrum"
        case .reactive: return "Flashes on keypress or click"
        case .starlight: return "Twinkling starfield lights"
        case .off: return "Turn off peripheral LEDs"
        }
    }
}

public enum WaveDirection: Int, CaseIterable, Identifiable, Codable, Sendable {
    case leftToRight = 1
    case rightToLeft = 2

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .leftToRight: return "Left to Right"
        case .rightToLeft: return "Right to Left"
        }
    }
}

public struct RGBColor: Codable, Equatable, Sendable {
    public var red: UInt8
    public var green: UInt8
    public var blue: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public static let razerGreen = RGBColor(red: 0, green: 231, blue: 0)
    public static let cyan = RGBColor(red: 0, green: 217, blue: 242)
    public static let purple = RGBColor(red: 166, green: 38, blue: 242)
    public static let pink = RGBColor(red: 255, green: 51, blue: 153)
    public static let orange = RGBColor(red: 255, green: 115, blue: 0)
    public static let yellow = RGBColor(red: 255, green: 217, blue: 0)
    public static let redColor = RGBColor(red: 242, green: 38, blue: 38)
    public static let white = RGBColor(red: 255, green: 255, blue: 255)

    public var swiftUIColor: Color {
        Color(
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0
        )
    }

    public static func fromSwiftUI(_ color: Color) -> RGBColor {
        let nsColor = NSColor(color).usingColorSpace(.sRGB) ?? .green
        return RGBColor(
            red: UInt8(max(0, min(255, nsColor.redComponent * 255))),
            green: UInt8(max(0, min(255, nsColor.greenComponent * 255))),
            blue: UInt8(max(0, min(255, nsColor.blueComponent * 255)))
        )
    }
}

// MARK: - Unified Profile Models

public struct RazerDeviceProfileConfig: Codable, Equatable, Sendable {
    public var mode: LightingEffectMode
    public var brightness: Double
    public var primaryColor: RGBColor
    public var secondaryColor: RGBColor
    public var waveDirection: WaveDirection
    public var effectSpeed: Double
    public var dpi: Int
    public var pollingRate: Int

    public init(
        mode: LightingEffectMode = .staticColor,
        brightness: Double = 100.0,
        primaryColor: RGBColor = .razerGreen,
        secondaryColor: RGBColor = .cyan,
        waveDirection: WaveDirection = .leftToRight,
        effectSpeed: Double = 1.0,
        dpi: Int = 1600,
        pollingRate: Int = 1000
    ) {
        self.mode = mode
        self.brightness = brightness
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.waveDirection = waveDirection
        self.effectSpeed = effectSpeed
        self.dpi = dpi
        self.pollingRate = pollingRate
    }
}

public struct RazerProfile: Identifiable, Codable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var isBuiltIn: Bool
    public var deviceConfigs: [String: RazerDeviceProfileConfig] // keyed by productId hex or device id
    public var defaultGlobalConfig: RazerDeviceProfileConfig

    public init(
        id: String = UUID().uuidString,
        name: String,
        isBuiltIn: Bool = false,
        deviceConfigs: [String: RazerDeviceProfileConfig] = [:],
        defaultGlobalConfig: RazerDeviceProfileConfig = RazerDeviceProfileConfig()
    ) {
        self.id = id
        self.name = name
        self.isBuiltIn = isBuiltIn
        self.deviceConfigs = deviceConfigs
        self.defaultGlobalConfig = defaultGlobalConfig
    }

    public static let turnAllOffId = "builtin-turn-all-off"

    public static var turnAllOff: RazerProfile {
        RazerProfile(
            id: turnAllOffId,
            name: "Turn All Off",
            isBuiltIn: true,
            defaultGlobalConfig: RazerDeviceProfileConfig(
                mode: .off,
                brightness: 0.0
            )
        )
    }
}

// MARK: - Razer Device Model

@Observable
public final class RazerDeviceModel: Identifiable {
    public let id: String
    public let productId: UInt16
    public var name: String
    public var type: RazerDeviceType
    public var imageURL: String?
    public var isConnected: Bool
    public var isSimulated: Bool

    // Performance
    public var batteryLevel: Int?
    public var isCharging: Bool?
    public var dpi: Int
    public var maxDpi: Int
    public var pollingRate: Int
    public var supportedPollRates: [Int]

    // Lighting
    public var brightness: Double // 0.0 - 100.0
    public var currentMode: LightingEffectMode
    public var previousMode: LightingEffectMode? = .staticColor
    public var primaryColor: RGBColor
    public var secondaryColor: RGBColor
    public var waveDirection: WaveDirection
    public var effectSpeed: Double // 1.0 (normal)

    // Per-zone brightness support
    public var supportsLogoBrightness: Bool
    public var supportsScrollBrightness: Bool
    public var supportsMatrixBrightness: Bool
    public var logoBrightness: Double
    public var scrollBrightness: Double

    // Driver reference
    public var internalDeviceId: Int32

    public init(
        id: String = UUID().uuidString,
        productId: UInt16,
        name: String,
        type: RazerDeviceType,
        imageURL: String? = nil,
        isConnected: Bool = true,
        isSimulated: Bool = false,
        batteryLevel: Int? = nil,
        isCharging: Bool? = nil,
        dpi: Int = 1600,
        maxDpi: Int = 20000,
        pollingRate: Int = 1000,
        supportedPollRates: [Int] = [125, 500, 1000],
        brightness: Double = 100.0,
        currentMode: LightingEffectMode = .staticColor,
        primaryColor: RGBColor = .razerGreen,
        secondaryColor: RGBColor = .cyan,
        waveDirection: WaveDirection = .leftToRight,
        effectSpeed: Double = 1.0,
        supportsLogoBrightness: Bool = true,
        supportsScrollBrightness: Bool = true,
        supportsMatrixBrightness: Bool = false,
        logoBrightness: Double = 100.0,
        scrollBrightness: Double = 100.0,
        internalDeviceId: Int32 = -1
    ) {
        self.id = id
        self.productId = productId
        self.name = name
        self.type = type
        self.imageURL = imageURL
        self.isConnected = isConnected
        self.isSimulated = isSimulated
        self.batteryLevel = batteryLevel
        self.isCharging = isCharging
        self.dpi = dpi
        self.maxDpi = maxDpi
        self.pollingRate = pollingRate
        self.supportedPollRates = supportedPollRates
        self.brightness = brightness
        self.currentMode = currentMode
        self.previousMode = currentMode == .off ? .staticColor : currentMode
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.waveDirection = waveDirection
        self.effectSpeed = effectSpeed
        self.supportsLogoBrightness = supportsLogoBrightness
        self.supportsScrollBrightness = supportsScrollBrightness
        self.supportsMatrixBrightness = supportsMatrixBrightness
        self.logoBrightness = logoBrightness
        self.scrollBrightness = scrollBrightness
        self.internalDeviceId = internalDeviceId
    }

    public var isLightingEnabled: Bool {
        currentMode != .off && brightness > 0
    }

    public var productIdHexString: String {
        String(format: "0x%04X", productId)
    }

    public var currentSettingDescription: String {
        if currentMode == .off || brightness == 0 {
            return "Lighting Off"
        }
        var desc = "\(currentMode.rawValue)"
        if currentMode == .staticColor || currentMode == .breathe {
            desc += " • \(Int(brightness))%"
        } else {
            desc += " • \(Int(brightness))%"
        }
        if type == .mouse {
            desc += " • \(dpi) DPI"
        }
        return desc
    }

    public func snapshotConfig() -> RazerDeviceProfileConfig {
        RazerDeviceProfileConfig(
            mode: currentMode,
            brightness: brightness,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            waveDirection: waveDirection,
            effectSpeed: effectSpeed,
            dpi: dpi,
            pollingRate: pollingRate
        )
    }

    public func apply(config: RazerDeviceProfileConfig) {
        self.currentMode = config.mode
        if config.mode != .off {
            self.previousMode = config.mode
        }
        self.brightness = config.brightness
        self.primaryColor = config.primaryColor
        self.secondaryColor = config.secondaryColor
        self.waveDirection = config.waveDirection
        self.effectSpeed = config.effectSpeed
        self.dpi = min(maxDpi, max(100, config.dpi))
        self.pollingRate = config.pollingRate
    }
}
