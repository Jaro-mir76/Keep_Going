//
//  NotificationSettingsInfo.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 27.11.2025.
//

import Foundation
import UserNotifications

struct NotificationSettingsInfo {
    let authorizationStatus: UNAuthorizationStatus
    let soundEnabled: Bool
    let badgeEnabled: Bool
    let alertEnabled: Bool
    let notificationCenterEnabled: Bool
    let lockScreenEnabled: Bool
    let carPlayEnabled: Bool
    let criticalAlertEnabled: Bool
    
    var isFullyEnabled: Bool {
        authorizationStatus == .authorized && alertEnabled
    }
    
    var statusDescription: String {
        switch authorizationStatus {
        case .notDetermined:
            return "User not asked yet"
        case .denied:
            return "No permission"
        case .authorized:
            return "Permission granted"
        case .provisional:
            return "Temporary permission (silent)"
        case .ephemeral:
            return "Temporary permission (App Clip)"
        @unknown default:
            return "Unknown status"
        }
    }
}
