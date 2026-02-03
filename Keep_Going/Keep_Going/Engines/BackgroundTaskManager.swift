//
//  BackgroundTaskManager.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 21.10.2025.
//

import Foundation
import BackgroundTasks
import SwiftData
import os

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    let notificationService: NotificationService
    private let goalService: GoalService
    
    init(notificationService: NotificationService = NotificationService(), goalService: GoalService = GoalService()) {
        self.notificationService = notificationService
        self.goalService = goalService
    }
    
    let logger = Logger(subsystem: "Keep_Going", category: "BackgroundTasksMonitoring")
    
    private let operationQueue = OperationQueue()
    
    private enum TaskIdentifier {
        static let reminderIdentifier = "com.keepgoing.background.goals.reminder"
        static let reminderSummaryIdentifier = "com.keepgoing.background.goals.reminder.summary"
        static let backgroundAppRefreshIdentifier = "com.keepgoing.background.app.refresh"
        
        static var all: [String] {
            [reminderIdentifier, reminderSummaryIdentifier, backgroundAppRefreshIdentifier]
        }
    }
    
    func registerAllTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: TaskIdentifier.backgroundAppRefreshIdentifier, using: nil) { [self] task in
            handleBacgroundAppRefreshTask(task: task as! BGAppRefreshTask)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: TaskIdentifier.reminderIdentifier, using: nil) { [self] task in
            handleReminderTask(task: task as! BGProcessingTask)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: TaskIdentifier.reminderSummaryIdentifier, using: nil) { [self] task in
            handleReminderSummaryTask(task: task as! BGProcessingTask)
        }
    }
    
    func scheduleAppRefresh() {
        let tomorrow = Calendar.current.startOfDay(for: Date()).addingTimeInterval(1.day + 5.minute)
        scheduleTaskBGAppRefreshTask(identifier: TaskIdentifier.backgroundAppRefreshIdentifier, earliestBeginDate: tomorrow)
    }
    
    func scheduleGoalReminder(at date: Date) {
        scheduleTaskBGProcessingTask(identifier: TaskIdentifier.reminderIdentifier, earliestBeginDate: date)
    }
    
    func scheduleGoalReminder() async {
        let goals = goalService.fetchUncompletedGoals()
        
        guard !goals.isEmpty else {
            return
        }

        var components = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: Date())
        let currentHour = components.hour ?? 0
        let currentMinute = components.minute ?? 0
        
        var filteredGoals: [Goal] = []
        for hour in Reminder.Hours.allCases {
            guard hour.rawValue >= currentHour else { continue }

            for minutes in Reminder.Minutes.allCases {
                guard hour.rawValue > currentHour || minutes.rawValue > currentMinute else { continue }

                filteredGoals = goals.filter { $0.reminderPreference.hours == hour && $0.reminderPreference.minutes == minutes }
                if filteredGoals.count > 0 {
                    let backlog = goals.filter { $0.reminderPreference.time.isItInPast }
                    
                    components.hour = hour.rawValue
                    components.minute = minutes.rawValue
                    let time = Calendar.current.date(from: components) ?? Date()
                    let intervalFromReminderTime = time.timeIntervalSinceNow
                    
//  If there is less than 15 minutes it schedules directly notification (and backgroud task after notification time) to avoid that background task won't be exectuted by iOS on time
                    if intervalFromReminderTime < 15.minute {
                        await notificationService.scheduleGoalReminder(for: filteredGoals, backlog: backlog, delayInSeconds: intervalFromReminderTime)
                        scheduleGoalReminder(at: time + 1.minute)
                    } else {
                        scheduleGoalReminder(at: time - 15.minute)
                    }
                    return
                }
            }
        }
    }
    
    func scheduleGoalReminderSummary() {
        var reminderDate: Date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(20.hour)
        if reminderDate.isItInPast {
            reminderDate = reminderDate.addingTimeInterval(1.day)
        }
        scheduleTaskBGProcessingTask(identifier: TaskIdentifier.reminderSummaryIdentifier, earliestBeginDate: reminderDate)
    }
    
    private func scheduleTaskBGAppRefreshTask(identifier: String, earliestBeginDate: Date) {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = earliestBeginDate
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background app refresh: \(error)")
        }
    }
    
    private func scheduleTaskBGProcessingTask(identifier: String, earliestBeginDate: Date) {
        let request = BGProcessingTaskRequest(identifier: identifier)
        request.earliestBeginDate = earliestBeginDate
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background app refresh: \(error)")
        }
    }
    
    func cancelScheduledRequests() async {
        let tasks = await BGTaskScheduler.shared.pendingTaskRequests()
        for task in tasks {
            if task.identifier == TaskIdentifier.reminderIdentifier {
                self.cancelTask(identifier: task.identifier)
            }
        }
    }
    
    func cancelTask(identifier: String){
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
    }
    
    func handleBacgroundAppRefreshTask (task: BGAppRefreshTask){
        
        scheduleAppRefresh()
        let operation = BackgroundAppRefresh()
        executeOperationBGAppRefreshTask(operation, for: task)
    }
    
    func handleReminderTask (task: BGProcessingTask){
        
        let operation = BackgroundGoalReminderActions()
        executeOperationBGProcessingTask(operation, for: task)
    }
    
    func handleReminderSummaryTask (task: BGProcessingTask){
        
        scheduleGoalReminderSummary()
        
        let operation = BackgroundGoalReminderSummaryActions()
        executeOperationBGProcessingTask(operation, for: task)
    }
    
    private func executeOperationBGAppRefreshTask(_ operation: Operation, for task: BGAppRefreshTask){
        task.expirationHandler = {
            operation.cancel()
        }
        
        operation.completionBlock = {
            let success = !operation.isCancelled
            task.setTaskCompleted(success: success)
        }
        
        operationQueue.addOperation(operation)
    }
    
    private func executeOperationBGProcessingTask(_ operation: Operation, for task: BGProcessingTask){
        task.expirationHandler = {
            operation.cancel()
        }
        
        operation.completionBlock = {
            let success = !operation.isCancelled
            task.setTaskCompleted(success: success)
        }
        
        operationQueue.addOperation(operation)
    }
    
    // MARK: - Debug Helpers

    func getPendingTasks() async -> [BGTaskRequest] {
        await BGTaskScheduler.shared.pendingTaskRequests()
    }

    func logPendingTasks(executionPlace: String = "") {
        Task {
            let pending = await getPendingTasks()
            for task in pending {
                LoggingEngine.shared.appendLog("\(executionPlace) > Pending: \(task.identifier) at \(task.earliestBeginDate?.description ?? "nil")")
            }
        }
    }
}
