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
    
    // Initialize the app menu
    let menu = MenuController()
    
    // Called when the application finishes launching
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        // Set the instance to itself
        AppDelegate.instance = self
        
        // Configure the status bar icon
        statusBarItem.button?.image = NSImage(named: NSImage.Name("statusBarIcon"))
        
        // Set the image position in the status bar
        statusBarItem.button?.imagePosition = .imageLeading
        
        // Attach the menu to the status bar item
        statusBarItem.menu = menu.createMenu()
        
        // Fetch the list of recent applications
        getRecentApplications()
    }
    
    // Function to retrieve and process recently used applications
    func getRecentApplications() {
        
        // Get access to the shared workspace
        let workspace = NSWorkspace.shared
        
        // Get all currently running applications
        let recentApps = workspace.runningApplications

        // Filter out applications that aren't user-facing or don't have bundle IDs
        let userApps = recentApps.filter { app in
            app.activationPolicy == .regular && app.bundleIdentifier != nil
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
}
