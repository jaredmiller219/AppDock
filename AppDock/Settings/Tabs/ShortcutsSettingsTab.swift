//
//  ShortcutsSettingsTab.swift
//  AppDock
//

import SwiftUI

struct ShortcutsSettingsTab: View {
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

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            ShortcutRecorder(shortcut: $shortcut)
                .frame(width: 160)
                .accessibilityLabel(Text(title))
                .accessibilityIdentifier(AppDockConstants.Accessibility.shortcutRecorderPrefix + title)
        }
    }
}
