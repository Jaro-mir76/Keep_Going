//
//  Keep_GoingApp.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 15/05/2025.
//

import SwiftUI
import SwiftData
import BackgroundTasks
import UserNotifications

@main
struct Keep_GoingApp: App {
    @State private var mainEngine: MainEngine
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        NotificationService.registerNotificationCategories()
        BackgroundTaskManager.shared.registerGoalReminder()
        
        self.mainEngine = MainEngine()
        if self.mainEngine.showWelcomePageDuringAppStart {
            self.mainEngine.welcomePageVisible = true
            self.mainEngine.appIconVisible = false
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
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
                } else {
                    MainView()
                        .environment(mainEngine)
                }
            }
        }
    }
}
