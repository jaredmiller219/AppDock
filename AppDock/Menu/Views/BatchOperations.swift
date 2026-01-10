//
//  BatchOperations.swift
//  AppDock
//
//  Multi-select and bulk operations functionality
//

import SwiftUI

/// Selection state for batch operations
struct SelectionState: Equatable {
    var selectedApps: Set<String> = []
    var isSelectionMode: Bool = false
    
    mutating func toggleSelection(bundleId: String) {
        if selectedApps.contains(bundleId) {
            selectedApps.remove(bundleId)
        } else {
            selectedApps.insert(bundleId)
        }
    }
    
    mutating func clearSelection() {
        selectedApps.removeAll()
        isSelectionMode = false
    }
    
    mutating func selectAll(_ bundleIds: [String]) {
        selectedApps = Set(bundleIds)
        isSelectionMode = true
    }
    
    var hasSelection: Bool {
        !selectedApps.isEmpty
    }
    
    var selectionCount: Int {
        selectedApps.count
    }
}

/// Batch operations toolbar
struct BatchOperationsToolbar: View {
    @Binding var selectionState: SelectionState
    let availableApps: [AppState.AppEntry]
    
    let onQuitSelected: ([String]) -> Void
    let onHideSelected: ([String]) -> Void
    let onAddToFavorites: ([String]) -> Void
    let onRemoveFromDock: ([String]) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Selection header
            HStack {
                Button(action: {
                    selectionState.clearSelection()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.secondary)
                
                Text(selectionState.selectionCount == 1 ? "1 app selected" : "\(selectionState.selectionCount) apps selected")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    let allBundleIds = availableApps.map { $0.bundleid }
                    if selectionState.selectionCount == availableApps.count {
                        selectionState.clearSelection()
                    } else {
                        selectionState.selectAll(allBundleIds)
                    }
                }) {
                    Text(selectionState.selectionCount == availableApps.count ? "Deselect All" : "Select All")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.controlBackgroundColor))
            
            Divider()
            
            // Action buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    BatchActionButton(
                        title: "Quit",
                        icon: "power",
                        color: .red,
                        isEnabled: selectionState.hasSelection
                    ) {
                        onQuitSelected(Array(selectionState.selectedApps))
                    }
                    
                    BatchActionButton(
                        title: "Hide",
                        icon: "eye.slash",
                        color: .orange,
                        isEnabled: selectionState.hasSelection
                    ) {
                        onHideSelected(Array(selectionState.selectedApps))
                    }
                    
                    BatchActionButton(
                        title: "Add to Favorites",
                        icon: "star",
                        color: .yellow,
                        isEnabled: selectionState.hasSelection
                    ) {
                        onAddToFavorites(Array(selectionState.selectedApps))
                    }
                    
                    BatchActionButton(
                        title: "Remove from Dock",
                        icon: "minus.circle",
                        color: .red,
                        isEnabled: selectionState.hasSelection
                    ) {
                        onRemoveFromDock(Array(selectionState.selectedApps))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .background(Color(.controlBackgroundColor))
        }
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

/// Individual batch action button
struct BatchActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(isEnabled ? color : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isEnabled ? color.opacity(0.1) : Color(.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isEnabled ? color.opacity(0.3) : Color(.separatorColor), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
    }
}

/// Enhanced app row with selection support
struct SelectableAppRow: View {
    let app: AppState.AppEntry
    @Binding var selectionState: SelectionState
    let isSelectionMode: Bool
    
    let onTap: (AppState.AppEntry) -> Void
    let onCommandClick: (AppState.AppEntry) -> Void
    
    private var isSelected: Bool {
        selectionState.selectedApps.contains(app.bundleid)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox
            if isSelectionMode {
                Button(action: {
                    selectionState.toggleSelection(bundleId: app.bundleid)
                }) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? .accentColor : .secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // App icon
            Image(nsImage: app.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .cornerRadius(6)
            
            // App info
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                
                Text(app.bundleid)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if isSelectionMode {
                selectionState.toggleSelection(bundleId: app.bundleid)
            } else {
                onTap(app)
            }
        }
        .gesture(
            TapGesture()
                .modifiers(.command)
                .onEnded { _ in
                    onCommandClick(app)
                }
        )
    }
}

/// Batch operations manager
class BatchOperationsManager: ObservableObject {
    @Published var selectionState = SelectionState()
    
