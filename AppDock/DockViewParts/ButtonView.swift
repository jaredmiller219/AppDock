//
//  ButtonView.swift
//  AppDock
//

import SwiftUI
import AppKit

// MARK: - ButtonView

/// Renders a single app icon slot and handles interactions.
///
/// Supports command-click context menus, hover removal, and activation.
struct ButtonView: View {
    let appName: String
    let bundleId: String
    let appIcon: NSImage
    let buttonWidth: CGFloat
    let buttonHeight: CGFloat
    let allowRemove: Bool

    // Controls whether THIS button's context menu is visible.
    @Binding var isContextMenuVisible: Bool

    // Called when the user taps the "X" remove button.
    let onRemove: () -> Void

    @State private var isHovering = false
    @State private var showRemoveButton = false
    @State private var removeButtonWorkItem: DispatchWorkItem?
    @State private var isCommandHeld = false
    @State private var modifierFlagsMonitor: Any?
    @State private var globalModifierFlagsMonitor: Any?

    private func openApp(bundleId: String) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            return
        }
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.createsNewApplicationInstance = false
        NSWorkspace.shared.openApplication(
            at: appURL,
            configuration: configuration,
            completionHandler: nil
        )
    }

    /// Attempts to activate an already running app and relaunch if needed.
    private func activateOrLaunchApp(bundleId: String) {
        guard !bundleId.isEmpty else { return }

        if let targetApp = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleId)
            .first(where: { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }) {
            // Unhide and activate all windows to restore minimized apps.
            targetApp.unhide()
            targetApp.activate(options: [.activateAllWindows])
            openApp(bundleId: bundleId)
        } else {
            // If the app isn't running, relaunch it.
            openApp(bundleId: bundleId)
        }
    }

    /// Handles primary click behavior: command-click toggles menu, otherwise activates the app.
    private func handlePrimaryClick() {
        if let event = NSApp.currentEvent,
           event.modifierFlags.contains(.command) {
            // Command-click: toggle this button's context menu.
            isContextMenuVisible.toggle()
        } else {
            // Any regular click closes all context menus first.
            isContextMenuVisible = false
            activateOrLaunchApp(bundleId: bundleId)
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Group {
                if appName.isEmpty {
                    EmptySlot(width: buttonWidth, height: buttonHeight)
                } else {
                    Button {
                        handlePrimaryClick()
                    } label: {
                        IconView(
                            appName: appName,
                            appIcon: appIcon,
                            width: buttonWidth,
                            height: buttonHeight
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isHovering ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Remove "X" button overlay in top-left
            if allowRemove && showRemoveButton && !appName.isEmpty {
                Button {
                    onRemove()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 10, weight: .bold))
                        .contentShape(Rectangle()) // nicer tap target
                }
                .buttonStyle(.plain)
                .padding(2)
            }
        }
        // Attach hover to the whole cell (icon + X), so moving onto the X doesn't "leave"
        .onHover { hovering in
            isHovering = hovering

            if allowRemove {
                if hovering {
                    let commandIsDown = isCommandHeld || (NSApp.currentEvent?.modifierFlags.contains(.command) ?? false)

                    // Only schedule the "X" if Command is held
                    if commandIsDown {
                        scheduleRemoveButton()
                    } else {
                        cancelRemoveButton()
                    }
                } else {
                    // Actually left the button area: hide X
                    cancelRemoveButton()
                }
            } else {
                cancelRemoveButton()
            }
        }
        .onAppear {
            if allowRemove {
                startMonitoringModifierFlags()
            }
        }
        .onDisappear {
            stopMonitoringModifierFlags()
        }
        .onChange(of: allowRemove) { _, enabled in
            if enabled {
                startMonitoringModifierFlags()
            } else {
                stopMonitoringModifierFlags()
                cancelRemoveButton()
            }
        }
        .disabled(bundleId.isEmpty)
    }

    // MARK: - Modifier key monitoring

    /// Begins tracking Command key state for the delayed remove button.
    private func startMonitoringModifierFlags() {
        if modifierFlagsMonitor != nil { return }

        isCommandHeld = NSEvent.modifierFlags.contains(.command)

        modifierFlagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
            handleModifierFlagsChange(event)
            return event
        }

        // Also listen globally so Command presses register even if the window isn't key yet.
        globalModifierFlagsMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
            handleModifierFlagsChange(event)
        }
    }

    /// Removes modifier monitors to avoid leaks.
    private func stopMonitoringModifierFlags() {
        if let monitor = modifierFlagsMonitor {
            NSEvent.removeMonitor(monitor)
            modifierFlagsMonitor = nil
        }

        if let globalMonitor = globalModifierFlagsMonitor {
            NSEvent.removeMonitor(globalMonitor)
            globalModifierFlagsMonitor = nil
        }
    }

    /// Updates local state when modifier flags change.
    private func handleModifierFlagsChange(_ event: NSEvent) {
        guard allowRemove else { return }
        let commandIsDown = event.modifierFlags.contains(.command)
        isCommandHeld = commandIsDown

        if commandIsDown {
            if isHovering {
                scheduleRemoveButton()
            }
        } else {
            cancelRemoveButton()
        }
    }

    // MARK: - Remove button timing

    /// Shows the remove button after a brief hover delay.
    private func scheduleRemoveButton() {
        removeButtonWorkItem?.cancel()

        let workItem = DispatchWorkItem {
            if isHovering {
                showRemoveButton = true
            }
        }
        removeButtonWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }

    /// Cancels any pending remove button display and hides it.
    private func cancelRemoveButton() {
        removeButtonWorkItem?.cancel()
        removeButtonWorkItem = nil
        showRemoveButton = false
    }
}
