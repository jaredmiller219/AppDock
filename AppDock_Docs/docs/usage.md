# Usage

## Build and Run

1. Open `AppDock.xcodeproj` in Xcode.
2. Select the `AppDock` scheme.
3. Run the app (menu bar icon appears).
4. Click the status item to open the dock popover.

## Using the Dock

- Click an app icon to activate the app.
- Command-click an icon to open the context menu (Hide/Quit).
- Command-hover an icon to reveal the remove “X” button.
- Apps stay listed after they quit when “Keep apps after quit” is enabled.
- Clicking a listed app that is no longer running relaunches it.
- Clicking a minimized app should restore its windows (OS behavior may vary).
- Use the Filter & Sort menu button to switch between running-only and all apps, or reorder by name.
- Use Settings to configure the default filter/sort, grid size, and behavior toggles.
- Click Apply in Settings to push changes into the live dock view.

## Settings

- Open Settings with `⌘,` or use the menu bar app menu and choose `Settings…`.
- Settings persist in `UserDefaults` via keys defined in `SettingsDefaults`.
- Settings edits are staged and only applied when you click Apply.
- Layout options include grid columns/rows, icon size, and label size.
- Behavior options include label visibility, hover remove, and quit confirmations.
- The bottom-left ellipsis menu provides Restore Defaults and Set as Default.

## Manually Testing the App (Real Usage)

1. Run the app from Xcode.
2. Verify the status bar icon appears.
3. Click the icon to open the popover.
4. Open a new app (Finder, Notes, etc.) and confirm it appears at the front.
5. Quit an app and confirm it stays listed (if “Keep apps after quit” is enabled).
6. Command-click an icon to open the context menu and test Hide/Quit.
7. Command-hover to verify the remove button appears and removes the item.
8. Open Settings from the menu and confirm the window opens.
