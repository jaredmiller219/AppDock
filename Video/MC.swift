//
//  MenuController.swift
//  AppDock
//

// Import the SwiftUI framework for user interface components

// Import Foundation framework for basic functionality

// Define the menu controller class that manages the status bar menu
// Inherits from NSObject to work with Objective-C runtime
    
    // NSMenu instance that will contain our menu items
    // This will hold all of our menu items and the dock view
    
    // Function to create and configure the status bar menu
    // Returns: NSMenu - The configured menu ready to be displayed
    
        // Access shared state
        
        // Create the main dock view with the current app state
        // This will display our grid of recent applications
        
        // Wrap the SwiftUI dock view in an NSHostingController
        // This allows us to use SwiftUI views in AppKit menus
        
        // Configure the size of the menu window
        // Set width to 170 points and height to 260 points
        
        // Create a menu item to hold our dock view
        // This will be the main content area of our menu
        
        // Attach the hosting view to our menu item
        // This embeds our SwiftUI view in the menu
        
        // Add the configured menu item to our menu
        // This is the top section containing the dock grid
        
        // Add a separator line below the dock grid
        // This visually separates the dock from the menu options
        
        // Create the "About" menu item
        // Configure it with a title and action, but no keyboard shortcut
        
        // Set the target for the about menu item
        // This ensures the action method will be called on this instance
        
        // Add the about menu item to the menu
        // This appears below the separator
        
        // Create the "Quit" menu item
        // Configure it with a title, action, and "q" keyboard shortcut
        
        // Set the target for the quit menu item to itself
        // This ensures the action method will be called on this instance
        
        // Add the quit menu item to the menu
        // This will be the last item in the menu
        
        // Return the menu
        // This will be used by the status bar item
    
    // Handler for the "About" menu item - sender is the menu item
    // Shows the standard macOS about panel
    
        // Display the default macOS about window
        // This shows application information and credits
    
    // Handler for the "Quit" menu item - sender is the menu item
    // Terminates the application
    
        // Terminate the application cleanly
        // This will close all windows and end the application
