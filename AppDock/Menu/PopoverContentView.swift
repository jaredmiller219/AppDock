//
//  PopoverContentView.swift
//  AppDock
//

import SwiftUI
import Foundation

/// Popover content for the menu bar window.
struct PopoverContentView: View {
    @ObservedObject var appState: AppState
    let settingsAction: () -> Void
    let aboutAction: () -> Void
    let quitAction: () -> Void
    @State private var previousPage: MenuPage = .dock

    private var popoverWidth: CGFloat {
        PopoverSizing.width(for: appState)
    }

    private var pageAnimation: Animation? {
        appState.reduceMotion ? nil : .easeInOut(duration: 0.22)
    }

    private var pageTransition: AnyTransition {
        guard !appState.reduceMotion else { return .opacity }
        let moveForward = appState.menuPage.orderIndex >= previousPage.orderIndex
        let insertion = AnyTransition.move(edge: moveForward ? .trailing : .leading)
            .combined(with: .opacity)
        let removal = AnyTransition.move(edge: moveForward ? .leading : .trailing)
            .combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }

    private func selectPage(_ page: MenuPage) {
        guard page != appState.menuPage else { return }
        previousPage = appState.menuPage
        if let animation = pageAnimation {
            withAnimation(animation) {
                appState.menuPage = page
            }
        } else {
            appState.menuPage = page
        }
    }

    private func handleSwipeDirection(_ direction: SwipeDirection) {
        let orderedPages = MenuPage.allCases.sorted { $0.orderIndex < $1.orderIndex }
        guard let currentIndex = orderedPages.firstIndex(of: appState.menuPage) else { return }
        let nextIndex = direction == .left ? currentIndex + 1 : currentIndex - 1
        guard orderedPages.indices.contains(nextIndex) else { return }
        selectPage(orderedPages[nextIndex])
    }

    private func handleDrag(_ value: DragGesture.Value) {
        let horizontal = value.translation.width
        let vertical = value.translation.height
        guard abs(horizontal) > abs(vertical),
              abs(horizontal) >= AppDockConstants.MenuGestures.swipeThreshold else { return }
        handleSwipeDirection(horizontal < 0 ? .left : .right)
    }

    var body: some View {
        VStack(spacing: 0) {
            if appState.menuLayoutMode == .simple {
                simpleMenuContent
            } else {
                advancedMenuContent
            }
        }
        .frame(width: popoverWidth, height: AppDockConstants.MenuPopover.height, alignment: .top)
        .simultaneousGesture(TapGesture().onEnded {
            NotificationCenter.default.post(name: .appDockDismissContextMenu, object: nil)
        })
        .onAppear {
            previousPage = appState.menuPage
        }
    }
}

