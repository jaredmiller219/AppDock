//
//  AppDockConstants.swift
//  AppDock
//
import CoreGraphics
import Foundation

public enum AppDockConstants {
    // MARK: - Settings

    /// Settings window sizing and sidebar layout.
    ///
    /// - Note: Used by the Settings window to enforce minimum size and sidebar width.
    public enum SettingsUI {
        /// Minimum window size to avoid clipped controls.
        public static let minWidth: CGFloat = 560
        /// Minimum height for the settings window so controls stay visible.
        public static let minHeight: CGFloat = 560
        /// Fixed sidebar width for tabs.
        public static let sidebarWidth: CGFloat = 160
    }

    /// Settings screen spacing and layout metrics.
    ///
    /// - Note: Keeps spacing consistent across Settings headers, sections, and tabs.
    public enum SettingsLayout {
        // Root + header
        /// Root padding keeps content off window edges.
        public static let rootPadding: CGFloat = 20
        /// Header stack spacing for icon/title block.
        public static let headerSpacing: CGFloat = 12
        /// Size of the icon shown in the settings header block.
        public static let headerIconSize: CGFloat = 38
        /// Font size for the header icon when rendered as a symbol.
        public static let headerIconFontSize: CGFloat = 18
        /// Spacing between title/subtitle text.
        public static let headerTextSpacing: CGFloat = 4

        // Content + columns
        /// Spacing between content blocks in the main pane.
        public static let contentSpacing: CGFloat = 12
        /// Gutter between columns when using multi-column layout.
        public static let contentColumnSpacing: CGFloat = 16

        // Sidebar + tabs
        /// Vertical spacing between sidebar sections to keep tab groups distinct.
        public static let sidebarSpacing: CGFloat = 6
        /// Spacing between tab rows in the sidebar list.
        public static let tabRowSpacing: CGFloat = 8
        /// Padding inside tab buttons to increase hit area.
        public static let tabButtonPaddingVertical: CGFloat = 6
        /// Horizontal padding inside tab buttons to balance vertical hit area.
        public static let tabButtonPaddingHorizontal: CGFloat = 8
        /// Corner radius for the tab button background pill.
        public static let tabButtonCornerRadius: CGFloat = 6
        /// Reserved width for tab icons so labels align vertically.
        public static let tabIconWidth: CGFloat = 16

        // Sections
        /// Spacing between major sections on a settings page.
        public static let sectionSpacing: CGFloat = 16
        /// Spacing between rows inside a section group.
        public static let sectionInnerSpacing: CGFloat = 10
        /// Top padding to separate section headers from prior content.
        public static let sectionTopPadding: CGFloat = 4

        // Value + content helpers
        /// Minor top padding used to align simple layout content with headers.
        public static let simpleContentTopPadding: CGFloat = 1
        /// Fixed width for value labels so numeric columns align.
        public static let valueLabelWidth: CGFloat = 36
        /// Maximum width for the mode picker to prevent layout overflow.
        public static let modePickerMaxWidth: CGFloat = 240
    }

    /// Settings control ranges for steppers and sliders.
    ///
    /// - Note: Defines slider/stepper bounds and steps for Settings controls.
    public enum SettingsRanges {
        // Grid
        /// Grid columns range (min/max allowed).
        public static let gridColumnsMin = 2
        /// Maximum number of columns available in the dock grid layout.
        public static let gridColumnsMax = 6
        /// Grid rows range (min/max allowed).
        public static let gridRowsMin = 2
        /// Maximum number of rows available in the dock grid layout.
        public static let gridRowsMax = 8

        // Icon sizing
        /// Slider bounds and step for icon size adjustments.
        public static let iconSizeMin: Double = 32
        /// Upper bound for icon size scaling in settings.
        public static let iconSizeMax: Double = 96
        /// Step increment used when adjusting icon size in the slider.
        public static let iconSizeStep: Double = 2

