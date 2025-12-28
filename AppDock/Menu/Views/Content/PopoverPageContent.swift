//
//  PopoverPageContent.swift
//  AppDock
//

import SwiftUI

struct PopoverPageContent: View {
    let page: MenuPage
    let appState: AppState
    let settingsAction: () -> Void
    let aboutAction: () -> Void
    let quitAction: () -> Void
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
