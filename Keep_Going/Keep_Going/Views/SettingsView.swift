//
//  SettingsView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 31.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(MainEngine.self) private var mainEngine
    @State private var showLogs = false

    var body: some View {
        @Bindable var mainEngine = mainEngine
        Form {
            Section {
                Toggle("Show Welcome Page during next application start", isOn: $mainEngine.showWelcomePageDuringAppStart)
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
