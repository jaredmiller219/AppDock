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
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Menu Controller

/// Centralizes popover sizing so content and AppKit stay in sync.
enum PopoverSizing {
    static var defaultWidth: CGFloat { AppDockConstants.MenuPopover.defaultWidth }
    static var height: CGFloat { AppDockConstants.MenuPopover.height }
    static var columnSpacing: CGFloat { AppDockConstants.MenuPopover.columnSpacing }

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
    private let swipeThreshold: CGFloat = 50

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

    private func handleSwipeDirection(_ direction: SwipeDirection, source: SwipeSource) {
        let orderedPages = MenuPage.allCases.sorted { $0.orderIndex < $1.orderIndex }
        guard let currentIndex = orderedPages.firstIndex(of: appState.menuPage) else { return }
        let nextIndex = direction == .left ? currentIndex + 1 : currentIndex - 1
        guard orderedPages.indices.contains(nextIndex) else { return }
        selectPage(orderedPages[nextIndex])
    }

    private func handleDrag(_ value: DragGesture.Value) {
        let horizontal = value.translation.width
        let vertical = value.translation.height
        guard abs(horizontal) > abs(vertical), abs(horizontal) >= swipeThreshold else { return }
        handleSwipeDirection(horizontal < 0 ? .left : .right, source: .drag)
    }

    var body: some View {
        VStack(spacing: 0) {
            if appState.menuLayoutMode == .simple {
                simpleMenuContent
            } else {
                advancedMenuContent
            }
        }
        .frame(width: popoverWidth, height: AppDockConstants.MenuPopover.height, alignment: .top)
        .simultaneousGesture(TapGesture().onEnded {
            NotificationCenter.default.post(name: .appDockDismissContextMenu, object: nil)
        })
        .onAppear {
            previousPage = appState.menuPage
        }
    }
}

private extension PopoverContentView {
    var simpleMenuContent: some View {
        VStack(spacing: 0) {
            FilterMenuButton(appState: appState)
                .padding(.horizontal, AppDockConstants.MenuLayout.headerPaddingHorizontal)
                .padding(.top, AppDockConstants.MenuLayout.headerPaddingTop)
                .padding(.bottom, AppDockConstants.MenuLayout.headerPaddingBottom)

            Divider()
                .padding(.horizontal, AppDockConstants.MenuLayout.dividerPaddingHorizontal)

            ScrollView(showsIndicators: false) {
                DockView(appState: appState)
                    .padding(.horizontal, AppDockConstants.MenuLayout.dockPaddingHorizontal)
                    .padding(.top, AppDockConstants.MenuLayout.dockPaddingTop)
                    .padding(.bottom, AppDockConstants.MenuLayout.dockPaddingBottom)
            }
            .frame(maxHeight: .infinity)
            .layoutPriority(1)

            Divider()
                .padding(.horizontal, AppDockConstants.MenuLayout.dividerPaddingHorizontal)
                .padding(.top, AppDockConstants.MenuLayout.bottomDividerPaddingTop)

            VStack(spacing: 0) {
                MenuRow(title: "Settings", action: settingsAction)
                Divider()
                MenuRow(title: "About", action: aboutAction)
                Divider()
                MenuRow(title: "Quit AppDock", action: quitAction)
            }
            .padding(.horizontal, AppDockConstants.MenuLayout.actionsPaddingHorizontal)
            .padding(.top, AppDockConstants.MenuLayout.actionsPaddingTop)
            .padding(.bottom, AppDockConstants.MenuLayout.actionsPaddingBottom)
        }
    }

