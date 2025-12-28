/*
 GeneralSettingsTab.swift
 AppDock

 PURPOSE:
 This view displays general application preferences for AppDock.
 Allows users to configure launch behavior and update settings.

 OVERVIEW:
 GeneralSettingsTab contains three main toggles:
 - Launch at login: Start AppDock automatically when the Mac boots
 - Open dock on startup: Show the menu popover when AppDock first launches
 - Check for updates automatically: Download and install updates without user confirmation
 
 All options update the SettingsDraft binding when changed.

 STYLING:
 - Uses system GroupBox with standard settings layout
 - Consistent padding and spacing from AppDockConstants
*/

import SwiftUI

/// Settings tab for general application preferences and launch behavior.
/// 
/// Displays toggles for launch at login, open on startup, and automatic updates.
struct GeneralSettingsTab: View {
    /// Binding to settings draft being edited
    @Binding var draft: SettingsDraft

    var body: some View {
        VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
            GroupBox("General") {
                VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
                    Toggle("Launch at login", isOn: $draft.launchAtLogin)
                    Toggle("Open dock on startup", isOn: $draft.openOnStartup)
                    Toggle("Check for updates automatically", isOn: $draft.autoUpdates)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("SettingsTab-General")
        .padding(.top, AppDockConstants.SettingsLayout.sectionTopPadding)
    }
}
