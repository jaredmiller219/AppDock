//
//  DockView.swift
//  AppDock
//
/*
 DockView.swift

 Purpose:
    - Primary SwiftUI view responsible for rendering the dock grid, paging
        behavior and the centered context menu overlay.

 Overview:
    - Reads layout and user preferences from `AppState` and composes smaller
        view components such as `ButtonView`, `ContextMenuView`, and
        `IconView` to render each slot.
    - Handles paging gestures and context menu lifecycle.

 Notes:
    - Keep view code declarative; move heavy work into helper types so SwiftUI
        can diff efficiently.
*/

import AppKit
import SwiftUI

// MARK: - DockView

/// Main grid view that renders the dock layout and context menus.
struct DockView: View {
    @ObservedObject var appState: AppState

    /// Local alias to keep tuple types readable.
    typealias AppEntry = AppState.AppEntry
    
//    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AppDock", category: "DockView")
//
//    private func log(_ message: String) {
//        logger.debug("\(message, privacy: .public)")
//    }

    /// Tracks which app index currently has its context menu open.
    /// - `nil` when no context menu is visible.
    @State private var activeContextMenuIndex: Int? = nil

    /// Token changed whenever a context menu is opened to force a new
    /// view identity for animation/transition correctness.
    @State private var contextMenuToken = UUID()

    /// Current page index when the dock is paged.
    @State private var pageIndex = 0

    private var contextMenuAnimation: Animation? {
        appState.reduceMotion ? nil : Animation.spring(response: 0.25, dampingFraction: 0.8)
    }

    /// Clears any open context menu.
    private func dismissContextMenus() {
        withAnimation(contextMenuAnimation) {
            activeContextMenuIndex = nil
        }
    }

    private func setActiveContextMenuIndex(_ index: Int?) {
        withAnimation(contextMenuAnimation) {
            activeContextMenuIndex = index
            if index != nil {
                contextMenuToken = UUID()
            }
        }
    }

    // Layout constants for the grid.
    private let columnSpacing: CGFloat = AppDockConstants.DockLayout.columnSpacing
    private let extraSpace: CGFloat = AppDockConstants.DockLayout.extraSpace

