//
//  AppDockNotifications.swift
//  AppDock
//
/*
 AppDockNotifications.swift

 Purpose:
  - Centralize `Notification.Name` values used for app-wide UI coordination
    (for example, dismissing context menus or notifying when shortcuts change).
*/

import Foundation

extension Notification.Name {
    /// Broadcast when context menus should dismiss (e.g., taps outside the menu).
    static let appDockDismissContextMenu = Notification.Name("AppDockDismissContextMenu")
    /// Broadcast when keyboard shortcut settings change.
    static let appDockShortcutsChanged = Notification.Name("AppDockShortcutsChanged")
}
