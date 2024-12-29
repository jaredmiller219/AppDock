//
//  MenuController.swift
//  AppDock
//
//  Created by Jared Miller on 12/17/24.
//

// Import the SwiftUI framework for user interface components
import SwiftUI

// Import Foundation framework for basic functionality
import Foundation

// Define the AppMenu class that manages the status bar menu
// Inherits from NSObject to work with Objective-C runtime
class MenuController: NSObject {
    
    // Initialize the NSMenu instance that will contain our menu items
    // This will hold all of our menu items and the dock view
    let menu = NSMenu()
    
    // Function to create and configure the status bar menu
    // Returns: NSMenu - The configured menu ready to be displayed
    func createMenu() -> NSMenu {
        
        // Access shared state
        let appState = AppDelegate.instance.appState
        
        // Create the main dock view with the current app state
        // This will display our grid of recent applications
        let dockView = DockView(appState: appState)
        
        // Wrap the SwiftUI dock view in an NSHostingController
        // This allows us to use SwiftUI views in AppKit menus
        let topView = NSHostingController(rootView: dockView)
        
        // Configure the size of the menu window
        // Set width to 200 and height to 300
        topView.view.frame.size = CGSize(width: 200, height: 340)
        
        // Create a menu item to hold our dock view
        // This will be the main content area of our menu
        let menuItem = NSMenuItem()
        
        // Attach the hosting view to our menu item
        // This embeds our SwiftUI view in the menu
        menuItem.view = topView.view
        
        // Add the configured menu item to our menu
        // This is the top section containing the dock grid
        menu.addItem(menuItem)
        
        // Add a separator line below the dock grid
        // This visually separates the dock from the menu options
        menu.addItem(NSMenuItem.separator())
        
        
        // Create the "About" menu item
        // Configure it with a title and action, but no keyboard shortcut
        let aboutMenuItem = NSMenuItem(title: "About AppDock",
                                     action: #selector(about),
                                     keyEquivalent: "")
        
        // Set the target for the about menu item
        // This ensures the action method will be called on this instance
        aboutMenuItem.target = self
        
        // Add the about menu item to the menu
        // This appears below the separator
        menu.addItem(aboutMenuItem)
        
        // Create the "Quit" menu item
        // Configure it with a title, action, and "q" keyboard shortcut
        let quitMenuItem = NSMenuItem(title: "Quit",
                                    action: #selector(quit),
                                    keyEquivalent: "q")
        
        // Set the target for the quit menu item
        // This ensures the action method will be called on this instance
        quitMenuItem.target = self
        
        // Add the quit menu item to the menu
        // This will be the last item in the menu
        menu.addItem(quitMenuItem)
        
        // Return the fully configured menu
        // This will be used by the status bar item
        return menu
    }
    
    // Handler for the "About" menu item
    // Shows the standard macOS about panel
    @objc func about(sender: NSMenuItem) {
        // Display the default macOS about window
        // This shows application information and credits
        NSApp.orderFrontStandardAboutPanel()
    }
    
    // Handler for the "Quit" menu item
    // Terminates the application
    @objc func quit(sender: NSMenuItem) {
        // Terminate the application cleanly
        // This will close all windows and end the application
        NSApp.terminate(self)
    }
}
