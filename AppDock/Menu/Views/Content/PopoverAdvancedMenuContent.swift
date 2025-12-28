//
//  PopoverAdvancedMenuContent.swift
//  AppDock
//

import Foundation
import SwiftUI

struct PopoverAdvancedMenuContent<PageContent: View>: View {
    @ObservedObject var appState: AppState
    @ObservedObject var menuState: MenuState
    let popoverWidth: CGFloat
    let pageAnimation: Animation?
    let shouldAnimatePageSwap: Bool
    let isDragging: Bool
    let showNeighborDuringDrag: Bool
    let dragOffset: CGFloat
    let dragDirection: SwipeDirection?
    let isUITestMode: Bool
    let onSelectPage: (MenuPage) -> Void
    let onSwipeDirection: (SwipeDirection) -> Void
    let onInteractiveChanged: (CGFloat, CGFloat) -> Void
    let onInteractiveEnded: (CGFloat, CGFloat) -> Void
    let neighborPage: (SwipeDirection) -> MenuPage?
    let swipeModeLabel: (SwipeDirection) -> String
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
