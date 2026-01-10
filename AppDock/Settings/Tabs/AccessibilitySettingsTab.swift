/*
 AccessibilitySettingsTab.swift
 AppDock

 PURPOSE:
 This view displays accessibility settings for users with motion sensitivity.
 Currently provides option to disable animations for reduced motion preference.

 OVERVIEW:
 AccessibilitySettingsTab contains a single toggle:
 - Reduce motion: Disable page transition animations and other motion-based effects

 When enabled, disables animated page swaps, drag previews, and other kinetic effects
 to accommodate users who experience motion sickness or prefer static interfaces.

 STYLING:
 - Standard Toggle control within GroupBox
 - Consistent spacing and accessibility identifiers
 - Placeholder for future accessibility features
*/

import SwiftUI

/// Settings tab for accessibility preferences and motion sensitivity options.
///
/// Provides toggle for reducing motion/animations in the user interface.
struct AccessibilitySettingsTab: View {
    /// Binding to settings draft being edited
    @Binding var draft: SettingsDraft

    var body: some View {
        VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
            GroupBox("Accessibility") {
                VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
                    Toggle("Reduce motion", isOn: $draft.reduceMotion)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("SettingsTab-Accessibility")
        .padding(.top, AppDockConstants.SettingsLayout.sectionTopPadding)
    }
}
