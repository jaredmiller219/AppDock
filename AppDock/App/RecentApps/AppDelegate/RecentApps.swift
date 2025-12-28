//
//  RecentApps.swift
//  AppDock
//

import Cocoa

// MARK: - Recent Apps

extension AppDelegate {
    // MARK: App List Updates

    /// Loads the current list of running user apps and publishes them.
    ///
    /// - Note: Filters to user-facing apps and sorts by launch time.
    func getRecentApplications() {
        let workspace = NSWorkspace.shared
        let userApps = fetchUserApps(from: workspace)
        let sortedApps = sortAppsByLaunchDate(userApps)
        let appDetails = buildAppEntries(from: sortedApps, workspace: workspace)
        updateRecentApps(with: appDetails)
    }

    /// Inserts a newly launched app at the front of the list without removing older entries.
    ///
    /// - Note: De-duplicates by bundle identifier before inserting.
    func handleLaunchedApp(_ app: NSRunningApplication) {
        guard app.bundleIdentifier != Bundle.main.bundleIdentifier else { return }
        guard let appEntry = makeAppEntry(from: app, workspace: NSWorkspace.shared) else { return }

        DispatchQueue.main.async {
            var updated = AppDelegate.instance.appState.recentApps
            updated.removeAll { $0.bundleid == appEntry.bundleid }
            updated.insert(appEntry, at: 0)
            AppDelegate.instance.appState.recentApps = updated
        }
    }

    /// Removes terminated apps when the user disables "Keep apps after quit".
    ///
    /// - Note: The current app is ignored to avoid hiding AppDock itself.
    func handleTerminatedApp(_ app: NSRunningApplication) {
        guard !appState.keepQuitApps else { return }
        guard app.bundleIdentifier != Bundle.main.bundleIdentifier else { return }
        guard let bundleId = app.bundleIdentifier else { return }

        DispatchQueue.main.async {
            var updated = self.appState.recentApps
            updated.removeAll { $0.bundleid == bundleId }
            self.appState.recentApps = updated
        }
    }

    /// Converts a running app into an entry for the dock list.
    ///
    /// - Note: Icons are resized to the dock thumbnail size.
    func makeAppEntry(
        from app: NSRunningApplication,
        workspace: NSWorkspace
    ) -> AppState.AppEntry? {
        guard
            let appName = app.localizedName,
            let bundleid = app.bundleIdentifier,
            let appPath = app.bundleURL?.path
        else {
            return nil
        }

        let appIcon = workspace.icon(forFile: appPath)
        appIcon.size = NSSize(width: AppDockConstants.AppIcon.size, height: AppDockConstants.AppIcon.size)
        return (name: appName, bundleid: bundleid, icon: appIcon)
    }

    // MARK: App List Helpers

    /// Filters running applications to user-facing apps with required metadata.
    ///
    /// - Note: Excludes background agents and missing metadata.
    func fetchUserApps(from workspace: NSWorkspace) -> [NSRunningApplication] {
        workspace.runningApplications.filter { app in
            app.activationPolicy == .regular &&
                app.bundleIdentifier != nil &&
                app.launchDate != nil
        }
    }

    /// Sorts by launch date, newest first. Apps missing a launch date are excluded.
    ///
    /// - Note: Ensures the most recently launched apps appear first.
    func sortAppsByLaunchDate(_ apps: [NSRunningApplication]) -> [NSRunningApplication] {
        apps.sorted { app1, app2 in
            guard let date1 = app1.launchDate, let date2 = app2.launchDate else {
                return false
            }
            return date1 > date2
        }
    }

    /// Maps running apps into dock entries with resized icons.
    ///
    /// - Note: Only apps with valid metadata become entries.
    func buildAppEntries(
        from apps: [NSRunningApplication],
        workspace: NSWorkspace
    ) -> [AppState.AppEntry] {
        apps.compactMap { app in
            makeAppEntry(from: app, workspace: workspace)
        }
    }

    /// Applies the newly built list on the main thread for SwiftUI updates.
    ///
    /// - Note: UI bindings must be updated on the main thread.
    func updateRecentApps(with entries: [AppState.AppEntry]) {
        DispatchQueue.main.async {
            AppDelegate.instance.appState.recentApps = entries
        }
    }
}
