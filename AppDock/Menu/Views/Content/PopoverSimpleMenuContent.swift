/*
 PopoverSimpleMenuContent.swift
 AppDock

 PURPOSE:
 This view provides the simple (single-page) menu layout without paging or swipe navigation.
 It displays the dock view with filter button in a single, static layout.

 OVERVIEW:
 PopoverSimpleMenuContent is a minimal container that shows:
 - FilterMenuButton at top for app filtering
 - DockView in scrollable middle area
 - Essential action menu (Settings/About/Quit) at bottom
 - "More Options" dropdown for additional actions (Keyboard Shortcuts/Help/Release Notes/App Groups)
 - No page navigation or gesture handling

 KEY FEATURES:
 - Static single-page layout
 - Maximizes vertical space for dock content
 - Essential actions always visible, secondary actions in dropdown
 - Consistent padding matching other menu layouts
 - Dropdown menu with hover feedback matching MenuRow styling

 INTEGRATION:
 - Used by PopoverContentView in simple menu layout mode
 - Observes AppState for dock content and filtering
 - No gesture handling; callbacks not needed
*/

import SwiftUI

/// Simple menu layout without paging—displays dock, filter button, and action menu in single view.
/// 
/// Minimal layout for users who prefer a single-page menu without swipe navigation.
/// Focuses on dock content with filter controls and system actions.
struct PopoverSimpleMenuContent: View {
    /// Reference to shared app state for dock content and filtering
    let appState: AppState
    
    /// Callback triggered when Settings is selected
    let settingsAction: () -> Void
    
    /// Callback triggered when About is selected
    let aboutAction: () -> Void
    
    /// Callback triggered when Keyboard Shortcuts is selected
    let shortcutsAction: () -> Void
    
    /// Callback triggered when Help is selected
    let helpAction: () -> Void
    
    /// Callback triggered when Release Notes is selected
    let releaseNotesAction: () -> Void
    
    /// Callback triggered when App Groups is selected
    let appGroupsAction: () -> Void
    
    /// Callback triggered when Quit is selected
    let quitAction: () -> Void
    
    /// Local state tracking whether mouse is hovering over "More Options" menu
    @State private var isHoveringMoreOptions = false

    var body: some View {
        VStack(spacing: 0) {
            FilterMenuButton(appState: appState)
                .padding(.horizontal, AppDockConstants.MenuLayout.headerPaddingHorizontal)
                .padding(.top, AppDockConstants.MenuLayout.headerPaddingTop)
                .padding(.bottom, AppDockConstants.MenuLayout.headerPaddingBottom)

            Divider()
                .padding(.horizontal, AppDockConstants.MenuLayout.dividerPaddingHorizontal)

            ScrollView(showsIndicators: false) {
                DockView(appState: appState)
                    .padding(.horizontal, AppDockConstants.MenuLayout.dockPaddingHorizontal)
                    .padding(.top, AppDockConstants.MenuLayout.dockPaddingTop)
                    .padding(.bottom, AppDockConstants.MenuLayout.dockPaddingBottom)
            }
            .frame(maxHeight: .infinity)
            .layoutPriority(1)

            Divider()
                .padding(.horizontal, AppDockConstants.MenuLayout.dividerPaddingHorizontal)
                .padding(.top, AppDockConstants.MenuLayout.bottomDividerPaddingTop)

            VStack(spacing: 0) {
                MenuRow(title: "Settings", action: settingsAction)
                Divider()
                MenuRow(title: "About", action: aboutAction)
                Divider()
                MenuRow(title: "Quit AppDock", action: quitAction)
                Divider()
                Menu {
                    Button("Keyboard Shortcuts", action: shortcutsAction)
                    Button("Help", action: helpAction)
                    Button("Release Notes", action: releaseNotesAction)
                    Button("App Groups", action: appGroupsAction)
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text("More Options")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, AppDockConstants.MenuRow.paddingHorizontal)
                    .padding(.vertical, AppDockConstants.MenuRow.paddingVertical)
                    .background(
                        RoundedRectangle(cornerRadius: AppDockConstants.MenuRow.cornerRadius)
                            .fill(isHoveringMoreOptions ? Color.primary.opacity(0.08) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .contentShape(RoundedRectangle(cornerRadius: AppDockConstants.MenuRow.cornerRadius))
                .accessibilityIdentifier(AppDockConstants.Accessibility.menuRowPrefix + "More Options")
                .accessibilityLabel(Text("More Options"))
                .accessibilityHint(Text("Activate More Options"))
                .onHover { hovering in
                    isHoveringMoreOptions = hovering
                }
            }
            .padding(.top, AppDockConstants.MenuLayout.actionsPaddingTop)
            .padding(.bottom, AppDockConstants.MenuLayout.actionsPaddingBottom)
        }
    }
}
