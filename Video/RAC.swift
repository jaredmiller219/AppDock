//
//  RecentAppsController.swift
//  AppDock
//

// Documentation-only outline used for video/script narration.

// Import SwiftUI framework for the user interface

// Import Cocoa framework for macOS functionality

// Mark this as the main entry point of the application - @main

// Define the main app structure that conforms to the App protocol
    
    // Create an instance of AppDelegate and connect it to the SwiftUI app lifecycle
    
    // Define the scene for the app
    
        // Use Settings scene type with an empty view since we're making a menu bar app

// Define a class for the shared state of the application with a protocol of ObservableObject
    
    // Create a published array to store recent applications
    // Each element is a tuple containing:
    // - name: The localized name of the application
    // - bundleid: The bundle identifier of the application
    // - icon: The application's icon as an NSImage

// Define the a class for the application delegate to handle app lifecycle and menu bar functionality, with protocols NSObject and NSApplicationDelegate
    
    // Create an instance of the app delegate that can be accessed globally
    
    // Initialize the shared app state as published
    
    // Create the status bar item with variable length
    
    // Initialize the app menu
    
    // Function to call when the "application finishes launching"
    
        // Set the instance to itself
        
        // Configure the status bar icon
        
        // Set the image position in the status bar
        
        // Attach the menu to the status bar item
        
        // Fetch the list of recent applications
    
    // Function to retrieve and process recently used applications
    
        // Get access to the shared workspace
        
        // Get all currently running applications
        
        // Filter out applications that aren't user-facing or don't have bundle IDs
        
        // Sort the applications by launch date, most recent first
        
        // Process each application to extract necessary info using a compact map
        
            // Extract app's name, bundleid, and icon
            
                // return nil if any are missing
            
            // Get the application's icon
            
            // Resize the icon to fit our UI
            
            // Return the tuple of app's name, bundleid, and icon
        
        // Update the UI on the main thread using a dispatch queue
        
            // Update the shared state with the new app information
