//
//  LightingView.swift
//  RazerMacOS
//
//  Created by Garrett Butchko.
//

import SwiftUI
import BaseColors

struct LightingView: View {
    @Bindable var manager: RazerDeviceManager

    private var activeDevice: RazerDeviceModel? {
        manager.selectedDevice
    }

    private let presetColors: [(name: String, rgb: RGBColor)] = [
        ("Razer Green", .razerGreen),
        ("Chroma Cyan", .cyan),
        ("Quartz Pink", .pink),
        ("Electric Purple", .purple),
        ("Amber Orange", .orange),
        ("Cyber Yellow", .yellow),
        ("Signal Red", .redColor),
        ("Mercury White", .white)
    ]

    var body: some View {
        ZStack {
            Color.bg
                .ignoresSafeArea()

            if let device = activeDevice {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // 1. Device Ribbon & Sync Header
                        deviceSelectorRibbon(activeDevice: device)

                        // 2. Interactive Chroma Live Preview
                        chromaLivePreview(for: device)

                        // 3. Effect Selection Grid
                        effectSelectionSection(for: device)

                        // 4. Unified Contextual Parameter Panel
                        if hasConfigurableParameters(for: device.currentMode) {
                            effectParametersSection(for: device)
                        }

                        // 5. Brightness & Power Section
                        brightnessSection(for: device)
                    }
                    .padding(20)
                }
            } else {
                EmptyStateView(
                    icon: "sparkles",
                    title: "No Device Selected",
                    message: "Connect a Razer device via USB or enable Demo Mode in Preferences to configure Chroma lighting effects."
                )
            }
        }
    }

    // MARK: - 1. Device Ribbon & Sync Header

    private func deviceSelectorRibbon(activeDevice: RazerDeviceModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Target Device")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.mainOpp.opacity(0.6))
                    .textCase(.uppercase)

                Spacer()

                // Sync All Devices Toggle
                Button {
                    manager.syncAllDevices.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: manager.syncAllDevices ? "link.circle.fill" : "link.circle")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(manager.syncAllDevices ? Color.black : Color.razerGreen)

                        Text("Sync All Devices")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(manager.syncAllDevices ? Color.black : Color.mainOpp)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(manager.syncAllDevices ? Color.razerGreen : Color.subTwo)
                    )
                }
                .buttonStyle(.plain)
                .help("Apply Chroma lighting changes across all connected Razer hardware simultaneously")
            }

            // Scrollable device tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(manager.devices) { dev in
                        let isSelected = dev.id == activeDevice.id
                        Button {
                            manager.selectedDeviceId = dev.id
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: dev.type.iconName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(isSelected ? Color.razerGreen : Color.mainOpp.opacity(0.7))

                                Text(dev.name)
                                    .font(.system(size: 12, weight: isSelected ? .bold : .medium, design: .rounded))
                                    .foregroundStyle(Color.mainOpp)

                                if dev.isSimulated {
                                    Text("DEMO")
                                        .font(.system(size: 9, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.purple)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(Color.purple.opacity(0.15), in: Capsule())
                                }

                                if let battery = dev.batteryLevel {
                                    HStack(spacing: 3) {
                                        Image(systemName: dev.isCharging == true ? "bolt.fill" : "battery.75")
                                            .font(.system(size: 10))
                                        Text("\(battery)%")
                                            .font(.system(size: 10, weight: .medium, design: .rounded))
                                    }
                                    .foregroundStyle(battery < 20 ? Color.orange : Color.mainOpp.opacity(0.6))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(isSelected ? Color.razerGreen.opacity(0.14) : Color.sub)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(isSelected ? Color.razerGreen : Color.mainOpp.opacity(0.08), lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - 2. Chroma Live Preview Canvas

    private func chromaLivePreview(for device: RazerDeviceModel) -> some View {
        VStack(spacing: 12) {
            ZStack {
                // Background surface
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.sub)

                // Animated light bar / effect visualization
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    livePreviewCanvas(for: device, time: time)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                // Overlay Controls & Badges
                VStack {
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(device.isLightingEnabled ? Color.razerGreen : Color.mainOpp.opacity(0.3))
                                .frame(width: 8, height: 8)

                            Text(device.isLightingEnabled ? "Chroma Active" : "Chroma Off")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(device.isLightingEnabled ? Color.razerGreen : Color.mainOpp.opacity(0.6))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())

                        Spacer()

                        // Quick Power Button
                        Button {
                            manager.toggleLightingPower(for: device)
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "power")
                                    .font(.system(size: 11, weight: .bold))
                                Text(device.currentMode == .off ? "Turn On" : "Turn Off")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.ultraThinMaterial, in: Capsule())
                            .foregroundStyle(device.currentMode == .off ? Color.razerGreen : Color.mainOpp)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(14)

                    Spacer()

                    // Bottom info label
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(device.name)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white)

                            Text("\(device.currentMode.rawValue) • \(Int(device.brightness))% Brightness\(device.currentMode == .wave ? " • \(device.waveDirection.title)" : "")")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.85))
                        }

                        Spacer()

                        Image(systemName: device.type.iconName)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.4))
                    }
                    .padding(14)
                    .background(
                        LinearGradient(
                            colors: [Color.black.opacity(0.65), Color.clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                }
            }
            .frame(height: 140)
        }
    }

    @ViewBuilder
    private func livePreviewCanvas(for device: RazerDeviceModel, time: TimeInterval) -> some View {
        if device.currentMode == .off || device.brightness <= 0 {
            Color.black.opacity(0.75)
        } else {
            let opacity = max(0.15, device.brightness / 100.0)

            switch device.currentMode {
            case .staticColor:
                ZStack {
                    device.primaryColor.swiftUIColor
                        .opacity(0.4 * opacity)
                    RadialGradient(
                        colors: [device.primaryColor.swiftUIColor.opacity(0.85 * opacity), Color.clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                }

            case .breathe:
                let pulse = (sin(time * 2.0) + 1.0) / 2.0 // 0.0 to 1.0
                let primary = device.primaryColor.swiftUIColor
                let secondary = device.secondaryColor.swiftUIColor
                ZStack {
                    LinearGradient(
                        colors: [primary.opacity(pulse * opacity), secondary.opacity((1.0 - pulse) * opacity)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    RadialGradient(
                        colors: [primary.opacity(pulse * opacity), Color.clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 180
                    )
                }

            case .spectrum:
                let shift = (time * 0.15).truncatingRemainder(dividingBy: 1.0)
                LinearGradient(
                    colors: [
                        Color(hue: (0.0 + shift).truncatingRemainder(dividingBy: 1.0), saturation: 0.9, brightness: 0.95),
                        Color(hue: (0.2 + shift).truncatingRemainder(dividingBy: 1.0), saturation: 0.9, brightness: 0.95),
                        Color(hue: (0.4 + shift).truncatingRemainder(dividingBy: 1.0), saturation: 0.9, brightness: 0.95),
                        Color(hue: (0.6 + shift).truncatingRemainder(dividingBy: 1.0), saturation: 0.9, brightness: 0.95),
                        Color(hue: (0.8 + shift).truncatingRemainder(dividingBy: 1.0), saturation: 0.9, brightness: 0.95),
                        Color(hue: (1.0 + shift).truncatingRemainder(dividingBy: 1.0), saturation: 0.9, brightness: 0.95)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(opacity)

            case .wave:
                let speedFactor = max(0.5, device.effectSpeed)
                let directionSign: Double = device.waveDirection == .leftToRight ? 1.0 : -1.0
                let offset = (time * 0.3 * speedFactor * directionSign).truncatingRemainder(dividingBy: 1.0)
                let normalizedOffset = offset < 0 ? offset + 1.0 : offset

                LinearGradient(
                    stops: [
                        .init(color: .red, location: CGFloat((0.0 + normalizedOffset).truncatingRemainder(dividingBy: 1.0))),
                        .init(color: .orange, location: CGFloat((0.2 + normalizedOffset).truncatingRemainder(dividingBy: 1.0))),
                        .init(color: .green, location: CGFloat((0.4 + normalizedOffset).truncatingRemainder(dividingBy: 1.0))),
                        .init(color: .cyan, location: CGFloat((0.6 + normalizedOffset).truncatingRemainder(dividingBy: 1.0))),
                        .init(color: .blue, location: CGFloat((0.8 + normalizedOffset).truncatingRemainder(dividingBy: 1.0))),
                        .init(color: .purple, location: CGFloat((1.0 + normalizedOffset).truncatingRemainder(dividingBy: 1.0)))
                    ].sorted(by: { $0.location < $1.location }),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(opacity)

            case .reactive:
                let flash = max(0.2, (sin(time * 3.5) + 1.0) / 2.0)
                ZStack {
                    device.primaryColor.swiftUIColor
                        .opacity(0.15 * opacity)
                    RadialGradient(
                        colors: [device.primaryColor.swiftUIColor.opacity(flash * opacity), Color.clear],
                        center: .center,
                        startRadius: 5,
                        endRadius: 160
                    )
                }

            case .starlight:
                let twinkle1 = (sin(time * 4.0) + 1.0) / 2.0
                let twinkle2 = (cos(time * 3.0) + 1.0) / 2.0
                ZStack {
                    Color.black.opacity(0.7)
                    RadialGradient(
                        colors: [Color.razerGreen.opacity(twinkle1 * opacity), Color.clear],
                        center: .init(x: 0.3, y: 0.4),
                        startRadius: 5,
                        endRadius: 80
                    )
                    RadialGradient(
                        colors: [Color.cyan.opacity(twinkle2 * opacity), Color.clear],
                        center: .init(x: 0.7, y: 0.6),
                        startRadius: 5,
                        endRadius: 70
                    )
                }

            case .off:
                Color.black.opacity(0.75)
            }
        }
    }

    // MARK: - 3. Effect Selection Grid

    private func effectSelectionSection(for device: RazerDeviceModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Chroma Effect")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.mainOpp)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 155), spacing: 10)], spacing: 10) {
                ForEach(LightingEffectMode.allCases) { mode in
                    effectTile(for: mode, isSelected: device.currentMode == mode) {
                        manager.setLightingMode(for: device, mode: mode)
                    }
                }
            }
        }
        .padding(16)
        .jellyCard(cornerRadius: 14)
    }

    private func effectTile(for mode: LightingEffectMode, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(isSelected ? Color.razerGreen.opacity(0.2) : Color.subTwo)
                            .frame(width: 32, height: 32)

                        Image(systemName: mode.icon)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(isSelected ? Color.razerGreen : Color.mainOpp.opacity(0.75))
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.razerGreen)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.mainOpp)

                    Text(mode.description)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.mainOpp.opacity(0.55))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.razerGreen.opacity(0.12) : Color.subTwo)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(isSelected ? Color.razerGreen : Color.mainOpp.opacity(0.06), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 4. Unified Effect Parameters Section

    private func hasConfigurableParameters(for mode: LightingEffectMode) -> Bool {
        switch mode {
        case .staticColor, .breathe, .reactive, .wave:
            return true
        case .spectrum, .starlight, .off:
            return false
        }
    }

    private func effectParametersSection(for device: RazerDeviceModel) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(device.currentMode.rawValue) Settings")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.mainOpp)

            // A. Primary & Secondary Colors
            if device.currentMode == .staticColor || device.currentMode == .breathe || device.currentMode == .reactive {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(device.currentMode == .breathe ? "Primary Color" : "Lighting Color")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.mainOpp.opacity(0.8))

                        Spacer()

                        ColorPicker("Custom RGB", selection: Binding(
                            get: { device.primaryColor.swiftUIColor },
                            set: { newColor in
                                let rgb = RGBColor.fromSwiftUI(newColor)
                                manager.setPrimaryColor(for: device, color: rgb)
                            }
                        ))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.mainOpp)
                    }

                    // Palette Swatches
                    paletteSwatches(selected: device.primaryColor) { rgb in
                        manager.setPrimaryColor(for: device, color: rgb)
                    }
                }

                // Dual-color breathe section
                if device.currentMode == .breathe {
                    Divider()
                        .overlay(Color.mainOpp.opacity(0.08))

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Secondary Color (Dual-Breathe)")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.mainOpp.opacity(0.8))

                            Spacer()

                            ColorPicker("Custom RGB", selection: Binding(
                                get: { device.secondaryColor.swiftUIColor },
                                set: { newColor in
                                    let rgb = RGBColor.fromSwiftUI(newColor)
                                    manager.setSecondaryColor(for: device, color: rgb)
                                }
                            ))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.mainOpp)
                        }

                        paletteSwatches(selected: device.secondaryColor) { rgb in
                            manager.setSecondaryColor(for: device, color: rgb)
                        }
                    }
                }
            }

            // B. Wave Direction
            if device.currentMode == .wave {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Wave Direction")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.mainOpp.opacity(0.8))

                    HStack(spacing: 10) {
                        ForEach(WaveDirection.allCases) { dir in
                            let isSelected = device.waveDirection == dir
                            Button {
                                manager.setWaveDirection(for: device, direction: dir)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: dir == .leftToRight ? "arrow.right" : "arrow.left")
                                        .font(.system(size: 13, weight: .bold))
                                    Text(dir.title)
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(isSelected ? Color.razerGreen : Color.subTwo)
                                )
                                .foregroundStyle(isSelected ? Color.black : Color.mainOpp)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            // C. Effect Speed
            if device.currentMode == .wave || device.currentMode == .reactive {
                if device.currentMode == .wave {
                    Divider()
                        .overlay(Color.mainOpp.opacity(0.08))
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Effect Speed")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.mainOpp.opacity(0.8))

                        Spacer()

                        Text(speedLabel(for: device.effectSpeed))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.razerGreen)
                    }

                    HStack(spacing: 8) {
                        ForEach([(1.0, "Slow"), (2.0, "Normal"), (3.0, "Fast")], id: \.0) { speed, label in
                            let isSelected = Int(device.effectSpeed) == Int(speed)
                            Button {
                                manager.setEffectSpeed(for: device, speed: speed)
                            } label: {
                                Text(label)
                                    .font(.system(size: 12, weight: isSelected ? .bold : .medium, design: .rounded))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(isSelected ? Color.razerGreen : Color.subTwo)
                                    )
                                    .foregroundStyle(isSelected ? Color.black : Color.mainOpp)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding(16)
        .jellyCard(cornerRadius: 14)
    }

    private func paletteSwatches(selected: RGBColor, onSelect: @escaping (RGBColor) -> Void) -> some View {
        HStack(spacing: 10) {
            ForEach(presetColors, id: \.name) { preset in
                let isMatch = selected == preset.rgb
                Button {
                    onSelect(preset.rgb)
                } label: {
                    Circle()
                        .fill(preset.rgb.swiftUIColor)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .strokeBorder(isMatch ? Color.white : Color.clear, lineWidth: 2.5)
                        )
                }
                .buttonStyle(.plain)
                .help(preset.name)
            }
            Spacer()
        }
    }

    private func speedLabel(for speed: Double) -> String {
        switch Int(speed) {
        case 1: return "Slow (1x)"
        case 2: return "Normal (2x)"
        case 3: return "Fast (3x)"
        default: return "\(Int(speed))x"
        }
    }

    // MARK: - 5. Brightness & Intensity Section

    private func brightnessSection(for device: RazerDeviceModel) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("LED Brightness")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.mainOpp)

                Spacer()

                Text("\(Int(device.brightness))%")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.razerGreen)
            }

            // Slider
            HStack(spacing: 12) {
                Image(systemName: "sun.min")
                    .foregroundStyle(Color.mainOpp.opacity(0.4))

                Slider(value: Binding(
                    get: { device.brightness },
                    set: { manager.setBrightness(for: device, brightness: $0) }
                ), in: 0...100, step: 1)
                .tint(Color.razerGreen)

                Image(systemName: "sun.max.fill")
                    .foregroundStyle(Color.mainOpp.opacity(0.8))
            }

            // Quick Preset Pills
            HStack(spacing: 8) {
                ForEach([0, 25, 50, 75, 100], id: \.self) { preset in
                    let isCurrent = Int(device.brightness) == preset
                    Button {
                        manager.setBrightness(for: device, brightness: Double(preset))
                    } label: {
                        Text(preset == 0 ? "Off" : "\(preset)%")
                            .font(.system(size: 11, weight: isCurrent ? .bold : .medium, design: .rounded))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(isCurrent ? Color.razerGreen : Color.subTwo)
                            )
                            .foregroundStyle(isCurrent ? Color.black : Color.mainOpp.opacity(0.75))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .jellyCard(cornerRadius: 14)
    }
}
