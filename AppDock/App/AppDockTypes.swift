//
//  AppDockTypes.swift
//  AppDock
//

import Foundation
import SwiftUI

/// Filter options for the dock list.
enum AppFilterOption: String, CaseIterable, Identifiable {
    case all
    case runningOnly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All Apps"
        case .runningOnly:
            return "Running Only"
        }
    }
}

/// Sorting options for the dock list.
enum AppSortOption: String, CaseIterable, Identifiable {
    case recent
    case nameAscending
    case nameDescending

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recent:
            return "Recently Opened"
        case .nameAscending:
            return "Name A-Z"
        case .nameDescending:
            return "Name Z-A"
        }
    }
}

/// Pages available in the menu bar popover.
enum MenuPage: String, CaseIterable, Identifiable {
    case dock
    case recents
    case favorites
    case actions

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dock: return "Dock"
        case .recents: return "Recents"
        case .favorites: return "Favorites"
        case .actions: return "Menu"
        }
    }

    var systemImage: String {
        switch self {
        case .dock: return "square.grid.3x3"
        case .recents: return "clock.arrow.circlepath"
        case .favorites: return "star"
        case .actions: return "ellipsis.circle"
        }
    }

    var orderIndex: Int {
        switch self {
        case .dock: return 0
        case .recents: return 1
        case .favorites: return 2
        case .actions: return 3
        }
    }

    var shortcutKey: KeyEquivalent {
        let keyValue = String(orderIndex + 1).first ?? "1"
        return KeyEquivalent(keyValue)
    }
}