        // Label sizing
        /// Slider bounds and step for label size adjustments.
        public static let labelSizeMin: Double = 6
        /// Upper bound for label size scaling in settings.
        public static let labelSizeMax: Double = 14
        /// Step increment used when adjusting label size in the slider.
        public static let labelSizeStep: Double = 1
    }

    /// Settings window default size.
    ///
    /// - Note: Default window size before user-driven resizing.
    public enum SettingsWindow {
        /// Default window size before user resize.
        public static let width: CGFloat = 480
        /// Default height for the settings window before user resize.
        public static let height: CGFloat = 640
    }

    // MARK: - Status Item

    /// Status bar icon sizing.
    ///
    /// - Note: Keeps the menu bar icon aligned with system sizing.
    public enum StatusBarIcon {
        /// Target size for the menu bar icon so it matches system metrics.
        public static let size: CGFloat = 18
    }

    /// Standard app icon sizing in the dock.
    ///
    /// - Note: Target icon size for dock thumbnails in the popover grid.
    public enum AppIcon {
        /// Target size for dock icon thumbnails in the popover grid.
        public static let size: CGFloat = 64
    }

    // MARK: - Accessibility

    /// Accessibility identifiers used by UI tests.
    ///
    /// - Note: Stable identifiers for UI tests and accessibility lookups.
    public enum Accessibility {
        // Dock grid + icons
        /// Prefix for dock slot identifiers used in UI tests.
        public static let dockSlotPrefix = "DockSlot-"
        /// Identifier for empty slot placeholders in UI tests.
        public static let emptySlot = "DockEmptySlot"
        /// Prefix for dock icon identifiers in the accessibility tree.
        public static let iconPrefix = "DockIcon-"
        /// Identifier for the filter and sort menu button.
        public static let dockFilterMenu = "DockFilterMenu"

        // Menu rows + buttons
        /// Prefix for Settings/About/Quit menu row identifiers.
        public static let menuRowPrefix = "MenuRow-"
        /// Prefix for menu app row identifiers.
        public static let menuAppRowPrefix = "MenuAppRow-"
        /// Prefix for shortcut recorder identifiers.
        public static let shortcutRecorderPrefix = "ShortcutRecorder-"
        /// Prefix for shortcut recorder value identifiers.
        public static let shortcutRecorderValuePrefix = "ShortcutRecorderValue-"
        /// Identifier for the dock context menu container.
        public static let contextMenu = "DockContextMenu"
        /// Identifier for the favorites empty state.
        public static let favoritesEmptyState = "FavoritesEmptyState"
        /// Identifier for the status item button in the menu bar.
        public static let statusItem = "AppDockStatusItem"
        /// Status item label used for UI lookups and assertions.
        public static let statusItemLabel = "AppDock"
        /// Window title used when opening the UI test popover window.
        public static let uiTestWindow = "AppDock UI Test"
        /// Prefix for menu page bar button identifiers.
        public static let menuPageButtonPrefix = "MenuPage-"
        /// Prefix for menu page header label identifiers.
        public static let menuPageHeaderPrefix = "MenuPageHeader-"
        /// Identifier for the UI test trackpad swipe trigger.
        public static let uiTestTrackpadSwipeLeft = "UITestTrackpadSwipeLeft"
        /// Identifier for the UI test context menu dismiss trigger.
        public static let uiTestDismissContextMenu = "UITestDismissContextMenu"
        /// Identifier for the UI test status item proxy button.
        public static let uiTestStatusItemProxy = "UITestStatusItemProxy"
        /// Window title used when opening the UI test shortcuts panel.
        public static let uiTestShortcutsWindow = "AppDock Shortcuts Panel"
        /// Prefix for UI test shortcut action buttons.
        public static let uiTestShortcutPrefix = "UITestShortcut-"
        /// Identifier for the UI test activation request label.
        public static let uiTestActivationRequest = "UITestActivationRequest"
        /// Identifier for the UI test swipe mode label (left).
        public static let uiTestSwipeModeLeft = "UITestSwipeModeLeft"
        /// Identifier for the UI test swipe mode label (right).
        public static let uiTestSwipeModeRight = "UITestSwipeModeRight"
        /// Identifier for the Settings menu layout picker.
        public static let settingsMenuLayoutPicker = "SettingsMenuLayoutPicker"
    }

