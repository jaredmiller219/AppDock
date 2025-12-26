//
//  AppDockConstants.swift
//  AppDock
//

import Foundation
import CoreGraphics

public enum AppDockConstants {
    // Settings window sizing and sidebar layout.
    public enum SettingsUI {
        public static let minWidth: CGFloat = 560
        public static let minHeight: CGFloat = 560
        public static let sidebarWidth: CGFloat = 160
    }

    // Settings screen spacing and layout metrics.
    public enum SettingsLayout {
        public static let rootPadding: CGFloat = 20
        public static let headerSpacing: CGFloat = 12
        public static let headerIconSize: CGFloat = 38
        public static let headerIconFontSize: CGFloat = 18
        public static let headerTextSpacing: CGFloat = 4
        public static let contentSpacing: CGFloat = 12
        public static let contentColumnSpacing: CGFloat = 16
        public static let sidebarSpacing: CGFloat = 6
        public static let tabRowSpacing: CGFloat = 8
        public static let tabButtonPaddingVertical: CGFloat = 6
        public static let tabButtonPaddingHorizontal: CGFloat = 8
        public static let tabButtonCornerRadius: CGFloat = 6
        public static let tabIconWidth: CGFloat = 16
        public static let sectionSpacing: CGFloat = 16
        public static let sectionInnerSpacing: CGFloat = 10
        public static let sectionTopPadding: CGFloat = 4
        public static let simpleContentTopPadding: CGFloat = 1
        public static let valueLabelWidth: CGFloat = 36
        public static let modePickerMaxWidth: CGFloat = 240
    }

    // Settings control ranges for steppers and sliders.
    public enum SettingsRanges {
        public static let gridColumnsMin = 2
        public static let gridColumnsMax = 6
        public static let gridRowsMin = 2
        public static let gridRowsMax = 8
        public static let iconSizeMin: Double = 32
        public static let iconSizeMax: Double = 96
        public static let iconSizeStep: Double = 2
        public static let labelSizeMin: Double = 6
        public static let labelSizeMax: Double = 14
        public static let labelSizeStep: Double = 1
    }

    // Settings window default size.
    public enum SettingsWindow {
        public static let width: CGFloat = 480
        public static let height: CGFloat = 640
    }

    // Status bar icon sizing.
    public enum StatusBarIcon {
        public static let size: CGFloat = 18
    }

    // Standard app icon sizing in the dock.
    public enum AppIcon {
        public static let size: CGFloat = 64
    }

    // Accessibility identifiers used by UI tests.
    public enum Accessibility {
        public static let dockSlotPrefix = "DockSlot-"
        public static let dockFilterMenu = "DockFilterMenu"
        public static let menuRowPrefix = "MenuRow-"
        public static let contextMenu = "DockContextMenu"
        public static let emptySlot = "DockEmptySlot"
        public static let iconPrefix = "DockIcon-"
        public static let statusItem = "AppDockStatusItem"
        public static let statusItemLabel = "AppDock"
        public static let uiTestWindow = "AppDock UI Test"
        public static let menuPageButtonPrefix = "MenuPage-"
    }

    // Timing constants for hover/remove behaviors.
    public enum Timing {
        public static let removeButtonDelay: TimeInterval = 0.5
    }

    // Popover sizing used by menu bar UI.
    public enum MenuPopover {
        public static let defaultWidth: CGFloat = 260
        public static let height: CGFloat = 460
        public static let columnSpacing: CGFloat = 16
    }

    // Popover layout padding for headers, content, and footers.
    public enum MenuLayout {
        public static let headerPaddingHorizontal: CGFloat = 12
        public static let headerPaddingTop: CGFloat = 8
        public static let headerPaddingBottom: CGFloat = 6
        public static let dividerPaddingHorizontal: CGFloat = 8
        public static let dockPaddingHorizontal: CGFloat = 8
        public static let dockPaddingTop: CGFloat = 6
        public static let dockPaddingBottom: CGFloat = 10
        public static let recentsPaddingHorizontal: CGFloat = 12
        public static let recentsPaddingTop: CGFloat = 10
        public static let recentsPaddingBottom: CGFloat = 12
        public static let favoritesPaddingHorizontal: CGFloat = 12
        public static let favoritesPaddingTop: CGFloat = 16
        public static let favoritesPaddingBottom: CGFloat = 12
        public static let actionsPaddingHorizontal: CGFloat = 8
        public static let actionsPaddingTop: CGFloat = 8
        public static let actionsPaddingBottom: CGFloat = 12
        public static let bottomDividerPaddingTop: CGFloat = 6
        public static let bottomBarPaddingHorizontal: CGFloat = 8
        public static let bottomBarPaddingBottom: CGFloat = 6
    }

    // Header pill styling for filter and page labels.
    public enum MenuHeader {
        public static let paddingHorizontal: CGFloat = 10
        public static let paddingVertical: CGFloat = 8
        public static let cornerRadius: CGFloat = 6
    }

    // Bottom page bar styling and spacing.
    public enum MenuPageBar {
        public static let spacing: CGFloat = 8
        public static let iconFontSize: CGFloat = 13
        public static let labelSpacing: CGFloat = 3
        public static let paddingVertical: CGFloat = 6
        public static let cornerRadius: CGFloat = 8
        public static let topPadding: CGFloat = 2
    }

