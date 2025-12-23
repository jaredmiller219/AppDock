# Overview

AppDock is a macOS menu bar app that presents a dock-style grid of running apps. The app runs as a status item with a popover UI, and it exposes quick actions (hide, quit) via a command-click context menu.

## Recent Changes

- Dock updates in real time when new apps launch (launch events insert at the front).
- Quitting apps stays listed when “Keep apps after quit” is enabled.
- Context menu dismisses when clicking outside and re-animates when switching apps.
- Status bar icon now uses a system symbol with a fallback image.
- Relaunch uses `NSWorkspace.OpenConfiguration` and `openApplication(at:)` APIs.
- Minimized apps are restored via `unhide()` + `activateAllWindows` and a relaunch event.
- Added a Filter & Sort menu button for running-only and name-based ordering.
- Moved shared filter/sort enums into `AppDock/AppDockTypes.swift`.
- Added a SettingsView narration outline in the Video folder.
- Expanded Settings with persistent layout, behavior, and accessibility preferences.
- Settings changes now apply on demand and update the live dock layout.

## Quick Start

1. Open `AppDock.xcodeproj` in Xcode.
2. Select the `AppDock` scheme.
3. Run the app (menu bar icon appears).
4. Click the status item to open the dock popover.
