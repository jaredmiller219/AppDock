# Project Layout

- `AppDock/`: SwiftUI app source, settings, assets, entitlements, and dock subcomponents.
- `AppDock/App/RecentApps/`: App entry point, shared state, and app delegate split into focused files.
- `AppDock/DockViewParts/`: Dock-specific subviews and helpers.
- `AppDockTests/`: Unit tests for dock logic, settings defaults, and controller wiring.
- `AppDockUITests/`: UI test helpers plus popover/settings/performance coverage and a launch screenshot baseline.
- `AppDock.xcodeproj/`: Xcode project, schemes, baselines, and workspace metadata.
- `appdock.md`: Root documentation page mirroring the MkDocs index.
