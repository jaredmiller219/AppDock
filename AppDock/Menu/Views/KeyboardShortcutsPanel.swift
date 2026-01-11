//
//  KeyboardShortcutsPanel.swift
//  AppDock
//
//  Comprehensive keyboard shortcuts reference panel
//

import SwiftUI

/// Keyboard shortcuts panel showing all available shortcuts
struct KeyboardShortcutsPanel: View {
    @Environment(\.dismiss) private var dismiss

    private let shortcuts: [ShortcutSection] = [
        ShortcutSection(
            title: "Menu Navigation",
            shortcuts: [
                ShortcutItem(key: "⌘1", description: "Open Dock page"),
                ShortcutItem(key: "⌘2", description: "Open Recents page"),
                ShortcutItem(key: "⌘3", description: "Open Favorites page"),
                ShortcutItem(key: "⌘4", description: "Open Menu page"),
                ShortcutItem(key: "←", description: "Previous page"),
                ShortcutItem(key: "→", description: "Next page"),
                ShortcutItem(key: "⌘[", description: "Previous page"),
                ShortcutItem(key: "⌘]", description: "Next page")
            ]
        ),
        ShortcutSection(
            title: "App Management",
            shortcuts: [
                ShortcutItem(key: "⌘+Click", description: "Show context menu"),
                ShortcutItem(key: "⌥+Click", description: "Hide app"),
                ShortcutItem(key: "⌘⌥+Click", description: "Force quit app"),
                ShortcutItem(key: "Space", description: "Launch selected app"),
                ShortcutItem(key: "Enter", description: "Launch selected app"),
                ShortcutItem(key: "⌫", description: "Remove from dock"),
                ShortcutItem(key: "⌘⌫", description: "Force remove from dock")
            ]
        ),
        ShortcutSection(
            title: "Search & Filter",
            shortcuts: [
                ShortcutItem(key: "⌘F", description: "Focus search"),
                ShortcutItem(key: "/", description: "Focus search"),
                ShortcutItem(key: "⌘1", description: "Show all apps"),
                ShortcutItem(key: "⌘2", description: "Show running only"),
                ShortcutItem(key: "⌘R", description: "Sort by recent"),
                ShortcutItem(key: "⌘N", description: "Sort by name"),
                ShortcutItem(key: "Esc", description: "Clear search")
            ]
        ),
        ShortcutSection(
            title: "Selection",
            shortcuts: [
                ShortcutItem(key: "↑↓", description: "Navigate apps"),
                ShortcutItem(key: "←→", description: "Navigate pages"),
                ShortcutItem(key: "Tab", description: "Next section"),
                ShortcutItem(key: "⇧Tab", description: "Previous section"),
                ShortcutItem(key: "Home", description: "First app"),
                ShortcutItem(key: "End", description: "Last app"),
                ShortcutItem(key: "⌘A", description: "Select all"),
                ShortcutItem(key: "⌘D", description: "Deselect all")
            ]
        ),
        ShortcutSection(
            title: "Window Management",
            shortcuts: [
                ShortcutItem(key: "⌘W", description: "Close popover"),
                ShortcutItem(key: "Esc", description: "Close popover"),
                ShortcutItem(key: "⌘M", description: "Minimize to menu bar"),
                ShortcutItem(key: "⌘,", description: "Open Settings"),
                ShortcutItem(key: "⌘?", description: "Show help"),
                ShortcutItem(key: "F1", description: "Show keyboard shortcuts")
            ]
        ),
        ShortcutSection(
            title: "System Integration",
            shortcuts: [
                ShortcutItem(key: "⌘⌥D", description: "Show/Hide Dock"),
                ShortcutItem(key: "⌘⌥F", description: "Toggle Focus Mode"),
                ShortcutItem(key: "⌘⌥S", description: "Toggle Search"),
                ShortcutItem(key: "⌘⌥P", description: "Toggle Preferences"),
                ShortcutItem(key: "⌘⌥Q", description: "Quit AppDock")
            ]
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Keyboard Shortcuts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    headerView

                    ForEach(shortcuts) { section in
                        ShortcutSectionView(section: section)
                    }

                    footerView
                }
                .padding()
            }
        }
        .frame(minWidth: 500, minHeight: 600)
    }

    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "keyboard")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("Keyboard Shortcuts")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Master AppDock with these keyboard shortcuts")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 24)
    }

    private var footerView: some View {
        VStack(spacing: 12) {
            Divider()

            Text("Tips")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                Text("• Hold ⌘ for quick page navigation")
                Text("• Use ⌘+Click for context menus")
                Text("• Press Space or Enter to launch apps")
                Text("• Type while popover is open to search")
            }
            .font(.caption)
            .foregroundColor(.secondary)

            Text("Shortcuts can be customized in Settings → Shortcuts")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding(.top, 24)
    }
}

/// Data model for shortcut sections
struct ShortcutSection: Identifiable {
    let id = UUID()
    let title: String
    let shortcuts: [ShortcutItem]
}

/// Individual shortcut item
struct ShortcutItem: Identifiable {
    let id = UUID()
    let key: String
    let description: String
}

/// View for displaying a shortcut section
struct ShortcutSectionView: View {
    let section: ShortcutSection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.top, 16)

            VStack(spacing: 8) {
                ForEach(section.shortcuts) { shortcut in
                    ShortcutRowView(shortcut: shortcut)
                }
            }
        }
    }
}

/// View for displaying a single shortcut row
struct ShortcutRowView: View {
    let shortcut: ShortcutItem

    var body: some View {
        HStack {
            Text(shortcut.key)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.controlBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(.separatorColor), lineWidth: 1)
                        )
                )

            Text(shortcut.description)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
}

/// Preview provider for SwiftUI previews
struct KeyboardShortcutsPanel_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardShortcutsPanel()
    }
}
