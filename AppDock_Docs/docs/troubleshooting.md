# Troubleshooting

## Debugging Tips

- Use `NSLog` or unified logging if output is not visible in Xcode's console.
- If the popover isn’t visible, check `popover.contentSize` and the status item configuration in `AppDock/RecentAppsController.swift`.
- If icons are missing, verify the bundle URL and icon retrieval in `makeAppEntry(from:workspace:)`.
- If minimized windows do not restore, this may require Accessibility APIs.
- Menu bar apps can log to Console.app; filter by “AppDock”.
- If filtering appears incorrect, verify the current selection in the Filter & Sort menu and re-open the popover.
- If settings look off, use Restore Defaults in the Settings ellipsis menu.
- If a quit app still appears, check the “Keep apps after quit” setting.

## Menu Bar Icon Not Showing

- Ensure `makeStatusBarImage()` returns a valid image.
- Verify `statusBarItem.button?.image` is set in `applicationDidFinishLaunching`.

## Popover Does Not Appear

- Verify `statusBarItem.button` is non-nil.
- Check `popover.contentSize` and `popover.show(...)` positioning.

## App Does Not Reactivate

- Confirm the bundle identifier is valid and app URL is found.
- Some apps may ignore activation when sandboxed or in special states.

## Minimized Windows Not Restoring

- Some apps require Accessibility APIs to explicitly unminimize.
- Consider adding an AX-based restore path if this is a requirement.
