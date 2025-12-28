//
//  PopoverContentView.swift
//  AppDock
//

import Foundation
import os
import SwiftUI

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
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AppDock", category: "Menu")
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

    private func logPageAppearance(_ page: MenuPage) {
        guard appState.debugLogging else { return }
        logger.debug("Menu page appeared: \(page.rawValue, privacy: .public)")
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
           neighbor == .dock
        {
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
               let nextPage = neighborPage(for: direction)
            {
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

    private func pageContentView(for page: MenuPage) -> some View {
        PopoverPageContent(
            page: page,
            appState: appState,
            settingsAction: settingsAction,
            aboutAction: aboutAction,
            quitAction: quitAction,
            onPageAppear: logPageAppearance
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            if appState.menuLayoutMode == .simple {
                PopoverSimpleMenuContent(
                    appState: appState,
                    settingsAction: settingsAction,
                    aboutAction: aboutAction,
                    quitAction: quitAction
                )
            } else {
                PopoverAdvancedMenuContent(
                    appState: appState,
                    menuState: menuState,
                    popoverWidth: popoverWidth,
                    pageAnimation: pageAnimation,
                    shouldAnimatePageSwap: shouldAnimatePageSwap,
                    isDragging: isDragging,
                    showNeighborDuringDrag: showNeighborDuringDrag,
                    dragOffset: dragOffset,
                    dragDirection: dragDirection,
                    isUITestMode: isUITestMode,
                    onSelectPage: { selectPage($0) },
                    onSwipeDirection: handleSwipeDirection,
                    onInteractiveChanged: handleInteractiveChanged,
                    onInteractiveEnded: handleInteractiveEnded,
                    neighborPage: neighborPage,
                    swipeModeLabel: swipeModeLabel,
                    pageContent: { pageContentView(for: $0) }
                )
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