private extension PopoverContentView {
    var simpleMenuContent: some View {
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
            .padding(.horizontal, AppDockConstants.MenuLayout.actionsPaddingHorizontal)
            .padding(.top, AppDockConstants.MenuLayout.actionsPaddingTop)
            .padding(.bottom, AppDockConstants.MenuLayout.actionsPaddingBottom)
        }
    }

    var advancedMenuContent: some View {
        VStack(spacing: 0) {
            Group {
                if appState.menuPage == .dock {
                    FilterMenuButton(appState: appState)
                } else {
                    MenuPageHeader(page: appState.menuPage)
                }
            }
            .padding(.horizontal, AppDockConstants.MenuLayout.headerPaddingHorizontal)
            .padding(.top, AppDockConstants.MenuLayout.headerPaddingTop)
            .padding(.bottom, AppDockConstants.MenuLayout.headerPaddingBottom)

            Divider()
                .padding(.horizontal, AppDockConstants.MenuLayout.dividerPaddingHorizontal)

            ZStack {
                switch appState.menuPage {
                case .dock:
                    ScrollView(showsIndicators: false) {
                        DockView(appState: appState)
                            .padding(.horizontal, AppDockConstants.MenuLayout.dockPaddingHorizontal)
                            .padding(.top, AppDockConstants.MenuLayout.dockPaddingTop)
                            .padding(.bottom, AppDockConstants.MenuLayout.dockPaddingBottom)
                    }
                    .frame(maxHeight: .infinity)
                    .transition(pageTransition)
                case .recents:
                    ScrollView(showsIndicators: false) {
                        MenuAppListView(
                            title: "Recent Apps",
                            apps: appState.recentApps,
                            emptyTitle: "No Recent Apps",
                            emptyMessage: "Launch an app to see it here.",
                            emptySystemImage: "clock.arrow.circlepath"
                        )
                        .padding(.horizontal, AppDockConstants.MenuLayout.recentsPaddingHorizontal)
                        .padding(.top, AppDockConstants.MenuLayout.recentsPaddingTop)
                        .padding(.bottom, AppDockConstants.MenuLayout.recentsPaddingBottom)
                    }
                    .frame(maxHeight: .infinity)
                    .transition(pageTransition)
                case .favorites:
                    ScrollView(showsIndicators: false) {
                        MenuEmptyState(
                            title: "No Favorites Yet",
                            message: "Pin apps to keep them on this page.",
                            systemImage: "star"
                        )
                        .padding(.horizontal, AppDockConstants.MenuLayout.favoritesPaddingHorizontal)
                        .padding(.top, AppDockConstants.MenuLayout.favoritesPaddingTop)
                        .padding(.bottom, AppDockConstants.MenuLayout.favoritesPaddingBottom)
                    }
                    .frame(maxHeight: .infinity)
                    .transition(pageTransition)
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
                    .frame(maxHeight: .infinity)
                    .transition(pageTransition)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .layoutPriority(1)

            Divider()
                .padding(.horizontal, AppDockConstants.MenuLayout.dividerPaddingHorizontal)
                .padding(.top, AppDockConstants.MenuLayout.bottomDividerPaddingTop)

            MenuPageBar(selectedPage: appState.menuPage, onSelect: selectPage)
                .padding(.horizontal, AppDockConstants.MenuLayout.bottomBarPaddingHorizontal)
                .padding(.bottom, AppDockConstants.MenuLayout.bottomBarPaddingBottom)
        }
        .contentShape(Rectangle())
        #if canImport(AppKit) || canImport(UIKit)
        .background(SwipeGestureCaptureView(swipeThreshold: AppDockConstants.MenuGestures.swipeThreshold) { direction in
            handleSwipeDirection(direction)
        })
        #endif
        .simultaneousGesture(
            DragGesture(minimumDistance: AppDockConstants.MenuGestures.dragMinimumDistance,
                        coordinateSpace: .local)
                .onEnded { value in
                    handleDrag(value)
                }
        )
    }
}

private struct MenuPageHeader: View {
    let page: MenuPage

    var body: some View {
        HStack {
            Label(page.title, systemImage: page.systemImage)
                .font(.caption)
            Spacer()
        }
        .padding(.horizontal, AppDockConstants.MenuHeader.paddingHorizontal)
        .padding(.vertical, AppDockConstants.MenuHeader.paddingVertical)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppDockConstants.MenuHeader.cornerRadius)
                .fill(Color.primary.opacity(0.08))
        )
    }
}

private struct FilterMenuButton: View {
    @ObservedObject var appState: AppState

    var body: some View {
        Menu {
            Picker("Show", selection: $appState.filterOption) {
                ForEach(AppFilterOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            Divider()
            Picker("Sort", selection: $appState.sortOption) {
                ForEach(AppSortOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
        } label: {
            HStack {
                Label("Filter & Sort", systemImage: "line.3.horizontal.decrease.circle")
                    .font(.caption)
                Spacer()
            }
            .padding(.horizontal, AppDockConstants.MenuHeader.paddingHorizontal)
            .padding(.vertical, AppDockConstants.MenuHeader.paddingVertical)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppDockConstants.MenuHeader.cornerRadius)
                    .fill(Color.primary.opacity(0.08))
            )
        }
        .accessibilityIdentifier(AppDockConstants.Accessibility.dockFilterMenu)
    }
}
