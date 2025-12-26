//
//  SettingsView.swift
//  AppDock
//

import SwiftUI

/// Settings UI with staged changes and an explicit Apply action.
struct SettingsView: View {
    private enum SettingsTab: String, CaseIterable, Identifiable {
        case general
        case layout
        case filtering
        case behavior
        case accessibility
        case advanced

        var id: String { rawValue }

        var title: String {
            switch self {
            case .general: return "General"
            case .layout: return "Layout"
            case .filtering: return "Filtering"
            case .behavior: return "Behavior"
            case .accessibility: return "Accessibility"
            case .advanced: return "Advanced"
            }
        }

        var systemImage: String {
            switch self {
            case .general: return "gearshape"
            case .layout: return "square.grid.3x3"
            case .filtering: return "line.3.horizontal.decrease.circle"
            case .behavior: return "hand.tap"
            case .accessibility: return "figure.walk"
            case .advanced: return "wrench.and.screwdriver"
            }
        }
    }

    @ObservedObject var appState: AppState
    @State private var draft: SettingsDraft
    @State private var selectedTab: SettingsTab = .general
    @AppStorage(SettingsDefaults.simpleSettingsKey) private var useSimpleSettings = SettingsDefaults.simpleSettingsDefault

    init(appState: AppState) {
        self.appState = appState
        // Load staged values from UserDefaults when the settings UI is created.
        _draft = State(initialValue: SettingsDraft.load())
    }

    private let accentColor: Color = .blue

    /// Writes draft values to disk and applies them immediately to the live UI.
    private func applySettings() {
        draft.apply()
        appState.applySettings(draft)
    }

    /// Persists draft values without changing the live in-memory settings.
    private func saveAsDefault() {
        draft.apply()
    }

    /// Restores default values, updates the draft, and refreshes the live state.
    private func restoreDefaults() {
        SettingsDefaults.restore()
        draft = SettingsDraft.load()
        appState.applySettings(draft)
    }

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.contentSpacing) {
                HStack(spacing: AppDockConstants.SettingsLayout.headerSpacing) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.15))
                        Image(systemName: "gearshape.2.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: AppDockConstants.SettingsLayout.headerIconFontSize, weight: .semibold))
                    }
                    .frame(
                        width: AppDockConstants.SettingsLayout.headerIconSize,
                        height: AppDockConstants.SettingsLayout.headerIconSize
                    )

                    VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.headerTextSpacing) {
                        Text("Settings")
                            .font(.title2)
                            .bold()
                        Text("Configure AppDock preferences.")
                            .foregroundColor(.secondary)
                    }
                }

                HStack(spacing: AppDockConstants.SettingsLayout.contentColumnSpacing) {
                    if !useSimpleSettings {
                        VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sidebarSpacing) {
                            ForEach(SettingsTab.allCases) { tab in
                                Button {
                                    selectedTab = tab
                                } label: {
                                    HStack(spacing: AppDockConstants.SettingsLayout.tabRowSpacing) {
                                        Image(systemName: tab.systemImage)
                                            .frame(width: AppDockConstants.SettingsLayout.tabIconWidth)
                                        Text(tab.title)
                                        Spacer()
                                    }
                                    .padding(.vertical, AppDockConstants.SettingsLayout.tabButtonPaddingVertical)
                                    .padding(.horizontal, AppDockConstants.SettingsLayout.tabButtonPaddingHorizontal)
                                    .background(
                                        RoundedRectangle(cornerRadius: AppDockConstants.SettingsLayout.tabButtonCornerRadius)
                                            .fill(selectedTab == tab ? Color.accentColor.opacity(0.15) : Color.clear)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            Spacer()
                        }
                        .frame(width: AppDockConstants.SettingsUI.sidebarWidth)
                    }

                    ScrollView {
                        if useSimpleSettings {
                            simpleSettingsContent
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            settingsTabContent
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .topLeading)
                .tint(accentColor)
                .onAppear {
                    draft = SettingsDraft.load()
                }

                HStack {
                    Menu {
                        Button("Restore Defaults") {
                            restoreDefaults()
                        }
                        Button("Set as Default") {
                            saveAsDefault()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Settings Actions")

                    Spacer()

                    Button("Apply") {
                        applySettings()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(draft == SettingsDraft.from(appState: appState))
                }
            }
            .padding(AppDockConstants.SettingsLayout.rootPadding)
            .frame(maxHeight: .infinity, alignment: .topLeading)
        }
        .groupBoxStyle(CardGroupBoxStyle())
        .frame(
            minWidth: AppDockConstants.SettingsUI.minWidth,
            minHeight: AppDockConstants.SettingsUI.minHeight,
            alignment: .topLeading
        )
    }
}

private extension SettingsView {
	@ViewBuilder
	var settingsTabContent: some View {
		switch selectedTab {
		case .general:
			GeneralSettingsTab(draft: $draft, useSimpleSettings: $useSimpleSettings)
		case .layout:
			LayoutSettingsTab(draft: $draft)
		case .filtering:
			FilteringSettingsTab(draft: $draft)
		case .behavior:
			BehaviorSettingsTab(draft: $draft)
		case .accessibility:
			AccessibilitySettingsTab(draft: $draft)
		case .advanced:
			AdvancedSettingsTab(draft: $draft)
		}
	}
	
	var simpleSettingsContent: some View {
		VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
			GeneralSettingsTab(draft: $draft, useSimpleSettings: $useSimpleSettings)
			LayoutSettingsTab(draft: $draft)
			FilteringSettingsTab(draft: $draft)
			BehaviorSettingsTab(draft: $draft)
			AccessibilitySettingsTab(draft: $draft)
			AdvancedSettingsTab(draft: $draft)
		}
		.padding(.top, AppDockConstants.SettingsLayout.simpleContentTopPadding)
	}
	
	private struct GeneralSettingsTab: View {
		@Binding var draft: SettingsDraft
		@Binding var useSimpleSettings: Bool

		private var useAdvancedLayout: Binding<Bool> {
			Binding(
				get: { !useSimpleSettings },
				set: { useSimpleSettings = !$0 }
			)
		}
		
		var body: some View {
			VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
				GroupBox("Settings Layout") {
					VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
						Toggle("Use advanced settings layout", isOn: useAdvancedLayout)
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}

				GroupBox("General") {
					VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
						Toggle("Launch at login", isOn: $draft.launchAtLogin)
						Toggle("Open dock on startup", isOn: $draft.openOnStartup)
						Toggle("Check for updates automatically", isOn: $draft.autoUpdates)
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.accessibilityIdentifier("SettingsTab-General")
			.padding(.top, AppDockConstants.SettingsLayout.sectionTopPadding)
		}
	}
	
	private struct LayoutSettingsTab: View {
		@Binding var draft: SettingsDraft
		
		var body: some View {
			VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
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
	
	private struct FilteringSettingsTab: View {
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
	
	private struct BehaviorSettingsTab: View {
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
	
	private struct AccessibilitySettingsTab: View {
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
	
	private struct AdvancedSettingsTab: View {
		@Binding var draft: SettingsDraft
		
		var body: some View {
			VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
				GroupBox("Advanced") {
					VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
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
	
	//#Preview {
	//    SettingsView(appState: .init())
	//}
}
