//
//  DockAppList.swift
//  AppDock
//

import AppKit

/// Pure helper for filtering, sorting, and padding the dock list.
///
/// Keeping this logic outside the SwiftUI view makes it easier to test and reuse.
enum DockAppList {
    typealias AppEntry = AppState.AppEntry

    /// Returns the list after applying filter + sort + padding.
    ///
    /// - Parameters:
    ///   - apps: The original list of app entries.
    ///   - filter: Current `AppFilterOption` to apply.
    ///   - sort: Current `AppSortOption` to apply.
    ///   - totalSlots: The total number of slots the UI will render (used to pad).
    ///   - isRunning: A small function used to determine whether a bundle id has a running instance.
    /// - Returns: A list of `AppEntry` values filtered, sorted and padded to `totalSlots`.
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
    ///
    /// - Note: The `runningOnly` case uses the provided `isRunning` predicate
    ///   so filter logic can be tested without querying system APIs.
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
    ///
    /// - Note: `recent` currently leaves the original order intact; to
    ///   enable true recency sorting the model should timestamp entries.
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
    ///
    /// - Note: Padding entries are empty tuples (empty strings and an empty image)
    ///   so the UI can render placeholder `EmptySlot` views in the grid.
    static func padApps(_ apps: [AppEntry], totalSlots: Int) -> [AppEntry] {
        let paddingCount = max(0, totalSlots - apps.count)
        guard paddingCount > 0 else { return apps }
        let padding = Array(repeating: ("", "", NSImage()), count: paddingCount)
        return apps + padding
    }
}
