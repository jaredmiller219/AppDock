//
//  SettingsView.swift
//  AppDock
//

// Documentation-only outline used for video/script narration.

// Import SwiftUI framework

// Define SettingsView

    // ZStack background
        // Neutral window background

    // Header row
        // Circular icon with gear
        // Title + subtitle text stack

    // ScrollView with section cards
        // GroupBox cards using custom style

        // General section
            // Launch at login
            // Open dock on startup
            // Auto update toggle

        // Dock Layout section
            // Columns/rows steppers
            // Icon size slider
            // Label size slider

        // Filtering & Sorting section
            // Default filter picker
            // Default sort picker

        // Appearance section
            // Accent color picker

        // Behavior section
            // Labels, running indicator, hover remove
            // Confirm quit, keep apps after quit

        // Accessibility section
            // Reduce motion toggle

        // Advanced section
            // Debug logging
            // Restore defaults button

    // Footer actions
        // Restore Defaults
        // Apply button to push staged values into AppState

    // Settings persist via SettingsDefaults keys and apply through SettingsDraft
