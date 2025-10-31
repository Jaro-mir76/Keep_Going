//
//  SettingsView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 31.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(MainEngine.self) private var mainEngine

    var body: some View {
        @Bindable var mainEngine = mainEngine
        Form {
            Section {
                Toggle("Show Welcome Page during next application start", isOn: $mainEngine.showWelcomePageDuringAppStart)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(MainEngine())
}
