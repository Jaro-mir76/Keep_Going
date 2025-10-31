//
//  MainEngine.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 16.06.2025.
//

import Foundation
import SwiftUI

@Observable
class MainEngine {
    var selectedGoal: Goal?
    var welcomeTab: Int = 1
    private var _showWelcomePageDuringAppStart = UserDefaults.standard.bool(forKey: AppStorageKeys.showWelcomePageDuringAppStart)
    var showWelcomePageDuringAppStart: Bool {
        get{
            return _showWelcomePageDuringAppStart
        }
        set{
            UserDefaults.standard.set(newValue, forKey: AppStorageKeys.showWelcomePageDuringAppStart)
            _showWelcomePageDuringAppStart = newValue
        }
    }
    var welcomePageVisible = false
    var appIconVisible = true
    
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
