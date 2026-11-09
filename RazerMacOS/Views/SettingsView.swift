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
    var onBack: () -> Void

    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                Spacer()

                Button(action: onBack) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .bold))

                        Text("Preferences")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(Color.mainOpp)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .jellyCard(cornerRadius: 10)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // 1. Startup Profile Management
                    settingsSection(title: "Startup Profile", icon: "arrow.clockwise.circle.fill") {
                        VStack(spacing: 12) {
                            Toggle("Restore Profile on Launch", isOn: $manager.restoreProfileOnLaunch)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .toggleStyle(.switch)
                                .tint(Color.razerGreen)

                            Text("Automatically restore device lighting and performance settings whenever the application opens.")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundStyle(Color.mainOpp.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if manager.restoreProfileOnLaunch {
                                Divider()
                                    .overlay(Color.mainOpp.opacity(0.06))

                                HStack {
                                    Text("Profile to Apply")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(Color.mainOpp)

                                    Spacer()

                                    Picker("", selection: $manager.startupProfileId) {
                                        Text("Last Active State").tag("")
                                        Text("Turn All Off").tag(RazerProfile.turnAllOffId)
                                        ForEach(manager.savedProfiles) { profile in
                                            Text(profile.name).tag(profile.id)
                                        }
                                    }
                                    .labelsHidden()
                                    .pickerStyle(.menu)
                                    .frame(maxWidth: 180)
                                }
                            }
                        }
                    }

                    // 2. Sleep & Shutdown Profile
                    settingsSection(title: "Sleep & Shutdown", icon: "moon.fill") {
                        VStack(spacing: 12) {
                            Toggle("Apply Profile on Sleep or Shutdown", isOn: $manager.applySleepProfile)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .toggleStyle(.switch)
                                .tint(Color.razerGreen)

                            Text("Activate a custom profile or power off LEDs when macOS enters sleep mode or when this app is closed.")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundStyle(Color.mainOpp.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if manager.applySleepProfile {
                                Divider()
                                    .overlay(Color.mainOpp.opacity(0.06))

                                HStack {
                                    Text("Sleep Profile")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(Color.mainOpp)

                                    Spacer()

                                    Picker("", selection: $manager.sleepProfileId) {
                                        Text("Turn All Off (Default)").tag(RazerProfile.turnAllOffId)
                                        ForEach(manager.savedProfiles) { profile in
                                            Text(profile.name).tag(profile.id)
                                        }
                                    }
                                    .labelsHidden()
                                    .pickerStyle(.menu)
                                    .frame(maxWidth: 180)
                                }
                            }
                        }
                    }

                    // 3. Saved Profiles Management
                    if !manager.savedProfiles.isEmpty {
                        settingsSection(title: "Saved Profiles (\(manager.savedProfiles.count))", icon: "slider.horizontal.3") {
                            VStack(spacing: 8) {
                                ForEach(manager.savedProfiles) { profile in
                                    HStack {
                                        Text(profile.name)
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundStyle(Color.mainOpp)

                                        if manager.activeProfileId == profile.id {
                                            Text("Active")
                                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                                .foregroundStyle(Color.razerGreen)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.razerGreen.opacity(0.15), in: Capsule())
                                        }

                                        Spacer()

                                        Button {
                                            manager.deleteProfile(id: profile.id)
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 12))
                                                .foregroundStyle(Color.red.opacity(0.8))
                                        }
                                        .buttonStyle(.plain)
                                    }

                                    if profile.id != manager.savedProfiles.last?.id {
                                        Divider().overlay(Color.mainOpp.opacity(0.06))
                                    }
                                }
                            }
                        }
                    }

                    // 4. System Integration
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

                    // 5. Hardware Engine
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

                    // 6. About
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
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .frame(maxWidth: 620)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
