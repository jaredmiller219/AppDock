//
//  ContextMenuView.swift
//  AppDock
//

import AppKit
import os
import SwiftUI

// MARK: - ContextMenuView

/// Small helpers used by the `ContextMenuView` for confirmation and titles.
enum ContextMenuViewPrompt {
    static func requiresConfirmation(confirmBeforeQuit: Bool) -> Bool {
        confirmBeforeQuit
    }

    static func quitTitle(for appName: String) -> String {
        appName.isEmpty ? "Quit this app?" : "Quit \(appName)?"
    }
}

/// Context menu shown when a slot is command-clicked.
///
/// Provides simple actions that operate on the target `bundleId` such as
/// hiding and quitting the application. The view will optionally prompt
/// for confirmation when the user requests to quit.
struct ContextMenuView: View {
    /// Called after the menu performs an action to allow the caller to
    /// dismiss overlays or update state.
    var onDismiss: () -> Void

    /// Human-readable app name for presenting titles.
    let appName: String

    /// Target app bundle identifier used to find running instances.
    let bundleId: String

    /// When `true`, present a confirmation alert before quitting.
    let confirmBeforeQuit: Bool

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AppDock", category: "ContextMenu")

    private var isDebugLoggingEnabled: Bool {
        SettingsDefaults.boolValue(
            forKey: SettingsDefaults.debugLoggingKey,
            defaultValue: SettingsDefaults.debugLoggingDefault
        )
    }

    private func log(_ message: String) {
        guard isDebugLoggingEnabled else { return }
        logger.debug("\(message, privacy: .public)")
    }

    private func shouldQuitApp() -> Bool {
        guard ContextMenuViewPrompt.requiresConfirmation(confirmBeforeQuit: confirmBeforeQuit) else { return true }

        let alert = NSAlert()
        let title = ContextMenuViewPrompt.quitTitle(for: appName)
        alert.messageText = title
        alert.informativeText = "Any unsaved changes may be lost."
        alert.addButton(withTitle: "Quit")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }

    var body: some View {
        VStack(spacing: AppDockConstants.ContextMenu.spacing) {
            Button("Hide App") {
                if let app = NSRunningApplication
                    .runningApplications(withBundleIdentifier: bundleId)
                    .first
                {
                    log("Hiding app with bundle ID: \(bundleId)")
                    app.hide()
                }
                onDismiss()
            }
            .frame(maxWidth: .infinity, minHeight: AppDockConstants.ContextMenu.buttonMinHeight)

            Button("Quit App") {
                guard shouldQuitApp() else { return }
                if let targetApp = NSRunningApplication
                    .runningApplications(withBundleIdentifier: bundleId)
                    .first(where: { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier })
                {
                    log("Quitting app with bundle ID: \(bundleId)")
                    let terminated = targetApp.terminate()
                    if !terminated {
                        targetApp.forceTerminate()
                    }
                }
                onDismiss()
            }
            .frame(maxWidth: .infinity, minHeight: AppDockConstants.ContextMenu.buttonMinHeight)
        }
        .padding(.horizontal, AppDockConstants.ContextMenu.paddingHorizontal)
        .padding(.vertical, AppDockConstants.ContextMenu.paddingVertical)
        .frame(width: AppDockConstants.ContextMenu.width)
        .accessibilityIdentifier(AppDockConstants.Accessibility.contextMenu)
    }
}
