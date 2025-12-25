//
//  DockAppList.swift
//  AppDock
//

import AppKit

/// Pure helper for filtering, sorting, and padding the dock list.
///
/// Keeping this logic outside the SwiftUI view makes it easier to test and reuse.
struct DockAppList {
    typealias AppEntry = AppState.AppEntry

    /// Returns the list after applying filter + sort + padding.
    static func build(
        apps: [AppEntry],
        filter: AppFilterOption,
        sort: AppSortOption,
        totalSlots: Int,
        isRunning: (String) -> Bool
    ) -> [AppEntry] {
        let filtered = filterApps(apps, filter: filter, isRunning: isRunning)
        let sorted = sortApps(filtered, sort: sort)
        return padApps(sorted, totalSlots: totalSlots)
    }

    /// Applies the current filter option.
    static func filterApps(
        _ apps: [AppEntry],
        filter: AppFilterOption,
        isRunning: (String) -> Bool
    ) -> [AppEntry] {
        switch filter {
        case .all:
            return apps
        case .runningOnly:
            return apps.filter { app in
                !app.bundleid.isEmpty && isRunning(app.bundleid)
            }
        }
    }

    /// Applies the current sort option.
    static func sortApps(_ apps: [AppEntry], sort: AppSortOption) -> [AppEntry] {
        switch sort {
        case .recent:
            return apps
        case .nameAscending:
            return apps.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .nameDescending:
            return apps.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending
            }
        }
    }

    /// Pads the app list to match the total grid slot count.
    static func padApps(_ apps: [AppEntry], totalSlots: Int) -> [AppEntry] {
        let paddingCount = max(0, totalSlots - apps.count)
        guard paddingCount > 0 else { return apps }
        let padding = Array(repeating: ("", "", NSImage()), count: paddingCount)
        return apps + padding
    }
}
