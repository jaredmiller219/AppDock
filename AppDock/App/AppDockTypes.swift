//
//  AppDockTypes.swift
//  AppDock
//

import Foundation
import SwiftUI

/// Filter options for the dock list.
enum AppFilterOption: String, CaseIterable, Identifiable {
    /// Shows every app in the dock list, regardless of running state.
    case all
    
	/// Restricts the dock list to currently running apps.
    case runningOnly

    /// Stable identifier for SwiftUI lists.
    var id: String { rawValue }

    /// Human-readable label shown in the menu.
    // Mappings
    // - All: "All Apps"
    // - Running Only: "Running Only"
    var title: String {
        switch self {
			// All apps label.
			case .all: return "All Apps"
			
			// Running-only label.
			case .runningOnly: return "Running Only"
        }
    }
}

/// Sorting options for the dock list.
enum AppSortOption: String, CaseIterable, Identifiable {
    /// Orders apps by most recent launch time.
    case recent
    
	/// Orders apps alphabetically A–Z.
    case nameAscending
    
	/// Orders apps alphabetically Z–A.
    case nameDescending

    /// Stable identifier for SwiftUI lists.
    var id: String { rawValue }

    /// Human-readable label shown in the menu.
    // Mappings
    // - Recent: "Recently Opened"
    // - Name A-Z: "Name A-Z"
    // - Name Z-A: "Name Z-A"
    var title: String {
        switch self {
			// Recent sort label.
			case .recent: return "Recently Opened"
			
			// A-Z sort label.
			case .nameAscending: return "Name A-Z"
			
			// Z-A sort label.
			case .nameDescending: return "Name Z-A"
        }
    }
}

/// Pages available in the menu bar popover.
enum MenuPage: String, CaseIterable, Identifiable {
    /// Primary dock grid page.
    case dock
    
	/// Recent apps list page.
    case recents
    
	/// Favorites page (empty state if none).
    case favorites
    
	/// Menu actions page (Settings/About/Quit).
    case actions

    /// Stable identifier for SwiftUI lists.
    var id: String { rawValue }

    /// Human-readable title shown in headers and the tab bar.
    // Mappings
    // - Dock: "Dock"
    // - Recents: "Recents"
    // - Favorites: "Favorites"
    // - Actions: "Menu"
    var title: String {
        switch self {
			// Dock page label.
			case .dock: return "Dock"
			
			// Recents page label.
			case .recents: return "Recents"
			
			// Favorites page label.
			case .favorites: return "Favorites"
		   
			// Actions page label.
			case .actions: return "Menu"
        }
    }

    /// SF Symbol used in the tab bar.
    // Mappings
    // - Dock: `square.grid.3x3`
    // - Recents: `clock.arrow.circlepath`
    // - Favorites: `star`
    // - Actions: `ellipsis.circle`
    var systemImage: String {
        switch self {
			// Dock grid icon.
			case .dock: return "square.grid.3x3"
			
			// Recents icon.
			case .recents: return "clock.arrow.circlepath"
			
			// Favorites icon.
			case .favorites: return "star"
			
			// Actions/menu icon.
			case .actions: return "ellipsis.circle"
        }
    }

    /// Stable ordering for swipe navigation and keyboard shortcuts.
    // Mappings
    // - Dock: 0
    // - Recents: 1
    // - Favorites: 2
    // - Actions: 3
    var orderIndex: Int {
        switch self {
			// Dock is first in the tab order.
			case .dock: return 0
			
			// Recents follows Dock.
			case .recents: return 1
			
			// Favorites sits between Recents and Actions.
			case .favorites: return 2
			
			// Actions is last in the tab order.
			case .actions: return 3
        }
    }

    /// Command-key shortcut derived from the page order.
    /// - Note: `⌘1` maps to the first page, `⌘2` to the second, and so on.
    var shortcutKey: KeyEquivalent {
        /// Convert the numeric order to a single character so we can build a KeyEquivalent.
        let keyValue = String(orderIndex + 1).first ?? "1"
        
		// Use the derived character as the command shortcut (e.g., 1–4).
        return KeyEquivalent(keyValue)
    }
}

/// Layout modes for the menu bar popover UI.
enum MenuLayoutMode: String, CaseIterable, Identifiable {
    /// Single-page menu layout without tabs.
    case simple
    
	/// Tabbed menu layout with paging and gestures.
    case advanced

    /// Stable identifier for SwiftUI lists.
    var id: String { rawValue }

    /// Human-readable label shown in Settings.
    // Mappings
    // - Simple: "Simple"
    // - Advanced: "Advanced"
    var title: String {
        switch self {
			// Simple layout label.
			case .simple: return "Simple"
			
			// Advanced layout label.
			case .advanced: return "Advanced"
        }
    }
}