    // MARK: - Timing

    /// Timing constants for hover/remove behaviors.
    ///
    /// - Note: Shared delays for hover and interaction behaviors.
    public enum Timing {
        /// Delay before showing remove button on hover.
        public static let removeButtonDelay: TimeInterval = 0.5
    }

    // MARK: - Menu Popover

    /// Popover sizing used by menu bar UI.
    ///
    /// - Note: Popover size used by the menu bar UI.
    public enum MenuPopover {
        /// Baseline width for the popover before adding extra grid columns.
        /// - Note: Adjusting this changes the default popover width across layouts.
        public static let defaultWidth: CGFloat = 260
        /// Fixed popover height to match the menu bar design.
        /// - Note: Keep in sync with visual chrome to avoid clipping.
        public static let height: CGFloat = 460
        /// Spacing between dock columns when calculating popover width.
        public static let columnSpacing: CGFloat = 16
    }

    /// Popover layout padding for headers, content, and footers.
    ///
    /// - Note: Padding values shared across menu pages and sections.
    public enum MenuLayout {
        // Header
        /// Horizontal padding for the header row content.
        public static let headerPaddingHorizontal: CGFloat = 12
        /// Top padding above the header content.
        public static let headerPaddingTop: CGFloat = 8
        /// Bottom padding below the header content.
        public static let headerPaddingBottom: CGFloat = 6

        // Divider + dock
        /// Horizontal padding around dividers to align with content edges.
        public static let dividerPaddingHorizontal: CGFloat = 8
        /// Horizontal padding applied to the dock grid container.
        public static let dockPaddingHorizontal: CGFloat = 8
        /// Top padding above the dock grid in the popover.
        public static let dockPaddingTop: CGFloat = 6
        /// Bottom padding below the dock grid in the popover.
        public static let dockPaddingBottom: CGFloat = 10

        // Recents + favorites
        /// Horizontal padding for the recents list content.
        public static let recentsPaddingHorizontal: CGFloat = 24
        /// Top padding for the recents list section.
        public static let recentsPaddingTop: CGFloat = 10
        /// Bottom padding for the recents list section.
        public static let recentsPaddingBottom: CGFloat = 10
        /// Horizontal padding for the favorites empty state content.
        public static let favoritesPaddingHorizontal: CGFloat = 12
        /// Top padding for the favorites empty state section.
        public static let favoritesPaddingTop: CGFloat = 16
        /// Bottom padding for the favorites empty state section.
        public static let favoritesPaddingBottom: CGFloat = 12

        // Actions
        /// Horizontal padding for the actions menu rows.
        public static let actionsPaddingHorizontal: CGFloat = 24
        /// Top padding for the actions menu rows.
        public static let actionsPaddingTop: CGFloat = 8
        /// Bottom padding for the actions menu rows.
        public static let actionsPaddingBottom: CGFloat = 12

        // Bottom bar
        /// Top padding above the bottom divider line.
        public static let bottomDividerPaddingTop: CGFloat = 6
        /// Horizontal padding around the page bar.
        public static let bottomBarPaddingHorizontal: CGFloat = 8
        /// Bottom padding below the page bar to separate from window edge.
        public static let bottomBarPaddingBottom: CGFloat = 6
    }

    /// Header pill styling for filter and page labels.
    ///
    /// - Note: Styling for the header pill used on menu pages.
    public enum MenuHeader {
        /// Horizontal padding inside the header pill.
        public static let paddingHorizontal: CGFloat = 10
        /// Vertical padding inside the header pill.
        public static let paddingVertical: CGFloat = 8
        /// Corner radius for the header pill shape.
        public static let cornerRadius: CGFloat = 6
    }

