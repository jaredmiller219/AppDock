# Professional Polish Checklist

Use this list as a finishing pass to make AppDock feel production-ready.

## Logging and Diagnostics

- [x] Replace ad-hoc `print` statements with `Logger` and gate under a debug setting.
- [ ] Ensure logging is quiet in release builds.

## Icon and Visual Assets

- [ ] Verify app icon assets are crisp at 1x/2x/3x.
- [ ] Use a template-style status bar icon that reads well in light/dark modes.

## Accessibility

- [ ] Confirm labels, hints, and identifiers for menu items and interactive controls.
  - ensure accessibilityLabel, accessibilityHint, and accessibilityIdentifier exist where needed;
- [ ] Verify VoiceOver order and hit targets.

## Empty States and Copy

- [ ] Make empty-state copy consistent and action-oriented.
- [ ] Add subtle CTAs where appropriate (e.g., “Pin from Dock”).

## Settings UX

- [ ] Group settings into clear sections with succinct descriptions.
- [ ] Provide helpful defaults and inline guidance.
- [ ] A dedicated Preferences window with per-section grouping, inline help, and safe defaults

## Keyboard Shortcuts

- [ ] Add user-configurable shortcut mappings.
- [ ] Provide a shortcuts UI with recorder and clearable fields.
- [ ] Shortcuts for switching pages and opening settings;

## Motion and Transitions

- [ ] Use cohesive transitions that feel intentional.
- [ ] Respect Reduce Motion fully and avoid large layout shifts.

## Error Handling

- [ ] Add non-blocking error surfaces for failures (e.g., activation, permissions).
- [ ] Ensure errors are actionable and dismissible.

## Testing

- [ ] Add a small UI test pass for page navigation and menu actions.
- [ ] Add a unit test for swipe/page logic.
