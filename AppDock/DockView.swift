//
//  DockView.swift
//  AppDock
//
//  Created by Jared Miller on 12/12/24.
//

// Import SwiftUI framework for user interface
import SwiftUI

// Import AppKit for macOS specific functionality
import AppKit

// Create a separate view for the app button
struct ButtonView: View {
    // The name of the application
    let appName: String
    
    // The bundle identifier of the application
    let bundleId: String
    
    // The icon of the application
    let appIcon: NSImage
    
    // The width of the button
    let buttonWidth: CGFloat
    
    // The height of the button
    let buttonHeight: CGFloat
    
    // Whether or not the mouse is hovering over an app
    @State private var isHovering = false
    
    // The main view body
    var body: some View {
        // Create a button with action and label
        Button {
            if let event = NSApp.currentEvent {
                handleClick(with: event)
            }
        } label: {
            // If the app name is empty, show empty slot view
            if appName.isEmpty {
                EmptySlot(width: buttonWidth, height: buttonHeight)
            } else {
                // Otherwise show the app icon view
                IconView(appName: appName, appIcon: appIcon, width: buttonWidth, height: buttonHeight)
                    // Add a border when hovering
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isHovering ? Color.blue : Color.clear, lineWidth: 2)
                    )
            }
        }
        // Set the button style to plain
        .buttonStyle(PlainButtonStyle())
        
        // Disable the button if bundle ID is empty
        .disabled(bundleId.isEmpty)
        
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    private func handleClick(with event: NSEvent) {
        // Check if the bundle ID is not empty
        if !bundleId.isEmpty {
            // Get the shared workspace
            let workspace = NSWorkspace.shared
            
            // Check if command key is pressed
            let flags = NSEvent.modifierFlags
            if flags.contains(.command) {
                // Quit the app
                if let runningApp = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == bundleId }) {
                    runningApp.terminate()
                }
            } else {
                
                // Try to get the URL for the application using bundle identifier
                if let appURL = workspace.urlForApplication(withBundleIdentifier: bundleId) {
                    // Open the application with the specified URL
                    workspace.openApplication(at: appURL,
                                              configuration: NSWorkspace.OpenConfiguration()) { app, error in
                        // Handle potential errors
                        if let error = error {
                            print("BundleID Mismastch - Expected: (\(bundleId)), Actual: (\(app?.bundleIdentifier ?? ""))")
                            print("Trying to open \(appName), but got error: \(error)")
                        } else {
                            // Print success message
                            // print("Opened \(appName)")
                            
                            // Skip this block
                            ()
                        }
                    }
                }
            }
        }
    }
    
}

// Create a separate view for empty slots
struct EmptySlot: View {
    // The width of the empty slot
    let width: CGFloat
    
    // The height of the empty slot
    let height: CGFloat
    
    // The main view body
    var body: some View {
        // Create a clear background
        Color.clear
            // Set the frame dimensions
            .frame(width: width, height: height)
            // Add a border overlay
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
            // Add "Empty" text overlay
            .overlay(
                Text("Empty")
                    .foregroundColor(.gray)
                    .font(.system(size: 8))
            )
    }
}

// Create a separate view for app icons
struct IconView: View {
    // The name of the application
    let appName: String
    
    // The icon of the application
    let appIcon: NSImage
    
    // The width of the icon
    let width: CGFloat
    
    // The height of the icon
    let height: CGFloat
    
    // The main view body
    var body: some View {
            // Display the app icon image
            Image(nsImage: appIcon)
                // Make the image resizable
                .resizable()
                // Scale to fit the frame
                .scaledToFit()
                // Set the frame dimensions
                .frame(width: width, height: height)
                // Add corner radius
                .cornerRadius(8)
    }
    
}

// Main DockView that displays the grid of apps
struct DockView: View {
    // Observe the shared app state
    @ObservedObject var appState: AppState
    
    // Number of columns in the grid
    let numberOfColumns: Int = 3
    
    // Number of rows in the grid
    let numberOfRows: Int = 4
    
    // Width of each button = 50
    let buttonWidth: CGFloat = 50
    
    // Height of each button = 50
    let buttonHeight: CGFloat = 50
    
    // Extra spacing for the divider
    let extraSpace: CGFloat = 15
    
    // The main view body
    var body: some View {
        // Calculate the divider width
        let dividerWidth: CGFloat = (CGFloat(numberOfColumns) * buttonWidth) + extraSpace
        
        // Create vertical stack for rows
        VStack {
            
            // Calculate total number of slots
            let totalSlots = numberOfColumns * numberOfRows
            
            // Get the recent apps from app state
            let recentApps = appState.recentApps
            
            // Pad the apps array with empty slots
            let paddedApps = recentApps + Array(repeating: ("", "", NSImage()), count: max(0, totalSlots - recentApps.count))
            
            // Create rows of app buttons
            ForEach(0..<numberOfRows, id: \.self) { rowIndex in
                // Create horizontal stack for columns
                HStack(alignment: .center) {
                    // Create columns of app buttons
                    ForEach(0..<numberOfColumns, id: \.self) { columnIndex in
                        // Calculate the index for each app
                        let appIndex = (rowIndex * numberOfColumns) + columnIndex
                        
                        // Get the app details
                        let (appName, bundleId, appIcon) = paddedApps[appIndex]
                        
                        VStack(spacing: 3) {
                            
                            // Create button view for the app
                            ButtonView(appName: appName,
                                       bundleId: bundleId,
                                       appIcon: appIcon,
                                       buttonWidth: buttonWidth,
                                       buttonHeight: buttonHeight)
                            
                            // Create a Text label for the app name if the app is there
                            if !appName.isEmpty {
                                Text(appName)
                                    .font(.system(size: 8))
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.black.opacity(0.25))
                                    .cornerRadius(3)
                            }
                        }
                    }
                }
                
                // Add divider between rows (except last row)
                if rowIndex < (numberOfRows - 1) {
                    Divider()
                        .frame(width: dividerWidth)
                        .background(Color.blue)
                        .padding(.vertical, 5)
                }
            }
        }
        // Add padding to the entire view
        .padding()
    }
}

//// Preview provider for SwiftUI canvas
//#Preview {
//    // Initialize DockView with empty app state
//    DockView(appState: .init())
//}
