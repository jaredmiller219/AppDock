# Data Model

- `AppState.recentApps`: Array of tuples `(name: String, bundleid: String, icon: NSImage)`.
- Icons are sized to 64x64 before being stored in state to keep rendering consistent.
- `AppState.filterOption`: Selected `AppFilterOption` for filtering.
- `AppState.sortOption`: Selected `AppSortOption` for sorting.
- `SettingsDefaults`: Centralized `UserDefaults` keys and default values for Settings.
- `SettingsDraft`: Staged settings values applied to `AppState` on demand.
