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

## Key visualizer (show pressed keys during UI tests)

There are two ways to see which keys are being pressed while UI tests run:

- External overlay (recommended): install KeyCastr and run it before executing UI tests. KeyCastr shows a small on-screen overlay with the keys being pressed system-wide.

  - Install via Homebrew Cask:

  ```bash
  brew install --cask keycastr
  open -a KeyCastr
  ```

  - Grant Accessibility permission when prompted (System Settings → Privacy & Security → Accessibility) so KeyCastr can observe keystrokes.

- In-app visualizer (deterministic for tests): the project includes `KeyVisualizer.swift` which displays a small overlay when UI tests launch the app. It is triggered when the environment variable `SHOW_KEY_VISUALIZER=1` is present or when the app detects it's running under XCTest.

Files involved:

- `App/KeyVisualizer.swift` — the visualizer implementation that creates an overlay and listens for key events.
- `App/RecentApps/RecentAppsController.swift` — calls `KeyVisualizer.startIfRunningUITests()` at app startup.
- `AppDockUITests/UITestBase.swift` — UI test helper methods set `app.launchEnvironment["SHOW_KEY_VISUALIZER"] = "1"` so the visualizer starts for tests.

Notes and troubleshooting:

- If you don't see keys when running tests, try running KeyCastr (external) first — it captures system events and is most reliable for synthetic events produced by XCTest.
- The in-app visualizer uses a local event monitor and may not show synthetic events in some configurations; Accessibility permission may be required for global event capture.
- Check for the `KeyVisualizer: starting` message in the system log to confirm the visualizer started:

```bash
log show --style syslog --predicate 'eventMessage contains "KeyVisualizer:"' --last 5m
```
