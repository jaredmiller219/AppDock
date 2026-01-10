//
//  AppGroups.swift
//  AppDock
//
//  App Groups - Create folders/categories for organizing apps
//

import SwiftUI

/// App group for organizing applications
struct AppGroup: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var icon: String // SF Symbol name
    var color: String // Hex color
    var appBundleIds: Set<String>
    var isSystem: Bool // Built-in groups vs user-created
    var sortOrder: Int // Display order
    
    init(name: String, icon: String = "folder", color: String = "#007AFF", appBundleIds: Set<String> = [], isSystem: Bool = false, sortOrder: Int = 0) {
        self.name = name
        self.icon = icon
        self.color = color
        self.appBundleIds = appBundleIds
        self.isSystem = isSystem
        self.sortOrder = sortOrder
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
    static func == (lhs: AppGroup, rhs: AppGroup) -> Bool {
        lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case name, icon, color, appBundleIds, isSystem, sortOrder
    }
}

/// App group manager for persistence and operations
class AppGroupManager: ObservableObject {
    @Published var groups: [AppGroup] = []
    
    private let userDefaults = UserDefaults.standard
    private let groupsKey = "AppGroups"
    
    init() {
        loadGroups()
        ensureSystemGroups()
    }
    
    /// Load groups from UserDefaults
    private func loadGroups() {
        if let data = userDefaults.data(forKey: groupsKey),
           let decodedGroups = try? JSONDecoder().decode([AppGroup].self, from: data) {
            groups = decodedGroups.sorted { $0.sortOrder < $1.sortOrder }
        }
    }
    
    /// Save groups to UserDefaults
    private func saveGroups() {
        if let encoded = try? JSONEncoder().encode(groups) {
            userDefaults.set(encoded, forKey: groupsKey)
        }
    }
    
    /// Ensure system groups exist
    private func ensureSystemGroups() {
        let systemGroups: [AppGroup] = [
            AppGroup(
                name: "Work",
                icon: "briefcase",
                color: "#007AFF",
                isSystem: true,
                sortOrder: 0
            ),
            AppGroup(
                name: "Creative",
                icon: "paintbrush",
                color: "#FF9500",
                isSystem: true,
                sortOrder: 1
            ),
            AppGroup(
                name: "Development",
                icon: "hammer",
                color: "#34C759",
                isSystem: true,
                sortOrder: 2
            ),
            AppGroup(
                name: "Entertainment",
                icon: "gamecontroller",
                color: "#AF52DE",
                isSystem: true,
                sortOrder: 3
            ),
            AppGroup(
                name: "Utilities",
                icon: "wrench.and.screwdriver",
                color: "#6C757D",
                isSystem: true,
                sortOrder: 4
            )
        ]
        
        var hasChanges = false
        for systemGroup in systemGroups {
            if !groups.contains(where: { $0.name == systemGroup.name }) {
                groups.append(systemGroup)
                hasChanges = true
            }
        }
        
        if hasChanges {
            saveGroups()
        }
    }
    
    /// Add a new app group
    func addGroup(_ group: AppGroup) {
        let newGroup = AppGroup(
            name: group.name,
            icon: group.icon,
            color: group.color,
            appBundleIds: group.appBundleIds,
            isSystem: false,
            sortOrder: groups.filter { !$0.isSystem }.count
        )
        groups.append(newGroup)
        saveGroups()
    }
    
