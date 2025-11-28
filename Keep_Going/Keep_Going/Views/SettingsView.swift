//
//  SettingsView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 31.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(MainEngine.self) private var mainEngine
    @State private var viewModel: SettingsViewModel?
    @State private var showLogs = false
    
    var body: some View {
        @Bindable var mainEngine = mainEngine
        List {
            Section {
                Toggle("Show Welcome Page during next application start", isOn: $mainEngine.showWelcomePageDuringAppStart)
            }
            Section {
                if let viewModel = viewModel {
                    NotificationSettingsView(viewModel: viewModel)
                }
                
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
        .onAppear {
            viewModel = SettingsViewModel(mainEngine: mainEngine)
        }
    }
}

#Preview {
    SettingsView()
        .environment(MainEngine())
}
