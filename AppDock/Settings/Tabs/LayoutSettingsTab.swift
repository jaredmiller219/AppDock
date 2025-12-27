//
//  LayoutSettingsTab.swift
//  AppDock
//

import SwiftUI

struct LayoutSettingsTab: View {
    @Binding var draft: SettingsDraft

    var body: some View {
        VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
            GroupBox("Menu Layout") {
                VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
                    Picker("Menu layout", selection: $draft.menuLayoutMode) {
                        ForEach(MenuLayoutMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GroupBox("Dock Layout") {
                VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
                    Stepper(
                        value: $draft.gridColumns,
                        in: AppDockConstants.SettingsRanges.gridColumnsMin...AppDockConstants.SettingsRanges.gridColumnsMax
                    ) {
                        HStack {
                            Text("Columns")
                            Spacer()
                            Text("\(draft.gridColumns)")
                                .foregroundColor(.secondary)
                        }
                    }
                    Stepper(
                        value: $draft.gridRows,
                        in: AppDockConstants.SettingsRanges.gridRowsMin...AppDockConstants.SettingsRanges.gridRowsMax
                    ) {
                        HStack {
                            Text("Rows")
                            Spacer()
                            Text("\(draft.gridRows)")
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        Text("Icon size")
                        Slider(
                            value: $draft.iconSize,
                            in: AppDockConstants.SettingsRanges.iconSizeMin...AppDockConstants.SettingsRanges.iconSizeMax,
                            step: AppDockConstants.SettingsRanges.iconSizeStep
                        )
                        Text("\(Int(draft.iconSize))")
                            .frame(width: AppDockConstants.SettingsLayout.valueLabelWidth, alignment: .trailing)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Label size")
                        Slider(
                            value: $draft.labelSize,
                            in: AppDockConstants.SettingsRanges.labelSizeMin...AppDockConstants.SettingsRanges.labelSizeMax,
                            step: AppDockConstants.SettingsRanges.labelSizeStep
                        )
                        Text("\(Int(draft.labelSize))")
                            .frame(width: AppDockConstants.SettingsLayout.valueLabelWidth, alignment: .trailing)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("SettingsTab-Layout")
        .padding(.top, AppDockConstants.SettingsLayout.sectionTopPadding)
    }
}
