//
//  SettingsContentView.swift
//  AppDock
//

import SwiftUI

struct SettingsContentView: View {
    let appliedSimpleSettings: Bool
    @Binding var draft: SettingsDraft
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
