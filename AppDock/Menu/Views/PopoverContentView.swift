//
//  PopoverContentView.swift
//  AppDock
//
/*
 PopoverContentView.swift

 Purpose:
    - High-level SwiftUI view that composes the popover used by the menu
        bar status item. Coordinates page selection, interactive swipes and
        chooses between the `simple` and `advanced` menu layouts.

 Overview:
    - Manages drag state and coordinates `MenuSwipeLogic` with `MenuState`.
    - Delegates rendering of page content to `PopoverPageContent` so this
        file focuses on interaction and page lifecycle.
*/

import Foundation
import os
import SwiftUI

/// Popover content for the menu bar window.
///
/// Manages page selection, interactive drag gestures, and layout mode switching
/// (simple vs. advanced). Coordinates between `MenuState` and `AppState` to
/// determine which page to display and handle swipe transitions.
struct PopoverContentView: View {
    /// Shared app state for reading layout and display settings.
    @ObservedObject var appState: AppState

    /// Menu-specific state for the current page selection.
    @ObservedObject var menuState: MenuState

    /// Callback to open the Settings window.
    let settingsAction: () -> Void

    /// Callback to open the About window.
    let aboutAction: () -> Void

    /// Callback to quit the application.
    let quitAction: () -> Void

    /// Tracks the page shown before a transition (used for animation logic).
    @State private var previousPage: MenuPage = .dock

    /// Current horizontal drag offset during an interactive swipe.
    @State private var dragOffset: CGFloat = 0

    /// Whether we are actively tracking an interactive swipe.
    @State private var isDragging = false

    /// Flag to control whether to show neighbor page preview during drag.
    @State private var showNeighborDuringDrag = true

    /// When true, animations are suppressed during intermediate transitions.
    @State private var suppressNextTransition = false

    /// Logger for debug output about menu state changes.
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AppDock", category: "Menu")
    private var dragCommitDuration: TimeInterval {
        // Duration for the animation when a drag is committed to a page change.
        AppDockConstants.MenuGestures.dragCommitDuration
    }

    private var dragCancelDuration: TimeInterval {
        // Duration for the animation when a drag is cancelled and snaps back.
        AppDockConstants.MenuGestures.dragCancelDuration
    }

    private var popoverWidth: CGFloat {
        // Dynamically calculate popover width based on grid column count.
        PopoverSizing.width(for: appState)
    }

    private var pageAnimation: Animation? {
        // Return nil if reduce motion is enabled; otherwise use a smooth easing.
        appState.reduceMotion ? nil : .easeInOut(duration: 0.22)
    }

    private var shouldAnimatePageSwap: Bool {
        // Skip animation if reduce motion is enabled.
        guard !appState.reduceMotion else { return false }
        // Keep dock transitions snappy; animate only between lighter pages.
        // Skip animation if either the current or previous page is dock.
        return menuState.menuPage != .dock && previousPage != .dock
    }

