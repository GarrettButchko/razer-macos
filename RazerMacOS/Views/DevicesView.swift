//
//  DevicesView.swift
//  RazerMacOS
//
//  Created by Garrett Butchko.
//

import SwiftUI
import BaseColors

struct DevicesView: View {
    @Bindable var manager: RazerDeviceManager

    var body: some View {
        ZStack {
            Color.bg
                .ignoresSafeArea()

            if manager.devices.isEmpty {
                EmptyStateView(
                    icon: "keyboard.badge.ellipsis",
                    title: "No Razer Devices Found",
                    message: "Connect your Razer keyboard, mouse, mouse mat, or headset via USB to customize lighting and performance.",
                    buttonTitle: "Scan for Peripherals",
                    secondaryButtonTitle: "Enable Demo Mode",
                    action: {
                        manager.refreshDevices()
                    },
                    secondaryAction: {
                        manager.demoModeEnabled = true
                    }
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header bar
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Connected Hardware")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.mainOpp)

                                Text("\(manager.devices.count) Razer peripheral\(manager.devices.count == 1 ? "" : "s") online")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundStyle(Color.mainOpp.opacity(0.6))
                            }

                            Spacer()

                            Button {
                                manager.refreshDevices()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .rotationEffect(.degrees(manager.isScanning ? 360 : 0))
                                        .animation(manager.isScanning ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: manager.isScanning)
                                    Text("Rescan Bus")
                                }
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                            .jellyGlass(in: Capsule())
                            .foregroundStyle(Color.mainOpp)
                        }
                        .padding(.horizontal, 4)

                        // Devices list
                        LazyVStack(spacing: 12) {
                            ForEach(manager.devices) { device in
                                deviceCard(for: device)
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
    }

    // MARK: - Device Card (Flat Jelly Styling)

    private func deviceCard(for device: RazerDeviceModel) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                // Device Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.razerGreen.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: device.type.iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.razerGreen)
                }

                // Title & Details
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(device.name)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.mainOpp)

                        if device.isSimulated {
                            JellyBadge("Simulated", systemIcon: "wand.and.stars", tintColor: .purple)
                        } else {
                            JellyBadge("Connected", systemIcon: "cable.connector", tintColor: .razerGreen)
                        }
                    }

                    HStack(spacing: 6) {
                        Text(device.type.displayName)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.mainOpp.opacity(0.6))

                        Text("•")
                            .foregroundStyle(Color.mainOpp.opacity(0.3))

                        Text("Product ID: \(device.productIdHexString)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(Color.mainOpp.opacity(0.45))
                    }
                }

                Spacer()

                // Battery badge if mouse
                if let battery = device.batteryLevel {
                    HStack(spacing: 5) {
                        Image(systemName: device.isCharging == true ? "battery.100.bolt" : "battery.75")
                            .font(.system(size: 14))
                            .foregroundStyle(battery < 20 ? Color.orange : Color.razerGreen)

                        Text("\(battery)%")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.mainOpp)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.subTwo, in: Capsule())
                }
            }

            Divider()
                .overlay(Color.mainOpp.opacity(0.06))

            // Quick controls row
            HStack(spacing: 20) {
                // Quick Effect
                HStack(spacing: 8) {
                    Text("Effect:")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.mainOpp.opacity(0.7))

                    Menu {
                        ForEach(LightingEffectMode.allCases) { mode in
                            Button(mode.rawValue) {
                                manager.setLightingMode(for: device, mode: mode)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: device.currentMode.icon)
                            Text(device.currentMode.rawValue)
                        }
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.mainOpp)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.subTwo, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .fixedSize()
                }

                // Brightness slider
                HStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mainOpp.opacity(0.6))

                    Slider(value: Binding(
                        get: { device.brightness },
                        set: { manager.setBrightness(for: device, brightness: $0) }
                    ), in: 0...100, step: 5)
                    .tint(Color.razerGreen)
                    .frame(maxWidth: 160)

                    Text("\(Int(device.brightness))%")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.mainOpp.opacity(0.8))
                        .frame(width: 36, alignment: .leading)
                }

                Spacer()

                // Color swatch
                if device.currentMode == .staticColor || device.currentMode == .breathe {
                    Circle()
                        .fill(device.primaryColor.swiftUIColor)
                        .frame(width: 18, height: 18)
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.3), lineWidth: 1))
                }
            }
        }
        .padding(16)
        .jellyCard(cornerRadius: 14)
    }
}
