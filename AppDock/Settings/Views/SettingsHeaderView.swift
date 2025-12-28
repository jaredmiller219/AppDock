/*
 SettingsHeaderView.swift
 AppDock

 PURPOSE:
 This view displays the visual header for the Settings window with icon and title.
 Provides consistent branding and context for the settings interface.

 OVERVIEW:
 SettingsHeaderView shows:
 - A circular gray background with gear icon
 - Bold "Settings" title
 - Secondary text describing settings purpose
 
 Used at the top of the Settings window to establish context and visual hierarchy.

 STYLING:
 - Circular icon container with gray background
 - Bold title2 font for "Settings"
 - Secondary foreground color for description text
 - HStack layout with consistent spacing
*/

import SwiftUI

/// Header view for Settings window displaying title and icon.
/// 
/// Shows visual branding with gear icon and "Settings" title to establish
/// settings window context and visual hierarchy.
struct SettingsHeaderView: View {
    var body: some View {
        HStack(spacing: AppDockConstants.SettingsLayout.headerSpacing) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.15))
                Image(systemName: "gearshape.2.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: AppDockConstants.SettingsLayout.headerIconFontSize, weight: .semibold))
            }
            .frame(
                width: AppDockConstants.SettingsLayout.headerIconSize,
                height: AppDockConstants.SettingsLayout.headerIconSize
            )

            VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.headerTextSpacing) {
                Text("Settings")
                    .font(.title2)
                    .bold()
                Text("Configure AppDock preferences.")
                    .foregroundColor(.secondary)
            }
        }
    }
}
