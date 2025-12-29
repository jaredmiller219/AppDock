//
//  RecentAppsController.swift
//  AppDock
//
/*
 RecentAppsController.swift

 Purpose:
  - Application entry point. Installs `AppDelegate` as the application
    delegate and declares the Settings scene used by macOS to display
    the app settings window.

 Notes:
  - `AppDelegate` is responsible for creating the menu bar status item
    and hosting the SwiftUI popover; the Swift `App` here keeps the
    Settings scene simple and declarative.
*/

import SwiftUI
import AppKit

// MARK: - App Entry Point

/// AppDock's main entry point.
///
/// - Note: The SwiftUI `App` hosts the settings scene while `AppDelegate`
///   owns the menu bar status item and popover UI.
@main
struct RecentAppsController: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        KeyVisualizer.startIfRunningUITests()
    }

    // MARK: Scene

    var body: some Scene {
        Settings {
            SettingsView(appState: appDelegate.appState)
        }
    }
}
