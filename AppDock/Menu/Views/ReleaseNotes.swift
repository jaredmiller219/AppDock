//
//  ReleaseNotes.swift
//  AppDock
//
//  In-app changelog for updates
//

import SwiftUI

/// Release notes data structure
struct ReleaseNote: Identifiable, Hashable {
    let id = UUID()
    let version: String
    let buildNumber: String
    let releaseDate: Date
    let isCurrent: Bool
    let features: [ReleaseFeature]
    let fixes: [String]
    let improvements: [String]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(version)
    }

    static func == (lhs: ReleaseNote, rhs: ReleaseNote) -> Bool {
        lhs.id == rhs.id
    }
}

struct ReleaseFeature: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let isNew: Bool
    let isImproved: Bool
    let isFixed: Bool
}

/// Release notes panel
struct ReleaseNotesPanel: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedVersion: ReleaseNote?
    @State private var showOnlyNewFeatures = false

    private let releaseNotes: [ReleaseNote] = [
        ReleaseNote(
            version: "2.0.0",
            buildNumber: "20240109",
            releaseDate: Date(),
            isCurrent: true,
            features: [
                ReleaseFeature(
                    title: "Enhanced Context Menu",
                    description: "Added Show in Finder, Reveal in Dock, Open at Login, and Force Quit options",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                ),
                ReleaseFeature(
                    title: "Keyboard Shortcuts Panel",
                    description: "Comprehensive reference guide showing all available shortcuts and tips",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                ),
                ReleaseFeature(
                    title: "Search Functionality",
                    description: "Real-time app search with text highlighting and keyboard shortcuts",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                ),
                ReleaseFeature(
                    title: "Batch Operations",
                    description: "Multi-select mode for bulk actions like quit, hide, and organize apps",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                ),
                ReleaseFeature(
                    title: "Focus Mode",
                    description: "Hide distracting apps with scheduling and automatic activation",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                ),
                ReleaseFeature(
                    title: "In-App Help System",
                    description: "Built-in user guide with tutorials and troubleshooting information",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                ),
                ReleaseFeature(
                    title: "Release Notes Viewer",
                    description: "Stay updated with new features and improvements",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                )
            ],
            fixes: [
                "Fixed macOS 14 compatibility issues with app activation",
                "Resolved navigation bar display mode warnings",
                "Fixed color compatibility for tertiary text colors",
                "Improved hover effects for better cursor feedback"
            ],
            improvements: [
                "Enhanced search performance with better filtering",
                "Improved batch operations UI with visual feedback",
                "Better keyboard navigation throughout the app",
                "Optimized memory usage for large app collections"
            ]
        ),
        ReleaseNote(
            version: "1.5.0",
            buildNumber: "20231215",
            releaseDate: Calendar.current.date(byAdding: .day, value: -25, to: Date()) ?? Date(),
            isCurrent: false,
            features: [
                ReleaseFeature(
                    title: "Advanced Menu Layout",
                    description: "New tabbed interface with swipe gestures and page navigation",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                ),
                ReleaseFeature(
                    title: "Gesture Support",
                    description: "Swipe between pages with natural scrolling and animations",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                ),
                ReleaseFeature(
                    title: "Favorites System",
                    description: "Pin your most-used apps for quick access",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                )
            ],
            fixes: [
                "Fixed popover positioning on multiple displays",
                "Resolved memory leak in app monitoring",
                "Fixed keyboard shortcut conflicts"
            ],
            improvements: [
                "Reduced launch time by 40%",
                "Better handling of app bundle identifiers",
                "Improved accessibility labels throughout"
            ]
        ),
        ReleaseNote(
            version: "1.2.0",
            buildNumber: "20231120",
            releaseDate: Calendar.current.date(byAdding: .day, value: -50, to: Date()) ?? Date(),
            isCurrent: false,
            features: [
                ReleaseFeature(
                    title: "Customizable Grid Layout",
                    description: "Adjust grid columns, rows, and icon sizes to your preference",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                ),
                ReleaseFeature(
                    title: "App Filtering",
                    description: "Filter between all apps and running apps only",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                ),
                ReleaseFeature(
                    title: "Sorting Options",
                    description: "Sort apps by recent usage or alphabetically",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                )
            ],
            fixes: [
                "Fixed app icon rendering on Retina displays",
                "Resolved issues with app bundle detection"
            ],
            improvements: [
                "Better performance with large app collections",
                "Improved visual consistency across macOS versions"
            ]
        ),
        ReleaseNote(
            version: "1.0.0",
            buildNumber: "20231001",
            releaseDate: Calendar.current.date(byAdding: .day, value: -100, to: Date()) ?? Date(),
            isCurrent: false,
            features: [
                ReleaseFeature(
                    title: "Initial Release",
                    description: "Core AppDock functionality with menu bar integration",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                ),
                ReleaseFeature(
                    title: "Recent Apps Tracking",
                    description: "Automatically track and display recently launched applications",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                ),
                ReleaseFeature(
                    title: "Global Shortcuts",
                    description: "System-wide keyboard shortcuts for quick access",
                    isNew: true,
                    isImproved: false,
                    isFixed: false
                )
            ],
            fixes: [],
            improvements: [
                "Foundation for future enhancements",
                "Stable core architecture"
            ]
        )
    ]

    var body: some View {
        NavigationSplitView {
            // Version list
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(releaseNotes) { release in
                        DisclosureGroup(isExpanded: Binding(
                            get: { selectedVersion?.id == release.id },
                            set: { isExpanded in
                                if isExpanded {
                                    selectedVersion = release
                                } else {
                                    selectedVersion = nil
                                }
                            }
                        )) {
                            // Empty content - just for expansion
                        } label: {
                            ReleaseNoteDisclosureLabel(release: release)
                        }
                        .padding(.vertical, 2)
                        .accessibilityIdentifier("ReleaseVersion-\(release.version)")
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            }
            .frame(width: 125)
            .navigationSplitViewColumnWidth(min: 125, ideal: 125, max: 125)
        } detail: {
            // Content area
            Group {
                if let selectedVersion = selectedVersion {
                    ReleaseNoteContentView(release: selectedVersion)
                } else {
                    ReleaseNotesOverviewView(
                        releases: releaseNotes,
                        onSelectVersion: { version in
                            selectedVersion = version
                        }
                    )
                }
            }
            .frame(minWidth: 400, maxWidth: .infinity)
            .navigationTitle("Release Notes")
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .frame(minWidth: 650, minHeight: 500)
        .onAppear {
            selectedVersion = releaseNotes.first { $0.isCurrent }
        }
    }
}

