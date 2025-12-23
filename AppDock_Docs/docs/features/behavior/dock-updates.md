# Dock Updates

- On launch, the list is populated from `NSWorkspace.shared.runningApplications`.
- Apps are filtered to `.regular` with a bundle identifier and launch date.
- New launches insert at index 0 and dedupe existing bundle identifiers.
- App quits do not remove entries when “Keep apps after quit” is enabled.
- The Filter & Sort menu can further constrain or reorder the visible list.
- Settings can change the default filter/sort choice used at startup.
