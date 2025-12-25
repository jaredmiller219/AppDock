//
//  ContextMenuView.swift
//  AppDock
//

import SwiftUI
import AppKit

// MARK: - ContextMenuView

/// Context menu shown when a slot is command-clicked.
struct ContextMenuView: View {
    var onDismiss: () -> Void
    let appName: String
    let bundleId: String
    let confirmBeforeQuit: Bool

    private func shouldQuitApp() -> Bool {
        guard confirmBeforeQuit else { return true }

        let alert = NSAlert()
        let title = appName.isEmpty ? "Quit this app?" : "Quit \(appName)?"
        alert.messageText = title
        alert.informativeText = "Any unsaved changes may be lost."
        alert.addButton(withTitle: "Quit")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }

    var body: some View {
        VStack(spacing: 8) {
            Button("Hide App") {
                if let app = NSRunningApplication
                    .runningApplications(withBundleIdentifier: bundleId)
                    .first {
                    print("Hiding app with bundle ID: \(bundleId)")
                    app.hide()
                }
                onDismiss()
            }
            .frame(maxWidth: .infinity, minHeight: 36)

            Button("Quit App") {
                guard shouldQuitApp() else { return }
                if let targetApp = NSRunningApplication
                    .runningApplications(withBundleIdentifier: bundleId)
                    .first(where: { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }) {
                    print("Quitting app with bundle ID: \(bundleId)")
                    let terminated = targetApp.terminate()
                    if !terminated {
                        targetApp.forceTerminate()
                    }
                }
                onDismiss()
            }
            .frame(maxWidth: .infinity, minHeight: 36)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(width: 160)
    }
}