/// Release note disclosure label for sidebar
struct ReleaseNoteDisclosureLabel: View {
    let release: ReleaseNote

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(release.version)
                        .font(.headline)
                        .fontWeight(.semibold)

                    if release.isCurrent {
                        Text("Current")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.accentColor)
                            .cornerRadius(3)
                    }
                }

                Text(dateFormatter.string(from: release.releaseDate))
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text("\(release.features.count) features")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

/// Release note row for sidebar
struct ReleaseNoteRow: View {
    let release: ReleaseNote

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(release.version)
                    .font(.headline)
                    .fontWeight(.semibold)

                if release.isCurrent {
                    Text("Current")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor)
                        .cornerRadius(4)
                }

                Spacer()
            }

            Text(dateFormatter.string(from: release.releaseDate))
                .font(.caption)
                .foregroundColor(.secondary)

            Text("\(release.features.count) new features")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

/// Release notes overview
struct ReleaseNotesOverviewView: View {
    let releases: [ReleaseNote]
    let onSelectVersion: (ReleaseNote) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "newspaper")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)

                    Text("AppDock Release Notes")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Stay up to date with the latest features and improvements")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Current version highlight
                if let currentRelease = releases.first(where: { $0.isCurrent }) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What's New in \(currentRelease.version)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(currentRelease.features.prefix(4)) { feature in
                                ReleaseFeatureCard(feature: feature) {
                                    onSelectVersion(currentRelease)
                                }
                            }
                        }
                        .padding(.horizontal)

                        if currentRelease.features.count > 4 {
                            Button("View All \(currentRelease.features.count) Features") {
                                onSelectVersion(currentRelease)
                            }
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                }

                // Recent releases
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Releases")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    VStack(spacing: 8) {
                        ForEach(releases.prefix(3)) { release in
                            ReleaseSummaryRow(release: release) {
                                onSelectVersion(release)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
}

/// Release summary row
struct ReleaseSummaryRow: View {
    let release: ReleaseNote
    let onTap: () -> Void

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(release.version)
                            .font(.headline)
                            .fontWeight(.medium)

                        if release.isCurrent {
                            Text("Current")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.accentColor)
                                .cornerRadius(3)
                        }
                    }

                    Text(dateFormatter.string(from: release.releaseDate))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(release.features.count) features • \(release.fixes.count) fixes")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.controlBackgroundColor))
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

