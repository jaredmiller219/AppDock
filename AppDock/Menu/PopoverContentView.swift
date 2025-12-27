//
//  PopoverContentView.swift
//  AppDock
//

import SwiftUI
import Foundation

/// Popover content for the menu bar window.
struct PopoverContentView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var menuState: MenuState
    let settingsAction: () -> Void
    let aboutAction: () -> Void
    let quitAction: () -> Void
    @State private var previousPage: MenuPage = .dock
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var showNeighborDuringDrag = true
    @State private var suppressNextTransition = false
    private var dragCommitDuration: TimeInterval {
        AppDockConstants.MenuGestures.dragCommitDuration
    }

    private var dragCancelDuration: TimeInterval {
        AppDockConstants.MenuGestures.dragCancelDuration
    }

    private var popoverWidth: CGFloat {
        PopoverSizing.width(for: appState)
    }

    private var pageAnimation: Animation? {
        appState.reduceMotion ? nil : .easeInOut(duration: 0.22)
    }

    private var shouldAnimatePageSwap: Bool {
        guard !appState.reduceMotion else { return false }
        // Keep dock transitions snappy; animate between lighter pages.
        return menuState.menuPage != .dock && previousPage != .dock
    }

    private func selectPage(_ page: MenuPage, animated: Bool = true) {
        guard page != menuState.menuPage else { return }
        previousPage = menuState.menuPage
        if animated {
            menuState.menuPage = page
        } else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                menuState.menuPage = page
            }
        }
    }

    private var orderedPages: [MenuPage] {
        MenuSwipeLogic.orderedPages()
    }

    private var isUITestMode: Bool {
        ProcessInfo.processInfo.arguments.contains(AppDockConstants.Testing.uiTestMode)
    }

    private func handleSwipeDirection(_ direction: SwipeDirection) {
        guard let nextPage = MenuSwipeLogic.nextPage(from: menuState.menuPage, direction: direction) else { return }
        selectPage(nextPage)
    }

    private func shouldUseInteractiveSwipe(
        current: MenuPage,
        direction: SwipeDirection
    ) -> Bool {
        if current == .dock {
            return false
        }
        if let neighbor = neighborPage(for: direction),
           neighbor == .dock {
            return false
        }
        return true
    }

    private func swipeModeLabel(for direction: SwipeDirection) -> String {
        shouldUseInteractiveSwipe(current: menuState.menuPage, direction: direction) ? "interactive" : "snap"
    }

    private func handleInteractiveChanged(horizontal: CGFloat, vertical: CGFloat) {
        guard abs(horizontal) > abs(vertical) else { return }
        let direction: SwipeDirection = horizontal < 0 ? .left : .right
        guard neighborPage(for: direction) != nil else {
            resetDrag()
            return
        }
        guard shouldUseInteractiveSwipe(current: menuState.menuPage, direction: direction) else {
            return
        }
        isDragging = true
        showNeighborDuringDrag = true
        dragOffset = max(-popoverWidth, min(popoverWidth, horizontal))
    }

    private func handleInteractiveEnded(horizontal: CGFloat, vertical: CGFloat) {
        guard abs(horizontal) > abs(vertical) else {
            resetDrag()
            return
        }

        let direction: SwipeDirection = horizontal < 0 ? .left : .right
        guard neighborPage(for: direction) != nil else {
            resetDrag()
            return
        }
        guard shouldUseInteractiveSwipe(current: menuState.menuPage, direction: direction) else {
            if MenuSwipeLogic.shouldCommit(horizontal: horizontal, vertical: vertical, width: popoverWidth),
               let nextPage = neighborPage(for: direction) {
                selectPage(nextPage, animated: false)
            }
            resetDrag()
            return
        }

        guard MenuSwipeLogic.shouldCommit(horizontal: horizontal, vertical: vertical, width: popoverWidth) else {
            resetDrag()
            return
        }

        guard let nextPage = neighborPage(for: direction) else {
            resetDrag()
            return
        }

        suppressNextTransition = true
        isDragging = true
        let offsetAdjustment = direction == .left ? popoverWidth : -popoverWidth
        dragOffset += offsetAdjustment
        selectPage(nextPage, animated: false)
        withAnimation(.easeInOut(duration: dragCommitDuration)) {
            dragOffset = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + dragCommitDuration) {
            isDragging = false
            showNeighborDuringDrag = true
            DispatchQueue.main.asyncAfter(deadline: .now() + dragCommitDuration) {
                suppressNextTransition = false
            }
        }
    }

    private func resetDrag() {
        suppressNextTransition = true
        withAnimation(.easeOut(duration: dragCancelDuration)) {
            dragOffset = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + dragCancelDuration) {
            isDragging = false
            showNeighborDuringDrag = true
            DispatchQueue.main.asyncAfter(deadline: .now() + dragCancelDuration) {
                suppressNextTransition = false
            }
        }
    }

    private var dragDirection: SwipeDirection? {
        if dragOffset < 0 {
            return .left
        }
        if dragOffset > 0 {
            return .right
        }
        return nil
    }

    private func neighborPage(for direction: SwipeDirection) -> MenuPage? {
        guard let currentIndex = orderedPages.firstIndex(of: menuState.menuPage) else { return nil }
        let nextIndex = direction == .left ? currentIndex + 1 : currentIndex - 1
        guard orderedPages.indices.contains(nextIndex) else { return nil }
        return orderedPages[nextIndex]
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
            previousPage = menuState.menuPage
        }
    }
}

