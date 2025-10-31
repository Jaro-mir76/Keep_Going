//
//  Keep_GoingApp.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 15/05/2025.
//

import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct Keep_GoingApp: App {
    @State private var mainEngine = MainEngine()
    @State private var goalViewModel = GoalViewModel()
    
    init() {
        BackgroundTaskManager.shared.registerGoalReminder()
        BackgroundTaskManager.shared.scheduleGoalReminder()
    }
    
    var body: some Scene {
        WindowGroup() {
            ZStack {
                MainView()
                    .environment(goalViewModel)
                    .environment(mainEngine)
                
                if !mainEngine.welcomePageSeen {
                    WelcomeView()
                        .environment(mainEngine)
                }
            } 
        }
    }
}
