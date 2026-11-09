//
//  MenuBarView.swift
//  RazerMacOS
//
//  Created by Garrett Butchko.
//

import SwiftUI
import AppKit
import BaseColors

struct MenuBarView: View {
    @Bindable var manager: RazerDeviceManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(.razerSVG)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                        .foregroundStyle(Color.razerGreen)
                    Text("Razer macOS")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }

                Spacer()

                Button {
                    manager.refreshDevices()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
            }

            Divider()

            if manager.devices.isEmpty {
                VStack(spacing: 6) {
                    Text("No Devices Connected")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.secondary)

                    Button("Enable Demo Mode") {
                        manager.demoModeEnabled = true
                    }
                    .font(.system(size: 11, design: .rounded))
                    .buttonStyle(.link)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } else {
                ForEach(manager.devices) { device in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: device.type.iconName)
                                .foregroundStyle(Color.razerGreen)

                            Text(device.name)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .lineLimit(1)

                            Spacer()

                            if let bat = device.batteryLevel {
                                Text("\(bat)%")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.razerGreen)
                            }
                        }

                        // Quick Effect Picker
                        HStack(spacing: 8) {
                            Text("Effect:")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundStyle(Color.secondary)

                            Picker("", selection: Binding(
                                get: { device.currentMode },
                                set: { manager.setLightingMode(for: device, mode: $0) }
                            )) {
                                ForEach(LightingEffectMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .controlSize(.small)
                        }

                        // Quick Brightness
                        HStack(spacing: 8) {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.secondary)

                            Slider(value: Binding(
                                get: { device.brightness },
                                set: { manager.setBrightness(for: device, brightness: $0) }
                            ), in: 0...100, step: 5)
                            .controlSize(.small)
                            .tint(Color.razerGreen)

                            Text("\(Int(device.brightness))%")
                                .font(.system(size: 10, design: .monospaced))
                                .frame(width: 28, alignment: .trailing)
                        }
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.1)))
                }
            }

            Divider()

            // Footer
            HStack {
                Button("Open Razer macOS") {
                    NSApp.activate(ignoringOtherApps: true)
                    for window in NSApp.windows where window.canBecomeMain {
                        window.makeKeyAndOrderFront(nil)
                        return
                    }
                    openWindow(id: "mainWindow")
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .font(.system(size: 12, design: .rounded))
            }
        }
        .padding(14)
        .frame(width: 280)
    }
}
