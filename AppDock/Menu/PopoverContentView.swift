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

    private var pageTransition: AnyTransition {
        guard !appState.reduceMotion else { return .opacity }
        let moveForward = appState.menuPage.orderIndex >= previousPage.orderIndex
        let insertion = AnyTransition.move(edge: moveForward ? .trailing : .leading)
            .combined(with: .opacity)
        let removal = AnyTransition.move(edge: moveForward ? .leading : .trailing)
            .combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }

    private func selectPage(_ page: MenuPage, animated: Bool = true) {
        guard page != appState.menuPage else { return }
        previousPage = appState.menuPage
        if animated, let animation = pageAnimation {
            withAnimation(animation) {
                appState.menuPage = page
            }
        } else {
            appState.menuPage = page
        }
    }

    private var orderedPages: [MenuPage] {
        MenuPage.allCases.sorted { $0.orderIndex < $1.orderIndex }
    }

    private func handleSwipeDirection(_ direction: SwipeDirection) {
        guard let currentIndex = orderedPages.firstIndex(of: appState.menuPage) else { return }
        let nextIndex = direction == .left ? currentIndex + 1 : currentIndex - 1
        guard orderedPages.indices.contains(nextIndex) else { return }
        selectPage(orderedPages[nextIndex])
    }

    private func handleInteractiveChanged(horizontal: CGFloat, vertical: CGFloat) {
        guard abs(horizontal) > abs(vertical) else { return }
        isDragging = true
        showNeighborDuringDrag = true
        dragOffset = max(-popoverWidth, min(popoverWidth, horizontal))
    }

    private func handleInteractiveEnded(horizontal: CGFloat, vertical: CGFloat) {
        let isHorizontal = abs(horizontal) > abs(vertical)
        guard isHorizontal else {
            resetDrag()
            return
        }

        let minDistance = max(AppDockConstants.MenuGestures.swipeThreshold,
                              popoverWidth * AppDockConstants.MenuGestures.swipePageThresholdFraction)
        guard abs(horizontal) >= minDistance else {
            resetDrag()
            return
        }

        let direction: SwipeDirection = horizontal < 0 ? .left : .right
        guard let nextPage = neighborPage(for: direction) else {
            resetDrag()
            return
        }

        let targetOffset = direction == .left ? -popoverWidth : popoverWidth
        withAnimation(.easeOut(duration: dragCommitDuration)) {
            dragOffset = targetOffset
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + dragCommitDuration) {
            suppressNextTransition = true
            selectPage(nextPage, animated: false)
            dragOffset = 0
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
        guard let currentIndex = orderedPages.firstIndex(of: appState.menuPage) else { return nil }
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
            previousPage = appState.menuPage
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
                if isDragging {
                    if showNeighborDuringDrag, let direction = dragDirection, let neighbor = neighborPage(for: direction) {
                        pageContent(for: neighbor)
                            .offset(x: dragOffset + (direction == .left ? popoverWidth : -popoverWidth))
                    }
                    pageContent(for: appState.menuPage)
                        .offset(x: dragOffset)
                } else {
                    pageContent(for: appState.menuPage)
                        .transition(suppressNextTransition ? .identity : pageTransition)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .layoutPriority(1)
            .clipped()

            Divider()
                .padding(.horizontal, AppDockConstants.MenuLayout.dividerPaddingHorizontal)
                .padding(.top, AppDockConstants.MenuLayout.bottomDividerPaddingTop)

            MenuPageBar(selectedPage: appState.menuPage, onSelect: { selectPage($0) })
                .padding(.horizontal, AppDockConstants.MenuLayout.bottomBarPaddingHorizontal)
                .padding(.bottom, AppDockConstants.MenuLayout.bottomBarPaddingBottom)
        }
        .contentShape(Rectangle())
        #if canImport(AppKit)
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
        #elseif canImport(UIKit)
        .background(SwipeGestureCaptureView(
            swipeThreshold: AppDockConstants.MenuGestures.swipeThreshold,
            onSwipe: { direction in
                handleSwipeDirection(direction)
            },
            onScrollChanged: { _, _ in },
            onScrollEnded: { _, _ in }
        ))
        #endif
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
