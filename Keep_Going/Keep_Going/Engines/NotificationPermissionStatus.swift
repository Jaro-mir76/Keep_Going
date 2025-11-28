//
//  NotificationPermissionStatus.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 27.11.2025.
//

import Foundation

enum NotificationPermissionStatus {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral
    
    var title: String {
        switch self {
        case .notDetermined:
            return "User not asked yet"
        case .denied:
            return "No permission"
        case .authorized:
            return "Permission granted"
        case .provisional:
            return "Temporary permission"
        case .ephemeral:
            return "Ephemeral permission"
        }
    }
    
    var description: String {
        switch self {
        case .notDetermined:
            return "You can turn on notifications to receive reminders about your goals"
        case .denied:
            return "Notifications are disabled. Turn them on in Settings to receive reminders about your goals"
        case .authorized:
            return "You will receive reminders about your goals"
        case .provisional:
            return "You will receive silent reminders"
        case .ephemeral:
            return "Temporary permissions"
        }
    }
}
