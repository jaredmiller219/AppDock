# Strategy and Matrix

## Testing Strategy

- **AppDockTests** covers logic-level behaviors with local stubs and mocks.
- **AppDockUITests** covers popover, settings, performance, and launch screenshot checks.

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
- Trigger command-click with simulated input (or use UI-test helpers) to open the context menu.
- Open and close the popover repeatedly to check animations and dismissal.
- Open a test app, ensure it appears at the top of the dock list.

## Edge Case Checklist

- Running app missing bundle identifier or launch date is filtered out.
- Running app missing localized name or bundle URL is ignored.
- App is the same bundle as AppDock itself (ignored in launch handler).
- Duplicate bundle identifier launches are de-duplicated.
- Empty list is padded to a fixed 3x4 grid.
- Removing an item adjusts the active context menu index correctly.
