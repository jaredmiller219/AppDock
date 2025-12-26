# Application Code

- `AppDock/App/AppDockTypes.swift`: Shared enums for filter/sort, menu layout, and page navigation.
- `AppDock/App/RecentApps/RecentAppsController.swift`: App entry point (SwiftUI `App`).
- `AppDock/App/RecentApps/AppState.swift`: Shared app state and settings bindings.
- `AppDock/App/RecentApps/AppDelegate/Delegate.swift`: Status item setup, popover wiring, and lifecycle.
- `AppDock/App/RecentApps/AppDelegate/RecentApps.swift`: Recent app tracking helpers.
- `AppDock/App/RecentApps/AppDelegate/UITestSupport.swift`: UI test overrides and fixtures.
- `AppDock/App/RecentApps/AppDelegate/Actions.swift`: About/Settings/Quit handlers.
- `AppDock/Menu/MenuController.swift`: Popover host creation and menu row UI wiring for Settings/About/Quit.
- `AppDock/Menu/PopoverContentView.swift`: Popover layout and swipe/drag navigation.
- `AppDock/Menu/MenuGestures.swift`: Trackpad + drag gesture capture for menu pages.
- `AppDock/Menu/MenuSwipeLogic.swift`: Swipe threshold and page navigation math.
- `AppDock/Menu/MenuPageBar.swift`: Bottom tab bar UI.
- `AppDock/Menu/MenuPages.swift`: Page content builders (dock/recents/favorites/actions).
- `AppDock/Dock/DockView.swift`: Dock grid UI and context menu overlay composition.
- `AppDock/Dock/DockAppList.swift`: Pure helper for filtering, sorting, and padding dock entries.
- `AppDock/Dock/Parts/`: Dock subviews and helpers (ButtonView, ContextMenuView, IconView, EmptySlot, VisualEffectBlur, notifications).
- `AppDock/Settings/SettingsView.swift`: Settings UI with staged apply and `SettingsDefaults`/`SettingsDraft`.
- `AppDock/Settings/SettingsSupport.swift`: Supporting types and helpers for settings behavior.
