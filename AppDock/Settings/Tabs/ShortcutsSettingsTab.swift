//
//  ShortcutsSettingsTab.swift
//  AppDock
//

import SwiftUI
import AppKit

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
    @State private var isEditing = false

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

                if isEditing {
                    Button {
                        isEditing = false
                        NSApp.keyWindow?.makeFirstResponder(nil)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 6)
                    .accessibilityLabel(Text("Cancel recording"))
                    .accessibilityIdentifier(AppDockConstants.Accessibility.shortcutRecorderCancelPrefix + title)
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
