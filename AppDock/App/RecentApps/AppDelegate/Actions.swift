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
    /// - Note: Brings the About panel to the front and gives it focus, then closes the popover.
    @objc func about() {
        NSApp.orderFrontStandardAboutPanel()
        NSApp.activate(ignoringOtherApps: true)
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

    /// Handler for "Keyboard Shortcuts" action.
    ///
    /// - Note: Opens a dedicated window showing all keyboard shortcuts.
    @objc func openKeyboardShortcuts() {
        if shortcutsWindowController == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "Keyboard Shortcuts"
            window.isReleasedWhenClosed = false
            window.center()
            window.contentView = NSHostingView(rootView: KeyboardShortcutsPanel())
            shortcutsWindowController = NSWindowController(window: window)
        }

        shortcutsWindowController?.showWindow(nil)
        shortcutsWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        closePopover(nil)
    }

    /// Handler for "Help" action.
    ///
    /// - Note: Opens the in-app help system.
    @objc func openHelp() {
        if helpWindowController == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "AppDock Help"
            window.isReleasedWhenClosed = false
            window.center()
            window.contentView = NSHostingView(rootView: InAppHelpPanel())
            helpWindowController = NSWindowController(window: window)
        }

        helpWindowController?.showWindow(nil)
        helpWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        closePopover(nil)
    }

    /// Handler for "Release Notes" action.
    ///
    /// - Note: Opens the release notes viewer.
    @objc func openReleaseNotes() {
        if releaseNotesWindowController == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 650, height: 500),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "Release Notes"
            window.isReleasedWhenClosed = false
            window.center()
            window.contentView = NSHostingView(rootView: ReleaseNotesPanel())
            releaseNotesWindowController = NSWindowController(window: window)
        }

        releaseNotesWindowController?.showWindow(nil)
        releaseNotesWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        closePopover(nil)
    }

    /// Handler for "App Groups" action.
    ///
    /// - Note: Opens the app groups management panel.
    @objc func openAppGroups() {
        if appGroupsWindowController == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "App Groups"
            window.isReleasedWhenClosed = false
            window.center()
            window.contentView = NSHostingView(rootView: AppGroupsView(groupManager: AppGroupManager()))
            appGroupsWindowController = NSWindowController(window: window)
        }

        appGroupsWindowController?.showWindow(nil)
        appGroupsWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        closePopover(nil)
    }
}
