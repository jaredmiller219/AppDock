/*
 PopoverAdvancedMenuContent.swift
 AppDock

 PURPOSE:
 This view provides the advanced/paged menu layout with interactive swipe gesture support.
 It manages multi-page navigation with smooth animations and drag-based page transitions.

 OVERVIEW:
 PopoverAdvancedMenuContent is a container that displays multiple pages of menu content with:
 - Interactive swipe/drag navigation between pages
 - Neighbor page preview during drag
 - Animated page transitions
 - FilterMenuButton or MenuPageHeader based on current page
 - MenuPageBar tab control at bottom
 - Gesture capture via SwipeGestureCaptureView
 - Optional UI test controls for gesture simulation

 KEY FEATURES:
 - Supports interactive (drag-based) and non-interactive (animated) page transitions
 - Shows neighbor page during active drag if showNeighborDuringDrag is true
 - Uses offset animation to preview page swipe before commit
 - Clipping ensures neighbor page doesn't exceed bounds during drag
 - Includes test overlay buttons for simulating swipe directions

 INTEGRATION:
 - Used by PopoverContentView in advanced (paged) menu layout mode
 - Observes AppState for filter/sort settings
 - Observes MenuState for current page selection
 - Delegates gesture handling to PopoverContentView via callbacks
*/

import Foundation
import SwiftUI

/// Advanced menu layout with interactive swipe navigation, page transitions, and gesture handling.
///
/// Generic view that coordinates multi-page navigation with smooth animations and drag gesture support.
/// Displays current page content with optional neighbor preview during drag, and provides test controls
/// for gesture simulation in UI test mode.
struct PopoverAdvancedMenuContent<PageContent: View>: View {
    /// Shared app state for filter/sort settings
    @ObservedObject var appState: AppState

    /// Menu state tracking current page selection
    @ObservedObject var menuState: MenuState

    /// Width of the popover container for drag offset calculations
    let popoverWidth: CGFloat

    /// Animation to apply when swapping pages non-interactively
    let pageAnimation: Animation?

    /// Whether to animate page transitions (disable during interactive drag)
    let shouldAnimatePageSwap: Bool

    /// Whether user is currently dragging (interactive swipe in progress)
    let isDragging: Bool

    /// Whether to show neighbor page preview during active drag
    let showNeighborDuringDrag: Bool

    /// Horizontal offset distance during drag gesture (used to offset page views)
    let dragOffset: CGFloat

    /// Direction of current drag (left or right) if dragging, nil if not
    let dragDirection: SwipeDirection?

    /// Whether running in UI test mode (enables test gesture buttons)
    let isUITestMode: Bool

    /// Callback when user selects a page via tab bar or keyboard shortcut
    let onSelectPage: (MenuPage) -> Void

    /// Callback for UI test gesture simulation buttons
    let onSwipeDirection: (SwipeDirection) -> Void

    /// Callback for interactive drag position changes (totalX, totalY from gesture)
    let onInteractiveChanged: (CGFloat, CGFloat) -> Void

    /// Callback when interactive drag gesture ends (totalX, totalY at end position)
    let onInteractiveEnded: (CGFloat, CGFloat) -> Void

    /// Function to look up neighbor page in specified direction
    let neighborPage: (SwipeDirection) -> MenuPage?

    /// Function to get display label for swipe direction (for test buttons)
    let swipeModeLabel: (SwipeDirection) -> String

    /// ViewBuilder closure providing page content view for any MenuPage
    @ViewBuilder let pageContent: (MenuPage) -> PageContent

    var body: some View {
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
                    if showNeighborDuringDrag, let direction = dragDirection, let neighbor = neighborPage(direction) {
                        pageContent(neighbor)
                            .offset(x: dragOffset + (direction == .left ? popoverWidth : -popoverWidth))
                    }
                    pageContent(menuState.menuPage)
                        .offset(x: dragOffset)
                } else {
                    ZStack {
                        pageContent(.dock)
                            .opacity(menuState.menuPage == .dock ? 1 : 0)
                            .allowsHitTesting(menuState.menuPage == .dock)
                        pageContent(.recents)
                            .opacity(menuState.menuPage == .recents ? 1 : 0)
                            .allowsHitTesting(menuState.menuPage == .recents)
                        pageContent(.favorites)
                            .opacity(menuState.menuPage == .favorites ? 1 : 0)
                            .allowsHitTesting(menuState.menuPage == .favorites)
                        pageContent(.actions)
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

            MenuPageBar(selectedPage: menuState.menuPage, onSelect: { onSelectPage($0) })
                .padding(.horizontal, AppDockConstants.MenuLayout.bottomBarPaddingHorizontal)
                .padding(.bottom, AppDockConstants.MenuLayout.bottomBarPaddingBottom)
        }
        .contentShape(Rectangle())
        .background(SwipeGestureCaptureView(
            swipeThreshold: AppDockConstants.MenuGestures.swipeThreshold,
            onSwipe: { _ in },
            onScrollChanged: { totalX, totalY in
                onInteractiveChanged(totalX, totalY)
            },
            onScrollEnded: { totalX, totalY in
                onInteractiveEnded(totalX, totalY)
            }
        ))
        .overlay(alignment: .topLeading) {
            if isUITestMode {
                HStack(spacing: 8) {
                    Button(action: {
                        onSwipeDirection(.left)
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

                    Text(" ")
                        .font(.caption2)
                        .foregroundColor(.clear)
                        .frame(width: 1, height: 1)
                        .accessibilityLabel(appState.uiTestLastActivationBundleId)
                        .accessibilityValue(appState.uiTestLastActivationBundleId)
                        .accessibilityIdentifier(AppDockConstants.Accessibility.uiTestActivationRequest)

                    Text(" ")
                        .font(.caption2)
                        .foregroundColor(.clear)
                        .frame(width: 1, height: 1)
                        .accessibilityLabel(swipeModeLabel(.left))
                        .accessibilityValue(swipeModeLabel(.left))
                        .accessibilityIdentifier(AppDockConstants.Accessibility.uiTestSwipeModeLeft)

                    Text(" ")
                        .font(.caption2)
                        .foregroundColor(.clear)
                        .frame(width: 1, height: 1)
                        .accessibilityLabel(swipeModeLabel(.right))
                        .accessibilityValue(swipeModeLabel(.right))
                        .accessibilityIdentifier(AppDockConstants.Accessibility.uiTestSwipeModeRight)
                }
                .zIndex(10)
            }
        }
        .simultaneousGesture(
            DragGesture(
                minimumDistance: AppDockConstants.MenuGestures.dragMinimumDistance,
                coordinateSpace: .local
            )
            .onChanged { value in
                onInteractiveChanged(value.translation.width, value.translation.height)
            }
            .onEnded { value in
                onInteractiveEnded(value.translation.width, value.translation.height)
            }
        )
    }
}
