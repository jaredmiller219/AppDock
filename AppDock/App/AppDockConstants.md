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
  - `AppDock/App/RecentAppsController.swift`
- Notes: Keeps the Settings window readable and prevents cramped layouts.

### SettingsLayout
- Purpose: Layout spacing and sizing for the Settings UI.
- Defined in: `AppDock/App/AppDockConstants.swift#L18`
- Used in:
  - `AppDock/Settings/SettingsView.swift`
- Notes: Keeps section spacing, header sizing, and tab spacing consistent.

### SettingsRanges
- Purpose: Valid ranges for settings controls (steppers/sliders).
- Defined in: `AppDock/App/AppDockConstants.swift#L41`
- Used in:
  - `AppDock/Settings/SettingsView.swift`
- Notes: Enforces valid ranges for user-facing controls.

### SettingsWindow
- Purpose: Default Settings window size.
- Defined in: `AppDock/App/AppDockConstants.swift#L55`
- Used in:
  - `AppDock/App/RecentAppsController.swift`
- Notes: Creates the NSWindow with consistent dimensions.

## Menu Bar Popover

Popover sizing and layout used by the menu bar popover content.

### MenuPopover
- Purpose: Base popover size and column spacing.
- Defined in: `AppDock/App/AppDockConstants.swift#L90`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Keeps AppKit popover size in sync with SwiftUI content.

### MenuLayout
- Purpose: Padding and spacing for header/content/footer areas.
- Defined in: `AppDock/App/AppDockConstants.swift#L97`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Aligns the filter header, content stack, and bottom bar.

### MenuHeader
- Purpose: Styling for the filter/page header pill.
- Defined in: `AppDock/App/AppDockConstants.swift#L120`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Keeps header look consistent across pages.

### MenuPageBar
- Purpose: Bottom tab bar layout metrics.
- Defined in: `AppDock/App/AppDockConstants.swift#L127`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Aligns tab icons/labels and maintains tap targets.

### MenuAppList
- Purpose: Recents/favorites list spacing.
- Defined in: `AppDock/App/AppDockConstants.swift#L137`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Keeps list sections readable.

### MenuAppRow
- Purpose: App row sizing and padding.
- Defined in: `AppDock/App/AppDockConstants.swift#L143`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Ensures icons/text align and rows look balanced.

### MenuEmptyState
- Purpose: Empty state spacing.
- Defined in: `AppDock/App/AppDockConstants.swift#L153`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Gives empty pages a consistent look.

### MenuRow
- Purpose: Actions row padding and corner radius.
- Defined in: `AppDock/App/AppDockConstants.swift#L159`
- Used in:
  - `AppDock/Menu/MenuController.swift`
- Notes: Keeps action rows consistent across layouts.

## Dock UI

Grid sizing, paging, and decoration values for the dock grid.

### DockLayout
- Purpose: Grid spacing, page swipe thresholds, and divider spacing.
- Defined in: `AppDock/App/AppDockConstants.swift#L166`
- Used in:
  - `AppDock/Dock/DockView.swift`
- Notes: Controls layout geometry and paging gestures.

### DockPageIndicator
- Purpose: Dot sizes/spacing for the paging indicator.
- Defined in: `AppDock/App/AppDockConstants.swift#L178`
- Used in:
  - `AppDock/Dock/DockView.swift`
- Notes: Provides iOS-style page dots and background pill sizing.

### DockContextMenu
- Purpose: Context menu size and styling.
- Defined in: `AppDock/App/AppDockConstants.swift#L189`
- Used in:
  - `AppDock/Dock/DockView.swift`
- Notes: Keeps the floating menu consistent in size and shape.

### DockLabel
- Purpose: App label bubble padding and background.
- Defined in: `AppDock/App/AppDockConstants.swift#L201`
- Used in:
  - `AppDock/Dock/DockView.swift`
- Notes: Ensures labels are legible and uniformly padded.

### DockRunningIndicator
- Purpose: Running dot size/padding.
- Defined in: `AppDock/App/AppDockConstants.swift#L209`
- Used in:
  - `AppDock/Dock/DockView.swift`
- Notes: Keeps the running indicator subtle and consistent.

### DockButton
- Purpose: Hover outline and remove button sizing.
- Defined in: `AppDock/App/AppDockConstants.swift#L215`
- Used in:
  - `AppDock/Dock/Parts/ButtonView.swift`
- Notes: Standardizes hover highlight and remove button layout.

### IconView
- Purpose: App icon corner radius.
- Defined in: `AppDock/App/AppDockConstants.swift#L254`
- Used in:
  - `AppDock/Dock/Parts/IconView.swift`
- Notes: Keeps icon rounding consistent.

### EmptySlot
- Purpose: Placeholder slot styling.
- Defined in: `AppDock/App/AppDockConstants.swift#L245`
- Used in:
  - `AppDock/Dock/Parts/EmptySlot.swift`
- Notes: Renders empty grid slots with a consistent treatment.

## App Icons and Status

Shared icon sizing constants.

### AppIcon
- Purpose: Standard icon size used in dock entries.
- Defined in: `AppDock/App/AppDockConstants.swift#L66`
- Used in:
  - `AppDock/App/RecentAppsController.swift`
- Notes: Resizes app icons to a consistent grid size.

### StatusBarIcon
- Purpose: Status item symbol size.
- Defined in: `AppDock/App/AppDockConstants.swift#L61`
- Used in:
  - `AppDock/App/RecentAppsController.swift`
- Notes: Ensures the menu bar icon is crisp and aligned.

## Misc

Shared identifiers and visual system values.

### Accessibility
- Purpose: Accessibility identifiers used in UI tests and view lookup.
- Defined in: `AppDock/App/AppDockConstants.swift#L71`
- Used in:
  - `AppDock/App/AppDockConstants.swift` and shared across UI views/tests
- Notes: Provides stable identifiers for automation and accessibility.

### Timing
- Purpose: Animation and interaction delays.
- Defined in: `AppDock/App/AppDockConstants.swift#L85`
- Used in:
  - `AppDock/Dock/Parts/ButtonView.swift`
- Notes: Controls hover delay for the remove button.

### ContextMenu
- Purpose: Button sizing/padding in the dock context menu.
- Defined in: `AppDock/App/AppDockConstants.swift#L223`
- Used in:
  - `AppDock/Dock/Parts/ContextMenuView.swift`
- Notes: Keeps menu buttons uniform.

### CardStyle
- Purpose: Settings GroupBox styling.
- Defined in: `AppDock/App/AppDockConstants.swift#L232`
- Used in:
  - `AppDock/Settings/SettingsSupport.swift`
- Notes: Shared card appearance for Settings sections.

### Testing
- Purpose: UI test launch arguments.
- Defined in: `AppDock/App/AppDockConstants.swift#L259`
- Used in:
  - `AppDock/App/AppDockConstants.swift`
  - `AppDock/App/RecentAppsController.swift`
- Notes: Configures test-only behaviors at launch.
