//
//  MenuPages.swift
//  AppDock
//

import SwiftUI
import AppKit

struct MenuAppListView: View {
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

struct MenuAppRow: View {
    let app: AppState.AppEntry
    @State private var isHovering = false

    private func openApp(bundleId: String) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            return
        }
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.createsNewApplicationInstance = false
        NSWorkspace.shared.openApplication(
            at: appURL,
            configuration: configuration,
            completionHandler: nil
        )
    }

    private func activateOrLaunchApp(bundleId: String) {
        if ProcessInfo.processInfo.arguments.contains(AppDockConstants.Testing.uiTestDisableActivation) {
            return
        }
        guard !bundleId.isEmpty else { return }

        if let targetApp = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleId)
            .first(where: { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }) {
            targetApp.unhide()
            targetApp.activate(options: [.activateAllWindows])
            openApp(bundleId: bundleId)
        } else {
            openApp(bundleId: bundleId)
        }
    }

    var body: some View {
        Button {
            activateOrLaunchApp(bundleId: app.bundleid)
        } label: {
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
                    .fill(isHovering ? Color.primary.opacity(0.1) : Color.primary.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: AppDockConstants.MenuAppRow.cornerRadius))
        .onHover { hovering in
            isHovering = hovering
        }
        .disabled(app.bundleid.isEmpty)
    }
}

struct MenuEmptyState: View {
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
struct MenuRow: View {
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
