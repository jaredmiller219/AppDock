//
//  SettingsView.swift
//  AppDock
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.title2)
                .bold()
            Text("Configure AppDock preferences.")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(16)
        .frame(minWidth: 360, minHeight: 320, alignment: .topLeading)
    }
}

//#Preview {
//    SettingsView()
//}
