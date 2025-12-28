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
 - Action menu (Settings/About/Quit) at bottom
 - No page navigation or gesture handling

 KEY FEATURES:
 - Static single-page layout
 - Maximizes vertical space for dock content
 - Includes top and bottom dividers for visual separation
 - Consistent padding matching other menu layouts

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
    
    /// Callback triggered when Quit is selected
    let quitAction: () -> Void

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
            }
            .padding(.top, AppDockConstants.MenuLayout.actionsPaddingTop)
            .padding(.bottom, AppDockConstants.MenuLayout.actionsPaddingBottom)
        }
    }
}
