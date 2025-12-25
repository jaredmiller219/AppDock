# Application Code

- `AppDock/AppDockTypes.swift`: Shared enums for filter/sort options.
- `AppDock/RecentAppsController.swift`: App entry point, app delegate, shared state, workspace monitoring, and application lifecycle handling.
- `AppDock/MenuController.swift`: Popover host creation and menu row UI wiring for Settings/About/Quit.
- `AppDock/DockView.swift`: Dock grid UI and context menu overlay composition.
- `AppDock/DockAppList.swift`: Pure helper for filtering, sorting, and padding dock entries.
- `AppDock/DockViewParts/`: Dock subviews and helpers (ButtonView, ContextMenuView, IconView, EmptySlot, VisualEffectBlur, notifications).
- `AppDock/SettingsView.swift`: Settings UI with staged apply and `SettingsDefaults`/`SettingsDraft`.
- `AppDock/SettingsSupport.swift`: Supporting types and helpers for settings behavior.
