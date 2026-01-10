//
//  FocusMode.swift
//  AppDock
//
//  Focus mode for temporarily hiding distracting apps
//

import SwiftUI

/// Focus mode configuration
struct FocusModeConfiguration: Codable {
    var isEnabled: Bool = false
    var distractingApps: Set<String> = []
    var scheduleEnabled: Bool = false
    var startTime: Date = Date()
    var endTime: Date = Date()
    var weekdays: Set<Int> = Set(1...7) // All weekdays
    var autoActivate: Bool = false
    
    var isActive: Bool {
        guard isEnabled && scheduleEnabled else { return isEnabled }
        
        let now = Date()
        let calendar = Calendar.current
        
        // Check weekday
        let weekday = calendar.component(.weekday, from: now)
        guard weekdays.contains(weekday) else { return false }
        
        // Check time range
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTime = currentHour * 60 + currentMinute
        
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let startTimeMinutes = startHour * 60 + startMinute
        
        let endHour = calendar.component(.hour, from: endTime)
        let endMinute = calendar.component(.minute, from: endTime)
        let endTimeMinutes = endHour * 60 + endMinute
        
        return currentTime >= startTimeMinutes && currentTime <= endTimeMinutes
    }
}

/// Focus mode manager
class FocusModeManager: ObservableObject {
    @Published var configuration = FocusModeConfiguration()
    
    private let userDefaults = UserDefaults.standard
    private let configurationKey = "FocusModeConfiguration"
    
    init() {
        loadConfiguration()
    }
    
    func saveConfiguration() {
        if let data = try? JSONEncoder().encode(configuration) {
            userDefaults.set(data, forKey: configurationKey)
        }
    }
    
    func loadConfiguration() {
        if let data = userDefaults.data(forKey: configurationKey),
           let config = try? JSONDecoder().decode(FocusModeConfiguration.self, from: data) {
            configuration = config
        }
    }
    
    func toggleFocusMode() {
        configuration.isEnabled.toggle()
        saveConfiguration()
        
        if configuration.isActive {
            activateFocusMode()
        } else {
            deactivateFocusMode()
        }
    }
    
    func addDistractingApp(_ bundleId: String) {
        configuration.distractingApps.insert(bundleId)
        saveConfiguration()
    }
    
    func removeDistractingApp(_ bundleId: String) {
        configuration.distractingApps.remove(bundleId)
        saveConfiguration()
    }
    
    private func activateFocusMode() {
        // Hide distracting apps from the dock
        // This would integrate with the app filtering system
        NotificationCenter.default.post(name: .focusModeActivated, object: nil)
    }
    
    private func deactivateFocusMode() {
        // Show all apps again
        NotificationCenter.default.post(name: .focusModeDeactivated, object: nil)
    }
    
    func isAppHidden(_ bundleId: String) -> Bool {
        configuration.isActive && configuration.distractingApps.contains(bundleId)
    }
}

/// Focus mode toggle button
struct FocusModeToggle: View {
    @ObservedObject var focusManager: FocusModeManager
    
    var body: some View {
        Button(action: {
            focusManager.toggleFocusMode()
        }) {
            HStack(spacing: 8) {
                Image(systemName: focusManager.configuration.isActive ? "moon.fill" : "moon")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(focusManager.configuration.isActive ? .orange : .secondary)
                
                Text(focusManager.configuration.isActive ? "Focus Mode On" : "Focus Mode")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(focusManager.configuration.isActive ? .orange : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(focusManager.configuration.isActive ? Color.orange.opacity(0.1) : Color(.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(focusManager.configuration.isActive ? Color.orange.opacity(0.3) : Color(.separatorColor), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Focus mode configuration panel
struct FocusModeConfigurationPanel: View {
    @ObservedObject var focusManager: FocusModeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAppPicker = false
    @State private var tempStartTime = Date()
    @State private var tempEndTime = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Status section
                    FocusModeStatusCard(focusManager: focusManager)
                    
                    // Distracting apps section
                    FocusModeAppsCard(focusManager: focusManager, showingAppPicker: $showingAppPicker)
                    
                    // Schedule section
                    FocusModeScheduleCard(
                        focusManager: focusManager,
                        startTime: $tempStartTime,
                        endTime: $tempEndTime
                    )
                }
                .padding()
            }
            .navigationTitle("Focus Mode")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 600)
        .onAppear {
            tempStartTime = focusManager.configuration.startTime
            tempEndTime = focusManager.configuration.endTime
        }
        .onChange(of: tempStartTime) {
            focusManager.configuration.startTime = tempStartTime
            focusManager.saveConfiguration()
        }
        .onChange(of: tempEndTime) {
            focusManager.configuration.endTime = tempEndTime
            focusManager.saveConfiguration()
        }
        .sheet(isPresented: $showingAppPicker) {
            FocusModeAppPicker(focusManager: focusManager)
        }
    }
}

/// Focus mode status card
struct FocusModeStatusCard: View {
    @ObservedObject var focusManager: FocusModeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                Image(systemName: focusManager.configuration.isActive ? "moon.fill" : "moon")
                    .font(.system(size: 24))
                    .foregroundColor(focusManager.configuration.isActive ? .orange : .secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(focusManager.configuration.isActive ? "Focus Mode is Active" : "Focus Mode is Inactive")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(focusManager.configuration.isActive ? .orange : .primary)
                    
                    if focusManager.configuration.isActive {
                        Text("Distracting apps are hidden")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { focusManager.configuration.isEnabled },
                    set: { _ in focusManager.toggleFocusMode() }
                ))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.controlBackgroundColor))
        )
    }
}

