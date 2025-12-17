# AppDock Documentation

## Overview

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

## Feature Highlights

- Fixed-size grid with padding slots for a consistent layout.
- Command-click context menu with Hide/Quit actions.
- Command-hover remove affordance for manual list cleanup.
- Lightweight menu bar UI with a centered popover.
- App list is derived from `NSWorkspace` running apps and sorted by launch time.
- Built-in filter and sort menu for list customization.
- Settings panel includes grid sizing, labels, and behavior toggles stored in `UserDefaults`.
- Settings apply directly to the grid size, label size, and running indicators.

## Glossary

- **Dock Grid**: The 3x4 grid of app icons rendered in the popover.
- **Popover**: The floating menu bar window that hosts the dock UI.
- **Context Menu**: The overlay with Hide/Quit actions for a single app.
- **App Entry**: Tuple containing `(name, bundleid, icon)` stored in `AppState`.

## Instructions

### Build and Run

1. Open `AppDock.xcodeproj` in Xcode.
2. Select the `AppDock` scheme.
3. Run the app (menu bar icon appears).
4. Click the status item to open the dock popover.

### Using the Dock

- Click an app icon to activate the app.
- Command-click an icon to open the context menu (Hide/Quit).
- Command-hover an icon to reveal the remove “X” button.
- Apps stay listed after they quit when “Keep apps after quit” is enabled.
- Clicking a listed app that is no longer running relaunches it.
- Clicking a minimized app should restore its windows (OS behavior may vary).
- Use the Filter & Sort menu button to switch between running-only and all apps, or reorder by name.
- Use Settings to configure the default filter/sort, grid size, and behavior toggles.
- Click Apply in Settings to push changes into the live dock view.

### Settings

- Open the menu bar app menu, then choose `Settings…`.
- Settings persist in `UserDefaults` via keys defined in `SettingsDefaults`.
- Settings edits are staged and only applied when you click Apply.
- Layout options include grid columns/rows, icon size, and label size.
- Behavior options include label visibility, hover remove, and quit confirmations.
- The bottom-left ellipsis menu provides Restore Defaults and Set as Default.

### Tests

1. In Xcode, select `AppDockTests` or `AppDockUITests` targets.
2. Run the tests from the Test navigator.
3. UI launch tests include a screenshot baseline in `AppDockUITestsLaunchTests`.
4. For unit tests, keep logic isolated and use lightweight mocks (see `AppDockTests/RecentAppsController.swift`).

### Creating a New Unit Test File

1. In Xcode, `File > New > File...` and choose **Unit Test Case Class**.
2. Set the target to `AppDockTests`.
3. Name the file (for example, `DockViewLogicTests.swift`).
4. Import your module with `@testable import AppDock`.
5. Prefer logic-only tests that avoid UI where possible; use lightweight stubs or helpers.

Example skeleton:

```swift
import XCTest
@testable import AppDock

final class DockViewLogicTests: XCTestCase {
    func testExample() {
        // Arrange
        // Act
        // Assert
    }
}
```

### Creating a New UI Test File

1. In Xcode, `File > New > File...` and choose **UI Test Case Class**.
2. Set the target to `AppDockUITests`.
3. Use `XCUIApplication` to launch and validate UI behavior.

Example skeleton:

```swift
import XCTest

final class AppDockNewUITests: XCTestCase {
    @MainActor
    func testMenuOpens() throws {
        let app = XCUIApplication()
        app.launch()
        // Add UI interactions/assertions here
    }
}
```

### Adding a New Dock File (Feature Extension)

If you want another view or module that extends the dock, follow this pattern:

1. Create a Swift file in `AppDock/` (for example, `DockOverlayView.swift`).
2. Keep UI views in SwiftUI (`struct MyView: View`) and avoid global state.
3. If you need shared state, add it to `AppState` or pass it through view initializers.
4. Wire the new view from `DockView` or `MenuController` depending on where it appears.

Example structure:

```swift
import SwiftUI

struct DockOverlayView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
    }
}
```

To display it in the dock, add it to `DockView`:

```swift
DockOverlayView(title: "Now Playing")
```

### Manually Testing the App (Real Usage)

1. Run the app from Xcode.
2. Verify the status bar icon appears.
3. Click the icon to open the popover.
4. Open a new app (Finder, Notes, etc.) and confirm it appears at the front.
5. Quit an app and confirm it stays listed (if “Keep apps after quit” is enabled).
6. Command-click an icon to open the context menu and test Hide/Quit.
7. Command-hover to verify the remove button appears and removes the item.
8. Open Settings from the menu and confirm the window opens.

### Debugging Tips

- Use `NSLog` or unified logging if output is not visible in Xcode's console.
- If the popover isn’t visible, check `popover.contentSize` and the status item configuration in `AppDock/RecentAppsController.swift`.
- If icons are missing, verify the bundle URL and icon retrieval in `makeAppEntry(from:workspace:)`.
- If minimized windows do not restore, this may require Accessibility APIs.
- Menu bar apps can log to Console.app; filter by “AppDock”.
- If filtering appears incorrect, verify the current selection in the Filter & Sort menu and re-open the popover.
- If settings look off, use Restore Defaults in Settings to reset stored values.
- If a quit app still appears, check the “Keep apps after quit” setting.

### Common Development Tasks

