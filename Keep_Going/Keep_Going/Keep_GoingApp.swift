//
//  Keep_GoingApp.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 15/05/2025.
//

import SwiftUI
import SwiftData

@main
struct Keep_GoingApp: App {
    @State private var navigationManager = NavigationManager()
    
    var body: some Scene {
        WindowGroup() {
            ZStack {
                MainView()
                    .modelContainer(for: [
                        Goal.self,
                        Status.self
                    ])
                    .environment(navigationManager)
                if !navigationManager.welcomePageSeen {
                    WelcomeView()
                        .environment(navigationManager)
                }
            } 
        }
    }
}
