//
//  RecentAppsController.swift
//  AppDock
//
//  Created by Jared Miller on 12/12/24.
//

// Import SwiftUI framework for the user interface.
import SwiftUI

// Import Cocoa framework for macOS functionality.
import Cocoa

// MARK: - App Entry

/// AppDock's main entry point.
///
/// The SwiftUI `App` hosts the settings scene while the `AppDelegate` owns
/// the menu bar status item and the popover UI.
// Mark this as the main entry point of the application
@main

/// Main app definition that connects SwiftUI's lifecycle to `AppDelegate`.
struct RecentAppsController: App {
    
    // Create an instance of AppDelegate and connect it to the SwiftUI app lifecycle
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Define the scene for the app
    var body: some Scene {
        // Use Settings scene type with an empty view since we're making a menu bar app
        Settings {
            SettingsView(appState: appDelegate.appState)
        }
    }
}

// MARK: - Shared State

/// Shared state for the UI, published for SwiftUI bindings.
class AppState: ObservableObject {
    
    /// Dock entry tuple shared across view and model logic.
    typealias AppEntry = (name: String, bundleid: String, icon: NSImage)

    /// Recently launched/running applications shown in the dock grid.
    ///
    /// Each tuple contains:
    /// - name: The localized display name
    /// - bundleid: The bundle identifier
    /// - icon: A pre-sized application icon
    @Published var recentApps: [AppEntry] = []

    /// Selected filter for the dock list.
    @Published var filterOption: AppFilterOption = .all

    /// Selected sorting option for the dock list.
    @Published var sortOption: AppSortOption = .recent

    @Published var launchAtLogin = SettingsDefaults.launchAtLoginDefault
    @Published var openOnStartup = SettingsDefaults.openOnStartupDefault
    @Published var autoUpdates = SettingsDefaults.autoUpdatesDefault
    @Published var showAppLabels = SettingsDefaults.showAppLabelsDefault
    @Published var showRunningIndicator = SettingsDefaults.showRunningIndicatorDefault
    @Published var enableHoverRemove = SettingsDefaults.enableHoverRemoveDefault
    @Published var confirmBeforeQuit = SettingsDefaults.confirmBeforeQuitDefault
    @Published var keepQuitApps = SettingsDefaults.keepQuitAppsDefault
    @Published var gridColumns = SettingsDefaults.gridColumnsDefault
    @Published var gridRows = SettingsDefaults.gridRowsDefault
    @Published var iconSize = SettingsDefaults.iconSizeDefault
    @Published var labelSize = SettingsDefaults.labelSizeDefault
    @Published var reduceMotion = SettingsDefaults.reduceMotionDefault
    @Published var debugLogging = SettingsDefaults.debugLoggingDefault
    @Published var menuPage = SettingsDefaults.menuPageDefault {
        didSet {
            UserDefaults.standard.set(menuPage.rawValue, forKey: SettingsDefaults.menuPageKey)
        }
    }

    /// Initializes state from stored settings.
    init() {
        menuPage = SettingsDefaults.menuPageValue()
        applySettings(SettingsDraft.load())
    }

    /// Applies a full settings snapshot to the live state.
    func applySettings(_ settings: SettingsDraft) {
        launchAtLogin = settings.launchAtLogin
        openOnStartup = settings.openOnStartup
        autoUpdates = settings.autoUpdates
        showAppLabels = settings.showAppLabels
        showRunningIndicator = settings.showRunningIndicator
        enableHoverRemove = settings.enableHoverRemove
        confirmBeforeQuit = settings.confirmBeforeQuit
        keepQuitApps = settings.keepQuitApps
        filterOption = settings.defaultFilter
        sortOption = settings.defaultSort
        gridColumns = settings.gridColumns
        gridRows = settings.gridRows
        iconSize = settings.iconSize
        labelSize = settings.labelSize
        reduceMotion = settings.reduceMotion
        debugLogging = settings.debugLogging
    }
}

// MARK: - App Delegate