    /// Checks whether a bundle identifier currently has a running app instance.
    private func isBundleRunning(_ bundleId: String) -> Bool {
        !bundleId.isEmpty
            && !NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).isEmpty
    }

    /// Removes an app entry and keeps the context menu index in sync.
    private func removeApp(at appIndex: Int, appEntry: AppEntry) {
        guard !appEntry.bundleid.isEmpty else { return }
        if let index = appState.recentApps.firstIndex(where: { entry in
            entry.bundleid == appEntry.bundleid && entry.name == appEntry.name
        }) {
            appState.recentApps.remove(at: index)
        }

        // Clear or adjust active context menu index.
        if activeContextMenuIndex == appIndex {
            dismissContextMenus()
        } else if let active = activeContextMenuIndex, active > appIndex {
            activeContextMenuIndex = active - 1
        }
    }

    var body: some View {
        // Compute the overall divider width for row separators.
        let numberOfColumns = max(1, appState.gridColumns)
        let numberOfRows = max(1, appState.gridRows)
        let buttonWidth = CGFloat(appState.iconSize)
        let buttonHeight = CGFloat(appState.iconSize)
        let labelSize = CGFloat(appState.labelSize)

        let dividerWidth: CGFloat = (CGFloat(numberOfColumns) * buttonWidth)
            + (CGFloat(numberOfColumns - 1) * columnSpacing)
            + extraSpace

        let totalSlots = numberOfColumns * numberOfRows
        let filteredApps = DockAppList.filterApps(
            appState.recentApps,
            filter: appState.filterOption,
            isRunning: isBundleRunning
        )
        let sortedApps = DockAppList.sortApps(filteredApps, sort: appState.sortOption)
        let totalPages = max(1, Int(ceil(Double(sortedApps.count) / Double(totalSlots))))
        let paddedApps = DockAppList.padApps(sortedApps, totalSlots: totalPages * totalSlots)

        VStack {
            if totalPages > 1 {
                TabView(selection: $pageIndex) {
                    ForEach(0 ..< totalPages, id: \.self) { page in
                        dockPageView(
                            page: page,
                            totalSlots: totalSlots,
                            numberOfColumns: numberOfColumns,
                            numberOfRows: numberOfRows,
                            dividerWidth: dividerWidth,
                            buttonWidth: buttonWidth,
                            buttonHeight: buttonHeight,
                            labelSize: labelSize,
                            paddedApps: paddedApps
                        )
                        .tag(page)
                    }
                }
                .tabViewStyle(.automatic)
                .highPriorityGesture(
                    DragGesture(minimumDistance: AppDockConstants.DockLayout.swipeMinimumDistance)
                        .onEnded { value in
                            let threshold: CGFloat = AppDockConstants.DockLayout.swipeThreshold
                            if value.translation.width <= -threshold {
                                pageIndex = min(pageIndex + 1, totalPages - 1)
                            } else if value.translation.width >= threshold {
                                pageIndex = max(pageIndex - 1, 0)
                            }
                        }
                )
                .overlay(alignment: .bottom) {
                    pageIndicator(totalPages: totalPages)
                        .padding(.bottom, AppDockConstants.DockLayout.pageIndicatorBottomPadding)
                }
            } else {
                dockPageView(
                    page: 0,
                    totalSlots: totalSlots,
                    numberOfColumns: numberOfColumns,
                    numberOfRows: numberOfRows,
                    dividerWidth: dividerWidth,
                    buttonWidth: buttonWidth,
                    buttonHeight: buttonHeight,
                    labelSize: labelSize,
                    paddedApps: paddedApps
                )
            }
        }
        .padding()
        // Centered context menu overlay for the currently active app.
        .overlay(alignment: .center) {
            if let active = activeContextMenuIndex,
               active < paddedApps.count
            {
                let (appName, bundleId, _) = paddedApps[active]

                if !bundleId.isEmpty {
                    // Match menu frame in both blur and stroke layers.
                    let menuWidth: CGFloat = AppDockConstants.DockContextMenu.width
                    let menuHeight: CGFloat = AppDockConstants.DockContextMenu.height

                    ZStack {
                        // Background overlay to catch outside clicks (full screen)
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                dismissContextMenus()
                            }
                        
                        // Context menu area that blocks the background overlay
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: menuWidth, height: menuHeight)
                            .allowsHitTesting(false)
                        
                        VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                            .frame(width: menuWidth, height: menuHeight)
                            .clipShape(RoundedRectangle(cornerRadius: AppDockConstants.DockContextMenu.cornerRadius))
                            .shadow(radius: AppDockConstants.DockContextMenu.shadowRadius)
                            .allowsHitTesting(false)

                        RoundedRectangle(cornerRadius: AppDockConstants.DockContextMenu.cornerRadius)
                            .stroke(
                                Color.white.opacity(AppDockConstants.DockContextMenu.strokeOpacity),
                                lineWidth: AppDockConstants.DockContextMenu.strokeLineWidth
                            )
                            .frame(width: menuWidth, height: menuHeight)
                            .allowsHitTesting(false)

                        ContextMenuView(
                            onDismiss: { dismissContextMenus() },
                            appName: appName,
                            bundleId: bundleId,
                            confirmBeforeQuit: appState.confirmBeforeQuit
                        )
                        .padding(AppDockConstants.DockContextMenu.padding)
                        .allowsHitTesting(true)
                    }
                    .id(contextMenuToken)
                    .transition(
                        appState.reduceMotion
                            ? .opacity
                            : .scale(scale: AppDockConstants.DockContextMenu.transitionScale).combined(with: .opacity)
                    )
                    .zIndex(3)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            dismissContextMenus()
        }
        .onReceive(NotificationCenter.default.publisher(for: .appDockDismissContextMenu)) { _ in
            dismissContextMenus()
        }
        .onChange(of: pageIndex) { _, _ in
            dismissContextMenus()
        }
        .onChange(of: totalPages) { _, newValue in
            if pageIndex >= newValue {
                pageIndex = max(0, newValue - 1)
            }
        }
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didActivateApplicationNotification)) { notification in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
               app.bundleIdentifier != Bundle.main.bundleIdentifier
            {
                dismissContextMenus()
            }
        }
    }
}

