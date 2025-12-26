//
//  MenuController.swift
//  AppDock
//
//  Created by Jared Miller on 12/17/24.
//

// Import the SwiftUI framework for user interface components.
import SwiftUI

// Import Foundation framework for basic functionality.
import Foundation

// MARK: - Menu Controller

/// Centralizes popover sizing so content and AppKit stay in sync.
enum PopoverSizing {
    static let defaultWidth: CGFloat = 260
    static let height: CGFloat = 460
    static let columnSpacing: CGFloat = 16

    static func width(for appState: AppState) -> CGFloat {
        let extraColumns = max(0, appState.gridColumns - SettingsDefaults.gridColumnsDefault)
        let columnIncrement = CGFloat(appState.iconSize) + columnSpacing
        return defaultWidth + CGFloat(extraColumns) * columnIncrement
    }

    static func size(for appState: AppState) -> NSSize {
        NSSize(width: width(for: appState), height: height)
    }
}

/// Hosts the SwiftUI popover content inside an AppKit view controller.
///
/// This wrapper keeps AppKit/SwiftUI interop isolated from the rest of the app.
class MenuController: NSObject {
    
    /// Creates a popover controller for the dock and menu actions.
    func makePopoverController(
        appState: AppState,
        settingsAction: @escaping () -> Void,
        aboutAction: @escaping () -> Void,
        quitAction: @escaping () -> Void
    ) -> NSViewController {
        let contentView = PopoverContentView(
            appState: appState,
            settingsAction: settingsAction,
            aboutAction: aboutAction,
            quitAction: quitAction
        )
        let hostingController = NSHostingController(rootView: contentView)
        hostingController.view.frame.size = PopoverSizing.size(for: appState)
        return hostingController
    }
}

/// Popover content for the menu bar window.
struct PopoverContentView: View {
    @ObservedObject var appState: AppState
    let settingsAction: () -> Void
    let aboutAction: () -> Void
    let quitAction: () -> Void
    @State private var previousPage: MenuPage = .dock

    private var popoverWidth: CGFloat {
        PopoverSizing.width(for: appState)
    }

    private var pageAnimation: Animation? {
        appState.reduceMotion ? nil : .easeInOut(duration: 0.22)
    }

    private var pageTransition: AnyTransition {
        guard !appState.reduceMotion else { return .opacity }
        let moveForward = appState.menuPage.orderIndex >= previousPage.orderIndex
        let insertion = AnyTransition.move(edge: moveForward ? .trailing : .leading)
            .combined(with: .opacity)
        let removal = AnyTransition.move(edge: moveForward ? .leading : .trailing)
            .combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }

    private func selectPage(_ page: MenuPage) {
        guard page != appState.menuPage else { return }
        previousPage = appState.menuPage
        if let animation = pageAnimation {
            withAnimation(animation) {
                appState.menuPage = page
            }
        } else {
            appState.menuPage = page
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if appState.menuPage == .dock {
                    FilterMenuButton(appState: appState)
                } else {
                    MenuPageHeader(page: appState.menuPage)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 6)

            Divider()
                .padding(.horizontal, 8)

            ZStack {
                switch appState.menuPage {
                case .dock:
                    ScrollView(showsIndicators: false) {
                        DockView(appState: appState)
                            .padding(.horizontal, 8)
                            .padding(.top, 6)
                            .padding(.bottom, 10)
                    }
                    .transition(pageTransition)
                case .recents:
                    ScrollView(showsIndicators: false) {
                        MenuAppListView(
                            title: "Recent Apps",
                            apps: appState.recentApps,
                            emptyTitle: "No Recent Apps",
                            emptyMessage: "Launch an app to see it here.",
                            emptySystemImage: "clock.arrow.circlepath"
                        )
                        .padding(.horizontal, 12)
                        .padding(.top, 10)
                        .padding(.bottom, 12)
                    }
                    .transition(pageTransition)
                case .favorites:
                    ScrollView(showsIndicators: false) {
                        MenuEmptyState(
                            title: "No Favorites Yet",
                            message: "Pin apps to keep them on this page.",
                            systemImage: "star"
                        )
                        .padding(.horizontal, 12)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                    }
                    .transition(pageTransition)
                case .actions:
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            MenuRow(title: "Settings", action: settingsAction)
                            Divider()
                            MenuRow(title: "About", action: aboutAction)
                            Divider()
                            MenuRow(title: "Quit AppDock", action: quitAction)
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    }
                    .transition(pageTransition)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            Divider()
                .padding(.horizontal, 8)
                .padding(.top, 6)

            MenuPageBar(selectedPage: appState.menuPage, onSelect: selectPage)
                .padding(.horizontal, 8)
                .padding(.bottom, 6)
        }
        .frame(width: popoverWidth, height: PopoverSizing.height, alignment: .top)
        .simultaneousGesture(TapGesture().onEnded {
            NotificationCenter.default.post(name: .appDockDismissContextMenu, object: nil)
        })
        .onAppear {
            previousPage = appState.menuPage
        }
    }
}

private struct MenuPageHeader: View {
    let page: MenuPage

    var body: some View {
        HStack {
            Label(page.title, systemImage: page.systemImage)
                .font(.caption)
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.primary.opacity(0.08))
        )
    }
}

private struct FilterMenuButton: View {
    @ObservedObject var appState: AppState

    var body: some View {
        Menu {
            Picker("Show", selection: $appState.filterOption) {
                ForEach(AppFilterOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            Divider()
            Picker("Sort", selection: $appState.sortOption) {
                ForEach(AppSortOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
        } label: {
            HStack {
                Label("Filter & Sort", systemImage: "line.3.horizontal.decrease.circle")
                    .font(.caption)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.08))
            )
        }
        .accessibilityIdentifier(AppDockConstants.Accessibility.dockFilterMenu)
    }
}

private struct MenuPageBar: View {
    let selectedPage: MenuPage
    let onSelect: (MenuPage) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(MenuPage.allCases) { page in
                Button {
                    onSelect(page)
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: page.systemImage)
                            .font(.system(size: 13, weight: .semibold))
                        Text(page.title)
                            .font(.caption2)
                    }
                    .foregroundColor(selectedPage == page ? .accentColor : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedPage == page ? Color.accentColor.opacity(0.18) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .keyboardShortcut(page.shortcutKey, modifiers: .command)
                .accessibilityIdentifier(AppDockConstants.Accessibility.menuPageButtonPrefix + page.rawValue)
            }
        }
        .padding(.top, 2)
    }
}

private struct MenuAppListView: View {
    let title: String
    let apps: [AppState.AppEntry]
    let emptyTitle: String
    let emptyMessage: String
    let emptySystemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            if apps.isEmpty {
                MenuEmptyState(
                    title: emptyTitle,
                    message: emptyMessage,
                    systemImage: emptySystemImage
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(apps.enumerated()), id: \.offset) { _, app in
                        MenuAppRow(app: app)
                    }
                }
            }
        }
    }
}

private struct MenuAppRow: View {
    let app: AppState.AppEntry

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: app.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .cornerRadius(6)

            Text(app.name)
                .font(.callout)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(0.05))
        )
    }
}

private struct MenuEmptyState: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

/// Single menu row with hover feedback.
private struct MenuRow: View {
    let title: String
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovering ? Color.primary.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .contentShape(RoundedRectangle(cornerRadius: 6))
        .accessibilityIdentifier(AppDockConstants.Accessibility.menuRowPrefix + title)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
