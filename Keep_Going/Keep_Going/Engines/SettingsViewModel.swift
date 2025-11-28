//
//  SettingsViewModel.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 28.11.2025.
//

import Foundation
import UserNotifications

@MainActor
@Observable
class SettingsViewModel {
    let mainEngine: MainEngine
    let notificationDelegate: NotificationDelegate
    var isLoading: Bool = false
    var showPermissionAlert: Bool = false
    var permissionStatus: UNAuthorizationStatus = .notDetermined
    var detailedSettings: NotificationSettingsInfo?
    
    init (mainEngine: MainEngine, notificationDelegate: NotificationDelegate = .shared) {
        self.mainEngine = mainEngine
        self.notificationDelegate = notificationDelegate
    }
        
    var userWantsNotifications: Bool {
        get {
            return mainEngine.userWantsNotifications
        }
        set {
            Task {
                if newValue == true {
                    let rights = await notificationDelegate.requestOrOpenSettings()
                    mainEngine.userWantsNotifications = rights
                } else {
                    mainEngine.userWantsNotifications = false
                }
            }
        }
    }
    
    func checkPermissions() async {
        isLoading = true
        permissionStatus = await notificationDelegate.checkNotificationPermission()
        detailedSettings = await notificationDelegate.getDetailedNotificationSettings()
        isLoading = false
        
        if userWantsNotifications && permissionStatus == .denied {
            showPermissionAlert = true
        }
    }
}