    /// Update an existing group
    func updateGroup(_ group: AppGroup) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index] = group
            saveGroups()
        }
    }
    
    /// Delete a group (only user-created groups)
    func deleteGroup(_ group: AppGroup) {
        guard !group.isSystem else { return }
        groups.removeAll { $0.id == group.id }
        saveGroups()
    }
    
    /// Add app to group
    func addAppToGroup(_ bundleId: String, groupId: UUID) {
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].appBundleIds.insert(bundleId)
            saveGroups()
        }
    }
    
    /// Remove app from group
    func removeAppFromGroup(_ bundleId: String, groupId: UUID) {
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].appBundleIds.remove(bundleId)
            saveGroups()
        }
    }
    
    /// Get groups that contain a specific app
    func getGroupsForApp(_ bundleId: String) -> [AppGroup] {
        return groups.filter { $0.appBundleIds.contains(bundleId) }
    }
    
    /// Move group to new position
    func moveGroup(_ group: AppGroup, to newIndex: Int) {
        guard let currentIndex = groups.firstIndex(where: { $0.id == group.id }) else { return }
        guard currentIndex != newIndex && newIndex >= 0 && newIndex < groups.count else { return }
        
        let movedGroup = groups.remove(at: currentIndex)
        groups.insert(movedGroup, at: newIndex)
        
        // Update sort orders
        for (index, group) in groups.enumerated() {
            if !group.isSystem {
                groups[index].sortOrder = index
            }
        }
        
        saveGroups()
    }
}

/// App group creation/editing view
struct AppGroupEditorView: View {
    @ObservedObject var groupManager: AppGroupManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var groupName = ""
    @State private var selectedIcon = "folder"
    @State private var selectedColor = "#007AFF"
    @State private var editingGroup: AppGroup?
    
    init(groupManager: AppGroupManager, editingGroup: AppGroup? = nil) {
        self.groupManager = groupManager
        self.editingGroup = editingGroup
    }
    
    private let availableIcons = [
        "folder", "briefcase", "paintbrush", "hammer", "gamecontroller",
        "wrench.and.screwdriver", "star", "heart", "book", "music.note",
        "photo", "video", "doc.text", "calendar", "clock", "globe",
        "cloud", "house", "car", "airplane", "bicycle", "bag"
    ]
    
    private let availableColors = [
        "#007AFF", "#FF9500", "#34C759", "#AF52DE", "#FF3B30",
        "#6C757D", "#8E8E93", "#000000", "#FFFFFF", "#FF6B6B"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Group Info") {
                    TextField("Group Name", text: $groupName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Icon picker
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                            }) {
                                Image(systemName: icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedIcon == icon ? Color(hex: selectedColor) : .primary)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.2) : Color.clear)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Color picker
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                        ForEach(availableColors, id: \.self) { color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Section("Preview") {
                    HStack {
                        Image(systemName: selectedIcon)
                            .font(.system(size: 32))
                            .foregroundColor(Color(hex: selectedColor))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(groupName.isEmpty ? "New Group" : groupName)
                                .font(.headline)
                                Text("\(groupManager.groups.first(where: { $0.id == editingGroup?.id })?.appBundleIds.count ?? 0) apps")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.controlBackgroundColor))
                    )
                }
            }
            .navigationTitle(editingGroup == nil ? "New Group" : "Edit Group")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(editingGroup == nil ? "Create" : "Save") {
                        saveGroup()
                    }
                    .disabled(groupName.isEmpty)
                }
                
                if editingGroup != nil {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Delete") {
                            deleteGroup()
                        }
                    }
                }
            }
        }
        .onAppear {
            if let group = editingGroup {
                groupName = group.name
                selectedIcon = group.icon
                selectedColor = group.color
            }
        }
    }
    
    private func saveGroup() {
        let group = AppGroup(
            name: groupName,
            icon: selectedIcon,
            color: selectedColor,
            appBundleIds: editingGroup?.appBundleIds ?? [],
            isSystem: false
        )
        
        if let editingGroup = editingGroup {
            // Update existing group
            var updatedGroup = editingGroup
            updatedGroup.name = groupName
            updatedGroup.icon = selectedIcon
            updatedGroup.color = selectedColor
            groupManager.updateGroup(updatedGroup)
        } else {
            // Create new group
            groupManager.addGroup(group)
        }
        
        dismiss()
    }
    
    private func deleteGroup() {
        if let editingGroup = editingGroup {
            groupManager.deleteGroup(editingGroup)
            dismiss()
        }
    }
}

