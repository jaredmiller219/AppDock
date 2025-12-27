# AppDock Constants

This file documents the UI constants defined in `AppDockConstants` and points to where each group is used.
Each section below explains what the constants do, where they are defined, and which views or controllers consume them.

## Settings

Settings window sizing and layout behavior, used by the Settings window and its SwiftUI layout.

### SettingsUI

- Purpose: Settings window sizing and sidebar width.
- Defined in: `AppDock/App/AppDockConstants.swift#L11`
- Used in:
  - `AppDock/Settings/SettingsView.swift`
  - `AppDock/Settings/Views/SettingsSidebarView.swift`
  - `AppDock/App/RecentApps/AppDelegate/Delegate.swift`
- Notes: Keeps the Settings window readable and prevents cramped layouts.

```swift
public enum SettingsUI {
    public static let minWidth: CGFloat = 560
    public static let minHeight: CGFloat = 560
    public static let sidebarWidth: CGFloat = 160
}
```

### SettingsLayout

- Purpose: Layout spacing and sizing for the Settings UI.
- Defined in: `AppDock/App/AppDockConstants.swift#L18`
- Used in:
  - `AppDock/Settings/SettingsView.swift`
  - `AppDock/Settings/Views/SettingsHeaderView.swift`
  - `AppDock/Settings/Views/SettingsSidebarView.swift`
  - `AppDock/Settings/Views/SettingsContentView.swift`
  - `AppDock/Settings/Views/SettingsFooterView.swift`
  - `AppDock/Settings/Tabs/*.swift`
- Notes: Keeps section spacing, header sizing, and tab spacing consistent.

```swift
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
```

### SettingsRanges

- Purpose: Valid ranges for settings controls (steppers/sliders).
- Defined in: `AppDock/App/AppDockConstants.swift#L41`
- Used in:
  - `AppDock/Settings/Tabs/LayoutSettingsTab.swift`
- Notes: Enforces valid ranges for user-facing controls.

```swift
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
```

### SettingsWindow

- Purpose: Default Settings window size.
- Defined in: `AppDock/App/AppDockConstants.swift#L55`
- Used in:
  - `AppDock/App/RecentApps/AppDelegate/Delegate.swift`
- Notes: Creates the NSWindow with consistent dimensions.

```swift
public enum SettingsWindow {
    public static let width: CGFloat = 480
    public static let height: CGFloat = 640
}
```

## Menu Bar Popover

Popover sizing and layout used by the menu bar popover content.

Note: Menu UI code is split across `AppDock/Menu/MenuController.swift`, `AppDock/Menu/PopoverContentView.swift`,
`AppDock/Menu/MenuPageBar.swift`, `AppDock/Menu/MenuPages.swift`, and `AppDock/Menu/MenuGestures.swift`.

### MenuPopover

- Purpose: Base popover size and column spacing.
- Defined in: `AppDock/App/AppDockConstants.swift#L90`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Keeps AppKit popover size in sync with SwiftUI content.

```swift
public enum MenuPopover {
    public static let defaultWidth: CGFloat = 260
    public static let height: CGFloat = 460
    public static let columnSpacing: CGFloat = 16
}
```

### MenuLayout

- Purpose: Padding and spacing for header/content/footer areas.
- Defined in: `AppDock/App/AppDockConstants.swift#L97`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Aligns the filter header, content stack, and bottom bar.

```swift
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
```

### MenuHeader

- Purpose: Styling for the filter/page header pill.
- Defined in: `AppDock/App/AppDockConstants.swift#L120`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Keeps header look consistent across pages.

```swift
public enum MenuHeader {
    public static let paddingHorizontal: CGFloat = 10
    public static let paddingVertical: CGFloat = 8
    public static let cornerRadius: CGFloat = 6
}
```

### MenuPageBar

- Purpose: Bottom tab bar layout metrics.
- Defined in: `AppDock/App/AppDockConstants.swift#L127`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Aligns tab icons/labels and maintains tap targets.

```swift
public enum MenuPageBar {
    public static let spacing: CGFloat = 8
    public static let iconFontSize: CGFloat = 13
    public static let labelSpacing: CGFloat = 3
    public static let paddingVertical: CGFloat = 6
    public static let cornerRadius: CGFloat = 8
    public static let topPadding: CGFloat = 2
}
```

### MenuGestures

- Purpose: Swipe/drag thresholds for tab navigation.
- Defined in: `AppDock/App/AppDockConstants.swift#L137`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Adjusts how sensitive the menu tab switching feels.

```swift
public enum MenuGestures {
    public static let swipeThreshold: CGFloat = 30
    public static let dragMinimumDistance: CGFloat = 12
    public static let swipePageThresholdFraction: CGFloat = 0.5
    public static let dragCancelDuration: TimeInterval = 0.35
    public static let dragCommitDuration: TimeInterval = 0.28
}
```

