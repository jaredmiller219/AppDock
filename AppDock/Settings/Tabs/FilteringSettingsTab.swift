/*
 FilteringSettingsTab.swift
 AppDock

 PURPOSE:
 This view displays default filtering and sorting preferences.
 Allows users to set which apps appear by default and how they are ordered.

 OVERVIEW:
 FilteringSettingsTab contains two menu pickers:
 - Default filter: Choose which apps to show (all running, or hidden only)
 - Default sort order: Choose how to order displayed apps (by name, recency, etc.)
 
 These settings establish the initial filter/sort state when the app launches.
 Users can still change the filter/sort in the dock menu during use.

 STYLING:
 - Menu-style pickers for compact presentation
 - Options pulled from AppFilterOption and AppSortOption enums
 - Consistent spacing and padding from AppDockConstants
*/

import SwiftUI

/// Settings tab for default filter and sort order preferences.
/// 
/// Displays menu pickers for choosing default app filter (all/running/hidden)
/// and default sort order (name/recency/etc.).
struct FilteringSettingsTab: View {
    /// Binding to settings draft being edited
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
