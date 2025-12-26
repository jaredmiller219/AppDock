# Project Layout

- `AppDock/`: SwiftUI app source, settings, assets, entitlements, and dock subcomponents.
- `AppDock/App/RecentApps/`: App entry point, shared state, and app delegate split into focused files.
- `AppDock/Menu/`: Popover layout, swipe/drag gestures, and page bar.
- `AppDock/Dock/`: Dock grid, filters, and supporting helpers.
- `AppDock/Dock/Parts/`: Dock-specific subviews and helpers.
- `AppDock/Settings/`: Settings UI and defaults/draft helpers.
- `AppDockTests/`: Unit tests for dock logic, settings defaults, and controller wiring.
- `AppDockUITests/`: UI test helpers plus popover/settings/performance coverage and a launch screenshot baseline.
- `AppDock.xcodeproj/`: Xcode project, schemes, baselines, and workspace metadata.
- `appdock.md`: Root documentation page mirroring the MkDocs index.
