//
//  MenuAppListView.swift
//  AppDock
//

import SwiftUI

struct MenuAppListView: View {
    let title: String
    let apps: [AppState.AppEntry]
    let emptyTitle: String
    let emptyMessage: String
    let emptySystemImage: String
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
