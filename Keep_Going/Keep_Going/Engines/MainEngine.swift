//
//  MainEngine.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 16.06.2025.
//

import Foundation

@Observable
class MainEngine {
    var selectedGoal: Goal?
    var welcomeTab: Int = 1
    var welcomePageSeen: Bool = false
    var requestedNotificationPermission: Bool = false
    let notificationService: NotificationService
    
    init(selectedGoal: Goal? = nil, notificationService: NotificationService = NotificationService()) {
        self.selectedGoal = selectedGoal
        self.notificationService = notificationService
    }
    
    func requestNotificationPermission() async {
        await notificationService.requestNotificationPermission()
        self.requestedNotificationPermission = true
    }
}
