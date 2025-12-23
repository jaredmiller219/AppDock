# Reference

## Project Layout

- `AppDock/`: SwiftUI app source, settings, assets, and entitlements.
- `AppDockTests/`: Unit tests for dock logic, settings defaults, and controller wiring.
- `AppDockUITests/`: UI test scaffolding and launch screenshot baseline.
- `AppDock.xcodeproj/`: Xcode project, schemes, baselines, and workspace metadata.
- `AppDock_Docs/`: MkDocs configuration, source docs, and generated site output.
- `Video/`: Narration outlines for explaining key Swift files.
- `appdock.md`: Root documentation page mirroring the MkDocs index.

## Documentation Workflow

- Author docs in `AppDock_Docs/docs/` and keep `appdock.md` in sync.
- MkDocs config lives in `AppDock_Docs/mkdocs.yml`.
- Generated site output is in `AppDock_Docs/site/` (treat as build artifacts).

## File and Folder Reference

### Documentation

- `appdock.md`: Root documentation page and project overview.
- `AppDock_Docs/docs/index.md`: MkDocs source for the documentation site.
- `AppDock_Docs/mkdocs.yml`: MkDocs configuration and theme settings.
- `AppDock_Docs/site/`: Generated documentation site output.

### Application Code

- `AppDock/AppDockTypes.swift`: Shared enums for filter/sort options.
- `AppDock/RecentAppsController.swift`: App entry point, app delegate, shared state, workspace monitoring, and application lifecycle handling.
- `AppDock/MenuController.swift`: Popover host creation and menu row UI wiring for Settings/About/Quit.
- `AppDock/DockView.swift`: Dock grid UI, per-app button logic, context menu overlay, and hover/remove behavior.
- `AppDock/SettingsView.swift`: Settings UI with staged apply and `SettingsDefaults`/`SettingsDraft`.
- `AppDock/SettingsSupport.swift`: Supporting types and helpers for settings behavior.
- `AppDock/AppDock.entitlements`: App entitlements (sandbox, file access, network client).

### Assets

- `AppDock/Assets.xcassets/Contents.json`: Asset catalog manifest.
- `AppDock/Assets.xcassets/AccentColor.colorset/Contents.json`: Accent color definition.
- `AppDock/Assets.xcassets/AppIcon.appiconset/Contents.json`: App icon asset definitions.
- `AppDock/Preview Content/Preview Assets.xcassets/Contents.json`: SwiftUI preview assets.

### Tests

- `AppDockTests/AppDockTests.swift`: Placeholder test suite for future additions.
- `AppDockTests/DockViewTests.swift`: DockView layout and interaction logic tests using stubs.
- `AppDockTests/MenuControllerTests.swift`: Popover controller creation and action wiring tests.
- `AppDockTests/RecentAppsController.swift`: AppDelegate logic tests with mock workspace and running apps.
- `AppDockTests/SettingsDefaultsTests.swift`: Settings default values and restore behavior tests.
- `AppDockUITests/AppDockUITests.swift`: UI test scaffolding.
- `AppDockUITests/AppDockUITestsLaunchTests.swift`: Launch screenshot baseline.

### Xcode Project Files

- `AppDock.xcodeproj/project.pbxproj`: Build configuration, targets, settings, file references.
- `AppDock.xcodeproj/xcshareddata/xcschemes/AppDock.xcscheme`: Shared scheme configuration.
- `AppDock.xcodeproj/xcshareddata/xcbaselines/67C6BDB72D0BE5B9000F25E5.xcbaseline/Info.plist`: Performance baseline metadata.
- `AppDock.xcodeproj/xcshareddata/xcbaselines/67C6BDB72D0BE5B9000F25E5.xcbaseline/E77E07D1-ABB7-406E-9868-B517748CEC08.plist`: Performance baseline data.
- `AppDock.xcodeproj/project.xcworkspace/contents.xcworkspacedata`: Workspace metadata.
- `AppDock.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings`: Shared workspace settings.
- `AppDock.xcodeproj/project.xcworkspace/xcuserdata/jaredm.xcuserdatad/WorkspaceSettings.xcsettings`: User-specific workspace settings.
- `AppDock.xcodeproj/xcuserdata/jaredm.xcuserdatad/xcschemes/xcschememanagement.plist`: User scheme management metadata.
- `AppDock.xcodeproj/xcuserdata/jaredm.xcuserdatad/xcdebugger/Breakpoints_v2.xcbkptlist`: User breakpoint configuration.

### Video Notes

- `Video/MC.swift`: Documentation-only outline for MenuController narration.
- `Video/RAC.swift`: Documentation-only outline for RecentAppsController narration.
- `Video/DV.swift`: Documentation-only outline for DockView narration.
- `Video/SV.swift`: Documentation-only outline for SettingsView narration.
