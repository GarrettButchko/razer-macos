//
//  DeviceDetailView.swift
//  RazerMacOS
//
//  Created by Garrett Butchko.
//

import SwiftUI
import BaseColors

struct DeviceDetailView: View {
    @Bindable var manager: RazerDeviceManager
    let device: RazerDeviceModel
    var onBack: () -> Void

    @State private var localPrimaryColor: Color = .green
    @State private var localSecondaryColor: Color = .cyan

    private let presetColors: [RGBColor] = [
        .razerGreen, .cyan, .purple, .pink, .orange, .yellow, .redColor, .white
    ]

    var body: some View {
        GeometryReader { geometry in
            let showImage = geometry.size.width >= 720 && geometry.size.height >= 460

            VStack(spacing: 0) {
                // Top Navigation Bar
                topNavBar
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                // Main Content
                HStack(alignment: .top, spacing: 28) {
                    ScrollView(.vertical, showsIndicators: false) {
                        settingsForm
                            .padding(.bottom, 32)
                    }
                    .frame(maxWidth: showImage ? 460 : .infinity)

                    if showImage {
                        deviceShowcase
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.bottom, 32)
                    }
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            localPrimaryColor = device.primaryColor.swiftUIColor
            localSecondaryColor = device.secondaryColor.swiftUIColor
        }
    }

    // MARK: - Top Nav Bar

    private var topNavBar: some View {
        HStack {
            Spacer()

            Button(action: onBack) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))

                    Text(device.name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color.mainOpp)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .jellyCard(cornerRadius: 10)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Device Settings Form

    private var settingsForm: some View {
        VStack(spacing: 20) {
            // Lighting Section
            settingsSection(title: "Chroma Lighting", icon: "sparkles") {
                // Quick Power Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Lighting Power")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                        Text(device.isLightingEnabled ? "Active" : "Off")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.secondary)
                    }

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { device.isLightingEnabled },
                        set: { _ in manager.toggleLightingPower(for: device) }
                    ))
                    .toggleStyle(.switch)
                    .tint(Color.razerGreen)
                    .labelsHidden()
                }

                Divider()
                    .overlay(Color.mainOpp.opacity(0.08))

                // Mode Picker
                HStack {
                    Text("Effect Mode")
                        .font(.system(size: 13, weight: .medium, design: .rounded))

                    Spacer()

                    Picker("", selection: Binding(
                        get: { device.currentMode },
                        set: { manager.setLightingMode(for: device, mode: $0) }
                    )) {
                        ForEach(LightingEffectMode.allCases) { mode in
                            Label(mode.rawValue, systemImage: mode.icon).tag(mode)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(maxWidth: 170)
                }

                Divider()
                    .overlay(Color.mainOpp.opacity(0.08))

                // Brightness Slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Brightness", systemImage: "sun.max.fill")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                        Spacer()
                        Text("\(Int(device.brightness))%")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.razerGreen)
                    }