    /// Bottom page bar styling and spacing.
    ///
    /// - Note: Sizing and spacing for the bottom tab bar.
    public enum MenuPageBar {
        // Layout
        /// Spacing between page buttons in the bar.
        public static let spacing: CGFloat = 8
        /// Icon font size for tab bar symbols.
        public static let iconFontSize: CGFloat = 13
        /// Spacing between the icon and label in each tab.
        public static let labelSpacing: CGFloat = 3
        /// Vertical padding inside each tab button for touch targets.
        public static let paddingVertical: CGFloat = 6

        // Chrome
        /// Corner radius for the active tab highlight background.
        public static let cornerRadius: CGFloat = 8
        /// Top padding above the page bar row.
        public static let topPadding: CGFloat = 2
    }

    /// Gesture thresholds for menu navigation.
    ///
    /// - Note: Thresholds and timings for swipe/drag menu navigation.
    public enum MenuGestures {
        // Swipe distance
        /// Minimum horizontal distance before a swipe is considered valid.
        /// - Note: Lower values feel more sensitive but increase accidental paging.
        public static let swipeThreshold: CGFloat = 30
        /// Minimum drag distance to start tracking a manual drag.
        /// - Note: Prevents minor pointer jitter from triggering drags.
        public static let dragMinimumDistance: CGFloat = 12
        /// Fraction of popover width required to commit a page change.
        /// - Note: Higher fractions reduce accidental page changes.
        public static let swipePageThresholdFraction: CGFloat = 0.4

        // Animation pacing
        /// Duration for cancel snap-back.
        /// - Note: Longer durations feel softer but can feel sluggish.
        public static let dragCancelDuration: TimeInterval = 0.35
        /// Duration for commit snap-forward.
        /// - Note: Keep shorter than cancel to maintain forward momentum.
        public static let dragCommitDuration: TimeInterval = 0.25
    }

    // MARK: - Menu Content

    /// Recents/favorites list spacing.
    ///
    /// - Note: Spacing for recents and favorites list layouts.
    public enum MenuAppList {
        /// Spacing between the list title and the list content.
        public static let spacing: CGFloat = 12
        /// Spacing between rows in the list.
        public static let rowSpacing: CGFloat = 8
    }

    /// Row styling for app list entries.
    ///
    /// - Note: Row layout for app list entries.
    public enum MenuAppRow {
        // Icon + spacing
        /// Spacing between the icon and the app name label.
        public static let spacing: CGFloat = 10
        /// App icon size within the list rows.
        public static let iconSize: CGFloat = 28
        /// Corner radius for app icons inside list rows.
        public static let iconCornerRadius: CGFloat = 6

        // Padding + chrome
        /// Horizontal padding for row content inside list rows.
        public static let paddingHorizontal: CGFloat = 10
        /// Vertical padding for row content inside list rows.
        public static let paddingVertical: CGFloat = 6
        /// Corner radius for the row background.
        public static let cornerRadius: CGFloat = 8
    }

    /// Empty-state layout for menu pages.
    ///
    /// - Note: Spacing for empty state layouts on menu pages.
    public enum MenuEmptyState {
        /// Spacing between empty-state elements.
        public static let spacing: CGFloat = 8
        /// Vertical padding around empty-state block.
        public static let paddingVertical: CGFloat = 16
    }

    /// Generic menu row styling (Settings/About/Quit).
    ///
    /// - Note: Padding and chrome for Settings/About/Quit rows.
    public enum MenuRow {
        /// Horizontal padding for action menu rows.
        public static let paddingHorizontal: CGFloat = 12
        /// Vertical padding for action menu rows.
        public static let paddingVertical: CGFloat = 8
        /// Corner radius for action menu rows.
        public static let cornerRadius: CGFloat = 6
    }

    // MARK: - Dock Layout

