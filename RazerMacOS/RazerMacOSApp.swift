//
//  RazerMacOSApp.swift
//  RazerMacOS
//
//  Created by Garrett Butchko.
//

import SwiftUI
import AppKit

@main
struct RazerMacOSApp: App {
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra: Bool = true
    @State private var sharedManager = RazerDeviceManager()

    var body: some Scene {
        WindowGroup(id: "mainWindow") {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 900, height: 600)

        MenuBarExtra(isInserted: $showMenuBarExtra) {
            MenuBarView(manager: sharedManager)
        } label: {
            Image(.razerSVG)
        }
        .menuBarExtraStyle(.window)
    }
}
