//
//  HardwareDatabaseView.swift
//  RazerMacOS
//
//  Created by Garrett Butchko.
//

import SwiftUI
import BaseColors

struct HardwareDatabaseView: View {
    @State private var searchText: String = ""
    @State private var selectedCategory: RazerDeviceType? = nil

    private var catalog: [RazerDeviceDefinition] {
        RazerDeviceCatalog.shared.allDevices
    }

    private var filteredDevices: [RazerDeviceDefinition] {
        catalog.filter { item in
            if let cat = selectedCategory, item.mainType != cat {
                return false
            }
            if !searchText.isEmpty {
                let query = searchText.lowercased()
                return item.name.lowercased().contains(query) || item.productIdHex.lowercased().contains(query)
            }
            return true
        }
    }

    var body: some View {
        ZStack {
            Color.bg
                .ignoresSafeArea()

            VStack(spacing: 12) {
                // Controls bar
                HStack(spacing: 12) {
                    // Search bar
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.mainOpp.opacity(0.45))

                        TextField("Search models or Product IDs…", text: $searchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(Color.mainOpp)

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.mainOpp.opacity(0.4))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.sub, in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.mainOpp.opacity(0.08), lineWidth: 0.8))
                    .frame(maxWidth: 280)

                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            categoryPill(title: "All", type: nil)
                            ForEach(RazerDeviceType.allCases) { cat in
                                categoryPill(title: cat.displayName, type: cat)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Subtitle banner
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.razerGreen)

                    Text("\(filteredDevices.count) of \(catalog.count) Razer hardware models supported natively")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.mainOpp.opacity(0.75))

                    Spacer()
                }
                .padding(.horizontal, 20)

                // List
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredDevices) { item in
                            deviceDirectoryCard(for: item)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    private func categoryPill(title: String, type: RazerDeviceType?) -> some View {
        let isSelected = selectedCategory == type
        return Button {
            selectedCategory = type
        } label: {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? Color.black : Color.mainOpp)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.razerGreen : Color.sub)
                )
        }
        .buttonStyle(.plain)
    }

    private func deviceDirectoryCard(for item: RazerDeviceDefinition) -> some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.razerGreen.opacity(0.12))
                    .frame(width: 38, height: 38)

                Image(systemName: item.mainType.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.razerGreen)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(item.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.mainOpp)

                    Text(item.productIdHex)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Color.subTwo, in: Capsule())
                        .foregroundStyle(Color.mainOpp.opacity(0.6))
                }

                HStack(spacing: 6) {
                    Text(item.mainType.displayName)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.mainOpp.opacity(0.6))

                    if item.mainType == .mouse {
                        Text("•")
                            .foregroundStyle(Color.mainOpp.opacity(0.3))
                        Text("Up to \(item.maxDpi) DPI")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.razerGreen)
                    }
                }
            }

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.razerGreen)
                .padding(6)
                .background(Circle().fill(Color.razerGreen.opacity(0.12)))
        }
        .padding(12)
        .jellyCard(cornerRadius: 12)
    }
}
