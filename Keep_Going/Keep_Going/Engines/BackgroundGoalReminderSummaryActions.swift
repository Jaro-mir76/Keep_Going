//
//  BackgroundGoalFinalReminderActions.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 28.01.2026.
//

import Foundation
import SwiftData
import os
import UserNotifications

class BackgroundGoalReminderSummaryActions: Operation, @unchecked Sendable{
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
            await executeGoalFinalReminder()
        }
    }
    
    private func executeGoalFinalReminder() async {
        let filteredGoals = goalService.fetchUncompletedGoals()
        await notificationService.scheduleGoalReminderSummary(for: filteredGoals)
        
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
