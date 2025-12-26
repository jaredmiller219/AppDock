# Behavior

This section is split into subpages:

- [Status Bar Icon](status-bar-icon.md)
- [Context Menu](context-menu.md)
- [Dock Updates](dock-updates.md)
- [Activation and Relaunch](activation.md)
- [Minimized vs Hidden](minimized-hidden.md)

## High-Level Behavior

- On launch, the app reads the current list of running user apps and displays them in a fixed-size grid.
- When a new app launches, it is inserted at the front of the list.
- When an app quits, it remains in the list (the dock is not pruned on termination).
- Command-clicking an icon opens a context menu for Hide/Quit; command-hover reveals the remove control.
