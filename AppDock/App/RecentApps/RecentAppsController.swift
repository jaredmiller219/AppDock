//
//  RecentAppsController.swift
//  AppDock
//
//  Created by Jared Miller on 12/12/24.
//

import SwiftUI

// MARK: - App Entry Point

/// AppDock's main entry point.
///
/// - Note: The SwiftUI `App` hosts the settings scene while `AppDelegate`
///   owns the menu bar status item and popover UI.
@main
struct RecentAppsController: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // MARK: Scene

    var body: some Scene {
        Settings {
            SettingsView(appState: appDelegate.appState)
        }
    }
}
