/*
 AdvancedSettingsTab.swift
 AppDock

 PURPOSE:
 This view displays power-user and debugging settings.
 Allows advanced configuration of the Settings UI layout and debug logging.

 OVERVIEW:
 AdvancedSettingsTab contains two toggles:
 - Use advanced settings layout: Switch between sidebar+tabs vs stacked single-page layout
   for Settings window itself (not to be confused with menu layout mode)
 - Enable debug logging: Send verbose log messages to system logger for troubleshooting
 
 The "Use advanced settings layout" toggle inverts the simpleSettings property
 (when toggle is ON, simpleSettings is OFF, using advanced mode).

 STYLING:
 - Standard Toggle controls within GroupBox
 - Minimal settings focusing on workflow preferences
 - Consistent spacing and accessibility identifiers

 NOTE:
 The "advanced settings layout" toggle controls the Settings window presentation,
 while MenuLayoutMode (in LayoutSettingsTab) controls the dock menu layout.
*/

import SwiftUI

/// Settings tab for advanced options and debugging features.
/// 
/// Displays toggles for settings window layout mode (Simple/Advanced sidebar)
/// and debug logging for troubleshooting.
struct AdvancedSettingsTab: View {
    /// Binding to settings draft being edited
    @Binding var draft: SettingsDraft

    private var useAdvancedLayout: Binding<Bool> {
        Binding(
            get: { !draft.simpleSettings },
            set: { draft.simpleSettings = !$0 }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
            GroupBox("Advanced") {
                VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
                    Toggle("Use advanced settings layout", isOn: useAdvancedLayout)
                    Toggle("Enable debug logging", isOn: $draft.debugLogging)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("SettingsTab-Advanced")
        .padding(.top, AppDockConstants.SettingsLayout.sectionTopPadding)
    }
}
