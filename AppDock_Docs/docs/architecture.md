# Architecture

## Architecture Overview

- **SwiftUI App + AppDelegate**: `RecentAppsController` is the SwiftUI entry point while `AppDelegate` owns the status bar item and popover.
- **Shared State**: `AppState` is an `ObservableObject` that publishes the `recentApps` list for the UI.
- **Shared Types**: `AppDockTypes.swift` holds the filter/sort enums used by the UI.
- **Popover UI**: `MenuController` builds the popover host, with `DockView` rendering the grid and menu rows.
- **Workspace Monitoring**: `NSWorkspace` notifications are used to insert new apps as they launch.

## Data Model

- `AppState.recentApps`: Array of tuples `(name: String, bundleid: String, icon: NSImage)`.
- Icons are sized to 64x64 before being stored in state to keep rendering consistent.
- `AppState.filterOption`: Selected `AppFilterOption` for filtering.
- `AppState.sortOption`: Selected `AppSortOption` for sorting.
- `SettingsDefaults`: Centralized `UserDefaults` keys and default values for Settings.
- `SettingsDraft`: Staged settings values applied to `AppState` on demand.

## Runtime Flow

1. `RecentAppsController` starts and wires the `AppDelegate`.
2. `AppDelegate` creates the status bar item and the popover content via `MenuController`.
3. `getRecentApplications()` loads running apps and updates `AppState` on the main thread.
4. `NSWorkspace.didLaunchApplicationNotification` inserts new apps at the front of the list.
5. `DockView` renders the grid and handles interactions (activation, context menu, remove).

## Notifications and Observers

- `NSWorkspace.didLaunchApplicationNotification` inserts new apps at the front.
- `NSApplication.didResignActiveNotification` dismisses context menus.
- A local notification is used to dismiss context menus when tapping outside.
- The popover listens for a custom dismiss event posted by the popover container.

## Entitlements and Permissions

- Entitlements live in `AppDock/AppDock.entitlements` and are mirrored by build settings in `AppDock.xcodeproj/project.pbxproj`.
- Network client access is enabled; sandbox is configured for user-selected read-only files.