                    Slider(
                        value: Binding(
                            get: { device.brightness },
                            set: { manager.setBrightness(for: device, brightness: $0) }
                        ),
                        in: 0...100,
                        step: 1
                    )
                    .tint(Color.razerGreen)
                }

                // Color Configuration (if static, breathe, or reactive)
                if device.currentMode == .staticColor || device.currentMode == .breathe || device.currentMode == .reactive {
                    Divider()
                        .overlay(Color.mainOpp.opacity(0.08))

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(device.currentMode == .breathe ? "Primary Color" : "Lighting Color")
                                .font(.system(size: 13, weight: .medium, design: .rounded))

                            Spacer()

                            ColorPicker("", selection: $localPrimaryColor, supportsOpacity: false)
                                .labelsHidden()
                                .onChange(of: localPrimaryColor) { _, newColor in
                                    let rgb = RGBColor.fromSwiftUI(newColor)
                                    manager.setPrimaryColor(for: device, color: rgb)
                                }
                        }

                        // Presets
                        HStack(spacing: 8) {
                            ForEach(presetColors, id: \.red) { col in
                                Circle()
                                    .fill(col.swiftUIColor)
                                    .frame(width: 22, height: 22)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: device.primaryColor == col ? 2 : 0)
                                    )
                                    .shadow(color: col.swiftUIColor.opacity(0.4), radius: 3)
                                    .onTapGesture {
                                        localPrimaryColor = col.swiftUIColor
                                        manager.setPrimaryColor(for: device, color: col)
                                    }
                            }
                        }
                    }

                    // Secondary Color for Breathing
                    if device.currentMode == .breathe {
                        Divider()
                            .overlay(Color.mainOpp.opacity(0.08))

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Secondary Color")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))

                                Spacer()

                                ColorPicker("", selection: $localSecondaryColor, supportsOpacity: false)
                                    .labelsHidden()
                                    .onChange(of: localSecondaryColor) { _, newColor in
                                        let rgb = RGBColor.fromSwiftUI(newColor)
                                        manager.setSecondaryColor(for: device, color: rgb)
                                    }
                            }

                            HStack(spacing: 8) {
                                ForEach(presetColors, id: \.red) { col in
                                    Circle()
                                        .fill(col.swiftUIColor)
                                        .frame(width: 22, height: 22)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: device.secondaryColor == col ? 2 : 0)
                                        )
                                        .shadow(color: col.swiftUIColor.opacity(0.4), radius: 3)
                                        .onTapGesture {
                                            localSecondaryColor = col.swiftUIColor
                                            manager.setSecondaryColor(for: device, color: col)
                                        }
                                }
                            }
                        }
                    }
                }

                // Wave Direction
                if device.currentMode == .wave {
                    Divider()
                        .overlay(Color.mainOpp.opacity(0.08))

                    HStack {
                        Text("Wave Flow")
                            .font(.system(size: 13, weight: .medium, design: .rounded))

                        Spacer()

                        Picker("", selection: Binding(
                            get: { device.waveDirection },
                            set: { manager.setWaveDirection(for: device, direction: $0) }
                        )) {
                            ForEach(WaveDirection.allCases) { dir in
                                Text(dir.title).tag(dir)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .frame(maxWidth: 160)
                    }
                }

                // Effect Speed (Wave or Reactive)
                if device.currentMode == .wave || device.currentMode == .reactive {
                    Divider()
                        .overlay(Color.mainOpp.opacity(0.08))

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Effect Speed")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                            Spacer()
                            Text(String(format: "%.1fx", device.effectSpeed))
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.razerGreen)
                        }

                        Slider(
                            value: Binding(
                                get: { device.effectSpeed },
                                set: { manager.setEffectSpeed(for: device, speed: $0) }
                            ),
                            in: 1.0...3.0,
                            step: 1.0
                        )
                        .tint(Color.razerGreen)
                    }
                }
            }

            // Performance Section (for mice)
            if device.type == .mouse {
                settingsSection(title: "Performance & Sensor", icon: "gauge.with.needle.fill") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("DPI Sensitivity")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                            Spacer()
                            Text("\(device.dpi) DPI")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.razerGreen)
                        }

                        Slider(
                            value: Binding(
                                get: { Double(device.dpi) },
                                set: { manager.setDpi(for: device, dpi: Int($0)) }
                            ),
                            in: 100...Double(device.maxDpi),
                            step: 50
                        )
                        .tint(Color.razerGreen)

                        // Quick Presets
                        HStack(spacing: 8) {
                            ForEach([400, 800, 1600, 2400, 3200, 6400], id: \.self) { preset in
                                Button("\(preset)") {
                                    manager.setDpi(for: device, dpi: preset)
                                }
                                .font(.system(size: 11, weight: device.dpi == preset ? .bold : .medium, design: .rounded))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    device.dpi == preset ? Color.razerGreen.opacity(0.2) : Color.clear,
                                    in: RoundedRectangle(cornerRadius: 6)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(device.dpi == preset ? Color.razerGreen : Color.mainOpp.opacity(0.12), lineWidth: 1)
                                )
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Divider()
                        .overlay(Color.mainOpp.opacity(0.08))

                    // Polling Rate
                    HStack {
                        Text("Polling Rate")
                            .font(.system(size: 13, weight: .medium, design: .rounded))

                        Spacer()

                        Picker("", selection: Binding(
                            get: { device.pollingRate },
                            set: { manager.setPollingRate(for: device, rate: $0) }
                        )) {
                            ForEach(device.supportedPollRates, id: \.self) { rate in
                                Text("\(rate) Hz").tag(rate)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .frame(maxWidth: 140)
                    }
                }
            }

            // Hardware Information
            settingsSection(title: "Hardware Info", icon: "info.circle") {
                infoRow(label: "Device Category", value: device.type.displayName)
                Divider().overlay(Color.mainOpp.opacity(0.08))
                infoRow(label: "Product ID", value: device.productIdHexString)
                Divider().overlay(Color.mainOpp.opacity(0.08))
                infoRow(label: "Connection", value: device.isSimulated ? "Demo Simulation" : "USB Connected")

                if let bat = device.batteryLevel {
                    Divider().overlay(Color.mainOpp.opacity(0.08))
                    infoRow(label: "Battery Level", value: "\(bat)% \(device.isCharging == true ? "(Charging)" : "")")
                }
            }
        }
    }

    // MARK: - Device Showcase (Right Side)

    private var deviceShowcase: some View {
        VStack(spacing: 20) {
            Spacer()

            // Device Image with Glow / Shadow
            ZStack {
                if let urlString = device.imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 320, maxHeight: 320)
                        case .failure:
                            fallbackDeviceIcon
                        case .empty:
                            ProgressView()
                                .frame(width: 140, height: 140)
                        @unknown default:
                            fallbackDeviceIcon
                        }
                    }
                } else {
                    fallbackDeviceIcon
                }
            }
            .shadow(
                color: device.isLightingEnabled ? device.primaryColor.swiftUIColor.opacity(0.35) : Color.black.opacity(0.2),
                radius: 20,
                x: 0,
                y: 8
            )

            // Current Setting Capsule
            Text(device.currentSettingDescription)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.mainOpp)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .jellyCard(cornerRadius: 12)

            Spacer()
        }
    }

    private var fallbackDeviceIcon: some View {
        Image(systemName: device.type.iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 130, height: 130)
            .foregroundStyle(device.isLightingEnabled ? device.primaryColor.swiftUIColor : Color.secondary)
            .padding(40)
            .background(Color.sub, in: Circle())
    }

    // MARK: - Form Helper Components

    private func settingsSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.razerGreen)

                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.mainOpp)
            }

            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding(16)
            .jellyCard(cornerRadius: 14)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.mainOpp)
        }
    }
}
