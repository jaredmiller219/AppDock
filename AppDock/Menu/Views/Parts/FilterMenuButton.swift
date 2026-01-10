/*
 FilterMenuButton.swift
 AppDock

 PURPOSE:
 This view provides a dropdown menu for filtering and sorting displayed applications.
 Allows users to control which apps appear (all/running/hidden) and how they are ordered.

 OVERVIEW:
 FilterMenuButton is a Menu button containing two Picker controls:
 - Show filter: Select between showing all apps, only running apps, or only hidden apps
 - Sort option: Choose how apps are ordered (by name, by recent use, etc.)

 The selected options are bound to AppState properties and persist via UserDefaults.

 STYLING:
 - Uses gear icon with label text
 - Rounded rectangle background matching MenuPageHeader style
 - Caption font for compact menu bar display
 - System Menu styling for native macOS appearance

 ACCESSIBILITY:
 - Accessibility identifier for testing
 - Label and hint describing filter/sort function
*/

import SwiftUI

/// Dropdown menu for filtering and sorting applications shown in the dock.
///
/// Provides Picker controls for Show (all/running/hidden) and Sort options,
/// with selections persisted to AppState and UserDefaults.
struct FilterMenuButton: View {
    /// Reference to shared app state for reading/writing filter and sort selections
    @ObservedObject var appState: AppState

    var body: some View {
        Menu {
            Picker("Show", selection: $appState.filterOption) {
                ForEach(AppFilterOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            Divider()
            Picker("Sort", selection: $appState.sortOption) {
                ForEach(AppSortOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
        } label: {
            HStack {
                Label("Filter & Sort", systemImage: "line.3.horizontal.decrease.circle")
                    .font(.caption)
                Spacer()
            }
            .padding(.horizontal, AppDockConstants.MenuHeader.paddingHorizontal)
            .padding(.vertical, AppDockConstants.MenuHeader.paddingVertical)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppDockConstants.MenuHeader.cornerRadius)
                    .fill(Color.primary.opacity(0.08))
            )
        }
        .accessibilityIdentifier(AppDockConstants.Accessibility.dockFilterMenu)
        .accessibilityLabel(Text("Filter and sort"))
        .accessibilityHint(Text("Choose which apps to show and how to sort them"))
    }
}
