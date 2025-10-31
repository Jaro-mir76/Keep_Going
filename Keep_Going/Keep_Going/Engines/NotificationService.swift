//
//  NotificationService.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 27.10.2025.
//

import Foundation
import UserNotifications

struct NotificationService {
    
    func requestNotificationPermission() async {
        let notificationCenter = UNUserNotificationCenter.current()
        do {
            try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print ("Problem with request for Notification authorization, error: \(error)")
        }
    }
    
    func scheduleNotification(title: String, message: String) async {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        let notification = UNNotificationRequest(identifier: "com.keepgoing.notification", content: content, trigger: nil)
        do {
            try await center.add(notification)
        } catch{
            print ("Could not schedule notification, error: \(error)")
        }
    }
}
