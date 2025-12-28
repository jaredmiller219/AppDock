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
            //
            //  RecentApps.swift
            //  AppDock
            //
            /*
             RecentApps.swift

             Purpose:
              - Small AppDelegate extension that populates `AppState.recentApps` by
                querying running applications or other platform APIs. Kept separate to
                isolate platform-specific lookup logic from the main delegate.
            */

            import Foundation
            import AppKit

            // MARK: - Recent Apps

            /// Utilities to build the recent apps list used by the dock.
            extension AppDelegate {
                /// Queries running applications as a source for the recent apps list.
                ///
                /// - Note: This is a conservative fallback; more advanced heuristics
                ///   (e.g., Launch Services recency) can be added here if desired.
                func getRecentApplications() {
                    var items: [AppState.AppEntry] = []

                    // Fallback: list running apps as a reasonable default
                    for app in NSWorkspace.shared.runningApplications {
                        guard let bundleId = app.bundleIdentifier else { continue }
                        let name = app.localizedName ?? ""
                        let icon = app.icon ?? NSImage()
                        items.append((name: name, bundleid: bundleId, icon: icon))
                    }

                    appState.recentApps = items
                }
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
