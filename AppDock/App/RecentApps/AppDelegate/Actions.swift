//
//  Actions.swift
//  AppDock
//

import Cocoa
import SwiftUI

// MARK: - App Actions

extension AppDelegate {
    /// Handler for the "About" action.
    ///
    /// - Note: Closes the popover after showing the panel.
    @objc func about() {
        NSApp.orderFrontStandardAboutPanel()
        closePopover(nil)
    }

    /// Handler for "Settings" action (opens the in-app settings window).
    ///
    /// - Note: Reuses a single settings window controller.
    @objc func openSettings() {
        if settingsWindowController == nil {
            let window = NSWindow(
                contentRect: NSRect(
                    x: 0,
                    y: 0,
                    width: AppDockConstants.SettingsWindow.width,
                    height: AppDockConstants.SettingsWindow.height
                ),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window.title = "AppDock Settings"
            window.isReleasedWhenClosed = false
            window.center()
            window.contentView = NSHostingView(rootView: SettingsView(appState: appState))
            settingsWindowController = NSWindowController(window: window)
        }

        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        closePopover(nil)
    }

    /// Handler for the "Quit" action.
    ///
    /// - Note: Terminates the app immediately.
    @objc func quit() {
        NSApp.terminate(self)
    }
}
