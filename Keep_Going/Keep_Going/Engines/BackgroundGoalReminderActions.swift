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
    let reminderTimeIdentifier: String
    let logger = Logger(subsystem: "Keep_Going", category: "BackgroundTasksMonitoring")
    
    init(notificationService: NotificationService = NotificationService(), reminderTimeId: String) {
        self.notificationService = notificationService
        self.reminderTimeIdentifier = reminderTimeId
        
        LoggingEngine.shared.appendLog("BackgroundTasksMonitoring")
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
        print (">>> EXECUTION of executeGoalReminder func <<<")
        logger.notice(">>> EXECUTION of executeGoalReminder func <<<")
        logger.notice("time: \(Date())")
        
        LoggingEngine.shared.appendLog(">>> EXECUTION of executeGoalReminder func <<<")
        LoggingEngine.shared.appendLog("time: \(Date())")

        let context = ModelContext(PersistentStorage.shared.modelContainer)
        let goalsFetch = FetchDescriptor<Goal>(predicate: #Predicate { $0.schedule == 0 } )
        do {
            let goals = try context.fetch(goalsFetch)
            let filteredGoals = goals.filter { $0.reminderPreference?.backgroundTaskIdentifier == self.reminderTimeIdentifier && $0.done == false
            }
            logger.notice("scheduling notification message, goals count: \(filteredGoals.count)")
            LoggingEngine.shared.appendLog("scheduling notification message, goals count: \(filteredGoals.count)")

//            await notificationService.scheduleNotification(title: "Keep Going", message: "Hey, you have planed \(filteredGoals.count) \(filteredGoals.count > 1 ? "goals" : "goal") for now. Maybe you have a minute?")
            if !filteredGoals.isEmpty {
                await notificationService.scheduleGoalReminder(for: filteredGoals)
            }
        } catch {
            print ("Could not fetch goals")
        }
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
