//
//  NotificationService.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 27.10.2025.
//

import Foundation
import UserNotifications

struct NotificationService {
    
    enum NotificationIndentifier: String {
        case goalNotificationIdentifier = "com.keepgoing.notification.identifier"
        case goalReminderCategory = "com.keepgoing.reminder.identifier"
    }
    
    enum SnoozeOption: String, CaseIterable {
        case tenMinutes = "Snooze_10_min"
        case thirtyMinutes = "Snooze_30_min"
        case oneHour = "Snooze_60_min"
        
        var title: String {
            switch self {
            case .tenMinutes: return "Snooze for 10 minutes"
            case .thirtyMinutes: return "Snooze for 30 minutes"
            case .oneHour: return "Snooze for 60 minutes"
            }
        }
        
        var timeInterval: TimeInterval {
            switch self {
            case .tenMinutes: return 600
            case .thirtyMinutes: return 1800
            case .oneHour: return 3600
            }
        }
    }
    
    static func registerNotificationCategories() {
        let center = UNUserNotificationCenter.current()
        
        let snoozeActions = SnoozeOption.allCases.map { option in
            UNNotificationAction(
                identifier: option.rawValue,
                title: option.title,
                options: []
            )
        }
        
        let goalReminderCategory = UNNotificationCategory(
            identifier: NotificationIndentifier.goalReminderCategory.rawValue,
            actions: snoozeActions,
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        center.setNotificationCategories([goalReminderCategory])
    }
    
    func requestNotificationPermission() async -> Bool {
        let notificationCenter = UNUserNotificationCenter.current()
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print ("Problem with request for Notification authorization, error: \(error)")
            return false
        }
    }
    
    func createNotificationMessage(for goals: [Goal], backlog: [Goal]) -> (title: String, body: String) {
        
        let title = "Keep Going"
        var body = ""
        
        if goals.count == 1 {
            let goal = goals[0]
            if !goal.goalMotivation.isEmpty {
                body = "\(goal.goalMotivation), so it's time to roll up sleeves and get \(goal.name) done!"
            } else {
                body = "You asked me to remind you about \(goal.name)"
            }
        } else {
            let firstGoal = goals[0]
            let remainingCount = goals.count - 1
            body = "\(firstGoal.name)"
            
            if remainingCount == 1 {
                body += " and \(remainingCount) more goal is waiting for you, so hurry up!"
            } else {
                body += " and \(remainingCount) more goals are waiting for you, but queue is growing fast, so hurry up!"
            }
        }
        if !backlog.isEmpty {
            body += "\nThere \(backlog.count == 1 ? "is" : "are") also \(backlog.count) more \(backlog.count == 1 ? "goal" : "goals") in the backlog!"
        }
        return (title, body)
    }
    
    func scheduleGoalReminder(for goals: [Goal], backlog: [Goal] = [], delayInSeconds: TimeInterval = 0, playSound: Bool = true) async {
        let message = createNotificationMessage(for: goals, backlog: backlog)
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = message.title
        content.body = message.body
        content.categoryIdentifier = NotificationIndentifier.goalReminderCategory.rawValue
        
        if playSound {
            content.sound = .default
        }
        
        content.badge = goals.count > 0 ? goals.count as NSNumber : 1
        
        let trigger: UNNotificationTrigger? = delayInSeconds > 0 ? UNTimeIntervalNotificationTrigger(timeInterval: delayInSeconds, repeats: false) : nil
        let notification = UNNotificationRequest(identifier: NotificationIndentifier.goalNotificationIdentifier.rawValue, content: content, trigger: trigger)
        
        do {
            try await center.add(notification)
        } catch {
            print("scheduleNotification - Could not schedule notification, error: \(error)")
        }
    }
    
    func snoozeNotification(for goals: [Goal], minutes: Int, playSound: Bool = true) async {
        await scheduleGoalReminder(for: goals, delayInSeconds: TimeInterval(minutes * 60), playSound: playSound)
    }

    func cancelNotification() {
        let identifier: String = NotificationIndentifier.goalNotificationIdentifier.rawValue
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    func updateAppBadge(goals: [Goal]) {
        UNUserNotificationCenter.current().setBadgeCount(goals.count)
    }
}
