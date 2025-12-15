//
//  SettingsView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 31.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(MainEngine.self) private var mainEngine
    @State private var viewModel = SettingsViewModel()
    @State private var showLogs = false
    
    var body: some View {
        @Bindable var mainEngine = mainEngine
        List {
            Section {
                Toggle("Show introduction again", isOn: $mainEngine.showAppIntroduction)
            }
            Section {
                NotificationSettingsView()
                    .environment(viewModel)
            } header: {
                Text("Notifications")
            }

            Section {
                Button("Pokaż logi") {
                    showLogs = true
                }
            }
            .sheet(isPresented: $showLogs) {
                LogViewerView()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(MainEngine())
}