private extension DockView {
    func pageIndicator(totalPages: Int) -> some View {
        HStack(spacing: AppDockConstants.DockPageIndicator.spacing) {
            ForEach(0 ..< totalPages, id: \.self) { index in
                Circle()
                    .fill(
                        index == pageIndex
                            ? Color.white
                            : Color.white.opacity(AppDockConstants.DockPageIndicator.inactiveOpacity)
                    )
                    .frame(
                        width: AppDockConstants.DockPageIndicator.dotSize,
                        height: AppDockConstants.DockPageIndicator.dotSize
                    )
            }
        }
        .padding(.horizontal, AppDockConstants.DockPageIndicator.paddingHorizontal)
        .padding(.vertical, AppDockConstants.DockPageIndicator.paddingVertical)
        .background(
            Capsule()
                .fill(Color.black.opacity(AppDockConstants.DockPageIndicator.capsuleOpacity))
        )
        .padding(.top, AppDockConstants.DockPageIndicator.topPadding)
    }

    @ViewBuilder
    func dockPageView(
        page: Int,
        totalSlots: Int,
        numberOfColumns: Int,
        numberOfRows: Int,
        dividerWidth: CGFloat,
        buttonWidth: CGFloat,
        buttonHeight: CGFloat,
        labelSize: CGFloat,
        paddedApps: [AppEntry]
    ) -> some View {
        let startIndex = page * totalSlots
        let endIndex = min(startIndex + totalSlots, paddedApps.count)
        let pageApps = Array(paddedApps[startIndex ..< endIndex])

        VStack {
            ForEach(0 ..< numberOfRows, id: \.self) { rowIndex in
                HStack(alignment: .center, spacing: columnSpacing) {
                    ForEach(0 ..< numberOfColumns, id: \.self) { columnIndex in
                        let slotIndex = (rowIndex * numberOfColumns) + columnIndex
                        let appIndex = startIndex + slotIndex
                        let (appName, bundleId, appIcon) = pageApps[slotIndex]
                        let isRunning = isBundleRunning(bundleId)

                        VStack(spacing: AppDockConstants.DockLayout.tileSpacing) {
                            ZStack(alignment: .bottomTrailing) {
                                ButtonView(
                                    appName: appName,
                                    bundleId: bundleId,
                                    appIcon: appIcon,
                                    buttonWidth: buttonWidth,
                                    buttonHeight: buttonHeight,
                                    allowRemove: appState.enableHoverRemove,
                                    isContextMenuVisible: Binding(
                                        get: { activeContextMenuIndex == appIndex },
                                        set: { isVisible in
                                            setActiveContextMenuIndex(isVisible ? appIndex : nil)
                                        }
                                    ),
                                    onRemove: {
                                        removeApp(
                                            at: appIndex,
                                            appEntry: (appName, bundleId, appIcon)
                                        )
                                    }
                                )
                                .accessibilityIdentifier(AppDockConstants.Accessibility.dockSlotPrefix + "\(appIndex)")

                                if appState.showRunningIndicator && isRunning {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(
                                            width: AppDockConstants.DockRunningIndicator.size,
                                            height: AppDockConstants.DockRunningIndicator.size
                                        )
                                        .padding(AppDockConstants.DockRunningIndicator.padding)
                                }
                            }

                            if appState.showAppLabels && !appName.isEmpty {
                                Text(appName)
                                    .font(.system(size: labelSize))
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, AppDockConstants.DockLabel.horizontalPadding)
                                    .padding(.vertical, AppDockConstants.DockLabel.verticalPadding)
                                    .background(Color.black.opacity(AppDockConstants.DockLabel.backgroundOpacity))
                                    .cornerRadius(AppDockConstants.DockLabel.cornerRadius)
                            }
                        }
                    }
                }

                // Divider between rows (except last row)
                if rowIndex < (numberOfRows - 1) {
                    Divider()
                        .frame(width: dividerWidth)
                        .background(Color.blue)
                        .padding(.vertical, AppDockConstants.DockLayout.rowDividerPaddingVertical)
                }
            }
        }
    }
}

// #Preview {
//    DockView(appState: .init())
// }
