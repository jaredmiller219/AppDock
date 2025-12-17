//
//  DockView.swift
//  AppDock
//

// Documentation-only outline used for video/script narration.

// Import SwiftUI framework for user interface

// Import AppKit for macOS specific functionality

// Extend Notification.Name with appDockDismissContextMenu

// Create VisualEffectBlur (NSViewRepresentable wrapper)

    // Store material and blending mode

    // makeNSView
        // Create NSVisualEffectView
        // Set material and blending
        // Set state to active
        // Return the view

    // updateNSView
        // Update material and blending
        // Keep state active

// MARK: - ButtonView

// Create ButtonView for a single app icon

    // Inputs:
        // appName string
        // bundleId string
        // appIcon NSImage
        // button width/height
        // binding for isContextMenuVisible
        // onRemove closure

    // Local state:
        // hover state
        // remove button visibility
        // delayed work item for X button
        // command key tracking
        // local/global modifier monitors

    // Helper: openApp(bundleId)
        // Resolve URL with NSWorkspace.urlForApplication
        // Create OpenConfiguration
        // activates = true
        // createsNewApplicationInstance = false
        // Open the app with openApplication(at:)

    // View body

        // ZStack for icon + optional remove button

            // If appName is empty
                // Render EmptySlot
            // Else
                // Button tap handler

                    // If Command is held
                        // Toggle context menu for this icon
                    // Else
                        // Close any open context menu
                        // If running:
                            // Unhide app
                            // Activate all windows
                            // Call openApp to bring windows forward
                        // If not running:
                            // Call openApp to relaunch

                // Button label
                    // IconView
                    // Hover border

            // Remove button overlay
                // Visible only when showRemoveButton and appName not empty
                // Calls onRemove

        // onHover
            // Track hover state
            // If hovering with Command pressed, schedule X button
            // If hover ends, cancel X button

        // onAppear
            // Start modifier key monitoring

        // onDisappear
            // Stop modifier key monitoring

        // Disable button if bundleId is empty

    // Modifier key monitoring

        // startMonitoringModifierFlags
            // Set initial command state
            // Add local monitor for flagsChanged
            // Add global monitor for flagsChanged

        // stopMonitoringModifierFlags
            // Remove monitors

        // handleModifierFlagsChange
            // Update command state
            // Show or hide remove button based on hover

    // Remove button timing

        // scheduleRemoveButton
            // Cancel prior work item
            // Schedule show after delay

        // cancelRemoveButton
            // Cancel work item
            // Hide remove button

// MARK: - ContextMenuView

// Create ContextMenuView for Hide/Quit actions

    // Inputs:
        // onDismiss closure
        // bundleId string

    // View body
        // VStack with buttons
        // Hide App:
            // Find running app by bundleId
            // Call hide()
            // Dismiss menu
        // Quit App:
            // Find running app by bundleId
            // Try terminate; if false, forceTerminate
            // Dismiss menu
        // Apply padding and fixed width

// MARK: - EmptySlot

// Placeholder when no app is present

    // Inputs: width, height
    // Body: clear frame with border and "Empty" label

// MARK: - IconView

// Renders the NSImage icon

    // Inputs: appName, appIcon, width, height
    // Body: resizable image, scaled to fit, corner radius

// MARK: - DockView

// Main grid view for the dock

    // ObservedObject appState
    // Active context menu index
    // Context menu token for re-animation
    // Spring animation config

    // dismissContextMenus
        // Animate context menu index to nil

    // setActiveContextMenuIndex
        // Animate index change
        // Refresh token when opening

    // Layout settings from AppState
        // rows, columns, icon size, label size, spacing

    // View body

        // Compute divider width

        // Filter apps
            // AppFilterOption.all -> keep all
            // AppFilterOption.runningOnly -> keep only running apps

        // Sort apps
            // recent -> preserve order
            // nameAscending -> A-Z
            // nameDescending -> Z-A

        // Pad list to fixed grid size

        // Render rows and columns
            // For each slot:
                // ButtonView for icon
                // Optional label under icon
                // Optional running indicator dot

        // Divider between rows

        // Dismiss context menu on tap

        // Overlay context menu when active
            // VisualEffectBlur background
            // Rounded rectangle stroke
            // ContextMenuView content
            // Transition with scale + opacity

        // Dismiss rules
            // On app resign active
            // On custom dismiss notification
            // On other app activation
