//
//  SettingsViewTab.swift
//  AppDock
//

import Foundation

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