    func performBatchQuit(bundleIds: [String]) {
        for bundleId in bundleIds {
            if let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first {
                app.terminate()
            }
        }
        selectionState.clearSelection()
    }
    
    func performBatchHide(bundleIds: [String]) {
        for bundleId in bundleIds {
            if let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first {
                app.hide()
            }
        }
        selectionState.clearSelection()
    }
    
    func performBatchAddToFavorites(bundleIds: [String]) {
        // Implementation would depend on favorites storage
        selectionState.clearSelection()
    }
    
    func performBatchRemoveFromDock(bundleIds: [String]) {
        // Implementation would depend on dock storage
        selectionState.clearSelection()
    }
}

/// Enhanced dock view with batch operations support
struct BatchOperationsDockView: View {
    @StateObject private var batchManager = BatchOperationsManager()
    @State private var isSelectionMode = false
    
    let apps: [AppState.AppEntry]
    let appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Batch operations toolbar (shown when in selection mode)
            if isSelectionMode {
                BatchOperationsToolbar(
                    selectionState: $batchManager.selectionState,
                    availableApps: apps
                ) { bundleIds in
                    batchManager.performBatchQuit(bundleIds: bundleIds)
                } onHideSelected: { bundleIds in
                    batchManager.performBatchHide(bundleIds: bundleIds)
                } onAddToFavorites: { bundleIds in
                    batchManager.performBatchAddToFavorites(bundleIds: bundleIds)
                } onRemoveFromDock: { bundleIds in
                    batchManager.performBatchRemoveFromDock(bundleIds: bundleIds)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: isSelectionMode)
            }
            
            // Mode toggle button
            if !isSelectionMode {
                HStack {
                    Spacer()
                    Button(action: {
                        isSelectionMode = true
                        batchManager.selectionState.isSelectionMode = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.square")
                                .font(.system(size: 12, weight: .medium))
                            Text("Select Multiple")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.accentColor.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            
            // App list
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 4) {
                    ForEach(apps, id: \.bundleid) { app in
                        SelectableAppRow(
                            app: app,
                            selectionState: $batchManager.selectionState,
                            isSelectionMode: isSelectionMode
                        ) { selectedApp in
                            // Handle app launch
                            if let nsApp = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == selectedApp.bundleid }) {
                                nsApp.activate()
                            } else {
                                NSWorkspace.shared.launchApplication(withBundleIdentifier: selectedApp.bundleid, options: [], additionalEventParamDescriptor: nil, launchIdentifier: nil)
                            }
                        } onCommandClick: { selectedApp in
                            // Handle context menu
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .onChange(of: batchManager.selectionState.isSelectionMode) { newValue in
            if !newValue {
                isSelectionMode = false
            }
        }
    }
}

/// Preview provider for SwiftUI previews
struct BatchOperations_Previews: PreviewProvider {
    static var previews: some View {
        let sampleApps: [AppState.AppEntry] = [
            ("Safari", "com.apple.Safari", NSImage()),
            ("Notes", "com.apple.Notes", NSImage()),
            ("Music", "com.apple.Music", NSImage())
        ]
        
        VStack(spacing: 20) {
            BatchOperationsToolbar(
                selectionState: .constant(SelectionState(selectedApps: ["com.apple.Safari"], isSelectionMode: true)),
                availableApps: sampleApps
            ) { _ in } onHideSelected: { _ in } onAddToFavorites: { _ in } onRemoveFromDock: { _ in }
            
            SelectableAppRow(
                app: sampleApps[0],
                selectionState: .constant(SelectionState(selectedApps: ["com.apple.Safari"], isSelectionMode: true)),
                isSelectionMode: true
            ) { _ in } onCommandClick: { _ in }
        }
        .padding()
    }
}
