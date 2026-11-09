//
//  ContentView.swift
//  RazerMacOS
//
//  Created by Garrett Butchko.
//

import SwiftUI
import BaseColors

public enum ActiveScreen: Equatable {
    case overview
    case deviceDetail(String)
    case settings
}

struct ContentView: View {
    @Bindable var manager: RazerDeviceManager = RazerDeviceManager()
    @State private var activeScreen: ActiveScreen = .overview
    @State private var showSaveProfileSheet: Bool = false
    @State private var newProfileName: String = ""
    @State private var hoveredDeviceId: String? = nil

    var body: some View {
        ZStack {
            Color.bg
                .ignoresSafeArea()

            switch activeScreen {
            case .overview:
                overviewView
                    .transition(.opacity)

            case .deviceDetail(let deviceId):
                if let device = manager.devices.first(where: { $0.id == deviceId }) {
                    DeviceDetailView(
                        manager: manager,
                        device: device,
                        onBack: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                activeScreen = .overview
                            }
                        }
                    )
                    .transition(.opacity)
                } else {
                    overviewView
                        .onAppear { activeScreen = .overview }
                }

            case .settings:
                SettingsView(
                    manager: manager,
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            activeScreen = .overview
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .frame(minWidth: 840, minHeight: 560)
        .sheet(isPresented: $showSaveProfileSheet) {
            saveProfileSheet
        }
    }

    // MARK: - Overview Main Screen

    private var overviewView: some View {
        VStack(spacing: 0) {
            // Top Bar
            topHeader
                .padding(.horizontal, 28)
                .padding(.top, 22)
                .padding(.bottom, 16)

            Spacer(minLength: 10)

            // Devices Content Area
            if manager.devices.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                devicesShelf
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Spacer(minLength: 10)
        }
    }

    // MARK: - Top Header

    private var topHeader: some View {
        HStack(alignment: .center, spacing: 16) {
            // Top Left: Logo + App Title
            HStack(spacing: 10) {
                Image(.razerSVG)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 26, height: 26)
                    .foregroundStyle(Color.razerGreen)

                Text("Razer MacOS")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.mainOpp)
            }

            Spacer()

            // Top Right Controls
            HStack(spacing: 12) {
                // Profile Dropdown
                profileDropdown

                // Save Profile Button
                Button {
                    newProfileName = "Profile \(manager.savedProfiles.count + 1)"
                    showSaveProfileSheet = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                        Text("Save Profile")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(Color.mainOpp)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .jellyGlass(in: Capsule())
                }
                .buttonStyle(.plain)

                // Refresh Devices Button (Green with white text + interactive liquid glass)
                Button {
                    manager.refreshDevices()
                } label: {
                    HStack(spacing: 7) {
                        Text("Refresh Devices")
                            .font(.system(size: 12, weight: .bold, design: .rounded))

                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 12, weight: .bold))
                            .rotationEffect(.degrees(manager.isScanning ? 360 : 0))
                            .animation(
                                manager.isScanning
                                    ? .linear(duration: 1.0).repeatForever(autoreverses: false)
                                    : .default,
                                value: manager.isScanning
                            )
                    }
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.razerGreen, in: Capsule())
                    .jellyGlass(in: Capsule())
                }
                .buttonStyle(.plain)

                // Settings Button
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        activeScreen = .settings
                    }
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.mainOpp)
                        .padding(9)
                        .jellyGlass(in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Profile Dropdown

    private var profileDropdown: some View {
        Menu {
            Button {
                manager.applyProfile(id: RazerProfile.turnAllOffId)
            } label: {
                HStack {
                    Text("Turn All Off")
                    if manager.activeProfileId == RazerProfile.turnAllOffId {
                        Image(systemName: "checkmark")
                    }
                }
            }

            if !manager.savedProfiles.isEmpty {
                Divider()

                ForEach(manager.savedProfiles) { profile in
                    Button {
                        manager.applyProfile(id: profile.id)
                    } label: {
                        HStack {
                            Text(profile.name)
                            if manager.activeProfileId == profile.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.razerGreen)

                Text(currentProfileDisplayName)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.mainOpp)
                    .lineLimit(1)

                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.mainOpp.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .jellyGlass(in: Capsule())
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }

    private var currentProfileDisplayName: String {
        if manager.activeProfileId == RazerProfile.turnAllOffId {
            return "Turn All Off"
        }
        if let current = manager.savedProfiles.first(where: { $0.id == manager.activeProfileId }) {
            return current.name
        }
        return "Profiles"
    }

    // MARK: - Devices Shelf (Horizontal Row)

    private var devicesShelf: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(manager.devices) { device in
                    deviceCard(for: device)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
        }
    }

    // MARK: - Device Card

    private func deviceCard(for device: RazerDeviceModel) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                activeScreen = .deviceDetail(device.id)
            }
        } label: {
            VStack(spacing: 16) {
                // Device Image with Slight Shadow
                ZStack {
                    if let urlString = device.imageURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 170, height: 170)
                            case .failure:
                                fallbackIcon(for: device)
                            case .empty:
                                ProgressView()
                                    .frame(width: 170, height: 170)
                            @unknown default:
                                fallbackIcon(for: device)
                            }
                        }
                    } else {
                        fallbackIcon(for: device)
                    }
                }
                .shadow(
                    color: Color.black.opacity(0.18),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                .frame(width: 190, height: 190)

                // Device Name
                Text(device.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.mainOpp)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 190)

                // Current Setting Badge
                Text(device.currentSettingDescription)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.mainOpp.opacity(0.75))
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.sub, in: RoundedRectangle(cornerRadius: 8))
            }
            .padding(18)
            .jellyCard(cornerRadius: 18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        hoveredDeviceId == device.id ? Color.razerGreen.opacity(0.6) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .scaleEffect(hoveredDeviceId == device.id ? 1.02 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: hoveredDeviceId)
        }
        .buttonStyle(.plain)
        .onHover { isHovered in
            hoveredDeviceId = isHovered ? device.id : nil
        }
    }

    private func fallbackIcon(for device: RazerDeviceModel) -> some View {
        VStack(spacing: 8) {
            Image(systemName: device.type.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .foregroundStyle(device.isLightingEnabled ? device.primaryColor.swiftUIColor : Color.secondary)

            Text(device.type.displayName)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color.secondary)
        }
        .frame(width: 170, height: 170)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cable.connector.slash")
                .font(.system(size: 40))
                .foregroundStyle(Color.secondary)

            VStack(spacing: 4) {
                Text("No Razer Devices Detected")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.mainOpp)

                Text("Connect a supported Razer mouse, keyboard, or mouse mat via USB, or enable Demo Mode in Preferences.")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
            }

            HStack(spacing: 12) {
                Button("Enable Demo Mode") {
                    manager.demoModeEnabled = true
                }
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.razerGreen)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .jellyGlass(in: Capsule())
                .buttonStyle(.plain)

                Button("Scan Again") {
                    manager.refreshDevices()
                }
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.mainOpp)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .jellyGlass(in: Capsule())
                .buttonStyle(.plain)
            }
        }
        .padding(32)
        .jellyCard(cornerRadius: 18)
        .frame(maxWidth: 460)
    }

    // MARK: - Save Profile Sheet

    private var saveProfileSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Save Current Profile")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.mainOpp)

                Spacer()

                Button {
                    showSaveProfileSheet = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.secondary)
                }
                .buttonStyle(.plain)
            }

            Text("This will save the current lighting effects, colors, brightness, and sensor DPI across all active devices into a profile.")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(Color.secondary)

            TextField("Profile Name", text: $newProfileName)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13, design: .rounded))

            HStack {
                Spacer()

                Button("Cancel") {
                    showSaveProfileSheet = false
                }
                .keyboardShortcut(.cancelAction)

                Button("Save Profile") {
                    manager.saveCurrentAsProfile(name: newProfileName)
                    showSaveProfileSheet = false
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .tint(Color.razerGreen)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .frame(width: 360)
    }
}
