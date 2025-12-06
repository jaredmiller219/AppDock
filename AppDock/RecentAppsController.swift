//
//  RecentAppsController.swift
//  AppDock
//
//  Created by Jared Miller on 12/12/24.
//

// Import SwiftUI framework for the user interface
import SwiftUI

// Import Cocoa framework for macOS functionality
import Cocoa

// Mark this as the main entry point of the application
@main

// Define the main app structure that conforms to the App protocol
struct RecentAppsController: App {
    
    // Create an instance of AppDelegate and connect it to the SwiftUI app lifecycle
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Define the scene for the app
    var body: some Scene {
        // Use Settings scene type with an empty view since we're making a menu bar app
        Settings {
            EmptyView()
        }
    }
}

// Define the shared state for the application
class AppState: ObservableObject {
    
    // Create a published array to store recent applications
    // Each element is a tuple containing:
    // - name: The localized name of the application
    // - bundleid: The bundle identifier of the application
    // - icon: The application's icon as an NSImage
    @Published var recentApps: [(name: String, bundleid: String, icon: NSImage)] = []
}

// Define the application delegate to handle app lifecycle and menu bar functionality
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Create a singleton instance of the app delegate that can be accessed globally
    static private(set) var instance: AppDelegate!
    
    // Initialize the shared app state
    @Published var appState = AppState()
    
    // Create the status bar item with variable length
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    // Initialize the popover controller
    let menu = MenuController()
    
    // Create the popover that will host our dock view
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 260, height: 460)
        return popover
    }()
    
    // Monitor keyboard events to close the popover
    var keyEventMonitor: Any?
    
    // Called when the application finishes launching
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        // Set the instance to itself
        AppDelegate.instance = self
        
        // Configure the status bar icon
        statusBarItem.button?.image = NSImage(named: NSImage.Name("statusBarIcon"))
        
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

        // Build the main app menu so Settings/About/Quit are available from the menu bar
        setupMainMenu()
        
        // Fetch the list of recent applications
        getRecentApplications()
    }

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
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    private func showPopover(_ sender: Any?) {
        guard let button = statusBarItem.button else { return }
        
        // Bring the app/popup to the front immediately on open
        NSApp.activate(ignoringOtherApps: true)
        
        // Position the popover near the center of the visible screen instead of tethered to the status item
        let screenFrame = button.window?.screen?.visibleFrame ?? NSScreen.main?.visibleFrame
        if let screenFrame {
            let centerPointOnScreen = NSPoint(
                x: screenFrame.midX,
                y: screenFrame.midY
            )
            
            // Convert screen center into the status bar window's coordinates
            let centerInWindow = button.window?.convertPoint(fromScreen: centerPointOnScreen) ?? .zero
            let positioningRect = NSRect(origin: centerInWindow, size: .zero)
            
            // Prefer an upward arrow so it sits above the anchor point
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
            // Fallback: anchor to the button if screen info is unavailable
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        }
        
        startPopoverMonitor()
    }
    
    private func closePopover(_ sender: Any?) {
        popover.performClose(sender)
        stopPopoverMonitor()
    }
    
    private func startPopoverMonitor() {
        guard keyEventMonitor == nil else { return }
        
        // Close on Escape without interfering with mouse clicks inside the popover
        keyEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // Escape
                self?.closePopover(nil)
                return nil
            }
            return event
        }
    }
    
    private func stopPopoverMonitor() {
        if let monitor = keyEventMonitor {
            NSEvent.removeMonitor(monitor)
            keyEventMonitor = nil
        }
    }
    
    // Function to retrieve and process recently used applications
    func getRecentApplications() {
        
        // Get access to the shared workspace
        let workspace = NSWorkspace.shared
        
        // Get all currently running applications
        let recentApps = workspace.runningApplications

        // Filter out applications that aren't user-facing or don't have bundle IDs
        let userApps = recentApps.filter { app in
            app.activationPolicy == .regular &&
            app.bundleIdentifier != nil &&
            app.launchDate != nil
        }

        // Sort the applications by launch date, most recent first
        let sortedApps = userApps.sorted { app1, app2 in
            guard let date1 = app1.launchDate, let date2 = app2.launchDate else {
                return false
            }
            return date1 > date2
        }

        // Process each application to extract needed information
        let appDetails = sortedApps.compactMap { app -> (String, String, NSImage)? in
            // Extract required properties, return nil if any are missing
            guard let appName = app.localizedName,
                  let bundleid = app.bundleIdentifier,
                  let appPath = app.bundleURL?.path else { return nil }
            
            // Get the application's icon
            let appIcon = workspace.icon(forFile: appPath)
            
            // Resize the icon to fit our UI
            appIcon.size = NSSize(width: 64, height: 64)
            
            // Return the tuple of app information
            return (appName, bundleid, appIcon)
        }

        // Update the UI on the main thread
        DispatchQueue.main.async {
            // Update the shared state with the new app information
            AppDelegate.instance.appState.recentApps = appDetails
        }
    }
    
    // Handler for the "About" action
    @objc func about() {
        NSApp.orderFrontStandardAboutPanel()
        closePopover(nil)
    }
    
    // Handler for "Settings" action (opens System Settings)
    @objc func openSettings() {
        if let settingsURL = URL(string: "x-apple.systempreferences:") {
            NSWorkspace.shared.open(settingsURL)
        }
        closePopover(nil)
    }
    
    // Handler for the "Quit" action
    @objc func quit() {
        NSApp.terminate(self)
    }
}
