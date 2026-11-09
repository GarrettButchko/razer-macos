//
//  ContentView.swift
//  RazerMacOS
//
//  Created by Garrett Butchko.
//

import SwiftUI
import BaseColors

public enum NavigationSection: String, CaseIterable, Identifiable {
    case devices = "devices"
    case lighting = "lighting"
    case performance = "performance"
    case catalog = "catalog"
    case logs = "logs"
    case settings = "settings"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .devices: return "Devices"
        case .lighting: return "Chroma Lighting"
        case .performance: return "Performance"
        case .catalog: return "Supported Hardware"
        case .logs: return "Activity Logs"
        case .settings: return "Preferences"
        }
    }

    public var icon: String {
        switch self {
        case .devices: return "keyboard"
        case .lighting: return "paintbrush.fill"
        case .performance: return "slider.horizontal.3"
        case .catalog: return "checklist"
        case .logs: return "doc.plaintext"
        case .settings: return "gearshape"
        }
    }
}

struct ContentView: View {
    @State private var manager = RazerDeviceManager()
    @State private var selectedSection: NavigationSection = .devices
    @State private var hoveredSection: NavigationSection? = nil

    var body: some View {
        NavigationSplitView {
            sidebarContent
                .navigationSplitViewColumnWidth(min: 210, ideal: 230, max: 280)
        } detail: {
            detailContent
        }
        .frame(minWidth: 840, minHeight: 560)
    }

    // MARK: - Sidebar

    private var sidebarContent: some View {
        ZStack {
            Color.sub
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 6) {
                // App Branding Header
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.razerGreen.opacity(0.15))
                            .frame(width: 32, height: 32)

                        Image(.razerSVG)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                            .foregroundStyle(Color.razerGreen)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Razer macOS")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.mainOpp)

                        HStack(spacing: 5) {
                            Circle()
                                .fill(manager.devices.isEmpty ? Color.orange : Color.razerGreen)
                                .frame(width: 6, height: 6)

                            Text(manager.devices.isEmpty ? "No Hardware" : "\(manager.devices.count) Online")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.mainOpp.opacity(0.6))
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)
                .padding(.bottom, 12)

                // Navigation Items
                VStack(spacing: 3) {
                    sidebarRow(section: .devices, badge: "\(manager.devices.count)")
                    sidebarRow(section: .lighting)
                    sidebarRow(section: .performance)

                    Divider()
                        .overlay(Color.mainOpp.opacity(0.06))
                        .padding(.vertical, 4)

                    sidebarRow(section: .catalog, badge: "\(RazerDeviceCatalog.shared.allDevices.count)")
                    sidebarRow(section: .logs, badge: manager.logs.isEmpty ? nil : "\(manager.logs.count)")
                    sidebarRow(section: .settings)
                }
                .padding(.horizontal, 8)

                Spacer()
            }
        }
    }

    private func sidebarRow(section: NavigationSection, badge: String? = nil) -> some View {
        let isSelected = selectedSection == section
        let isHovered = hoveredSection == section

        return Button {
            selectedSection = section
        } label: {
            HStack(spacing: 10) {
                Image(systemName: section.icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.razerGreen : Color.mainOpp.opacity(0.7))
                    .frame(width: 20)

                Text(section.title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundStyle(isSelected ? Color.mainOpp : Color.mainOpp.opacity(0.85))

                Spacer()

                if let badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? Color.black : Color.mainOpp.opacity(0.6))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.razerGreen : Color.mainOpp.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(isSelected ? Color.mainOpp.opacity(0.12) : (isHovered ? Color.mainOpp.opacity(0.05) : Color.clear))
            )
            .contentShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hoveredSection = hovering ? section : nil
        }
    }

    // MARK: - Detail View

    @ViewBuilder
    private var detailContent: some View {
        switch selectedSection {
        case .devices:
            DevicesView(manager: manager)
        case .lighting:
            LightingView(manager: manager)
        case .performance:
            PerformanceView(manager: manager)
        case .catalog:
            HardwareDatabaseView()
        case .logs:
            LogView(manager: manager)
        case .settings:
            SettingsView(manager: manager)
        }
    }
}
