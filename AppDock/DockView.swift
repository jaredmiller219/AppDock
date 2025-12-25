//
//  DockView.swift
//  AppDock
//
//  Created by Jared Miller on 12/12/24.
//

import SwiftUI
import AppKit

// MARK: - DockView

/// Main grid view that renders the dock layout and context menus.
struct DockView: View {
    @ObservedObject var appState: AppState

    /// Local alias to keep tuple types readable.
    private typealias AppEntry = AppState.AppEntry

    // Tracks which app index currently has its context menu open.
    @State private var activeContextMenuIndex: Int? = nil
    @State private var contextMenuToken = UUID()

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
    private let columnSpacing: CGFloat = 16
    private let extraSpace: CGFloat = 15

    /// Checks whether a bundle identifier currently has a running app instance.
    private func isBundleRunning(_ bundleId: String) -> Bool {
        !bundleId.isEmpty
            && !NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).isEmpty
    }

    /// Removes an app entry and keeps the context menu index in sync.
    private func removeApp(at appIndex: Int) {
        // Only remove if this index corresponds to a real app.
        if appIndex < appState.recentApps.count {
            appState.recentApps.remove(at: appIndex)
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

        // Apply filter + sort before padding the grid to the desired slot count.
        let totalSlots = numberOfColumns * numberOfRows
        let paddedApps: [AppEntry] = DockAppList.build(
            apps: appState.recentApps,
            filter: appState.filterOption,
            sort: appState.sortOption,
            totalSlots: totalSlots,
            isRunning: isBundleRunning
        )

        VStack {
            ForEach(0..<numberOfRows, id: \.self) { rowIndex in
                HStack(alignment: .center, spacing: columnSpacing) {
                    ForEach(0..<numberOfColumns, id: \.self) { columnIndex in
                        let appIndex = (rowIndex * numberOfColumns) + columnIndex
                        let (appName, bundleId, appIcon) = paddedApps[appIndex]
                        let isRunning = isBundleRunning(bundleId)

                        VStack(spacing: 3) {
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
                                        removeApp(at: appIndex)
                                    }
                                )
                                .accessibilityIdentifier("DockSlot-\(appIndex)")

                                if appState.showRunningIndicator && isRunning {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 6, height: 6)
                                        .padding(4)
                                }
                            }

                            if appState.showAppLabels && !appName.isEmpty {
                                Text(appName)
                                    .font(.system(size: labelSize))
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.black.opacity(0.25))
                                    .cornerRadius(3)
                            }
                        }
                    }
                }

                // Divider between rows (except last row)
                if rowIndex < (numberOfRows - 1) {
                    Divider()
                        .frame(width: dividerWidth)
                        .background(Color.blue)
                        .padding(.vertical, 5)
                }
            }
        }
        .padding()
        // Dismiss on any tap in the dock when a context menu is open (without blocking buttons).
        .simultaneousGesture(TapGesture().onEnded {
            if activeContextMenuIndex != nil {
                dismissContextMenus()
            }
        })
        // Centered context menu overlay for the currently active app.
        .overlay(alignment: .center) {
            if let active = activeContextMenuIndex,
               active < paddedApps.count {
                let (appName, bundleId, _) = paddedApps[active]

                if !bundleId.isEmpty {
                    // Match the menu frame in both blur and stroke layers.
                    let menuWidth: CGFloat = 200
                    let menuHeight: CGFloat = 130

                    ZStack {
                        VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                            .frame(width: menuWidth, height: menuHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 6)
                            .allowsHitTesting(false)

                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            .frame(width: menuWidth, height: menuHeight)
                            .allowsHitTesting(false)

                        ContextMenuView(
                            onDismiss: { dismissContextMenus() },
                            appName: appName,
                            bundleId: bundleId,
                            confirmBeforeQuit: appState.confirmBeforeQuit
                        )
                        .padding(6)
                    }
                    .id(contextMenuToken)
                    .transition(appState.reduceMotion ? .opacity : .scale(scale: 0.96).combined(with: .opacity))
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
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didActivateApplicationNotification)) { notification in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
               app.bundleIdentifier != Bundle.main.bundleIdentifier {
                dismissContextMenus()
            }
        }
    }
}

//#Preview {
//    DockView(appState: .init())
//}
