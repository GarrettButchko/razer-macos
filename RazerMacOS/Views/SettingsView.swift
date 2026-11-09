//
//  SettingsView.swift
//  RazerMacOS
//
//  Created by Garrett Butchko.
//

import SwiftUI
import BaseColors
import ServiceManagement

struct SettingsView: View {
    @Bindable var manager: RazerDeviceManager
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra: Bool = true

    var body: some View {
        ZStack {
            Color.bg
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Preferences")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.mainOpp)

                        Text("Configure background monitoring, menu bar integration, and hardware simulation")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.mainOpp.opacity(0.6))
                    }
                    .padding(.horizontal, 4)

                    // 1. System Integration
                    settingsSection(title: "System Integration", icon: "macbook.and.iphone") {
                        VStack(spacing: 12) {
                            Toggle("Launch Razer macOS at Login", isOn: $launchAtLogin)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .toggleStyle(.switch)
                                .tint(Color.razerGreen)
                                .onChange(of: launchAtLogin) { _, newValue in
                                    do {
                                        if newValue {
                                            try SMAppService.mainApp.register()
                                        } else {
                                            try SMAppService.mainApp.unregister()
                                        }
                                    } catch {
                                        // Ignore or handle service registration failure
                                    }
                                }

                            Divider()
                                .overlay(Color.mainOpp.opacity(0.06))

                            Toggle("Show Quick Control in Menu Bar", isOn: $showMenuBarExtra)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .toggleStyle(.switch)
                                .tint(Color.razerGreen)
                        }
                    }

                    // 2. Hardware Engine
                    settingsSection(title: "Hardware Engine", icon: "cpu") {
                        VStack(spacing: 14) {
                            Toggle("Enable Demo / Simulation Mode", isOn: $manager.demoModeEnabled)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .toggleStyle(.switch)
                                .tint(Color.razerGreen)

                            Text("When enabled, simulates Razer DeathAdder V2, BlackWidow Elite, and Firefly V2 peripherals if no physical devices are connected.")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundStyle(Color.mainOpp.opacity(0.55))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Divider()
                                .overlay(Color.mainOpp.opacity(0.06))

                            HStack {
                                Text("Wireless Battery Poll Interval")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.mainOpp)

                                Spacer()

                                Picker("", selection: $manager.autoRefreshInterval) {
                                    Text("3 seconds").tag(3.0)
                                    Text("5 seconds").tag(5.0)
                                    Text("10 seconds").tag(10.0)
                                    Text("30 seconds").tag(30.0)
                                }
                                .labelsHidden()
                                .frame(maxWidth: 140)
                            }
                        }
                    }

                    // 3. About
                    settingsSection(title: "About", icon: "info.circle") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Razer macOS")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.mainOpp)

                                Spacer()

                                JellyBadge("Pure Swift Edition", tintColor: .razerGreen)
                            }

                            Text("Native macOS open-source driver and lighting controller for Razer hardware. Built without Electron or Node.js runtimes.")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(Color.mainOpp.opacity(0.6))

                            Divider()
                                .overlay(Color.mainOpp.opacity(0.06))

                            HStack {
                                Text("Version")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(Color.mainOpp.opacity(0.5))
                                Spacer()
                                Text("2.0.0 (Native)")
                                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(Color.mainOpp)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
    }

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

            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding(16)
            .jellyCard(cornerRadius: 14)
        }
    }
}
