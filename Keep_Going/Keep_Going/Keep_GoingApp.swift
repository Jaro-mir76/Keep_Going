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
    @State private var mainEngine: MainEngine
    @State private var goalViewModel = GoalViewModel()
    
    init() {
        BackgroundTaskManager.shared.registerGoalReminder()
        BackgroundTaskManager.shared.scheduleGoalReminder()
        self.mainEngine = MainEngine()
        if self.mainEngine.showWelcomePageDuringAppStart {
            self.mainEngine.welcomePageVisible = true
            self.mainEngine.appIconVisible = false
        }
    }
    
    var body: some Scene {
        WindowGroup() {
            ZStack {
                MainView()
                    .environment(goalViewModel)
                    .environment(mainEngine)
                if mainEngine.welcomePageVisible {
                    WelcomeView()
                        .environment(mainEngine)
                } else if mainEngine.appIconVisible {
                    AppIconView()
                        .task {
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            withAnimation(.easeInOut(duration: 0.6)) {
                                mainEngine.appIconVisible = false
                            }
                        }
                }
            }
        }
    }
}
