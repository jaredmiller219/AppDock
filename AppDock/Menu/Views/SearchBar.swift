//
//  SearchBar.swift
//  AppDock
//
//  Quick search functionality for popover menu
//

import SwiftUI

/// Search bar component for filtering apps in the popover
struct SearchBar: View {
    @Binding var searchText: String
    @State private var isFocused = false
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 14, weight: .medium))
            
            TextField("Search apps...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 14))
                .onTapGesture {
                    isFocused = true
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isFocused ? Color.accentColor : Color(.separatorColor), lineWidth: isFocused ? 2 : 1)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

/// Enhanced search bar with keyboard shortcuts support
struct EnhancedSearchBar: View {
    @Binding var searchText: String
    @State private var isFocused = false
    @FocusState private var isSearchFocused: Bool
    
    var onSearchChanged: (String) -> Void
    var onSearchSubmitted: (String) -> Void
    
    // Expose focus state to parent
    var isSearchFocusedBinding: Binding<Bool> {
        Binding(
            get: { isSearchFocused },
            set: { isSearchFocused = $0 }
        )
    }
    
    init(searchText: Binding<String>, onSearchChanged: @escaping (String) -> Void = { _ in }, onSearchSubmitted: @escaping (String) -> Void = { _ in }) {
        self._searchText = searchText
        self.onSearchChanged = onSearchChanged
        self.onSearchSubmitted = onSearchSubmitted
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 14, weight: .medium))
            
            TextField("Search apps...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 14))
                .focused($isSearchFocused)
                .onSubmit {
                    onSearchSubmitted(searchText)
                }
                .onChange(of: searchText) { newValue in
                    onSearchChanged(newValue)
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    onSearchChanged("")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSearchFocused ? Color.accentColor : Color(.separatorColor), lineWidth: isSearchFocused ? 2 : 1)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
        .onAppear {
            // Set up keyboard shortcuts
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 5 && event.modifierFlags.contains(.command) { // ⌘F
                    isSearchFocused = true
                    return nil
                }
                if event.keyCode == 47 && !event.modifierFlags.contains(.command) { // /
                    isSearchFocused = true
                    return nil
                }
                if event.keyCode == 53 { // Escape
                    if isSearchFocused && !searchText.isEmpty {
                        searchText = ""
                        onSearchChanged("")
                        return nil
                    }
                }
                return event
            }
        }
    }
}

/// Search results view with highlighting
struct SearchResultsView: View {
    let searchText: String
    let apps: [AppState.AppEntry]
    let onAppSelected: (AppState.AppEntry) -> Void
    
    private var filteredApps: [AppState.AppEntry] {
        guard !searchText.isEmpty else { return apps }
        
        return apps.filter { app in
            app.name.localizedCaseInsensitiveContains(searchText) ||
            app.bundleid.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        if filteredApps.isEmpty && !searchText.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 32))
                    .foregroundColor(.secondary)
                
                Text("No apps found")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Try searching for a different app name")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        } else {
            LazyVStack(spacing: 4) {
                ForEach(filteredApps, id: \.bundleid) { app in
                    SearchResultRow(
                        app: app,
                        searchText: searchText,
                        onTap: { onAppSelected(app) }
                    )
                }
            }
        }
    }
}

/// Individual search result row with text highlighting
struct SearchResultRow: View {
    let app: AppState.AppEntry
    let searchText: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(nsImage: app.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .cornerRadius(6)
                
                VStack(alignment: .leading, spacing: 2) {
                    HighlightedText(
                        text: app.name,
                        highlight: searchText,
                        defaultColor: .primary,
                        highlightColor: .accentColor
                    )
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                    
                    HighlightedText(
                        text: app.bundleid,
                        highlight: searchText,
                        defaultColor: .secondary,
                        highlightColor: .accentColor.opacity(0.7)
                    )
                    .font(.system(size: 11))
                    .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.clear)
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

/// Text view with highlighted search terms
struct HighlightedText: View {
    let text: String
    let highlight: String
    let defaultColor: Color
    let highlightColor: Color
    
    var body: some View {
        let parts = text.components(separatedBy: highlight)
        
        Text(AttributedStringBuilder.build(
            text: text,
            highlight: highlight,
            defaultColor: defaultColor,
            highlightColor: highlightColor
        ))
    }
}

/// Helper for building attributed strings with highlights
struct AttributedStringBuilder {
    static func build(text: String, highlight: String, defaultColor: Color, highlightColor: Color) -> AttributedString {
        guard !highlight.isEmpty else {
            return AttributedString(text)
        }
        
        var result = AttributedString()
        let parts = text.components(separatedBy: highlight)
        
        for (index, part) in parts.enumerated() {
            if !part.isEmpty {
                var attributedPart = AttributedString(part)
                attributedPart.foregroundColor = defaultColor
                result.append(attributedPart)
            }
            
            if index < parts.count - 1 {
                var attributedHighlight = AttributedString(highlight)
                attributedHighlight.foregroundColor = highlightColor
                attributedHighlight.font = .system(.body, weight: .semibold)
                result.append(attributedHighlight)
            }
        }
        
        return result
    }
}

/// Preview provider for SwiftUI previews
struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SearchBar(searchText: .constant(""))
            
            SearchBar(searchText: .constant("Safari"))
            
            EnhancedSearchBar(
                searchText: .constant(""),
                onSearchChanged: { _ in },
                onSearchSubmitted: { _ in }
            )
        }
        .padding()
    }
}