    /// Dock grid layout and paging interaction thresholds.
    ///
    /// - Note: Dock grid geometry and paging thresholds.
    public enum DockLayout {
        // Grid + spacing
        /// Spacing between columns in the dock grid.
        public static let columnSpacing: CGFloat = 16
        /// Extra trailing space to keep grid alignment balanced.
        public static let extraSpace: CGFloat = 15

        // Swipe thresholds
        /// Minimum distance to start a dock page swipe.
        /// - Note: Keeps vertical scrolling from triggering paging.
        public static let swipeMinimumDistance: CGFloat = 20
        /// Distance threshold required to change dock pages.
        /// - Note: Larger values reduce accidental page flips.
        public static let swipeThreshold: CGFloat = 40

        // Dividers + tiles
        /// Padding below the page indicator row.
        public static let pageIndicatorBottomPadding: CGFloat = 2
        /// Vertical padding around row divider lines.
        public static let rowDividerPaddingVertical: CGFloat = 5
        /// Divider line width between dock rows.
        public static let rowDividerLineWidth: CGFloat = 1
        /// Spacing between tiles in the dock grid.
        public static let tileSpacing: CGFloat = 3
    }

    /// Page dots indicator styling for dock paging.
    ///
    /// - Note: Sizing and chrome for dock page indicator dots.
    public enum DockPageIndicator {
        // Dot sizing
        /// Diameter of each page indicator dot.
        public static let dotSize: CGFloat = 6
        /// Spacing between adjacent dots.
        public static let spacing: CGFloat = 6

        // Padding + chrome
        /// Horizontal padding inside the page indicator pill.
        public static let paddingHorizontal: CGFloat = 10
        /// Vertical padding inside the page indicator pill.
        public static let paddingVertical: CGFloat = 6
        /// Background opacity for the indicator capsule.
        /// - Note: Keep low to avoid overpowering dock content.
        public static let capsuleOpacity: Double = 0.25
        /// Padding above the indicator row.
        public static let topPadding: CGFloat = 6
        /// Opacity for inactive page dots.
        /// - Note: Lower values emphasize the active page dot.
        public static let inactiveOpacity: Double = 0.4
    }

    /// Context menu chrome used inside the dock grid.
    ///
    /// - Note: Container styling for dock context menus.
    public enum DockContextMenu {
        /// Width of the dock context menu container.
        public static let width: CGFloat = 200
        /// Height of the dock context menu container.
        public static let height: CGFloat = 130
        /// Corner radius for the context menu container.
        public static let cornerRadius: CGFloat = 10
        /// Shadow radius for the floating menu chrome.
        /// - Note: Larger values soften the shadow edge.
        public static let shadowRadius: CGFloat = 6
        /// Opacity for the context menu border stroke.
        /// - Note: Keep subtle to avoid heavy outlines.
        public static let strokeOpacity: Double = 0.08
        /// Stroke width for the context menu border.
        public static let strokeLineWidth: CGFloat = 1
        /// Inner padding between menu content and container edges.
        public static let padding: CGFloat = 6
        /// Scale applied during the context menu show animation.
        /// - Note: Slightly below 1.0 helps the pop-in feel less abrupt.
        public static let transitionScale: CGFloat = 0.96
    }

    // Dock label bubble styling.
    public enum DockLabel {
        /// Horizontal padding for the dock label bubble.
        public static let horizontalPadding: CGFloat = 5
        /// Vertical padding for the dock label bubble.
        public static let verticalPadding: CGFloat = 2
        /// Corner radius for the dock label bubble.
        public static let cornerRadius: CGFloat = 3
        /// Background opacity for the dock label bubble.
        /// - Note: Lower values keep the label readable without blocking icons.
        public static let backgroundOpacity: Double = 0.25
    }

    // Running indicator dot sizing.
    public enum DockRunningIndicator {
        /// Diameter of the running indicator dot.
        public static let size: CGFloat = 6
        /// Padding around the running indicator dot.
        public static let padding: CGFloat = 4
    }

