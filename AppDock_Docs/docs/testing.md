# Testing

## Running Tests

1. In Xcode, select `AppDockTests` or `AppDockUITests` targets.
2. Run the tests from the Test navigator.
3. UI launch tests include a screenshot baseline in `AppDockUITestsLaunchTests`.
4. For unit tests, keep logic isolated and use lightweight mocks (see `AppDockTests/RecentAppsController.swift`).

## Creating a New Unit Test File

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

## Creating a New UI Test File

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
- Settings UI test opens the window via `⌘,` and verifies Apply + ellipsis actions.

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