/// Release feature card
struct ReleaseFeatureCard: View {
    let feature: ReleaseFeature
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: iconForFeature(feature))
                        .font(.system(size: 16))
                        .foregroundColor(colorForFeature(feature))

                    Spacer()

                    if feature.isNew {
                        Text("NEW")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.green)
                            .cornerRadius(3)
                    }
                }

                Text(feature.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 80)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
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

    private func iconForFeature(_ feature: ReleaseFeature) -> String {
        if feature.isNew { return "sparkles" }
        if feature.isImproved { return "arrow.up.circle" }
        if feature.isFixed { return "checkmark.circle" }
        return "info.circle"
    }

    private func colorForFeature(_ feature: ReleaseFeature) -> Color {
        if feature.isNew { return .green }
        if feature.isImproved { return .blue }
        if feature.isFixed { return .orange }
        return .gray
    }
}

/// Detailed release note content view
struct ReleaseNoteContentView: View {
    let release: ReleaseNote

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Version \(release.version)")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        if release.isCurrent {
                            Text("Current Version")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.accentColor)
                                .cornerRadius(6)
                        }

                        Spacer()
                    }

                    Text("Released on \(dateFormatter.string(from: release.releaseDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Build \(release.buildNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Features
                if !release.features.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("New Features")
                            .font(.title2)
                            .fontWeight(.bold)

                        LazyVStack(spacing: 12) {
                            ForEach(release.features) { feature in
                                ReleaseFeatureDetailView(feature: feature)
                            }
                        }
                    }
                }

                // Improvements
                if !release.improvements.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Improvements")
                            .font(.title2)
                            .fontWeight(.bold)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(release.improvements, id: \.self) { improvement in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "arrow.up.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(.blue)
                                        .frame(width: 20)

                                    Text(improvement)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)

                                    Spacer()
                                }
                            }
                        }
                    }
                }

                // Fixes
                if !release.fixes.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Bug Fixes")
                            .font(.title2)
                            .fontWeight(.bold)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(release.fixes, id: \.self) { fix in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(.green)
                                        .frame(width: 20)

                                    Text(fix)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)

                                    Spacer()
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
}

/// Detailed feature view
struct ReleaseFeatureDetailView: View {
    let feature: ReleaseFeature

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: iconForFeature(feature))
                .font(.system(size: 20))
                .foregroundColor(colorForFeature(feature))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(feature.title)
                        .font(.headline)
                        .fontWeight(.semibold)

                    if feature.isNew {
                        Text("NEW")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .cornerRadius(4)
                    }
                }

                Text(feature.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func iconForFeature(_ feature: ReleaseFeature) -> String {
        if feature.isNew { return "sparkles" }
        if feature.isImproved { return "arrow.up.circle" }
        if feature.isFixed { return "checkmark.circle" }
        return "info.circle"
    }

    private func colorForFeature(_ feature: ReleaseFeature) -> Color {
        if feature.isNew { return .green }
        if feature.isImproved { return .blue }
        if feature.isFixed { return .orange }
        return .gray
    }
}

/// Preview provider
struct ReleaseNotes_Previews: PreviewProvider {
    static var previews: some View {
        ReleaseNotesPanel()
    }
}