    var advancedMenuContent: some View {
        VStack(spacing: 0) {
            Group {
                if appState.menuPage == .dock {
                    FilterMenuButton(appState: appState)
                } else {
                    MenuPageHeader(page: appState.menuPage)
                }
            }
            .padding(.horizontal, AppDockConstants.MenuLayout.headerPaddingHorizontal)
            .padding(.top, AppDockConstants.MenuLayout.headerPaddingTop)
            .padding(.bottom, AppDockConstants.MenuLayout.headerPaddingBottom)

            Divider()
                .padding(.horizontal, AppDockConstants.MenuLayout.dividerPaddingHorizontal)

            ZStack {
                switch appState.menuPage {
                case .dock:
                    ScrollView(showsIndicators: false) {
                        DockView(appState: appState)
                            .padding(.horizontal, AppDockConstants.MenuLayout.dockPaddingHorizontal)
                            .padding(.top, AppDockConstants.MenuLayout.dockPaddingTop)
                            .padding(.bottom, AppDockConstants.MenuLayout.dockPaddingBottom)
                    }
                    .frame(maxHeight: .infinity)
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
                        .padding(.horizontal, AppDockConstants.MenuLayout.recentsPaddingHorizontal)
                        .padding(.top, AppDockConstants.MenuLayout.recentsPaddingTop)
                        .padding(.bottom, AppDockConstants.MenuLayout.recentsPaddingBottom)
                    }
                    .frame(maxHeight: .infinity)
                    .transition(pageTransition)
                case .favorites:
                    ScrollView(showsIndicators: false) {
                        MenuEmptyState(
                            title: "No Favorites Yet",
                            message: "Pin apps to keep them on this page.",
                            systemImage: "star"
                        )
                        .padding(.horizontal, AppDockConstants.MenuLayout.favoritesPaddingHorizontal)
                        .padding(.top, AppDockConstants.MenuLayout.favoritesPaddingTop)
                        .padding(.bottom, AppDockConstants.MenuLayout.favoritesPaddingBottom)
                    }
                    .frame(maxHeight: .infinity)
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
                        .padding(.horizontal, AppDockConstants.MenuLayout.actionsPaddingHorizontal)
                        .padding(.top, AppDockConstants.MenuLayout.actionsPaddingTop)
                        .padding(.bottom, AppDockConstants.MenuLayout.actionsPaddingBottom)
                    }
                    .frame(maxHeight: .infinity)
                    .transition(pageTransition)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .layoutPriority(1)

            Divider()
                .padding(.horizontal, AppDockConstants.MenuLayout.dividerPaddingHorizontal)
                .padding(.top, AppDockConstants.MenuLayout.bottomDividerPaddingTop)

            MenuPageBar(selectedPage: appState.menuPage, onSelect: selectPage)
                .padding(.horizontal, AppDockConstants.MenuLayout.bottomBarPaddingHorizontal)
                .padding(.bottom, AppDockConstants.MenuLayout.bottomBarPaddingBottom)
        }
        .contentShape(Rectangle())
#if canImport(AppKit) || canImport(UIKit)
        .background(SwipeGestureCaptureView(swipeThreshold: swipeThreshold) { direction in
            handleSwipeDirection(direction, source: .trackpad)
        })
#endif
        .simultaneousGesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    handleDrag(value)
                }
        )
    }
}

private enum SwipeDirection {
    case left
    case right
}

private enum SwipeSource {
    case trackpad
    case drag

    var label: String {
        switch self {
        case .trackpad:
            return "trackpad"
        case .drag:
            return "drag"
        }
    }
}

#if canImport(AppKit)
private struct SwipeGestureCaptureView: NSViewRepresentable {
    let swipeThreshold: CGFloat
    let onSwipe: (SwipeDirection) -> Void

    func makeNSView(context: Context) -> SwipeCaptureNSView {
        let view = SwipeCaptureNSView()
        view.swipeThreshold = swipeThreshold
        view.onSwipe = onSwipe
        return view
    }

    func updateNSView(_ nsView: SwipeCaptureNSView, context: Context) {
        nsView.swipeThreshold = swipeThreshold
        nsView.onSwipe = onSwipe
    }

    final class SwipeCaptureNSView: NSView {
        var onSwipe: ((SwipeDirection) -> Void)?
        var swipeThreshold: CGFloat = 50
        private var scrollMonitor: Any?
        private var accumulatedX: CGFloat = 0
        private var accumulatedY: CGFloat = 0
        private var didTrigger = false

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            wantsLayer = true
        }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if scrollMonitor == nil {
                scrollMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
                    guard let self else { return event }
                    guard self.window === event.window else { return event }
                    let location = self.convert(event.locationInWindow, from: nil)
                    guard self.bounds.contains(location) else { return event }
                    self.handleScrollEvent(event)
                    return event
                }
            }
        }

        deinit {
            if let scrollMonitor {
                NSEvent.removeMonitor(scrollMonitor)
            }
        }

        override func swipe(with event: NSEvent) {
            if event.deltaX > 0 {
                onSwipe?(.right)
            } else if event.deltaX < 0 {
                onSwipe?(.left)
            }
        }

        private func handleScrollEvent(_ event: NSEvent) {
            if event.phase == .began {
                accumulatedX = 0
                accumulatedY = 0
                didTrigger = false
            }

            accumulatedX += event.scrollingDeltaX
            accumulatedY += event.scrollingDeltaY

            if !didTrigger,
               abs(accumulatedX) > abs(accumulatedY),
               abs(accumulatedX) >= swipeThreshold {
                didTrigger = true
                onSwipe?(accumulatedX < 0 ? .left : .right)
            }

            if event.phase == .ended || event.phase == .cancelled || event.momentumPhase == .ended {
                accumulatedX = 0
                accumulatedY = 0
                didTrigger = false
            }
        }
    }
}
#elseif canImport(UIKit)
private struct SwipeGestureCaptureView: UIViewRepresentable {
    let onSwipe: (SwipeDirection) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSwipe: onSwipe)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let leftSwipe = UISwipeGestureRecognizer(target: context.coordinator,
                                                 action: #selector(Coordinator.handleSwipe(_:)))
        leftSwipe.direction = .left
        let rightSwipe = UISwipeGestureRecognizer(target: context.coordinator,
                                                  action: #selector(Coordinator.handleSwipe(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    final class Coordinator: NSObject {
        private let onSwipe: (SwipeDirection) -> Void

        init(onSwipe: @escaping (SwipeDirection) -> Void) {
            self.onSwipe = onSwipe
        }

        @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
            switch gesture.direction {
            case .left:
                onSwipe(.left)
            case .right:
                onSwipe(.right)
            default:
                break
            }
        }
    }
}
#endif

