/*
 SettingsContentView.swift
 AppDock

 PURPOSE:
 This view displays the main content area of the Settings window.
 Renders different settings tabs or all tabs stacked depending on layout mode.

 OVERVIEW:
 SettingsContentView handles two display modes:
 1. Simple layout (appliedSimpleSettings=true): Shows all tabs stacked vertically without sidebar
 2. Advanced layout (appliedSimpleSettings=false): Shows only the selected tab from sidebar

 Uses @ViewBuilder to dynamically create the appropriate tab view based on selection.
 Scrollable to accommodate tall settings panels.

 INTEGRATION:
 - Used by SettingsView to display settings content area
 - Observes selectedTab binding from sidebar
 - Edits SettingsDraft binding for user preferences
*/

import SwiftUI

/// Main content area displaying selected settings tab or all tabs in simple layout.
///
/// Renders either a single selected tab or all tabs stacked based on layout mode.
/// Handles both sidebar-based (advanced) and stacked (simple) layout presentations.
struct SettingsContentView: View {
    /// Whether simple layout (all tabs stacked) vs advanced (sidebar + tab selection)
    let appliedSimpleSettings: Bool

    /// Binding to settings draft being edited
    @Binding var draft: SettingsDraft

    /// Binding to currently selected settings tab in advanced mode
    @Binding var selectedTab: SettingsTab

    var body: some View {
        ScrollView {
            if appliedSimpleSettings {
                VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
                    GeneralSettingsTab(draft: $draft)
                    LayoutSettingsTab(draft: $draft)
                    FilteringSettingsTab(draft: $draft)
                    BehaviorSettingsTab(draft: $draft)
                    ShortcutsSettingsTab(draft: $draft)
                    AccessibilitySettingsTab(draft: $draft)
                    AdvancedSettingsTab(draft: $draft)
                }
                .padding(.top, AppDockConstants.SettingsLayout.simpleContentTopPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                settingsTabContent
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private var settingsTabContent: some View {
        switch selectedTab {
        case .general:
            GeneralSettingsTab(draft: $draft)
        case .layout:
            LayoutSettingsTab(draft: $draft)
        case .filtering:
            FilteringSettingsTab(draft: $draft)
        case .behavior:
            BehaviorSettingsTab(draft: $draft)
        case .shortcuts:
            ShortcutsSettingsTab(draft: $draft)
        case .accessibility:
            AccessibilitySettingsTab(draft: $draft)
        case .advanced:
            AdvancedSettingsTab(draft: $draft)
        }
    }
}
