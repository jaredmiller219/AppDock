# Future Enhancements

- Optional removal of quit apps after a timeout or on next launch.
- Accessibility-based window unminimize for consistent restoration.
- User-configurable grid sizing and sorting.
- Theming for icons, labels, and context menu appearance.
- Theme packs with presets (Classic, Minimal, High-contrast, Custom).
- Theme editor with live preview (colors, label styles, icon treatment).
- Optional per-theme layouts (grid sizing, spacing, icon/label scale).

## Quit App Cleanup

Provide an optional cleanup policy for apps that have been quit. This keeps the dock tidy while still supporting workflows where users want a short-lived history of recent apps. The policy should be configurable (timeout vs. on next launch) and respect "Keep apps after quit" when enabled.

## Accessibility Restore

Improve app restoration using accessibility APIs to unminimize and re-focus windows consistently. This should be opt-in and fail gracefully when the app or window does not allow AX control, falling back to existing `unhide()` and activation behavior.

## Grid Sizing and Sorting

Expose grid sizing and sorting preferences directly to users, including column/row bounds and default sort order. Changes should update the live dock layout and persist in settings so the popover opens with the chosen layout.

## Theme System

Add a theme system that controls icon, label, and menu styling in one place. Theme values should be applied consistently across dock tiles, context menu styling, and the popover chrome.

### Theme Packs

Ship a set of preset themes (Classic, Minimal, High-contrast, Custom) to provide quick starts without manual customization. Each pack should define colors, label styles, and icon treatments.

### Theme Editor

Offer a lightweight theme editor with live preview. Users should be able to tweak colors, label style, and icon treatment, with safe defaults and a reset-to-pack option.

### Per-Theme Layouts

Allow themes to optionally override layout values like grid size, spacing, and icon/label scale. This lets a compact theme differ materially from a spacious or accessibility-focused theme.

## Next Up: Paged Menu System

Goal: add multiple pages inside the popover menu with a bottom button bar and animated transitions, similar to iOS page dots or tab bar paging.

Recommended approach:

- Add a `MenuPage` enum that lists pages (Dock, Favorites, Recents, Settings shortcuts, etc).
- Replace the single `DockView` in `PopoverContentView` with a paged container.
- Use a custom bottom bar with icon buttons (SF Symbols) and labels, wired to the current page.
- Animate page changes with a horizontal slide + fade (respect `reduceMotion`).
- Keep page state in `AppState` so the menu opens on the last used page.
- Provide keyboard shortcuts for page navigation (e.g., `⌘1`, `⌘2`, `⌘3`).

Suggested file touch points:

- `AppDock/MenuController.swift` for the page host and bottom bar UI.
- `AppDock/AppDockTypes.swift` for `MenuPage` definitions.
- `AppDock/RecentAppsController.swift` for default page selection and persistence.

Testing ideas:

- UI test that switches pages and verifies the expected content appears.
- Unit tests for the page selection reducer/state changes.
