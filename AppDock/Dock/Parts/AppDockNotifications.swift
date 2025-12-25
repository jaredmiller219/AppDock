//
//  AppDockNotifications.swift
//  AppDock
//

import Foundation

extension Notification.Name {
    /// Broadcast when context menus should dismiss (e.g., taps outside the menu).
    static let appDockDismissContextMenu = Notification.Name("AppDockDismissContextMenu")
}
