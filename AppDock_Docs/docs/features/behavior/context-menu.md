# Context Menu

## Lifecycle

- Command-click toggles a per-item context menu state.
- The menu animates in with a scale+fade transition.
- Clicking outside the dock area posts a dismiss notification and closes the menu.
- When switching to another app, the menu is re-instantiated to replay the animation.