/// Handles menu bar setup, popover presentation, and app tracking.
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Create a singleton instance of the app delegate that can be accessed globally
    static private(set) var instance: AppDelegate!
    
    // Initialize the shared app state.
    @Published var appState = AppState()
    
    // Create the status bar item with variable length
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    // Initialize the popover controller
    let menu = MenuController()

    // Keep a reference to the Settings window so we reuse it
    var settingsWindowController: NSWindowController?
    private var uiTestWindow: NSWindow?
    
    // Create the popover that will host our dock view.
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = PopoverSizing.size(for: appState)
        return popover
    }()

    // Workspace notification observers for app launch/termination tracking.
    private var workspaceObservers: [NSObjectProtocol] = []
    
    // Monitor keyboard events to close the popover
    var keyEventMonitor: Any?
    
    /// Called when the application finishes launching.
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        // Set the instance to itself
        AppDelegate.instance = self
        
        // Configure a visible status bar icon.
        statusBarItem.button?.image = makeStatusBarImage()
        statusBarItem.button?.setAccessibilityIdentifier(AppDockConstants.Accessibility.statusItem)
        statusBarItem.button?.setAccessibilityLabel(AppDockConstants.Accessibility.statusItemLabel)
        
        // Set the image position in the status bar
        statusBarItem.button?.imagePosition = .imageLeading
        
        // Attach popover toggle to the status bar button
        statusBarItem.button?.target = self
        statusBarItem.button?.action = #selector(togglePopover(_:))
        
        // Prepare popover content
        popover.contentViewController = menu.makePopoverController(
            appState: appState,
            settingsAction: { [weak self] in self?.openSettings() },
            aboutAction: { [weak self] in self?.about() },
            quitAction: { [weak self] in self?.quit() }
        )

        // Build the main app menu so Settings/About/Quit are available from the menu bar.
        setupMainMenu()
        
        // Fetch the list of recent applications.
        getRecentApplications()

        // Keep the dock in sync with app launches.
        startWorkspaceMonitoring()

        applyUITestOverridesIfNeeded()
    }

    /// Creates the standard macOS app menu (About/Settings/Quit).
    private func setupMainMenu() {
        let mainMenu = NSMenu()

        // Top-level app menu item
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu

        let aboutItem = NSMenuItem(
            title: "About AppDock",
            action: #selector(about),
            keyEquivalent: ""
        )
        aboutItem.target = self
        appMenu.addItem(aboutItem)

        appMenu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(
            title: "Settings…",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        appMenu.addItem(settingsItem)

        appMenu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit AppDock",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        appMenu.addItem(quitItem)

        NSApp.mainMenu = mainMenu
    }
    
    /// Toggles the popover open/closed.
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    /// Displays the popover centered on the current screen.
    private func showPopover(_ sender: Any?) {
        guard let button = statusBarItem.button else { return }

        updatePopoverSize()
        
        // Bring the app/popup to the front immediately on open.
        NSApp.activate(ignoringOtherApps: true)
        
        // Position the popover near the center of the visible screen instead of tethered to the status item.
        let screenFrame = button.window?.screen?.visibleFrame ?? NSScreen.main?.visibleFrame
        if let screenFrame {
            let centerPointOnScreen = NSPoint(
                x: screenFrame.midX,
                y: screenFrame.midY
            )
            
            // Convert screen center into the status bar window's coordinates.
            let centerInWindow = button.window?.convertPoint(fromScreen: centerPointOnScreen) ?? .zero
            let positioningRect = NSRect(origin: centerInWindow, size: .zero)
            
            // Prefer an upward arrow so it sits above the anchor point.
            popover.show(
                relativeTo: positioningRect,
                of: button.window?.contentView ?? button,
                preferredEdge: .minY
            )
            if let popWindow = popover.contentViewController?.view.window {
                popWindow.makeKeyAndOrderFront(nil)
                popWindow.isMovableByWindowBackground = false
                popWindow.ignoresMouseEvents = false
            }
        } else {
            // Fallback: anchor to the button if screen info is unavailable.
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        }
        
        startPopoverMonitor()
    }

    private func updatePopoverSize() {
        let popoverSize = PopoverSizing.size(for: appState)
        if popover.contentSize != popoverSize {
            popover.contentSize = popoverSize
        }
        if let view = popover.contentViewController?.view, view.frame.size != popoverSize {
            view.frame.size = popoverSize
        }
    }

    /// Builds a status bar icon with a symbol and a fallback to the app icon.
    private func makeStatusBarImage() -> NSImage {
        let symbolImage = NSImage(
            systemSymbolName: "circle.grid.2x2",
            accessibilityDescription: "AppDock"
        )
        let image = symbolImage
            ?? NSApp.applicationIconImage
            ?? NSImage(size: NSSize(width: AppDockConstants.StatusBarIcon.size, height: AppDockConstants.StatusBarIcon.size))
        image.size = NSSize(width: AppDockConstants.StatusBarIcon.size, height: AppDockConstants.StatusBarIcon.size)
        image.isTemplate = true
        return image
    }
    
    /// Closes the popover and removes its event monitors.
    private func closePopover(_ sender: Any?) {
        popover.performClose(sender)
        stopPopoverMonitor()
    }
    
    /// Adds a local event monitor so Escape closes the popover.
    private func startPopoverMonitor() {
        guard keyEventMonitor == nil else { return }
        
        // Close on Escape without interfering with mouse clicks inside the popover.
        keyEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // Escape
                self?.closePopover(nil)
                return nil
            }
            return event
        }
    }
    
    /// Removes the Escape key monitor to avoid leaks.
    private func stopPopoverMonitor() {
        if let monitor = keyEventMonitor {
            NSEvent.removeMonitor(monitor)
            keyEventMonitor = nil
        }
    }

    /// Starts observing workspace app launch events to update the dock.
    private func startWorkspaceMonitoring() {
        let center = NSWorkspace.shared.notificationCenter
        let queue = OperationQueue.main
        workspaceObservers = [
            center.addObserver(
                forName: NSWorkspace.didLaunchApplicationNotification,
                object: nil,
                queue: queue
            ) { [weak self] notification in
                guard
                    let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
                        as? NSRunningApplication
                else {
                    return
                }
                self?.handleLaunchedApp(app)
            },
            center.addObserver(
                forName: NSWorkspace.didTerminateApplicationNotification,
                object: nil,
                queue: queue
            ) { [weak self] notification in
                guard
                    let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
                        as? NSRunningApplication
                else {
                    return
                }
                self?.handleTerminatedApp(app)
            }
        ]
    }

    /// Removes workspace observers when the app delegate is deallocated.
    private func stopWorkspaceMonitoring() {
        let center = NSWorkspace.shared.notificationCenter
        workspaceObservers.forEach { center.removeObserver($0) }
        workspaceObservers.removeAll()
    }

    deinit {
        stopWorkspaceMonitoring()
    }

    // MARK: - UI test support

    private func applyUITestOverridesIfNeeded() {
        let arguments = ProcessInfo.processInfo.arguments
        guard arguments.contains(AppDockConstants.Testing.uiTestMode) else { return }

        appState.menuPage = .dock
        UserDefaults.standard.set(
            SettingsDefaults.simpleSettingsDefault,
            forKey: SettingsDefaults.simpleSettingsKey
        )

        if arguments.contains(AppDockConstants.Testing.uiTestSeedDock) {
            seedDockForUITests()
        }

        if arguments.contains(AppDockConstants.Testing.uiTestOpenPopover) {
            DispatchQueue.main.async { [weak self] in
                self?.showUITestPopoverWindow()
            }
        }

        if arguments.contains(AppDockConstants.Testing.uiTestOpenSettings) {
            DispatchQueue.main.async { [weak self] in
                self?.openSettings()
            }
        }

        if arguments.contains(AppDockConstants.Testing.uiTestOpenPopovers) {
            DispatchQueue.main.async { [weak self] in
                self?.showUITestPopoverWindow()
                self?.openSettings()
            }
        }
    }

    private func seedDockForUITests() {
        let placeholderIcon = NSImage(size: NSSize(width: AppDockConstants.AppIcon.size, height: AppDockConstants.AppIcon.size))
        appState.recentApps = [
            (name: "Alpha", bundleid: "com.example.alpha", icon: placeholderIcon),
            (name: "Bravo", bundleid: "com.example.bravo", icon: placeholderIcon),
            (name: "Charlie", bundleid: "com.example.charlie", icon: placeholderIcon)
        ]
    }

    private func showUITestPopoverWindow() {
        if let window = uiTestWindow {
            window.makeKeyAndOrderFront(nil)
            return
        }

        let controller = menu.makePopoverController(
            appState: appState,
            settingsAction: { [weak self] in self?.openSettings() },
            aboutAction: { [weak self] in self?.about() },
            quitAction: { [weak self] in self?.quit() }
        )

        let window = NSWindow(contentViewController: controller)
        window.title = AppDockConstants.Accessibility.uiTestWindow
        window.setContentSize(PopoverSizing.size(for: appState))
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        uiTestWindow = window
    }
    
    /// Loads the current list of running user apps and publishes them.
    func getRecentApplications() {
        let workspace = NSWorkspace.shared
        let userApps = fetchUserApps(from: workspace)
        let sortedApps = sortAppsByLaunchDate(userApps)
        let appDetails = buildAppEntries(from: sortedApps, workspace: workspace)
        updateRecentApps(with: appDetails)
    }

    /// Inserts a newly launched app at the front of the list without removing older entries.
    private func handleLaunchedApp(_ app: NSRunningApplication) {
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
    private func handleTerminatedApp(_ app: NSRunningApplication) {
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
    private func makeAppEntry(
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

    // MARK: - Recent app helpers

    /// Filters running applications to user-facing apps with required metadata.
    private func fetchUserApps(from workspace: NSWorkspace) -> [NSRunningApplication] {
        workspace.runningApplications.filter { app in
            app.activationPolicy == .regular &&
            app.bundleIdentifier != nil &&
            app.launchDate != nil
        }
    }

    /// Sorts by launch date, newest first. Apps missing a launch date are excluded.
    private func sortAppsByLaunchDate(_ apps: [NSRunningApplication]) -> [NSRunningApplication] {
        apps.sorted { app1, app2 in
            guard let date1 = app1.launchDate, let date2 = app2.launchDate else {
                return false
            }
            return date1 > date2
        }
    }

    /// Maps running apps into dock entries with resized icons.
    private func buildAppEntries(
        from apps: [NSRunningApplication],
        workspace: NSWorkspace
    ) -> [AppState.AppEntry] {
        apps.compactMap { app in
            makeAppEntry(from: app, workspace: workspace)
        }
    }

    /// Applies the newly built list on the main thread for SwiftUI updates.
    private func updateRecentApps(with entries: [AppState.AppEntry]) {
        DispatchQueue.main.async {
            AppDelegate.instance.appState.recentApps = entries
        }
    }

    /// Handler for the "About" action.
    @objc func about() {
        NSApp.orderFrontStandardAboutPanel()
        closePopover(nil)
    }
    
    /// Handler for "Settings" action (opens the in-app settings window).
    @objc func openSettings() {
        if settingsWindowController == nil {
            let window = NSWindow(
                contentRect: NSRect(
                    x: 0,
                    y: 0,
                    width: AppDockConstants.SettingsWindow.width,
                    height: AppDockConstants.SettingsWindow.height
                ),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window.title = "AppDock Settings"
            window.isReleasedWhenClosed = false
            window.center()
            window.contentView = NSHostingView(rootView: SettingsView(appState: appState))
            settingsWindowController = NSWindowController(window: window)
        }

        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        closePopover(nil)
    }
    
    /// Handler for the "Quit" action.
    @objc func quit() {
        NSApp.terminate(self)
    }
}