### MenuAppList

- Purpose: Recents/favorites list spacing.
- Defined in: `AppDock/App/AppDockConstants.swift#L137`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Keeps list sections readable.

```swift
public enum MenuAppList {
    public static let spacing: CGFloat = 12
    public static let rowSpacing: CGFloat = 8
}
```

### MenuAppRow

- Purpose: App row sizing and padding.
- Defined in: `AppDock/App/AppDockConstants.swift#L143`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Ensures icons/text align and rows look balanced.

```swift
public enum MenuAppRow {
    public static let spacing: CGFloat = 10
    public static let iconSize: CGFloat = 28
    public static let iconCornerRadius: CGFloat = 6
    public static let paddingHorizontal: CGFloat = 10
    public static let paddingVertical: CGFloat = 6
    public static let cornerRadius: CGFloat = 8
}
```

### MenuEmptyState

- Purpose: Empty state spacing.
- Defined in: `AppDock/App/AppDockConstants.swift#L153`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Gives empty pages a consistent look.

```swift
public enum MenuEmptyState {
    public static let spacing: CGFloat = 8
    public static let paddingVertical: CGFloat = 16
}
```

### MenuRow

- Purpose: Actions row padding and corner radius.
- Defined in: `AppDock/App/AppDockConstants.swift#L159`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Keeps action rows consistent across layouts.

```swift
public enum MenuRow {
    public static let paddingHorizontal: CGFloat = 12
    public static let paddingVertical: CGFloat = 8
    public static let cornerRadius: CGFloat = 6
}
```

## Dock UI

Grid sizing, paging, and decoration values for the dock grid.

### DockLayout

- Purpose: Grid spacing, page swipe thresholds, and divider spacing.
- Defined in: `AppDock/App/AppDockConstants.swift#L166`
- Used in:
  - `AppDock/Dock/DockView.swift`
- Notes: Controls layout geometry and paging gestures.

```swift
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
```

### DockPageIndicator

- Purpose: Dot sizes/spacing for the paging indicator.
- Defined in: `AppDock/App/AppDockConstants.swift#L178`
- Used in:
  - `AppDock/Dock/DockView.swift`
- Notes: Provides iOS-style page dots and background pill sizing.

```swift
public enum DockPageIndicator {
    public static let dotSize: CGFloat = 6
    public static let spacing: CGFloat = 6
    public static let paddingHorizontal: CGFloat = 10
    public static let paddingVertical: CGFloat = 6
    public static let capsuleOpacity: Double = 0.25
    public static let topPadding: CGFloat = 6
    public static let inactiveOpacity: Double = 0.4
}
```

### DockContextMenu

- Purpose: Context menu size and styling.
- Defined in: `AppDock/App/AppDockConstants.swift#L189`
- Used in:
  - `AppDock/Dock/DockView.swift`
- Notes: Keeps the floating menu consistent in size and shape.

```swift
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
```

### DockLabel

- Purpose: App label bubble padding and background.
- Defined in: `AppDock/App/AppDockConstants.swift#L201`
- Used in:
  - `AppDock/Dock/DockView.swift`
- Notes: Ensures labels are legible and uniformly padded.

```swift
public enum DockLabel {
    public static let horizontalPadding: CGFloat = 5
    public static let verticalPadding: CGFloat = 2
    public static let cornerRadius: CGFloat = 3
    public static let backgroundOpacity: Double = 0.25
}
```

### DockRunningIndicator

- Purpose: Running dot size/padding.
- Defined in: `AppDock/App/AppDockConstants.swift#L209`
- Used in:
  - `AppDock/Dock/DockView.swift`
- Notes: Keeps the running indicator subtle and consistent.

```swift
public enum DockRunningIndicator {
    public static let size: CGFloat = 6
    public static let padding: CGFloat = 4
}
```

### DockButton

- Purpose: Hover outline and remove button sizing.
- Defined in: `AppDock/App/AppDockConstants.swift#L215`
- Used in:
  - `AppDock/Dock/Parts/ButtonView.swift`
- Notes: Standardizes hover highlight and remove button layout.

```swift
public enum DockButton {
    public static let overlayCornerRadius: CGFloat = 8
    public static let overlayLineWidth: CGFloat = 2
    public static let removeButtonFontSize: CGFloat = 10
    public static let removeButtonPadding: CGFloat = 2
}
```

### IconView

- Purpose: App icon corner radius.
- Defined in: `AppDock/App/AppDockConstants.swift#L254`
- Used in:
  - `AppDock/Dock/Parts/IconView.swift`
- Notes: Keeps icon rounding consistent.

