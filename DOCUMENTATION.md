# AppDock Documentation

## Overview

AppDock is a macOS menu bar app that presents a dock-style grid of running apps. The app runs as a status item with a popover UI, and it exposes quick actions (hide, quit) via a command-click context menu.

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
- Apps stay listed after they quit (by design).

### Settings

- Open the menu bar app menu, then choose `Settings…`.
- The settings window is a simple SwiftUI view and can be expanded with new controls.

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
5. Quit an app and confirm it stays listed.
6. Command-click an icon to open the context menu and test Hide/Quit.
7. Command-hover to verify the remove button appears and removes the item.
8. Open Settings from the menu and confirm the window opens.

### Debugging Tips

- Use `print` statements in `getRecentApplications()` or `handleLaunchedApp(_:)` to trace app updates.
- If the popover isn’t visible, check `popover.contentSize` and the status item configuration in `AppDock/RecentAppsController.swift`.
- If icons are missing, verify the bundle URL and icon retrieval in `makeAppEntry(from:workspace:)`.

### Common Development Tasks

- **Change grid size**: Edit constants in `AppDock/DockView.swift` (`numberOfColumns`, `numberOfRows`, and sizing constants).
- **Adjust popover size**: Update `popover.contentSize` in `AppDock/RecentAppsController.swift`.
- **Add menu actions**: Update `PopoverContentView` in `AppDock/MenuController.swift` and wire new actions in `AppDelegate`.
- **Modify app filtering**: Edit `getRecentApplications()` in `AppDock/RecentAppsController.swift`.
- **Keep apps after quit**: Launch updates are handled in `handleLaunchedApp`; termination does not remove items.

### Entitlements and Permissions

- Entitlements live in `AppDock/AppDock.entitlements` and are mirrored by build settings in `AppDock.xcodeproj/project.pbxproj`.
- Network client access is enabled; sandbox is configured for user-selected read-only files.

## High-Level Behavior

- On launch, the app reads the current list of running user apps and displays them in a fixed-size grid.
- When a new app launches, it is inserted at the front of the list.
- When an app quits, it remains in the list (the dock is not pruned on termination).
- Command-clicking an icon opens a context menu for Hide/Quit; command-hover reveals the remove control.

## Architecture Overview

- **SwiftUI App + AppDelegate**: `RecentAppsController` is the SwiftUI entry point while `AppDelegate` owns the status bar item and popover.
- **Shared State**: `AppState` is an `ObservableObject` that publishes the `recentApps` list for the UI.
- **Popover UI**: `MenuController` builds the popover host, with `DockView` rendering the grid and menu rows.
- **Workspace Monitoring**: `NSWorkspace` notifications are used to insert new apps as they launch.

## Data Model

- `AppState.recentApps`: Array of tuples `(name: String, bundleid: String, icon: NSImage)`.
- Icons are sized to 64x64 before being stored in state to keep rendering consistent.

## Runtime Flow

1. `RecentAppsController` starts and wires the `AppDelegate`.
2. `AppDelegate` creates the status bar item and the popover content via `MenuController`.
3. `getRecentApplications()` loads running apps and updates `AppState` on the main thread.
4. `NSWorkspace.didLaunchApplicationNotification` inserts new apps at the front of the list.
5. `DockView` renders the grid and handles interactions (activation, context menu, remove).

## Testing Strategy

- **AppDockTests** covers logic-level behaviors with local stubs and mocks.
- **AppDockUITests** provides the Xcode template UI test scaffolding and a launch screenshot baseline.

## File Reference

### Documentation

- `DOCUMENTATION.md`: This file; full project and file-level documentation.

### Application Code

- `AppDock/RecentAppsController.swift`: App entry point, app delegate, shared state, workspace monitoring, and application lifecycle handling.
- `AppDock/MenuController.swift`: Popover host creation and menu row UI wiring for Settings/About/Quit.
- `AppDock/DockView.swift`: Dock grid UI, per-app button logic, context menu overlay, and hover/remove behavior.
- `AppDock/SettingsView.swift`: Minimal settings window UI.
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
