//
//  FilteringSettingsTab.swift
//  AppDock
//

import SwiftUI

struct FilteringSettingsTab: View {
    @Binding var draft: SettingsDraft

    var body: some View {
        VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
            GroupBox("Filtering & Sorting") {
                VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
                    HStack {
                        Text("Default filter")
                        Spacer()
                        Picker("", selection: $draft.defaultFilter) {
                            ForEach(AppFilterOption.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                    }
                    HStack {
                        Text("Default sort order")
                        Spacer()
                        Picker("", selection: $draft.defaultSort) {
                            ForEach(AppSortOption.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("SettingsTab-Filtering")
        .padding(.top, AppDockConstants.SettingsLayout.sectionTopPadding)
    }
}