- **Change grid size**: Update defaults in `SettingsDefaults` or apply new values in Settings.
- **Adjust popover size**: Update `popover.contentSize` in `AppDock/RecentAppsController.swift`.
- **Add menu actions**: Update `PopoverContentView` in `AppDock/MenuController.swift` and wire new actions in `AppDelegate`.
- **Modify app filtering**: Edit `getRecentApplications()` in `AppDock/RecentAppsController.swift`.
- **Keep apps after quit**: Toggle the setting or adjust `handleTerminatedApp` in `AppDock/RecentAppsController.swift`.
- **Update settings defaults**: Edit `SettingsDefaults` in `AppDock/SettingsView.swift`.
- **Apply settings programmatically**: Call `appState.applySettings(_:)` in `AppDock/RecentAppsController.swift`.

### Entitlements and Permissions

- Entitlements live in `AppDock/AppDock.entitlements` and are mirrored by build settings in `AppDock.xcodeproj/project.pbxproj`.
- Network client access is enabled; sandbox is configured for user-selected read-only files.

## High-Level Behavior

- On launch, the app reads the current list of running user apps and displays them in a fixed-size grid.
- When a new app launches, it is inserted at the front of the list.
- When an app quits, it remains in the list (the dock is not pruned on termination).
- Command-clicking an icon opens a context menu for Hide/Quit; command-hover reveals the remove control.

## Detailed Interaction Behavior

### Status Bar Icon

- The status bar icon is created at launch and uses a system symbol.
- The image is marked as template for automatic light/dark rendering.
- The size is normalized to fit the menu bar.

### Context Menu Lifecycle

- Command-click toggles a per-item context menu state.
- The menu animates in with a scale+fade transition.
- Clicking outside the dock area posts a dismiss notification and closes the menu.
- When switching to another app, the menu is re-instantiated to replay the animation.

### Dock Update Rules

- On launch, the list is populated from `NSWorkspace.shared.runningApplications`.
- Apps are filtered to `.regular` with a bundle identifier and launch date.
- New launches insert at index 0 and dedupe existing bundle identifiers.
- App quits do not remove entries when “Keep apps after quit” is enabled.
- The Filter & Sort menu can further constrain or reorder the visible list.
- Settings can change the default filter/sort choice used at startup.

### App Activation and Relaunch

- Running apps are unhidden and activated with `activateAllWindows`.
- If an app is not running, it is relaunched using `openApplication(at:)`.
- Relaunch uses `NSWorkspace.OpenConfiguration` with `activates = true`.
- Relaunch logic is centralized in `ButtonView` via the `openApp(bundleId:)` helper.

### Minimized vs Hidden

- `unhide()` targets hidden apps; minimized windows should restore on activation.
- Some apps may not restore minimized windows without Accessibility APIs.
- If a specific app does not restore, consider enabling an AX-based restore flow.

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

## Testing Strategy

- **AppDockTests** covers logic-level behaviors with local stubs and mocks.
- **AppDockUITests** provides the Xcode template UI test scaffolding and a launch screenshot baseline.

## Testing Matrix

### Unit Tests (Logic)

- Sorting, filtering, and icon sizing in `getRecentApplications()`.
- Launch insertion and de-duplication in `handleLaunchedApp(_:)`.
- Dock padding math and removal index adjustment.
- Command-click context menu state toggling.
- Settings default values and UserDefaults restore behavior.
- Settings apply behavior and quit-removal handling.

### UI Tests (Launch)

- App launches and is running (foreground or background).
- Launch screenshot captured after startup.

### Integration Test Ideas

- Launch app, open popover, verify dock grid exists.
- Trigger command-click with simulated input (if possible) to open context menu.
- Open and close the popover repeatedly to check animations and dismissal.
- Open a test app, ensure it appears at the top of the dock list.

## Edge Case Checklist

- Running app missing bundle identifier or launch date is filtered out.
- Running app missing localized name or bundle URL is ignored.
- App is the same bundle as AppDock itself (ignored in launch handler).
- Duplicate bundle identifier launches are de-duplicated.
- Empty list is padded to a fixed 3x4 grid.
- Removing an item adjusts the active context menu index correctly.

## Troubleshooting

### Menu Bar Icon Not Showing

- Ensure `makeStatusBarImage()` returns a valid image.
- Verify `statusBarItem.button?.image` is set in `applicationDidFinishLaunching`.

### Popover Does Not Appear

- Verify `statusBarItem.button` is non-nil.
- Check `popover.contentSize` and `popover.show(...)` positioning.

### App Does Not Reactivate

- Confirm the bundle identifier is valid and app URL is found.
- Some apps may ignore activation when sandboxed or in special states.

### Minimized Windows Not Restoring

- Some apps require Accessibility APIs to explicitly unminimize.
- Consider adding an AX-based restore path if this is a requirement.

## Future Enhancements

- Optional removal of quit apps after a timeout or on next launch.
- Accessibility-based window unminimize for consistent restoration.
- User-configurable grid sizing and sorting.
- Theming for icons, labels, and context menu appearance.

## File Reference

### Documentation

- `DOCUMENTATION.md`: This file; full project and file-level documentation.

### Application Code

- `AppDock/AppDockTypes.swift`: Shared enums for filter/sort options.
- `AppDock/RecentAppsController.swift`: App entry point, app delegate, shared state, workspace monitoring, and application lifecycle handling.
- `AppDock/MenuController.swift`: Popover host creation and menu row UI wiring for Settings/About/Quit.
- `AppDock/DockView.swift`: Dock grid UI, per-app button logic, context menu overlay, and hover/remove behavior.
- `AppDock/SettingsView.swift`: Settings UI with staged apply and `SettingsDefaults`/`SettingsDraft`.
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
