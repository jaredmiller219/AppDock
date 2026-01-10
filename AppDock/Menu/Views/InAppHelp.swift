//
//  InAppHelp.swift
//  AppDock
//
//  Built-in user guide and tutorials
//

import SwiftUI

/// Help content structure
struct HelpSection: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let content: [HelpContent]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
    
    static func == (lhs: HelpSection, rhs: HelpSection) -> Bool {
        lhs.id == rhs.id
    }
}

struct HelpContent: Identifiable {
    let id = UUID()
    let type: ContentType
    let title: String
    let description: String
    let steps: [String]?
    let tips: [String]?
    
    enum ContentType {
        case overview
        case tutorial
        case troubleshooting
        case advanced
    }
}

/// Main help panel
struct InAppHelpPanel: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection: HelpSection?
    @State private var searchText = ""
    
    private let helpSections: [HelpSection] = [
        HelpSection(
            title: "Getting Started",
            icon: "play.circle",
            content: [
                HelpContent(
                    type: .overview,
                    title: "Welcome to AppDock",
                    description: "AppDock is a powerful menu bar application that gives you quick access to your favorite apps and recent applications.",
                    steps: [
                        "Click the AppDock icon in your menu bar to open the popover",
                        "Use the dock grid to launch your frequently used apps",
                        "Navigate between pages using the tab bar or keyboard shortcuts",
                        "Customize your experience in Settings"
                    ],
                    tips: [
                        "Hold ⌘ and click an app to show the context menu",
                        "Use ⌘1-4 to quickly switch between pages",
                        "Press ⌘F or / to search for apps"
                    ]
                ),
                HelpContent(
                    type: .tutorial,
                    title: "Basic Navigation",
                    description: "Learn how to navigate the AppDock interface efficiently.",
                    steps: [
                        "Menu Bar: Click the icon to open/close the popover",
                        "Dock Page: View and launch your recent apps",
                        "Recents Page: See your recently launched applications",
                        "Favorites Page: Access your pinned favorite apps",
                        "Menu Page: Access settings, help, and app actions"
                    ],
                    tips: [
                        "The popover automatically closes when you click outside",
                        "Use arrow keys to navigate between apps",
                        "Press Escape to close the popover"
                    ]
                )
            ]
        ),
        HelpSection(
            title: "App Management",
            icon: "app.badge",
            content: [
                HelpContent(
                    type: .tutorial,
                    title: "Launching Apps",
                    description: "Different ways to launch and manage your applications.",
                    steps: [
                        "Single-click any app icon to launch it",
                        "Use keyboard shortcuts for quick access",
                        "Search for apps using the search bar",
                        "Right-click for additional options"
                    ],
                    tips: [
                        "Apps you launch frequently will appear in Recents",
                        "Pin important apps to Favorites for easy access",
                        "Use batch operations to manage multiple apps"
                    ]
                ),
                HelpContent(
                    type: .advanced,
                    title: "Context Menu Actions",
                    description: "Advanced app management through context menus.",
                    steps: [
                        "⌘+Click any app to open the context menu",
                        "Choose from Hide, Show in Finder, Reveal in Dock",
                        "Use Open at Login to auto-launch apps",
                        "Quit or Force Quit apps when needed"
                    ],
                    tips: [
                        "Force Quit should only be used when apps are unresponsive",
                        "Show in Finder opens the app's location in Finder",
                        "Reveal in Dock brings the app to the foreground"
                    ]
                )
            ]
        ),
        HelpSection(
            title: "Search & Filter",
            icon: "magnifyingglass",
            content: [
                HelpContent(
                    type: .tutorial,
                    title: "Using Search",
                    description: "Quickly find and launch apps using the search functionality.",
                    steps: [
                        "Click the search bar or press ⌘F",
                        "Type app names or bundle identifiers",
                        "Use arrow keys to navigate results",
                        "Press Enter to launch the selected app"
                    ],
                    tips: [
                        "Search works on both app names and bundle IDs",
                        "Press Escape to clear search and return to normal view",
                        "Search results are highlighted for easy identification"
                    ]
                ),
                HelpContent(
                    type: .advanced,
                    title: "Filter Options",
                    description: "Filter your app list to show only what you need.",
                    steps: [
                        "Click the filter menu button",
                        "Choose between 'All Apps' or 'Running Only'",
                        "Sort by 'Recently Opened' or alphabetically",
                        "Filters apply immediately to the current view"
                    ],
                    tips: [
                        "'Running Only' is useful for managing active applications",
                        "Sorting helps when you have many apps in the dock"
                    ]
                )
            ]
        ),
        HelpSection(
            title: "Keyboard Shortcuts",
            icon: "keyboard",
            content: [
                HelpContent(
                    type: .tutorial,
                    title: "Essential Shortcuts",
                    description: "Master these keyboard shortcuts for maximum productivity.",
                    steps: [
                        "⌘1-4: Switch between pages (Dock, Recents, Favorites, Menu)",
                        "⌘F or /: Focus search bar",
                        "Arrow keys: Navigate between apps",
                        "Enter or Space: Launch selected app",
                        "Escape: Close popover or clear search"
                    ],
                    tips: [
                        "Hold ⌘ while using arrow keys for page navigation",
                        "Use Tab to move between different sections",
                        "⌘+Click for context menus without right-click"
                    ]
                ),
                HelpContent(
                    type: .advanced,
                    title: "Advanced Shortcuts",
                    description: "Power user shortcuts for advanced workflows.",
                    steps: [
                        "⌘[: Previous page, ⌘]: Next page",
                        "⌘A: Select all apps (in batch mode)",
                        "⌘D: Deselect all apps",
                        "⌘,: Open Settings",
                        "⌘?: Open Keyboard Shortcuts panel"
                    ],
                    tips: [
                        "Customize shortcuts in Settings → Shortcuts",
                        "Some shortcuts work globally, others only in the popover"
                    ]
                )
            ]
        ),
        HelpSection(
            title: "Batch Operations",
            icon: "checkmark.square",
            content: [
                HelpContent(
                    type: .tutorial,
                    title: "Multi-Select Mode",
                    description: "Perform actions on multiple apps simultaneously.",
                    steps: [
                        "Click 'Select Multiple' to enter selection mode",
                        "Click apps to select/deselect them",
                        "Use 'Select All' to select all visible apps",
                        "Perform batch actions from the toolbar"
                    ],
                    tips: [
                        "Selection mode shows checkboxes next to each app",
                        "Batch actions include Quit, Hide, Add to Favorites, Remove"
                    ]
                )
            ]
        ),
        HelpSection(
            title: "Focus Mode",
            icon: "moon",
            content: [
                HelpContent(
                    type: .tutorial,
                    title: "Reducing Distractions",
                    description: "Use Focus Mode to hide distracting apps during work.",
                    steps: [
                        "Toggle Focus Mode from the menu or with ⌘⌥F",
                        "Add distracting apps to your blocklist",
                        "Set schedules for automatic activation",
                        "Focus Mode hides selected apps from the dock"
                    ],
                    tips: [
                        "Focus Mode can be scheduled for specific times",
                        "Apps are hidden but not terminated",
                        "Toggle Focus Mode anytime to show/hide blocked apps"
                    ]
                )
            ]
        ),
        HelpSection(
            title: "Troubleshooting",
            icon: "wrench",
            content: [
                HelpContent(
                    type: .troubleshooting,
                    title: "Common Issues",
                    description: "Solutions to common problems you might encounter.",
                    steps: [
                        "App not launching: Check if the app is properly installed",
                        "Popover not opening: Restart AppDock from Activity Monitor",
                        "Shortcuts not working: Check for conflicts in System Settings",
                        "Apps not showing: Verify app permissions in Security & Privacy"
                    ],
                    tips: [
                        "Most issues are resolved by restarting the app",
                        "Check the console for detailed error messages",
                        "Ensure AppDock has necessary accessibility permissions"
                    ]
                ),
                HelpContent(
                    type: .troubleshooting,
                    title: "Performance Tips",
                    description: "Keep AppDock running smoothly with these tips.",
                    steps: [
                        "Limit the number of apps in your dock",
                        "Regularly clear old recents",
                        "Disable animations if you experience lag",
                        "Use Focus Mode to reduce visual clutter"
                    ],
                    tips: [
                        "AppDock is designed to be lightweight",
                        "Performance may vary based on the number of running apps"
                    ]
                )
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            // Sidebar
            List(helpSections, selection: $selectedSection) { section in
                Label(section.title, systemImage: section.icon)
                    .tag(section)
            }
            .frame(minWidth: 200)
            
            // Content area
            Group {
                if let selectedSection = selectedSection {
                    HelpSectionView(section: selectedSection)
                } else {
                    HelpOverviewView(sections: helpSections, onSectionSelected: { section in
                        selectedSection = section
                    })
                }
            }
            .frame(minWidth: 400, minHeight: 500)
        }
        .navigationTitle("AppDock Help")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .onAppear {
            selectedSection = helpSections.first
        }
    }
}

