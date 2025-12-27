//
//  BehaviorSettingsTab.swift
//  AppDock
//

import SwiftUI

struct BehaviorSettingsTab: View {
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
