//
//  BackgroundGoalReminderActions.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 21.10.2025.
//

import Foundation
import SwiftData
import os
import UserNotifications

class BackgroundGoalReminderActions: Operation, @unchecked Sendable{
    let notificationService: NotificationService
    let goalService: GoalService
    let logger = Logger(subsystem: "Keep_Going", category: "BackgroundTasksMonitoring")
    
    init(notificationService: NotificationService = NotificationService(), goalService: GoalService = GoalService()) {
        self.notificationService = notificationService
        self.goalService = goalService
    }
    
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isExecuting: Bool { _executing }
    override var isFinished: Bool { _finished }
    override var isAsynchronous: Bool { true }
    
    override func main() {
        guard !isCancelled else {
            finish()
            return
        }
        _executing = true
        Task {
            await executeGoalReminder()
        }
    }
    
    private func executeGoalReminder() async {
        notificationService.cancelNotification()
        
        await BackgroundTaskManager.shared.scheduleGoalReminder()
        
        self.finish()
    }
    
    private func finish() {
        _executing = false
        _finished = true
    }
    
    override func cancel() {
        super.cancel()
        finish()
    }
}
