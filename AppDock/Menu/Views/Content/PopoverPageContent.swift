/*
 PopoverPageContent.swift
 AppDock

 PURPOSE:
 This view is responsible for rendering the content of each menu page (dock, recents, favorites, actions).
 It acts as a content factory that displays different views based on the selected MenuPage.

 OVERVIEW:
 PopoverPageContent is a generic View that handles the layout and content display for four distinct
 menu pages. Each page has its own layout, padding, empty states, and behavior. When a page appears,
 it triggers an onPageAppear callback to notify the system.

 INTEGRATION:
 - Used by PopoverContentView to display page-specific content
 - Observes MenuState to know which page to display
 - Displays DockView (filtered apps), MenuAppListView (recents), MenuEmptyState (favorites), or action menu rows
 - Calls onPageAppear callback when pages become visible
*/

import SwiftUI

/// Renders the content view for a specific menu page (dock, recents, favorites, or actions).
/// 
/// This struct handles the layout and display of different content based on the page type,
/// including empty states, padding, and page appearance callbacks.
struct PopoverPageContent: View {
    /// The menu page to display (dock, recents, favorites, or actions)
    let page: MenuPage
    
    /// Reference to shared application state for dock content
    let appState: AppState
    
    /// Callback triggered when Settings is selected from action menu
    let settingsAction: () -> Void
    
    /// Callback triggered when About is selected from action menu
    let aboutAction: () -> Void
    
    /// Callback triggered when Quit is selected from action menu
    let quitAction: () -> Void
    
    /// Callback triggered when the page becomes visible to update page appearance tracking
    let onPageAppear: (MenuPage) -> Void

    var body: some View {
        Group {
            switch page {
            case .dock:
                ScrollView(showsIndicators: false) {
                    DockView(appState: appState)
                        .padding(.horizontal, AppDockConstants.MenuLayout.dockPaddingHorizontal)
                        .padding(.top, AppDockConstants.MenuLayout.dockPaddingTop)
                        .padding(.bottom, AppDockConstants.MenuLayout.dockPaddingBottom)
                }
                .onAppear { onPageAppear(.dock) }
            case .recents:
                ScrollView(showsIndicators: false) {
                    MenuAppListView(
                        title: "Recent Apps",
                        apps: appState.recentApps,
                        emptyTitle: "No Recent Apps",
                        emptyMessage: "Launch an app to see it here.",
                        emptySystemImage: "clock.arrow.circlepath",
                        appState: appState
                    )
                    .padding(.horizontal, AppDockConstants.MenuLayout.recentsPaddingHorizontal)
                    .padding(.top, AppDockConstants.MenuLayout.recentsPaddingTop)
                    .padding(.bottom, AppDockConstants.MenuLayout.recentsPaddingBottom)
                }
                .onAppear { onPageAppear(.recents) }
            case .favorites:
                ScrollView(showsIndicators: false) {
                    MenuEmptyState(
                        title: "No Favorites Yet",
                        message: "Pin apps to keep them on this page.",
                        systemImage: "star"
                    )
                    .accessibilityIdentifier(AppDockConstants.Accessibility.favoritesEmptyState)
                    .padding(.horizontal, AppDockConstants.MenuLayout.favoritesPaddingHorizontal)
                    .padding(.top, AppDockConstants.MenuLayout.favoritesPaddingTop)
                    .padding(.bottom, AppDockConstants.MenuLayout.favoritesPaddingBottom)
                }
                .onAppear { onPageAppear(.favorites) }
            case .actions:
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        MenuRow(title: "Settings", action: settingsAction)
                        Divider()
                        MenuRow(title: "About", action: aboutAction)
                        Divider()
                        MenuRow(title: "Quit AppDock", action: quitAction)
                    }
                    .padding(.horizontal, AppDockConstants.MenuLayout.actionsPaddingHorizontal)
                    .padding(.top, AppDockConstants.MenuLayout.actionsPaddingTop)
                    .padding(.bottom, AppDockConstants.MenuLayout.actionsPaddingBottom)
                }
                .onAppear { onPageAppear(.actions) }
            }
        }
        .frame(maxHeight: .infinity)
    }
}
