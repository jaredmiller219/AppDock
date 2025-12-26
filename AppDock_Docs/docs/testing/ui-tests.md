# UI Tests

## Creating a New UI Test File

1. In Xcode, `File > New > File...` and choose **UI Test Case Class**.
2. Set the target to `AppDockUITests`.
3. Use `XCUIApplication` to launch and validate UI behavior.

Example skeleton:

```swift
import XCTest

final class NewUITests: XCTestCase {
    @MainActor
    func testMenuOpens() throws {
        let app = XCUIApplication()
        app.launch()
        // Add UI interactions/assertions here
    }
}
```

## UI Test Launch Arguments

When a test needs predictable popovers or status item behavior, use the shared launch arguments in `UITestBase.swift`:

- `--ui-test-mode`: Enables UI-test-only helpers in the app.
- `--ui-test-open-popover`: Opens a dedicated popover window for automation.
- `--ui-test-seed-dock`: Seeds the dock with predictable app entries.
- `--ui-test-status-item-proxy`: Shows a test-only window that toggles the popover.