/// Focus mode apps card
struct FocusModeAppsCard: View {
    @ObservedObject var focusManager: FocusModeManager
    @Binding var showingAppPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Distracting Apps")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    showingAppPicker = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                    .font(.caption)
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if focusManager.configuration.distractingApps.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "moon")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    
                    Text("No distracting apps")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Add apps that distract you during work")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(focusManager.configuration.distractingApps), id: \.self) { bundleId in
                        FocusModeAppRow(
                            bundleId: bundleId,
                            onRemove: {
                                focusManager.removeDistractingApp(bundleId)
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.controlBackgroundColor))
        )
    }
}

/// Individual distracting app row
struct FocusModeAppRow: View {
    let bundleId: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            // App icon (would need to be loaded from bundle)
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.controlBackgroundColor))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "app")
                        .foregroundColor(.secondary)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(appName(for: bundleId))
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                
                Text(bundleId)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.windowBackgroundColor))
        )
    }
    
    private func appName(for bundleId: String) -> String {
        // This would need to be implemented to get the actual app name
        // For now, just return the bundle ID's last component
        bundleId.components(separatedBy: ".").last ?? bundleId
    }
}

/// Focus mode schedule card
struct FocusModeScheduleCard: View {
    @ObservedObject var focusManager: FocusModeManager
    @Binding var startTime: Date
    @Binding var endTime: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Schedule")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { focusManager.configuration.scheduleEnabled },
                    set: { enabled in
                        focusManager.configuration.scheduleEnabled = enabled
                        focusManager.saveConfiguration()
                    }
                ))
            }
            
            if focusManager.configuration.scheduleEnabled {
                VStack(spacing: 12) {
                    HStack {
                        Text("From:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                        
                        Text("To:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    // Weekday selection would go here
                    Text("Active every day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Focus mode will be manually controlled")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.controlBackgroundColor))
        )
    }
}

/// App picker for focus mode
struct FocusModeAppPicker: View {
    @ObservedObject var focusManager: FocusModeManager
    @Environment(\.dismiss) private var dismiss
    
    // This would be populated with actual running apps
    @State private var availableApps: [String] = [
        "com.apple.Safari",
        "com.apple.Music",
        "com.twitter.twitter-mac",
        "com.facebook.acebook"
    ]
    
    var body: some View {
        NavigationView {
            List(availableApps, id: \.self) { bundleId in
                Button(action: {
                    focusManager.addDistractingApp(bundleId)
                    dismiss()
                }) {
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.controlBackgroundColor))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "app")
                                    .foregroundColor(.secondary)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(appName(for: bundleId))
                                .font(.system(size: 14, weight: .medium))
                                .lineLimit(1)
                            
                            Text(bundleId)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        if focusManager.configuration.distractingApps.contains(bundleId) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(focusManager.configuration.distractingApps.contains(bundleId))
            }
            .navigationTitle("Add Distracting App")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
    }
    
    private func appName(for bundleId: String) -> String {
        bundleId.components(separatedBy: ".").last ?? bundleId
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let focusModeActivated = Notification.Name("FocusModeActivated")
    static let focusModeDeactivated = Notification.Name("FocusModeDeactivated")
}

/// Preview provider for SwiftUI previews
struct FocusMode_Previews: PreviewProvider {
    static var previews: some View {
        let focusManager = FocusModeManager()
        
        VStack(spacing: 20) {
            FocusModeToggle(focusManager: focusManager)
                .padding()
            
            FocusModeStatusCard(focusManager: focusManager)
                .padding()
        }
        .frame(width: 400)
    }
}