    // Hover/selection styling for dock buttons.
    public enum DockButton {
        /// Corner radius for the dock button selection overlay.
        public static let overlayCornerRadius: CGFloat = 8
        /// Line width for the dock button selection overlay.
        public static let overlayLineWidth: CGFloat = 2
        /// Font size for the remove button glyph.
        public static let removeButtonFontSize: CGFloat = 10
        /// Padding around the remove button glyph.
        public static let removeButtonPadding: CGFloat = 2
    }

    // Context menu button sizing and padding.
    public enum ContextMenu {
        /// Vertical spacing between context menu buttons.
        public static let spacing: CGFloat = 8
        /// Minimum height for each context menu button.
        public static let buttonMinHeight: CGFloat = 36
        /// Horizontal padding inside context menu buttons.
        public static let paddingHorizontal: CGFloat = 14
        /// Vertical padding inside context menu buttons.
        public static let paddingVertical: CGFloat = 10
        /// Fixed width for context menu buttons.
        public static let width: CGFloat = 160
    }

    // Card group box styling shared by settings sections.
    public enum CardStyle {
        /// Spacing between stacked card sections.
        public static let spacing: CGFloat = 10
        /// Inner padding for card-style containers.
        public static let padding: CGFloat = 12
        /// Corner radius for card-style containers.
        public static let cornerRadius: CGFloat = 12
        /// Opacity for the card border stroke.
        /// - Note: Keep low to avoid heavy outlines in Settings.
        public static let strokeOpacity: Double = 0.2
        /// Line width for the card border stroke.
        public static let strokeLineWidth: CGFloat = 1
        /// Opacity for the card drop shadow.
        /// - Note: Subtle shadow keeps panels separated without strong depth.
        public static let shadowOpacity: Double = 0.05
        /// Blur radius for the card drop shadow.
        public static let shadowRadius: CGFloat = 6
        /// X offset for the card drop shadow.
        public static let shadowOffsetX: CGFloat = 0
        /// Y offset for the card drop shadow.
        public static let shadowOffsetY: CGFloat = 3
    }

    // Empty slot placeholder styling.
    public enum EmptySlot {
        /// Label text for empty dock slots.
        public static let labelText = "Empty"
        /// Corner radius for the empty slot outline.
        public static let cornerRadius: CGFloat = 5
        /// Opacity for the empty slot border stroke.
        public static let strokeOpacity: Double = 0.4
        /// Font size for the empty slot label text.
        public static let fontSize: CGFloat = 8
        /// Line width for the empty slot border stroke.
        public static let strokeLineWidth: CGFloat = 1
    }

    // Icon corner radius in dock tiles.
    public enum IconView {
        /// Corner radius for dock tile icons.
        public static let cornerRadius: CGFloat = 8
    }

    // CLI args used to control UI tests.
    public enum Testing {
        /// Launch argument to enable UI test mode overrides.
        public static let uiTestMode = "--ui-test-mode"
        /// Launch argument to open the popover window for UI tests.
        public static let uiTestOpenPopover = "--ui-test-open-popover"
        /// Launch argument to seed dock data for UI tests.
        public static let uiTestSeedDock = "--ui-test-seed-dock"
        /// Launch argument to disable activation during UI tests.
        public static let uiTestDisableActivation = "--ui-test-disable-activation"
        /// Launch argument to open the settings window for UI tests.
        public static let uiTestOpenSettings = "--ui-test-open-settings"
        /// Launch argument to open both popover and settings windows.
        public static let uiTestOpenPopovers = "--ui-test-open-popovers"
        /// Launch argument to force the simple menu layout during UI tests.
        public static let uiTestMenuSimple = "--ui-test-menu-simple"
        /// Launch argument to show the status item proxy window during UI tests.
        public static let uiTestStatusItemProxy = "--ui-test-status-item-proxy"
        /// Launch argument to show the shortcuts panel during UI tests.
        public static let uiTestShortcutsPanel = "--ui-test-shortcuts-panel"
    }
}
