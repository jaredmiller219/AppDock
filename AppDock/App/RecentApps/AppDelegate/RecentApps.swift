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

		let userApps = workspace.runningApplications.filter { app in
			app.activationPolicy == .regular && app.bundleIdentifier != nil && app.launchDate != nil
		}

		let sortedApps = userApps.sorted { (firstApp, secondApp) in
			guard let firstDate = firstApp.launchDate, let secondDate = secondApp.launchDate else { return false }
			return firstDate > secondDate
		}

		let appDetails = sortedApps.compactMap { makeAppEntry(from: $0, workspace: workspace) }

		DispatchQueue.main.async {
			self.appState.recentApps = appDetails
		}
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
		else { return nil }

		let icon = workspace.icon(forFile: appPath)
		icon.size = NSSize(width: AppDockConstants.AppIcon.size, height: AppDockConstants.AppIcon.size)

		return (name: appName, bundleid: bundleid, icon: icon)
	}
}