/// Help overview view
struct HelpOverviewView: View {
    let sections: [HelpSection]
    let onSectionSelected: (HelpSection) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                    
                    Text("AppDock Help Center")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Find answers and learn how to use AppDock effectively")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Quick links
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(sections) { section in
                        HelpOverviewCard(section: section) {
                            onSectionSelected(section)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Quick tips
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Tips")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HelpTipRow(icon: "keyboard", text: "Press ⌘? for keyboard shortcuts")
                        HelpTipRow(icon: "magnifyingglass", text: "Use ⌘F to search quickly")
                        HelpTipRow(icon: "moon", text: "Toggle Focus Mode with ⌘⌥F")
                        HelpTipRow(icon: "gear", text: "Customize everything in Settings")
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
}

/// Help overview card
struct HelpOverviewCard: View {
    let section: HelpSection
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: section.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)
                
                Text(section.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("\(section.content.count) articles")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separatorColor), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovered in
            if isHovered {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
    }
}

/// Help tip row
struct HelpTipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

/// Help section content view
struct HelpSectionView: View {
    let section: HelpSection
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(section.content) { content in
                    HelpContentView(content: content)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
}

/// Individual help content view
struct HelpContentView: View {
    let content: HelpContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: iconForType(content.type))
                    .font(.system(size: 20))
                    .foregroundColor(colorForType(content.type))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(content.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(typeLabel(for: content.type))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Description
            Text(content.description)
                .font(.body)
                .foregroundColor(.primary)
            
            // Steps
            if let steps = content.steps, !steps.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Steps:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1).")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.accentColor)
                                .frame(width: 20, alignment: .leading)
                            
                            Text(step)
                                .font(.body)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                    }
                }
            }
            
            // Tips
            if let tips = content.tips, !tips.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tips:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    ForEach(tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                                .frame(width: 16, alignment: .center)
                            
                            Text(tip)
                                .font(.body)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                    }
                }
            }
            
            Divider()
        }
    }
    
    private func iconForType(_ type: HelpContent.ContentType) -> String {
        switch type {
        case .overview: return "info.circle"
        case .tutorial: return "play.circle"
        case .troubleshooting: return "wrench"
        case .advanced: return "gear"
        }
    }
    
    private func colorForType(_ type: HelpContent.ContentType) -> Color {
        switch type {
        case .overview: return .blue
        case .tutorial: return .green
        case .troubleshooting: return .orange
        case .advanced: return .purple
        }
    }
    
    private func typeLabel(for type: HelpContent.ContentType) -> String {
        switch type {
        case .overview: return "Overview"
        case .tutorial: return "Tutorial"
        case .troubleshooting: return "Troubleshooting"
        case .advanced: return "Advanced"
        }
    }
}

/// Preview provider
struct InAppHelp_Previews: PreviewProvider {
    static var previews: some View {
        InAppHelpPanel()
    }
}
