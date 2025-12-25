//
//  AppDockTypes.swift
//  AppDock
//

import Foundation

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
