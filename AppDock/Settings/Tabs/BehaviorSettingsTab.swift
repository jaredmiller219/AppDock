/*
 BehaviorSettingsTab.swift
 AppDock

 PURPOSE:
 This view displays behavior and interaction preferences for AppDock.
 Allows users to customize how the dock responds to user actions.

 OVERVIEW:
 BehaviorSettingsTab contains five toggles controlling app behavior:
 - Show app labels: Display text names below app icons (vs icons only)
 - Show running indicator: Visual indicator showing which apps are currently running
 - Enable hover remove button: Show delete button when hovering over an app
 - Confirm before quitting apps: Ask for confirmation before terminating applications
 - Keep apps after quit: Keep quit/terminated apps in the dock list or remove them

 All options affect the dock's real-time behavior during use.

 STYLING:
 - Standard Toggle controls within GroupBox
 - Consistent spacing and accessibility identifiers
*/

import SwiftUI

/// Settings tab for dock behavior and user interaction preferences.
///
/// Displays toggles for app labels, running indicators, hover remove,
/// quit confirmation, and app retention after quit.
struct BehaviorSettingsTab: View {
    /// Binding to settings draft being edited
    @Binding var draft: SettingsDraft

    var body: some View {
        VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
            GroupBox("Behavior") {
                VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
                    Toggle("Show app labels", isOn: $draft.showAppLabels)
                    Toggle("Show running indicator", isOn: $draft.showRunningIndicator)
                    Toggle("Enable hover remove button", isOn: $draft.enableHoverRemove)
                    Toggle("Confirm before quitting apps", isOn: $draft.confirmBeforeQuit)
                    Toggle("Keep apps after quit", isOn: $draft.keepQuitApps)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("SettingsTab-Behavior")
        .padding(.top, AppDockConstants.SettingsLayout.sectionTopPadding)
    }
}
