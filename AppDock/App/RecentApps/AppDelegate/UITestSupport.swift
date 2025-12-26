//
//  UITestSupport.swift
//  AppDock
//

import Cocoa
import SwiftUI

// MARK: - UI Test Support

extension AppDelegate {
    /// Applies UI test launch arguments to the live app state.
    ///
    /// - Note: Only runs when `--ui-test-mode` is present.
    func applyUITestOverridesIfNeeded() {
        let arguments = ProcessInfo.processInfo.arguments
        guard arguments.contains(AppDockConstants.Testing.uiTestMode) else { return }

        appState.menuPage = .dock
        UserDefaults.standard.set(
            SettingsDefaults.simpleSettingsDefault,
            forKey: SettingsDefaults.simpleSettingsKey
        )
        UserDefaults.standard.set(
            SettingsDefaults.menuLayoutModeDefault.rawValue,
            forKey: SettingsDefaults.menuLayoutModeKey
        )
        appState.menuLayoutMode = SettingsDefaults.menuLayoutModeDefault

        if arguments.contains(AppDockConstants.Testing.uiTestSeedDock) {
            seedDockForUITests()
        }

        if arguments.contains(AppDockConstants.Testing.uiTestOpenPopover) {
            DispatchQueue.main.async { [weak self] in
                self?.showUITestPopoverWindow()
            }
        }

        if arguments.contains(AppDockConstants.Testing.uiTestOpenSettings) {
            DispatchQueue.main.async { [weak self] in
                self?.openSettings()
            }
        }

        if arguments.contains(AppDockConstants.Testing.uiTestOpenPopovers) {
            DispatchQueue.main.async { [weak self] in
                self?.showUITestPopoverWindow()
                self?.openSettings()
            }
        }

        if arguments.contains(AppDockConstants.Testing.uiTestStatusItemProxy) {
            DispatchQueue.main.async { [weak self] in
                self?.showUITestStatusItemProxyWindow()
            }
        }

        if arguments.contains(AppDockConstants.Testing.uiTestMenuSimple) {
            UserDefaults.standard.set(
                MenuLayoutMode.simple.rawValue,
                forKey: SettingsDefaults.menuLayoutModeKey
            )
            appState.menuLayoutMode = .simple
        }
    }

    /// Seeds a predictable dock list for UI tests.
    ///
    /// - Note: Uses placeholder icons to avoid file system dependencies.
    func seedDockForUITests() {
        let placeholderIcon = NSImage(size: NSSize(width: AppDockConstants.AppIcon.size, height: AppDockConstants.AppIcon.size))
        appState.recentApps = [
            (name: "Alpha", bundleid: "com.example.alpha", icon: placeholderIcon),
            (name: "Bravo", bundleid: "com.example.bravo", icon: placeholderIcon),
            (name: "Charlie", bundleid: "com.example.charlie", icon: placeholderIcon)
        ]
    }

    /// Opens a standalone popover window for UI tests.
    ///
    /// - Note: This bypasses the status item for more reliable automation.
    func showUITestPopoverWindow() {
        if let window = uiTestWindow {
            window.makeKeyAndOrderFront(nil)
            return
        }

        let controller = menu.makePopoverController(
            appState: appState,
            settingsAction: { [weak self] in self?.openSettings() },
            aboutAction: { [weak self] in self?.about() },
            quitAction: { [weak self] in self?.quit() }
        )

        let window = NSWindow(contentViewController: controller)
        window.title = AppDockConstants.Accessibility.uiTestWindow
        window.setContentSize(PopoverSizing.size(for: appState))
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        uiTestWindow = window
    }

    /// Opens a lightweight UI test window that toggles the popover.
    func showUITestStatusItemProxyWindow() {
        if let window = uiTestStatusItemWindow {
            window.makeKeyAndOrderFront(nil)
            return
        }

        let view = StatusItemProxyView { [weak self] in
            self?.togglePopover(nil)
        }
        let controller = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: controller)
        window.title = "AppDock Status Item Proxy"
        window.setContentSize(NSSize(width: 220, height: 80))
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        uiTestStatusItemWindow = window
    }
}

private struct StatusItemProxyView: View {
    let onToggle: () -> Void

    var body: some View {
        Button("Open Popover") {
            onToggle()
        }
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier(AppDockConstants.Accessibility.uiTestStatusItemProxy)
        .padding()
    }
}
