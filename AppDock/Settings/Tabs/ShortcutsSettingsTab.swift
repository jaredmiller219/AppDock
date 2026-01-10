/*
 ShortcutsSettingsTab.swift
 AppDock

 PURPOSE:
 This view displays and manages global keyboard shortcut configuration.
 Allows users to set custom hotkeys for controlling AppDock without using the mouse.

 OVERVIEW:
 ShortcutsSettingsTab contains seven keyboard shortcut recorders:

 Menu Control Shortcuts:
 - Toggle popover: Show/hide the menu popover
 - Next page: Swipe to the next menu page
 - Previous page: Swipe to the previous menu page

 Direct Page Access Shortcuts:
 - Open Dock: Jump directly to dock/apps page
 - Open Recents: Jump directly to recent apps page
 - Open Favorites: Jump directly to favorites page
 - Open Menu: Jump directly to actions page

 Each shortcut row uses ShortcutRecorder component with live editing and display formatting.
 Helper text explains how to record new shortcuts (press key combo, Delete to clear).

 STYLING:
 - ShortcutRow subcomponents with title + recorder + display value
 - Clear (X) button appears on hover when a shortcut is set
 - Display values use ShortcutFormatter for consistent formatting
 - Divider separates control shortcuts from direct page access shortcuts

 INTEGRATION:
 - ShortcutRecorder: Component for capturing keyboard input
 - ShortcutFormatter: Converts ShortcutDefinition to display strings
 - Carbon API for actual global hotkey registration (in ShortcutManager)
*/

import SwiftUI
import AppKit

/// Settings tab for keyboard shortcut customization and management.
///
/// Displays recorders for seven global shortcuts: Toggle Popover, Next/Previous Page,
/// and direct shortcuts to Dock, Recents, Favorites, and Actions pages.
struct ShortcutsSettingsTab: View {
    /// Binding to settings draft being edited
    @Binding var draft: SettingsDraft

    var body: some View {
        VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
            GroupBox("Keyboard Shortcuts") {
                VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
                    ShortcutRow(title: "Toggle popover", shortcut: $draft.shortcutTogglePopover)
                    ShortcutRow(title: "Next page", shortcut: $draft.shortcutNextPage)
                    ShortcutRow(title: "Previous page", shortcut: $draft.shortcutPreviousPage)
                    Divider()
                    ShortcutRow(title: "Open Dock", shortcut: $draft.shortcutOpenDock)
                    ShortcutRow(title: "Open Recents", shortcut: $draft.shortcutOpenRecents)
                    ShortcutRow(title: "Open Favorites", shortcut: $draft.shortcutOpenFavorites)
                    ShortcutRow(title: "Open Menu", shortcut: $draft.shortcutOpenActions)
                    Text("Click a shortcut field and press the key combo. Press Delete to clear.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("SettingsTab-Shortcuts")
        .padding(.top, AppDockConstants.SettingsLayout.sectionTopPadding)
    }
}

private struct ShortcutRow: View {
    let title: String
    @Binding var shortcut: ShortcutDefinition?
    @State private var isEditing = false
    @State private var isHovering = false

    private var displayValue: String {
        guard let shortcut else { return "Record Shortcut" }
        return ShortcutFormatter.string(for: shortcut)
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            ZStack(alignment: .trailing) {
                ShortcutRecorder(
                    shortcut: $shortcut,
                    accessibilityIdentifier: AppDockConstants.Accessibility.shortcutRecorderPrefix + title,
                    isEditing: $isEditing
                )
                .accessibilityLabel(Text(title))

                if isHovering && shortcut != nil {
                    Button {
                        shortcut = nil
                        isEditing = false
                        NSApp.keyWindow?.makeFirstResponder(nil)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 6)
                    .accessibilityLabel(Text("Clear shortcut"))
                    .accessibilityIdentifier(AppDockConstants.Accessibility.shortcutRecorderCancelPrefix + title)
                }
            }
            .onContinuousHover { phase in
                switch phase {
                case .active:
                    isHovering = true
                case .ended:
                    isHovering = false
                }
            }
            .onContinuousHover { phase in
                switch phase {
                case .active:
                    isHovering = true
                case .ended:
                    isHovering = false
                }
            }
            .frame(width: 160)
            Text(displayValue)
                .font(.caption2)
                .foregroundColor(.clear)
                .frame(width: 1, height: 1)
                .accessibilityIdentifier(AppDockConstants.Accessibility.shortcutRecorderValuePrefix + title)
        }
        .onAppear {
            isEditing = false
        }
    }
}
