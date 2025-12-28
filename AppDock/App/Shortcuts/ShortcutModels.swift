//
//  ShortcutModels.swift
//  AppDock
//

import Cocoa
import Carbon

struct ShortcutDefinition: Equatable {
    let keyCode: UInt16
    let modifiers: NSEvent.ModifierFlags

    var modifierMask: NSEvent.ModifierFlags {
        modifiers.intersection(.deviceIndependentFlagsMask)
    }

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

enum ShortcutAction: String, CaseIterable, Identifiable {
    case togglePopover
    case nextPage
    case previousPage
    case openDock
    case openRecents
    case openFavorites
    case openActions

    var id: String { rawValue }

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