    // Gesture thresholds for menu navigation.
    public enum MenuGestures {
        public static let swipeThreshold: CGFloat = 30
        public static let dragMinimumDistance: CGFloat = 12
        public static let swipePageThresholdFraction: CGFloat = 0.4
        public static let dragCancelDuration: TimeInterval = 0.35
        public static let dragCommitDuration: TimeInterval = 0.28
    }

    // Recents/favorites list spacing.
    public enum MenuAppList {
        public static let spacing: CGFloat = 12
        public static let rowSpacing: CGFloat = 8
    }

    // Row styling for app list entries.
    public enum MenuAppRow {
        public static let spacing: CGFloat = 10
        public static let iconSize: CGFloat = 28
        public static let iconCornerRadius: CGFloat = 6
        public static let paddingHorizontal: CGFloat = 10
        public static let paddingVertical: CGFloat = 6
        public static let cornerRadius: CGFloat = 8
    }

    // Empty-state layout for menu pages.
    public enum MenuEmptyState {
        public static let spacing: CGFloat = 8
        public static let paddingVertical: CGFloat = 16
    }

    // Generic menu row styling (Settings/About/Quit).
    public enum MenuRow {
        public static let paddingHorizontal: CGFloat = 12
        public static let paddingVertical: CGFloat = 8
        public static let cornerRadius: CGFloat = 6
    }

    // Dock grid layout and paging interaction thresholds.
    public enum DockLayout {
        public static let columnSpacing: CGFloat = 16
        public static let extraSpace: CGFloat = 15
        public static let swipeMinimumDistance: CGFloat = 20
        public static let swipeThreshold: CGFloat = 40
        public static let pageIndicatorBottomPadding: CGFloat = 2
        public static let rowDividerPaddingVertical: CGFloat = 5
        public static let rowDividerLineWidth: CGFloat = 1
        public static let tileSpacing: CGFloat = 3
    }

    // Page dots indicator styling for dock paging.
    public enum DockPageIndicator {
        public static let dotSize: CGFloat = 6
        public static let spacing: CGFloat = 6
        public static let paddingHorizontal: CGFloat = 10
        public static let paddingVertical: CGFloat = 6
        public static let capsuleOpacity: Double = 0.25
        public static let topPadding: CGFloat = 6
        public static let inactiveOpacity: Double = 0.4
    }

    // Context menu chrome used inside the dock grid.
    public enum DockContextMenu {
        public static let width: CGFloat = 200
        public static let height: CGFloat = 130
        public static let cornerRadius: CGFloat = 10
        public static let shadowRadius: CGFloat = 6
        public static let strokeOpacity: Double = 0.08
        public static let strokeLineWidth: CGFloat = 1
        public static let padding: CGFloat = 6
        public static let transitionScale: CGFloat = 0.96
    }

    // Dock label bubble styling.
    public enum DockLabel {
        public static let horizontalPadding: CGFloat = 5
        public static let verticalPadding: CGFloat = 2
        public static let cornerRadius: CGFloat = 3
        public static let backgroundOpacity: Double = 0.25
    }

    // Running indicator dot sizing.
    public enum DockRunningIndicator {
        public static let size: CGFloat = 6
        public static let padding: CGFloat = 4
    }

    // Hover/selection styling for dock buttons.
    public enum DockButton {
        public static let overlayCornerRadius: CGFloat = 8
        public static let overlayLineWidth: CGFloat = 2
        public static let removeButtonFontSize: CGFloat = 10
        public static let removeButtonPadding: CGFloat = 2
    }

    // Context menu button sizing and padding.
    public enum ContextMenu {
        public static let spacing: CGFloat = 8
        public static let buttonMinHeight: CGFloat = 36
        public static let paddingHorizontal: CGFloat = 14
        public static let paddingVertical: CGFloat = 10
        public static let width: CGFloat = 160
    }

    // Card group box styling shared by settings sections.
    public enum CardStyle {
        public static let spacing: CGFloat = 10
        public static let padding: CGFloat = 12
        public static let cornerRadius: CGFloat = 12
        public static let strokeOpacity: Double = 0.2
        public static let strokeLineWidth: CGFloat = 1
        public static let shadowOpacity: Double = 0.05
        public static let shadowRadius: CGFloat = 6
        public static let shadowOffsetX: CGFloat = 0
        public static let shadowOffsetY: CGFloat = 3
    }

    // Empty slot placeholder styling.
    public enum EmptySlot {
        public static let labelText = "Empty"
        public static let cornerRadius: CGFloat = 5
        public static let strokeOpacity: Double = 0.4
        public static let fontSize: CGFloat = 8
        public static let strokeLineWidth: CGFloat = 1
    }

    // Icon corner radius in dock tiles.
    public enum IconView {
        public static let cornerRadius: CGFloat = 8
    }

    // CLI args used to control UI tests.
    public enum Testing {
        public static let uiTestMode = "--ui-test-mode"
        public static let uiTestOpenPopover = "--ui-test-open-popover"
        public static let uiTestSeedDock = "--ui-test-seed-dock"
        public static let uiTestDisableActivation = "--ui-test-disable-activation"
        public static let uiTestOpenSettings = "--ui-test-open-settings"
        public static let uiTestOpenPopovers = "--ui-test-open-popovers"
        public static let uiTestMenuSimple = "--ui-test-menu-simple"
    }
}
