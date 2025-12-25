# Future Enhancements

- Optional removal of quit apps after a timeout or on next launch.
- Accessibility-based window unminimize for consistent restoration.
- User-configurable grid sizing and sorting.
- Theming for icons, labels, and context menu appearance.

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
