# Activation and Relaunch

- Running apps are unhidden and activated with `activateAllWindows`.
- If an app is not running, it is relaunched using `openApplication(at:)`.
- Relaunch uses `NSWorkspace.OpenConfiguration` with `activates = true`.
- Relaunch logic is centralized in `ButtonView` via the `openApp(bundleId:)` helper.
