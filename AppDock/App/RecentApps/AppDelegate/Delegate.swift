//
//  Delegate.swift
//  AppDock
//

import SwiftUI
import Cocoa

// MARK: - App Delegate

/// Handles menu bar setup, popover presentation, and app tracking.
///
/// - Note: Owns the status item, popover, and application lifecycle hooks.
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: State + Dependencies
    /// Shared instance for cross-object coordination.
    static private(set) var instance: AppDelegate!

    /// Initialize the shared app state.
    @Published var appState = AppState()
    /// Menu-only state to avoid re-rendering dock views on page switches.
    @Published var menuState = MenuState()

    /// Create the status bar item with variable length.
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    /// Initialize the popover controller.
    let menu = MenuController()

    /// Keep a reference to the Settings window so we reuse it.
    var settingsWindowController: NSWindowController?
    var uiTestWindow: NSWindow?
    var uiTestStatusItemWindow: NSWindow?
    var uiTestShortcutsWindow: NSWindow?

    private lazy var shortcutManager = ShortcutManager { [weak self] action in
        self?.handleShortcut(action)
    }

    /// Create the popover that will host our dock view.
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = PopoverSizing.size(for: appState)
        return popover
    }()

    // MARK: Workspace Monitoring

    /// Workspace notification observers for app launch/termination tracking.
    private var workspaceObservers: [NSObjectProtocol] = []

    /// Monitor keyboard events to close the popover.
    var keyEventMonitor: Any?

    // MARK: Lifecycle

    /// Called when the application finishes launching.
    ///
    /// - Note: Sets up the status item, popover content, and workspace observers.
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self

        // Configure a visible status bar icon.
        statusBarItem.button?.image = makeStatusBarImage()
        statusBarItem.button?.setAccessibilityIdentifier(AppDockConstants.Accessibility.statusItem)
        statusBarItem.button?.setAccessibilityLabel(AppDockConstants.Accessibility.statusItemLabel)

        // Set the image position in the status bar.
        statusBarItem.button?.imagePosition = .imageLeading

        // Attach popover toggle to the status bar button.
        statusBarItem.button?.target = self
        statusBarItem.button?.action = #selector(togglePopover(_:))

        // Prepare popover content.
        popover.contentViewController = menu.makePopoverController(
            appState: appState,
            menuState: menuState,
            settingsAction: { [weak self] in self?.openSettings() },
            aboutAction: { [weak self] in self?.about() },
            quitAction: { [weak self] in self?.quit() }
        )

        // Build the main app menu so Settings/About/Quit are available from the menu bar.
        setupMainMenu()

        let isUITestMode = ProcessInfo.processInfo.arguments.contains(AppDockConstants.Testing.uiTestMode)

        if !isUITestMode {
            // Fetch the list of recent applications.
            getRecentApplications()

            // Keep the dock in sync with app launches.
            startWorkspaceMonitoring()
        }

        shortcutManager.refreshShortcuts()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshShortcuts),
            name: .appDockShortcutsChanged,
            object: nil
        )

        applyUITestOverridesIfNeeded()
    }

    // MARK: App Menu

    /// Creates the standard macOS app menu (About/Settings/Quit).
    private func setupMainMenu() {
        let mainMenu = NSMenu()

        // Top-level app menu item.
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

    // MARK: Popover Presentation

    /// Toggles the popover open/closed.
    ///
    /// - Note: Acts as the status item action target.
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    /// Displays the popover centered on the current screen.
    ///
    /// - Note: The popover is positioned at screen center for consistency.
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

    /// Keeps the popover size in sync with app state.
    ///
    /// - Note: Called before showing the popover to account for layout changes.
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
    ///
    /// - Note: Uses a template image so the icon adapts to menu bar appearance.
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
    ///
    /// - Note: Also clears the Escape key monitor to avoid leaks.
    func closePopover(_ sender: Any?) {
        popover.performClose(sender)
        stopPopoverMonitor()
    }

    @objc private func refreshShortcuts() {
        shortcutManager.refreshShortcuts()
    }

    func handleShortcut(_ action: ShortcutAction) {
        switch action {
        case .togglePopover:
            togglePopover(nil)
        case .nextPage:
            advanceMenuPage(direction: .left)
        case .previousPage:
            advanceMenuPage(direction: .right)
        case .openDock:
            showPopoverAndSelectPage(.dock)
        case .openRecents:
            showPopoverAndSelectPage(.recents)
        case .openFavorites:
            showPopoverAndSelectPage(.favorites)
        case .openActions:
            showPopoverAndSelectPage(.actions)
        }
    }

    private func showPopoverAndSelectPage(_ page: MenuPage) {
        menuState.menuPage = page
        if !popover.isShown {
            showPopover(nil)
        }
    }

    private func advanceMenuPage(direction: SwipeDirection) {
        guard appState.menuLayoutMode == .advanced else {
            if !popover.isShown {
                showPopover(nil)
            }
            return
        }
        if let next = MenuSwipeLogic.nextPage(from: menuState.menuPage, direction: direction) {
            menuState.menuPage = next
        }
        if !popover.isShown {
            showPopover(nil)
        }
    }

    // MARK: Popover Event Monitoring

    /// Adds a local event monitor so Escape closes the popover.
    ///
    /// - Note: The monitor is local so it doesn't affect other apps.
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
    ///
    /// - Note: Safe to call multiple times.
    private func stopPopoverMonitor() {
        if let monitor = keyEventMonitor {
            NSEvent.removeMonitor(monitor)
            keyEventMonitor = nil
        }
    }

    /// Starts observing workspace app launch events to update the dock.
    ///
    /// - Note: Observers are removed in `deinit`.
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
    ///
    /// - Note: Prevents retained observers after shutdown.
    private func stopWorkspaceMonitoring() {
        let center = NSWorkspace.shared.notificationCenter
        workspaceObservers.forEach { center.removeObserver($0) }
        workspaceObservers.removeAll()
    }

    deinit {
        stopWorkspaceMonitoring()
    }
}