```swift
public enum IconView {
    public static let cornerRadius: CGFloat = 8
}
```

### EmptySlot

- Purpose: Placeholder slot styling.
- Defined in: `AppDock/App/AppDockConstants.swift#L245`
- Used in:
  - `AppDock/Dock/Parts/EmptySlot.swift`
- Notes: Renders empty grid slots with a consistent treatment.

```swift
public enum EmptySlot {
    public static let labelText = "Empty"
    public static let cornerRadius: CGFloat = 5
    public static let strokeOpacity: Double = 0.4
    public static let fontSize: CGFloat = 8
    public static let strokeLineWidth: CGFloat = 1
}
```

## App Icons and Status

Shared icon sizing constants.

### AppIcon

- Purpose: Standard icon size used in dock entries.
- Defined in: `AppDock/App/AppDockConstants.swift#L66`
- Used in:
  - `AppDock/App/RecentApps/AppDelegate/UITestSupport.swift`
- Notes: Resizes app icons to a consistent grid size.

```swift
public enum AppIcon {
    public static let size: CGFloat = 64
}
```

### StatusBarIcon

- Purpose: Status item symbol size.
- Defined in: `AppDock/App/AppDockConstants.swift#L61`
- Used in:
  - `AppDock/App/RecentApps/AppDelegate/Delegate.swift`
- Notes: Ensures the menu bar icon is crisp and aligned.

```swift
public enum StatusBarIcon {
    public static let size: CGFloat = 18
}
```

## Misc

Shared identifiers and visual system values, grouped by feature area in `AppDockConstants`. The Swift file now uses Quick Help-style doc comments with a summary and `- Note:` for enums, plus fuller per-constant descriptions. Use this doc as an index and the code comments for details.

Notes: Thresholds, opacities, and animation timings include extra `- Note:` guidance inline in the Swift file. Use Quick Help in Xcode to see the expanded per-constant explanations.

### Accessibility

- Purpose: Accessibility identifiers used in UI tests and view lookup.
- Defined in: `AppDock/App/AppDockConstants.swift#L71`
- Used in:
  - `AppDock/App/AppDockConstants.swift` and shared across UI views/tests
- Notes: Provides stable identifiers for automation and accessibility.

```swift
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
    public static let menuPageHeaderPrefix = "MenuPageHeader-"
    public static let uiTestTrackpadSwipeLeft = "UITestTrackpadSwipeLeft"
    public static let uiTestDismissContextMenu = "UITestDismissContextMenu"
    public static let uiTestStatusItemProxy = "UITestStatusItemProxy"
}
```

### Timing

- Purpose: Animation and interaction delays.
- Defined in: `AppDock/App/AppDockConstants.swift#L85`
- Used in:
  - `AppDock/Dock/Parts/ButtonView.swift`
- Notes: Controls hover delay for the remove button.

```swift
public enum Timing {
    public static let removeButtonDelay: TimeInterval = 0.5
}
```

### ContextMenu

- Purpose: Button sizing/padding in the dock context menu.
- Defined in: `AppDock/App/AppDockConstants.swift#L223`
- Used in:
  - `AppDock/Dock/Parts/ContextMenuView.swift`
- Notes: Keeps menu buttons uniform.

```swift
public enum ContextMenu {
    public static let spacing: CGFloat = 8
    public static let buttonMinHeight: CGFloat = 36
    public static let paddingHorizontal: CGFloat = 14
    public static let paddingVertical: CGFloat = 10
    public static let width: CGFloat = 160
}
```

### CardStyle

- Purpose: Settings GroupBox styling.
- Defined in: `AppDock/App/AppDockConstants.swift#L232`
- Used in:
  - `AppDock/Settings/SettingsSupport.swift`
- Notes: Shared card appearance for Settings sections.

```swift
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
```

### Testing

- Purpose: UI test launch arguments.
- Defined in: `AppDock/App/AppDockConstants.swift#L259`
- Used in:
  - `AppDock/App/AppDockConstants.swift`
  - `AppDock/App/RecentApps/AppDelegate/UITestSupport.swift`
- Notes: Configures test-only behaviors at launch.

```swift
public enum Testing {
    public static let uiTestMode = "--ui-test-mode"
    public static let uiTestOpenPopover = "--ui-test-open-popover"
    public static let uiTestSeedDock = "--ui-test-seed-dock"
    public static let uiTestDisableActivation = "--ui-test-disable-activation"
    public static let uiTestOpenSettings = "--ui-test-open-settings"
    public static let uiTestOpenPopovers = "--ui-test-open-popovers"
    public static let uiTestMenuSimple = "--ui-test-menu-simple"
    public static let uiTestStatusItemProxy = "--ui-test-status-item-proxy"
}
```
