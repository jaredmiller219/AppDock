# Architecture

## Architecture Overview

- **SwiftUI App + AppDelegate**: `RecentAppsController` is the SwiftUI entry point while `AppDelegate` owns the status bar item and popover.
- **Shared State**: `AppState` is an `ObservableObject` that publishes the `recentApps` list for the UI.
- **Shared Types**: `AppDockTypes.swift` holds the filter/sort enums used by the UI.
- **Popover UI**: `MenuController` builds the popover host, with `DockView` rendering the grid and menu rows.
- **Dock Composition**: `DockView` uses `DockAppList` to shape entries and `DockViewParts` for subviews.
- **Workspace Monitoring**: `NSWorkspace` notifications are used to insert new apps as they launch.

## Subpages

- [Data Model](data-model.md)
- [Runtime Flow](runtime-flow.md)
- [Notifications](notifications.md)