    /// Transition to a new page, optionally with animation.
    ///
    /// - Parameters:
    ///   - page: The target `MenuPage` to display.
    ///   - animated: If `true` use SwiftUI animations; if `false` disable them.
    private func selectPage(_ page: MenuPage, animated: Bool = true) {
        // Guard against redundant page transitions.
        guard page != menuState.menuPage else { return }
        // Store the old page for animation decisions.
        previousPage = menuState.menuPage
        if animated {
            // Allow SwiftUI's default animation system to handle the transition.
            menuState.menuPage = page
        } else {
            // Create a transaction with animations disabled.
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                menuState.menuPage = page
            }
        }
    }

    private var orderedPages: [MenuPage] {
        // Get pages in the canonical order for swipe navigation.
        MenuSwipeLogic.orderedPages()
    }

    private var isUITestMode: Bool {
        // Check if running in UI test mode by looking for the test argument.
        ProcessInfo.processInfo.arguments.contains(AppDockConstants.Testing.uiTestMode)
    }

    /// Log a message when the popover appears on a given page.
    /// - Parameter page: The page that just appeared.
    private func logPageAppearance(_ page: MenuPage) {
        // Only log if debug logging is enabled in settings.
        guard appState.debugLogging else { return }
        logger.debug("Menu page appeared: \(page.rawValue, privacy: .public)")
    }

    /// Handle a recognized swipe gesture by advancing the page in that direction.
    /// - Parameter direction: The direction of the swipe (left or right).
    private func handleSwipeDirection(_ direction: SwipeDirection) {
        // Look up the next page in this direction.
        guard let nextPage = MenuSwipeLogic.nextPage(from: menuState.menuPage, direction: direction) else { return }
        // Select the next page with animation.
        selectPage(nextPage)
    }

    /// Determine whether to use interactive (live) swipe or snap-only mode.
    ///
    /// - Parameters:
    ///   - current: The currently displayed page.
    ///   - direction: The direction of the attempted swipe.
    /// - Returns: `true` if interactive dragging should be allowed.
    ///
    /// - Note: Interactive swipes are disabled:
    ///   - When on the dock page (always snap-only).
    ///   - When swiping from a non-dock page towards the dock (snap-only).
    private func shouldUseInteractiveSwipe(
        current: MenuPage,
        direction: SwipeDirection
    ) -> Bool {
        // Dock page never uses interactive swipe.
        if current == .dock {
            return false
        }
        // Check if the next page would be the dock.
        if let neighbor = neighborPage(for: direction),
           neighbor == .dock
        {
            // Swiping towards dock uses snap mode.
            return false
        }
        // All other cases use interactive swipe.
        return true
    }

    /// Return a label describing the swipe mode for the given direction.
    /// - Parameter direction: The direction of the swipe.
    /// - Returns: Either "interactive" or "snap" depending on the rules.
    private func swipeModeLabel(for direction: SwipeDirection) -> String {
        shouldUseInteractiveSwipe(current: menuState.menuPage, direction: direction) ? "interactive" : "snap"
    }

    /// Handle the changed phase of an interactive swipe drag.
    ///
    /// - Parameters:
    ///   - horizontal: Horizontal delta accumulated since drag began.
    ///   - vertical: Vertical delta accumulated since drag began.
    ///
    /// - Note: Updates `dragOffset` and state flags to track the drag in real-time.
    private func handleInteractiveChanged(horizontal: CGFloat, vertical: CGFloat) {
        // Ignore vertical motion; require mostly horizontal drag.
        guard abs(horizontal) > abs(vertical) else { return }
        // Determine drag direction.
        let direction: SwipeDirection = horizontal < 0 ? .left : .right
        // Check if there's a neighbor page in this direction.
        guard neighborPage(for: direction) != nil else {
            // No neighbor; cancel the drag.
            resetDrag()
            return
        }
        // Check if interactive swipe is allowed in this context.
        guard shouldUseInteractiveSwipe(current: menuState.menuPage, direction: direction) else {
            // Interactive swipe disabled; ignore the drag.
            return
        }
        // Begin tracking the drag.
        isDragging = true
        showNeighborDuringDrag = true
        // Clamp the offset to the popover width.
        dragOffset = max(-popoverWidth, min(popoverWidth, horizontal))
    }

    /// Handle the ended phase of an interactive swipe drag.
    ///
    /// - Parameters:
    ///   - horizontal: Total horizontal drag distance.
    ///   - vertical: Total vertical drag distance.
    ///
    /// - Note: Determines whether to commit the page change or snap back.
    private func handleInteractiveEnded(horizontal: CGFloat, vertical: CGFloat) {
        // Require mostly horizontal drag.
        guard abs(horizontal) > abs(vertical) else {
            resetDrag()
            return
        }

        // Determine the direction of the drag.
        let direction: SwipeDirection = horizontal < 0 ? .left : .right
        // Check if a neighbor page exists in this direction.
        guard neighborPage(for: direction) != nil else {
            resetDrag()
            return
        }
        
        // Check if interactive swipe is allowed for this context.
        guard shouldUseInteractiveSwipe(current: menuState.menuPage, direction: direction) else {
            // Not interactive; check if we should snap to a page change anyway.
            if MenuSwipeLogic.shouldCommit(horizontal: horizontal, vertical: vertical, width: popoverWidth),
               let nextPage = neighborPage(for: direction)
            {
                // Snap mode: page change committed; no animation.
                selectPage(nextPage, animated: false)
            }
            resetDrag()
            return
        }

        // Check if the drag distance exceeded the commit threshold.
        guard MenuSwipeLogic.shouldCommit(horizontal: horizontal, vertical: vertical, width: popoverWidth) else {
            // Insufficient distance; snap back.
            resetDrag()
            return
        }

        // Get the next page.
        guard let nextPage = neighborPage(for: direction) else {
            resetDrag()
            return
        }

        // Commit to the page change with animation.
        suppressNextTransition = true
        isDragging = true
        // Adjust the drag offset to fully scroll out the current page.
        let offsetAdjustment = direction == .left ? popoverWidth : -popoverWidth
        dragOffset += offsetAdjustment
        // Change the page without animation (animation is handled by dragOffset).
        selectPage(nextPage, animated: false)
        // Animate the offset back to zero.
        withAnimation(.easeInOut(duration: dragCommitDuration)) {
            dragOffset = 0
        }
        // Schedule cleanup after the animation.
        DispatchQueue.main.asyncAfter(deadline: .now() + dragCommitDuration) {
            isDragging = false
            showNeighborDuringDrag = true
            DispatchQueue.main.asyncAfter(deadline: .now() + dragCommitDuration) {
                suppressNextTransition = false
            }
        }
    }

    /// Cancel an in-progress drag and snap back to the current page.
    private func resetDrag() {
        // Suppress animations during the snap-back.
        suppressNextTransition = true
        // Animate the offset back to zero (snap back).
        withAnimation(.easeOut(duration: dragCancelDuration)) {
            dragOffset = 0
        }
        // Schedule cleanup after the snap-back animation.
        DispatchQueue.main.asyncAfter(deadline: .now() + dragCancelDuration) {
            isDragging = false
            showNeighborDuringDrag = true
            // Re-enable animations after a brief delay.
            DispatchQueue.main.asyncAfter(deadline: .now() + dragCancelDuration) {
                suppressNextTransition = false
            }
        }
    }

    /// Derive the swipe direction from the current drag offset.
    /// - Returns: `.left` if offset is negative, `.right` if positive, `nil` if zero.
    private var dragDirection: SwipeDirection? {
        if dragOffset < 0 {
            return .left
        }
        if dragOffset > 0 {
            return .right
        }
        return nil
    }

    /// Get the neighbor page in the specified direction, if it exists.
    /// - Parameter direction: The direction to check.
    /// - Returns: The neighboring page, or `nil` if out of bounds.
    private func neighborPage(for direction: SwipeDirection) -> MenuPage? {
        // Find the current page's index in the ordered list.
        guard let currentIndex = orderedPages.firstIndex(of: menuState.menuPage) else { return nil }
        // Calculate the neighbor index.
        let nextIndex = direction == .left ? currentIndex + 1 : currentIndex - 1
        // Check if the neighbor index is valid.
        guard orderedPages.indices.contains(nextIndex) else { return nil }
        return orderedPages[nextIndex]
    }

    /// Create the content view for a specific menu page.
    /// - Parameter page: The page to render content for.
    /// - Returns: A `PopoverPageContent` view.
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
            // Choose layout based on user preference.
            if appState.menuLayoutMode == .simple {
                // Simple single-page layout with dock, recents, favorites, and actions on one page.
                PopoverSimpleMenuContent(
                    appState: appState,
                    settingsAction: settingsAction,
                    aboutAction: aboutAction,
                    quitAction: quitAction
                )
            } else {
                // Advanced tabbed layout with paging and interactive swipes.
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
        // Set the popover frame to match the required dimensions.
        .frame(width: popoverWidth, height: AppDockConstants.MenuPopover.height, alignment: .top)
        // Dismiss context menus in the dock on any tap in the popover.
        .simultaneousGesture(TapGesture().onEnded {
            NotificationCenter.default.post(name: .appDockDismissContextMenu, object: nil)
        })
        // Synchronize previous page when the view appears.
        .onAppear {
            previousPage = menuState.menuPage
        }
    }
}
