/*
 SettingsTab.swift
 AppDock

 PURPOSE:
 This enum defines the seven settings tabs available in the Settings window.
 Provides metadata (title, icon) for each tab and enables tab navigation.

 OVERVIEW:
 SettingsTab is a CaseIterable enum representing all available settings panels:
 - General: Launch behavior and auto-update options
 - Layout: Menu display mode and sizing preferences
 - Filtering: Default filter and sort options
 - Behavior: Interaction defaults and hover behaviors
 - Shortcuts: Global keyboard shortcut definitions
 - Accessibility: Visual and interaction accessibility options
 - Advanced: Power-user and debugging features

 Each case provides:
 - Human-readable title for UI display
 - SF Symbol name for icon display
 - CaseIterable conformance for ForEach iteration
 - Identifiable conformance via rawValue

 STYLING:
 - Icons chosen to visually represent each settings category
 - Titles match settings sidebar and window labels
*/

import Foundation

/// Settings window tabs representing different preference categories.
///
/// Enum cases for General, Layout, Filtering, Behavior, Shortcuts, Accessibility, and Advanced tabs.
/// Each provides title and icon for sidebar navigation and tab display.
enum SettingsTab: String, CaseIterable, Identifiable {
    case general
    case layout
    case filtering
    case behavior
    case shortcuts
    case accessibility
    case advanced

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: return "General"
        case .layout: return "Layout"
        case .filtering: return "Filtering"
        case .behavior: return "Behavior"
        case .shortcuts: return "Shortcuts"
        case .accessibility: return "Accessibility"
        case .advanced: return "Advanced"
        }
    }

    var systemImage: String {
        switch self {
        case .general: return "gearshape"
        case .layout: return "square.grid.3x3"
        case .filtering: return "line.3.horizontal.decrease.circle"
        case .behavior: return "hand.tap"
        case .shortcuts: return "keyboard"
        case .accessibility: return "figure.walk"
        case .advanced: return "wrench.and.screwdriver"
        }
    }
}
