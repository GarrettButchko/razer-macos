//
//  PerformanceView.swift
//  RazerMacOS
//
//  Created by Garrett Butchko.
//

import SwiftUI
import BaseColors

struct PerformanceView: View {
    @Bindable var manager: RazerDeviceManager

    private var activeDevice: RazerDeviceModel? {
        manager.selectedDevice
    }

    private let dpiPresets: [Int] = [400, 800, 1600, 2400, 3200, 6400, 12000, 16000]
    private let pollingPresets: [Int] = [125, 500, 1000, 8000]

    var body: some View {
        ZStack {
            Color.bg
                .ignoresSafeArea()

            if let device = activeDevice {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        HStack(spacing: 12) {
                            Text("Target:")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.mainOpp.opacity(0.6))

                            Picker("", selection: $manager.selectedDeviceId) {
                                ForEach(manager.devices) { dev in
                                    Text(dev.name).tag(Optional(dev.id))
                                }
                            }
                            .labelsHidden()
                            .frame(maxWidth: 260)

                            Spacer()

                            if let bat = device.batteryLevel {
                                HStack(spacing: 6) {
                                    Image(systemName: device.isCharging == true ? "battery.100.bolt" : "battery.75")
                                        .foregroundStyle(Color.razerGreen)
                                    Text("\(bat)% Battery")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.sub, in: Capsule())
                            }
                        }
                        .padding(.horizontal, 4)

                        if device.type == .mouse {
                            // 1. DPI Sensitivity
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Optical Sensor Sensitivity")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.mainOpp)
                                        Text("Configures true hardware tracking DPI without interpolation")
                                            .font(.system(size: 12, weight: .regular, design: .rounded))
                                            .foregroundStyle(Color.mainOpp.opacity(0.6))
                                    }

                                    Spacer()

                                    Text("\(device.dpi) DPI")
                                        .font(.system(size: 18, weight: .heavy, design: .rounded))
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
                                    ForEach(dpiPresets.filter { $0 <= device.maxDpi }, id: \.self) { preset in
                                        Button {
                                            manager.setDpi(for: device, dpi: preset)
                                        } label: {
                                            Text("\(preset)")
                                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                        .fill(device.dpi == preset ? Color.razerGreen : Color.subTwo)
                                                )
                                                .foregroundStyle(device.dpi == preset ? Color.black : Color.mainOpp)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(16)
                            .jellyCard(cornerRadius: 14)

                            // 2. Polling Rate
                            VStack(alignment: .leading, spacing: 14) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("USB Polling Rate")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.mainOpp)
                                    Text("Controls report frequency to the macOS USB host")
                                        .font(.system(size: 12, weight: .regular, design: .rounded))
                                        .foregroundStyle(Color.mainOpp.opacity(0.6))
                                }

                                HStack(spacing: 12) {
                                    ForEach(pollingPresets, id: \.self) { rate in
                                        Button {
                                            manager.setPollingRate(for: device, rate: rate)
                                        } label: {
                                            VStack(spacing: 2) {
                                                Text("\(rate) Hz")
                                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                                Text(rate == 1000 ? "1ms" : rate == 500 ? "2ms" : rate == 8000 ? "0.125ms" : "8ms")
                                                    .font(.system(size: 10, design: .monospaced))
                                                    .opacity(0.7)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(device.pollingRate == rate ? Color.razerGreen : Color.subTwo)
                                            )
                                            .foregroundStyle(device.pollingRate == rate ? Color.black : Color.mainOpp)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(16)
                            .jellyCard(cornerRadius: 14)
                        } else {
                            // Non-mouse hardware info
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Hardware Configuration")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.mainOpp)

                                VStack(spacing: 8) {
                                    settingInfoRow(label: "Device Name", value: device.name)
                                    settingInfoRow(label: "USB Vendor ID", value: "0x1532 (Razer)")
                                    settingInfoRow(label: "USB Product ID", value: device.productIdHexString)
                                    settingInfoRow(label: "Internal Device ID", value: "\(device.internalDeviceId)")
                                    settingInfoRow(label: "Driver Architecture", value: "librazermacos (Kernel USB IOKit)")
                                }
                            }
                            .padding(16)
                            .jellyCard(cornerRadius: 14)
                        }
                    }
                    .padding(20)
                }
            } else {
                EmptyStateView(
                    icon: "slider.horizontal.3",
                    title: "No Device Selected",
                    message: "Select a connected Razer mouse to adjust DPI sensor precision and polling rates."
                )
            }
        }
    }

    private func settingInfoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color.mainOpp.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.mainOpp)
        }
        .padding(.vertical, 4)
    }
}
