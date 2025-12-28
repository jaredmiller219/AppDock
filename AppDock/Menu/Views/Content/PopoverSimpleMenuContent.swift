//
//  PopoverSimpleMenuContent.swift
//  AppDock
//

import SwiftUI

struct PopoverSimpleMenuContent: View {
    let appState: AppState
    let settingsAction: () -> Void
    let aboutAction: () -> Void
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