private extension PopoverContentView {
    @ViewBuilder
    func pageContent(for page: MenuPage) -> some View {
        Group {
            switch page {
            case .dock:
                ScrollView(showsIndicators: false) {
                    DockView(appState: appState)
                        .padding(.horizontal, AppDockConstants.MenuLayout.dockPaddingHorizontal)
                        .padding(.top, AppDockConstants.MenuLayout.dockPaddingTop)
                        .padding(.bottom, AppDockConstants.MenuLayout.dockPaddingBottom)
                }
                .onAppear {
                    print("Menu page appeared: dock")
                }
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
                .onAppear {
                    print("Menu page appeared: recents")
                }
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
                .onAppear {
                    print("Menu page appeared: favorites")
                }
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
                .onAppear {
                    print("Menu page appeared: actions")
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

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
            .padding(.top, AppDockConstants.MenuLayout.actionsPaddingTop)
            .padding(.bottom, AppDockConstants.MenuLayout.actionsPaddingBottom)
        }
    }

    var advancedMenuContent: some View {
        VStack(spacing: 0) {
            Group {
                if menuState.menuPage == .dock {
                    FilterMenuButton(appState: appState)
                } else {
                    MenuPageHeader(page: menuState.menuPage)
                }
            }
            .padding(.horizontal, AppDockConstants.MenuLayout.headerPaddingHorizontal)
            .padding(.top, AppDockConstants.MenuLayout.headerPaddingTop)
            .padding(.bottom, AppDockConstants.MenuLayout.headerPaddingBottom)

            Divider()
                .padding(.horizontal, AppDockConstants.MenuLayout.dividerPaddingHorizontal)

            ZStack {
                if isDragging {
                    if showNeighborDuringDrag, let direction = dragDirection, let neighbor = neighborPage(for: direction) {
                        pageContent(for: neighbor)
                            .offset(x: dragOffset + (direction == .left ? popoverWidth : -popoverWidth))
                    }
                    pageContent(for: menuState.menuPage)
                        .offset(x: dragOffset)
                } else {
                    ZStack {
                        pageContent(for: .dock)
                            .opacity(menuState.menuPage == .dock ? 1 : 0)
                            .allowsHitTesting(menuState.menuPage == .dock)
                        pageContent(for: .recents)
                            .opacity(menuState.menuPage == .recents ? 1 : 0)
                            .allowsHitTesting(menuState.menuPage == .recents)
                        pageContent(for: .favorites)
                            .opacity(menuState.menuPage == .favorites ? 1 : 0)
                            .allowsHitTesting(menuState.menuPage == .favorites)
                        pageContent(for: .actions)
                            .opacity(menuState.menuPage == .actions ? 1 : 0)
                            .allowsHitTesting(menuState.menuPage == .actions)
                    }
                    .animation(shouldAnimatePageSwap ? pageAnimation : nil, value: menuState.menuPage)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .layoutPriority(1)
            .clipped()

            Divider()
                .padding(.horizontal, AppDockConstants.MenuLayout.dividerPaddingHorizontal)
                .padding(.top, AppDockConstants.MenuLayout.bottomDividerPaddingTop)

            MenuPageBar(selectedPage: menuState.menuPage, onSelect: { selectPage($0) })
                .padding(.horizontal, AppDockConstants.MenuLayout.bottomBarPaddingHorizontal)
                .padding(.bottom, AppDockConstants.MenuLayout.bottomBarPaddingBottom)
        }
        .contentShape(Rectangle())
        .background(SwipeGestureCaptureView(
            swipeThreshold: AppDockConstants.MenuGestures.swipeThreshold,
            onSwipe: { _ in },
            onScrollChanged: { totalX, totalY in
                handleInteractiveChanged(horizontal: totalX, vertical: totalY)
            },
            onScrollEnded: { totalX, totalY in
                handleInteractiveEnded(horizontal: totalX, vertical: totalY)
            }
        ))
        .overlay(alignment: .topLeading) {
            if isUITestMode {
                HStack(spacing: 8) {
                    Button(action: {
                        handleSwipeDirection(.left)
                    }) {
                        Text("Swipe Left")
                            .font(.caption2)
                            .foregroundColor(.clear)
                            .padding(2)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 32, height: 24)
                    .background(Color.white.opacity(0.001))
                    .contentShape(Rectangle())
                    .opacity(0.05)
                    .allowsHitTesting(true)
                    .accessibilityLabel("UI Test Swipe Left")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier(AppDockConstants.Accessibility.uiTestTrackpadSwipeLeft)

                    Button(action: {
                        NotificationCenter.default.post(name: .appDockDismissContextMenu, object: nil)
                    }) {
                        Text("Dismiss Menu")
                            .font(.caption2)
                            .foregroundColor(.clear)
                            .padding(2)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 32, height: 24)
                    .background(Color.white.opacity(0.001))
                    .contentShape(Rectangle())
                    .opacity(0.05)
                    .allowsHitTesting(true)
                    .accessibilityLabel("UI Test Dismiss Context Menu")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier(AppDockConstants.Accessibility.uiTestDismissContextMenu)

                    Text(appState.uiTestLastActivationBundleId)
                        .font(.caption2)
                        .foregroundColor(.clear)
                        .frame(width: 1, height: 1)
                        .accessibilityIdentifier(AppDockConstants.Accessibility.uiTestActivationRequest)

                    Text(swipeModeLabel(for: .left))
                        .font(.caption2)
                        .foregroundColor(.clear)
                        .frame(width: 1, height: 1)
                        .accessibilityIdentifier(AppDockConstants.Accessibility.uiTestSwipeModeLeft)

                    Text(swipeModeLabel(for: .right))
                        .font(.caption2)
                        .foregroundColor(.clear)
                        .frame(width: 1, height: 1)
                        .accessibilityIdentifier(AppDockConstants.Accessibility.uiTestSwipeModeRight)
                }
                .zIndex(10)
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: AppDockConstants.MenuGestures.dragMinimumDistance,
                        coordinateSpace: .local)
                .onChanged { value in
                    handleInteractiveChanged(horizontal: value.translation.width,
                                             vertical: value.translation.height)
                }
                .onEnded { value in
                    handleInteractiveEnded(horizontal: value.translation.width,
                                           vertical: value.translation.height)
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
        .accessibilityIdentifier(AppDockConstants.Accessibility.menuPageHeaderPrefix + page.rawValue)
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
