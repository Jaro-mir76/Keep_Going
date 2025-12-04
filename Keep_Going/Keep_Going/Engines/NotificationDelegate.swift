//
//  NotificationDelegate.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 26.11.2025.
//

import Foundation
import UserNotifications
import SwiftData
import os
import UIKit

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    let notificationService = NotificationService()
    var notificationPermission: Bool = false
    
    let logger = Logger(subsystem: "Keep_Going", category: "Notifications")
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//  to show notifications even app in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        logger.notice("Notification action received: \(response.actionIdentifier)")
        
        let actionIdentifier = response.actionIdentifier
        
        Task {
            switch actionIdentifier {
            case NotificationService.SnoozeOption.tenMinutes.rawValue:
                await handleSnooze(minutes: 10)
            case NotificationService.SnoozeOption.thirtyMinutes.rawValue:
                await handleSnooze(minutes: 30)
            case NotificationService.SnoozeOption.oneHour.rawValue:
                await handleSnooze(minutes: 60)
            case UNNotificationDefaultActionIdentifier:
//  User tapped notification - open app
                LoggingEngine.shared.appendLog("User tapped on notification - opening app")
            case UNNotificationDismissActionIdentifier:
//  User dismissed notification
                LoggingEngine.shared.appendLog("User dismissed notification")
            default:
                break
            }
            completionHandler()
        }
    }
    
    func areNotificationsEnabled() async -> Bool {
        let status = await checkNotificationPermission()
        return status == .authorized || status == .provisional
    }
    
    func checkNotificationPermission() async -> UNAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    func getDetailedNotificationSettings() async -> NotificationSettingsInfo {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        return NotificationSettingsInfo(
            authorizationStatus: settings.authorizationStatus,
            soundEnabled: settings.soundSetting == .enabled,
            badgeEnabled: settings.badgeSetting == .enabled,
            alertEnabled: settings.alertSetting == .enabled,
            notificationCenterEnabled: settings.notificationCenterSetting == .enabled,
            lockScreenEnabled: settings.lockScreenSetting == .enabled,
            carPlayEnabled: settings.carPlaySetting == .enabled,
            criticalAlertEnabled: settings.criticalAlertSetting == .enabled
        )
    }
    
    func requestOrOpenSettings() async -> Bool {
        let status = await checkNotificationPermission()
        
        switch status {
// seem user was not asked, then ask him now
        case .notDetermined:
            return await notificationService.requestNotificationPermission()
// user denied - open settings
        case .denied:
            openAppSettings()
            return false
        case .authorized, .provisional, .ephemeral:
            return true
        @unknown default:
            return false
        }
    }
    
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            Task { @MainActor in
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
    
    private func handleSnooze(minutes: Int) async {
        LoggingEngine.shared.appendLog("Snoozing notification for \(minutes) minutes")
        
        let goals = fetchPendingGoals()
        
        guard !goals.isEmpty else {
            LoggingEngine.shared.appendLog("No pending goals found for snooze")
            return
        }
        
        await notificationService.snoozeNotification(for: goals, minutes: minutes)
        LoggingEngine.shared.appendLog("Snoozed notification scheduled successfully")
    }
    
    private func fetchPendingGoals() -> [Goal] {
        let context = ModelContext(PersistentStorage.shared.modelContainer)
//        guard let reminderPreference = getCurrentReminderPreference() else {return []}
        
        let goalsFetch = FetchDescriptor<Goal>(
            predicate: #Predicate { $0.schedule == 0 && $0.done == false }
        )
        do {
            let goals = try context.fetch(goalsFetch)
            return goals.filter { $0.reminderPreference.time.isItInPast }
        } catch {
            logger.error("Could not fetch goals: \(error.localizedDescription)")
            return []
        }
    }
    
//    private func getCurrentReminderPreference() -> Reminder? {
//        let now = Date()
//        
//        return Reminder.allCases.first { reminder in
//            return reminder.time > Date(timeInterval: -900, since: now)
//        }
//    }
}
