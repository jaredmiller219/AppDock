/*
 MenuAppListView.swift
 AppDock

 PURPOSE:
 This view displays a scrollable list of applications with title, rows, and empty state handling.
 It serves as a reusable container for displaying any list of apps (recents, favorites, etc.).

 OVERVIEW:
 MenuAppListView combines a title, optional empty state, and app rows in a vertical stack.
 When the app list is empty, it shows an empty state with icon, title, and message.
 When apps exist, it renders MenuAppRow for each app in a vertical list.

 STYLING:
 - Title uses caption font and secondary foreground color
 - VStack uses consistent spacing from constants
 - Empty state centered with optional icon and message

 INTEGRATION:
 - Used by PopoverPageContent to display recents and favorites
 - Configurable title and empty state text for different contexts
 - Passes AppState to MenuAppRow for UI test hooks
*/

import SwiftUI

/// Displays a titled list of applications with empty state handling and app rows.
/// 
/// Reusable container that shows a section title, renders app entries as clickable rows,
/// and displays a custom empty state when the app list is empty.
struct MenuAppListView: View {
    /// Section title displayed above the app list (e.g., "Recent Apps")
    let title: String
    
    /// Array of app entries to display (name, bundleId, icon tuples)
    let apps: [AppState.AppEntry]
    
    /// Title shown when app list is empty
    let emptyTitle: String
    
    /// Message shown when app list is empty
    let emptyMessage: String
    
    /// SF Symbol name for empty state icon
    let emptySystemImage: String
    
    /// Reference to shared app state for UI test hooks
    let appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: AppDockConstants.MenuAppList.spacing) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            if apps.isEmpty {
                MenuEmptyState(
                    title: emptyTitle,
                    message: emptyMessage,
                    systemImage: emptySystemImage
                )
            } else {
                VStack(spacing: AppDockConstants.MenuAppList.rowSpacing) {
                    ForEach(Array(apps.enumerated()), id: \.offset) { _, app in
                        MenuAppRow(app: app, appState: appState)
                    }
                }
            }
        }
    }
}
