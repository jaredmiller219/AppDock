# Features

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

## Future Enhancements

- Optional removal of quit apps after a timeout or on next launch.
- Accessibility-based window unminimize for consistent restoration.
- User-configurable grid sizing and sorting.
- Theming for icons, labels, and context menu appearance.
