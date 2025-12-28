//
//  ShortcutModels.swift
//  AppDock
//

import Carbon
import Cocoa

/// Small value type describing a global keyboard shortcut.
///
/// Stores the hardware `keyCode` and the `NSEvent.ModifierFlags` used by
/// AppKit; helpers translate the modifier flags into masks suitable for
/// persisting and registering with Carbon APIs.
struct ShortcutDefinition: Equatable {
    /// Hardware key code representing the key.
    let keyCode: UInt16

    /// Raw modifier flags captured from `NSEvent`.
    let modifiers: NSEvent.ModifierFlags

    /// Normalized mask containing only device-independent modifier flags.
    var modifierMask: NSEvent.ModifierFlags {
        modifiers.intersection(.deviceIndependentFlagsMask)
    }

    /// Converts the `modifierMask` into Carbon-compatible modifier bits.
    var carbonModifiers: UInt32 {
        var flags: UInt32 = 0
        if modifierMask.contains(.command) {
            flags |= UInt32(cmdKey)
        }
        if modifierMask.contains(.option) {
            flags |= UInt32(optionKey)
        }
        if modifierMask.contains(.control) {
            flags |= UInt32(controlKey)
        }
        if modifierMask.contains(.shift) {
            flags |= UInt32(shiftKey)
        }
        return flags
    }
}

/// Logical actions that can be triggered via global shortcuts.
enum ShortcutAction: String, CaseIterable, Identifiable {
    case togglePopover
    case nextPage
    case previousPage
    case openDock
    case openRecents
    case openFavorites
    case openActions

    /// Stable identifier for SwiftUI lists.
    var id: String { rawValue }

    /// Human-readable title for Settings UI.
    var title: String {
        switch self {
        case .togglePopover:
            return "Toggle Popover"
        case .nextPage:
            return "Next Page"
        case .previousPage:
            return "Previous Page"
        case .openDock:
            return "Open Dock"
        case .openRecents:
            return "Open Recents"
        case .openFavorites:
            return "Open Favorites"
        case .openActions:
            return "Open Menu"
        }
    }

    /// Returns the `UserDefaults` key used to persist this action's shortcut.
    var settingsKey: String {
        switch self {
        case .togglePopover:
            return SettingsDefaults.shortcutTogglePopoverKey
        case .nextPage:
            return SettingsDefaults.shortcutNextPageKey
        case .previousPage:
            return SettingsDefaults.shortcutPreviousPageKey
        case .openDock:
            return SettingsDefaults.shortcutOpenDockKey
        case .openRecents:
            return SettingsDefaults.shortcutOpenRecentsKey
        case .openFavorites:
            return SettingsDefaults.shortcutOpenFavoritesKey
        case .openActions:
            return SettingsDefaults.shortcutOpenActionsKey
        }
    }
}