/// App groups management view
struct AppGroupsView: View {
    @ObservedObject var groupManager: AppGroupManager
    @State private var showingEditor = false
    @State private var editingGroup: AppGroup?
    @State private var showingAppPicker = false
    @State private var targetGroupId: UUID?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupManager.groups) { group in
                    AppGroupRow(
                        group: group,
                        onEdit: {
                            editingGroup = group
                            showingEditor = true
                        },
                        onDelete: {
                            groupManager.deleteGroup(group)
                        },
                        onAddApps: {
                            targetGroupId = group.id
                            showingAppPicker = true
                        }
                    )
                }
                .onMove { indexSet, index in
                    guard let fromIndex = indexSet.first else { return }
                    let movedGroup = groupManager.groups[fromIndex]
                    groupManager.moveGroup(movedGroup, to: index)
                }
            }
            .navigationTitle("App Groups")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        editingGroup = nil
                        showingEditor = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            AppGroupEditorView(groupManager: groupManager, editingGroup: editingGroup)
        }
        .sheet(isPresented: $showingAppPicker) {
            if let groupId = targetGroupId {
                AppPickerView(groupManager: groupManager, groupId: groupId)
            }
        }
    }
}

/// Individual app group row
struct AppGroupRow: View {
    let group: AppGroup
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onAddApps: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Group icon
            Image(systemName: group.icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: group.color))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: group.color).opacity(0.2))
                )
            
            // Group info
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text("\(group.appBundleIds.count) apps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 8) {
                if !group.isSystem {
                    Button(action: onAddApps) {
                        Image(systemName: "plus")
                            .font(.system(size: 14))
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Button(action: onAddApps) {
                        Image(systemName: "plus")
                            .font(.system(size: 14))
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.controlBackgroundColor))
        )
    }
}

/// App picker for adding apps to groups
struct AppPickerView: View {
    @ObservedObject var groupManager: AppGroupManager
    let groupId: UUID
    @Environment(\.dismiss) private var dismiss
    
    // This would be populated with actual running apps
    @State private var availableApps: [(bundleId: String, name: String, icon: NSImage)] = [
        ("com.apple.Safari", "Safari", NSImage()),
        ("com.apple.Music", "Music", NSImage()),
        ("com.apple.Notes", "Notes", NSImage()),
        ("com.apple.Photos", "Photos", NSImage()),
        ("com.apple.Mail", "Mail", NSImage()),
        ("com.apple.Calendar", "Calendar", NSImage()),
        ("com.apple.Reminders", "Reminders", NSImage()),
        ("com.apple.VoiceMemos", "Voice Memos", NSImage()),
        ("com.apple.Finder", "Finder", NSImage()),
        ("com.apple.Terminal", "Terminal", NSImage())
    ]
    
    var body: some View {
        NavigationView {
            List(availableApps, id: \.bundleId) { app in
                AppPickerRow(
                    app: app,
                    groupId: groupId,
                    groupManager: groupManager
                )
            }
            .navigationTitle("Add Apps")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Individual app row in picker
struct AppPickerRow: View {
    let app: (bundleId: String, name: String, icon: NSImage)
    let groupId: UUID
    @ObservedObject var groupManager: AppGroupManager
    
    private var isInGroup: Bool {
        groupManager.groups.first(where: { $0.id == groupId })?.appBundleIds.contains(app.bundleId) ?? false
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: app.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(app.bundleId)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                if isInGroup {
                    groupManager.removeAppFromGroup(app.bundleId, groupId: groupId)
                } else {
                    groupManager.addAppToGroup(app.bundleId, groupId: groupId)
                }
            }) {
                Image(systemName: isInGroup ? "minus.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isInGroup ? .red : .green)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isInGroup ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
        )
    }
}

/// Drop delegate for reordering groups
struct DropDelegateDelegate: DropDelegate {
    let groupManager: AppGroupManager
    let targetGroup: AppGroup
    
    func validateDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
}

/// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics)
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255,
            green: Double((rgb & 0xFF00) >> 8) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

/// Preview provider
struct AppGroups_Previews: PreviewProvider {
    static var previews: some View {
        AppGroupsView(groupManager: AppGroupManager())
    }
}
