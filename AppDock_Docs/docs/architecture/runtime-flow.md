# Runtime Flow

1. `RecentAppsController` starts and wires the `AppDelegate`.
2. `AppDelegate` creates the status bar item and the popover content via `MenuController`.
3. `getRecentApplications()` loads running apps and updates `AppState` on the main thread.
4. `NSWorkspace.didLaunchApplicationNotification` inserts new apps at the front of the list.
5. `DockAppList` filters/sorts/pads entries, and `DockView` renders the grid and handles interactions.
