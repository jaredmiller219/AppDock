/*
 LayoutSettingsTab.swift
 AppDock

 PURPOSE:
 This view displays layout configuration for the dock menu and app grid.
 Allows users to customize how the dock appears and how apps are sized.

 OVERVIEW:
 LayoutSettingsTab contains two main sections:

 1. Menu Layout
 - Segmented picker to choose between Simple (single-page) and Advanced (paged) menu modes
 
 2. Dock Layout
 - Stepper to adjust grid columns (min/max defined in constants)
 - Stepper to adjust grid rows
 - Slider for app icon size with numeric display
 - Slider for app label size with numeric display
 
 All changes update the SettingsDraft binding and are applied when Apply is pressed.

 STYLING:
 - Segmented picker for mode selection (simple/advanced)
 - Stepper controls for discrete values
 - Sliders with trailing numeric value display for continuous sizing
*/

import SwiftUI

/// Settings tab for menu layout and dock grid customization.
/// 
/// Provides controls for choosing menu layout mode (Simple/Advanced) and adjusting
/// grid dimensions and icon/label sizing.
struct LayoutSettingsTab: View {
    /// Binding to settings draft being edited
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
                    .accessibilityIdentifier(AppDockConstants.Accessibility.settingsMenuLayoutPicker)

                    Text("Menu Layout Picker")
                        .font(.caption2)
                        .foregroundColor(.clear)
                        .frame(width: 1, height: 1)
                        .accessibilityIdentifier(AppDockConstants.Accessibility.settingsMenuLayoutPicker)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GroupBox("Dock Layout") {
                VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
                    Stepper(
                        value: $draft.gridColumns,
                        in: AppDockConstants.SettingsRanges.gridColumnsMin ... AppDockConstants.SettingsRanges.gridColumnsMax
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
                        in: AppDockConstants.SettingsRanges.gridRowsMin ... AppDockConstants.SettingsRanges.gridRowsMax
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
                            in: AppDockConstants.SettingsRanges.iconSizeMin ... AppDockConstants.SettingsRanges.iconSizeMax,
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
                            in: AppDockConstants.SettingsRanges.labelSizeMin ... AppDockConstants.SettingsRanges.labelSizeMax,
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
