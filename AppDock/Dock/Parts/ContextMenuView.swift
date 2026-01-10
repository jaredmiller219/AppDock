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

    @State private var isXButtonHovered = false

    private func shouldQuitApp() -> Bool {
        let alert = NSAlert()
        let title = ContextMenuViewPrompt.quitTitle(for: appName)
        alert.messageText = title
        alert.informativeText = "Any unsaved changes may be lost."
        alert.addButton(withTitle: "Quit")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }

    private func shouldForceQuitApp() -> Bool {
        let alert = NSAlert()
        alert.messageText = "Force Quit \(appName)?"
        alert.informativeText = "The app will not be able to save any unsaved changes."
        alert.addButton(withTitle: "Force Quit")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }

    private func showInFinder() {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            NSWorkspace.shared.selectFile(appURL.path, inFileViewerRootedAtPath: "")
        }
        onDismiss()
    }

    private func revealInDock() {
        if let app = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == bundleId }) {
            if #available(macOS 14.0, *) {
                app.activate()
            } else {
                app.activate(options: [.activateIgnoringOtherApps])
            }
        }
        onDismiss()
    }

    private func toggleLaunchAtLogin() {
        // This would need to be implemented with SMLoginItemSetEnabled
        // For now, just log the action
//        log("Toggle launch at login for: \(bundleId)")
        onDismiss()
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background layer that absorbs taps
            Rectangle()
                .fill(Color.clear)
                .frame(width: AppDockConstants.ContextMenu.width, height: 220)
                .simultaneousGesture(
                    TapGesture()
                        .onEnded { _ in
                            // Do nothing - absorbs taps that aren't on buttons
                        }
                )

            VStack(spacing: AppDockConstants.ContextMenu.spacing) {
                Button(action: {
//                    log("🔍 ContextMenuView: 'Hide App' button tapped")
                    if let app = NSRunningApplication
                        .runningApplications(withBundleIdentifier: bundleId)
                        .first
                    {
//                        log("Hiding app with bundle ID: \(bundleId)")
                        app.hide()
                    }
                    onDismiss()
                }, label: {
                    Text("Hide App")
                })
                .frame(maxWidth: .infinity, minHeight: AppDockConstants.ContextMenu.buttonMinHeight)
                .lineLimit(1)
                .truncationMode(.tail)

                Button(action: {
                    showInFinder()
                }, label: {
                    Text("Show in Finder")
                })
                .frame(maxWidth: .infinity, minHeight: AppDockConstants.ContextMenu.buttonMinHeight)
                .lineLimit(1)
                .truncationMode(.tail)

                Button(action: {
                    revealInDock()
                }, label: {
                    Text("Reveal in Dock")
                })
                .frame(maxWidth: .infinity, minHeight: AppDockConstants.ContextMenu.buttonMinHeight)
                .lineLimit(1)
                .truncationMode(.tail)

                Button(action: {
                    toggleLaunchAtLogin()
                }, label: {
                    Text("Open at Login")
                })
                .frame(maxWidth: .infinity, minHeight: AppDockConstants.ContextMenu.buttonMinHeight)
                .lineLimit(1)
                .truncationMode(.tail)

                Button(action: {
                    guard shouldQuitApp() else { return }
                    if let targetApp = NSRunningApplication
                        .runningApplications(withBundleIdentifier: bundleId)
                        .first(where: { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier })
                    {
//                        log("Quitting app with bundle ID: \(bundleId)")
                        let terminated = targetApp.terminate()
                        if !terminated {
                            targetApp.forceTerminate()
                        }
                    }
                    onDismiss()
                }, label: {
                    Text("Quit App")
                })
                .frame(maxWidth: .infinity, minHeight: AppDockConstants.ContextMenu.buttonMinHeight)
                .lineLimit(1)
                .truncationMode(.tail)

                Button(action: {
                    guard shouldForceQuitApp() else { return }
                    if let targetApp = NSRunningApplication
                        .runningApplications(withBundleIdentifier: bundleId)
                        .first(where: { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier })
                    {
//                        log("Force quitting app with bundle ID: \(bundleId)")
                        targetApp.forceTerminate()
                    }
                    onDismiss()
                }, label: {
                    Text("Force Quit")
                })
                .frame(maxWidth: .infinity, minHeight: AppDockConstants.ContextMenu.buttonMinHeight)
                .lineLimit(1)
                .truncationMode(.tail)
            }
            .padding(.horizontal, AppDockConstants.ContextMenu.paddingHorizontal)
            .padding(.vertical, AppDockConstants.ContextMenu.paddingVertical)
            .frame(width: AppDockConstants.ContextMenu.width)
            .background(
                Material.ultraThinMaterial
                    .opacity(0.8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

            Button(action: {
                onDismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: AppDockConstants.ContextMenu.closeButtonSize, height: AppDockConstants.ContextMenu.closeButtonSize)
                    .background(
                        Circle()
                            .fill(isXButtonHovered ? Color.secondary.opacity(0.2) : Color.secondary.opacity(0.1))
                            .frame(width: AppDockConstants.ContextMenu.closeButtonSize, height: AppDockConstants.ContextMenu.closeButtonSize)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(AppDockConstants.ContextMenu.closeButtonPadding)
            .accessibilityLabel("Close context menu")
            .onHover { isHovering in
                isXButtonHovered = isHovering
            }
        }
        .accessibilityIdentifier(AppDockConstants.Accessibility.contextMenu)
    }
}