private struct MenuPageHeader: View {
    let page: MenuPage

    var body: some View {
        HStack {
            Label(page.title, systemImage: page.systemImage)
                .font(.caption)
            Spacer()
        }
        .padding(.horizontal, AppDockConstants.MenuHeader.paddingHorizontal)
        .padding(.vertical, AppDockConstants.MenuHeader.paddingVertical)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppDockConstants.MenuHeader.cornerRadius)
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
            .padding(.horizontal, AppDockConstants.MenuHeader.paddingHorizontal)
            .padding(.vertical, AppDockConstants.MenuHeader.paddingVertical)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppDockConstants.MenuHeader.cornerRadius)
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
        HStack(spacing: AppDockConstants.MenuPageBar.spacing) {
            ForEach(MenuPage.allCases) { page in
                Button {
                    onSelect(page)
                } label: {
                    VStack(spacing: AppDockConstants.MenuPageBar.labelSpacing) {
                        Image(systemName: page.systemImage)
                            .font(.system(size: AppDockConstants.MenuPageBar.iconFontSize, weight: .semibold))
                        Text(page.title)
                            .font(.caption2)
                    }
                    .foregroundColor(selectedPage == page ? .accentColor : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppDockConstants.MenuPageBar.paddingVertical)
                    .background(
                        RoundedRectangle(cornerRadius: AppDockConstants.MenuPageBar.cornerRadius)
                            .fill(selectedPage == page ? Color.accentColor.opacity(0.18) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .keyboardShortcut(page.shortcutKey, modifiers: .command)
                .accessibilityIdentifier(AppDockConstants.Accessibility.menuPageButtonPrefix + page.rawValue)
            }
        }
        .padding(.top, AppDockConstants.MenuPageBar.topPadding)
    }
}

private struct MenuAppListView: View {
    let title: String
    let apps: [AppState.AppEntry]
    let emptyTitle: String
    let emptyMessage: String
    let emptySystemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppDockConstants.MenuAppList.spacing) {
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
                VStack(spacing: AppDockConstants.MenuAppList.rowSpacing) {
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
        HStack(spacing: AppDockConstants.MenuAppRow.spacing) {
            Image(nsImage: app.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: AppDockConstants.MenuAppRow.iconSize, height: AppDockConstants.MenuAppRow.iconSize)
                .cornerRadius(AppDockConstants.MenuAppRow.iconCornerRadius)

            Text(app.name)
                .font(.callout)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, AppDockConstants.MenuAppRow.paddingHorizontal)
        .padding(.vertical, AppDockConstants.MenuAppRow.paddingVertical)
        .background(
            RoundedRectangle(cornerRadius: AppDockConstants.MenuAppRow.cornerRadius)
                .fill(Color.primary.opacity(0.05))
        )
    }
}

private struct MenuEmptyState: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: AppDockConstants.MenuEmptyState.spacing) {
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
        .padding(.vertical, AppDockConstants.MenuEmptyState.paddingVertical)
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
            .padding(.horizontal, AppDockConstants.MenuRow.paddingHorizontal)
            .padding(.vertical, AppDockConstants.MenuRow.paddingVertical)
            .background(
                RoundedRectangle(cornerRadius: AppDockConstants.MenuRow.cornerRadius)
                    .fill(isHovering ? Color.primary.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .contentShape(RoundedRectangle(cornerRadius: AppDockConstants.MenuRow.cornerRadius))
        .accessibilityIdentifier(AppDockConstants.Accessibility.menuRowPrefix + title)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
