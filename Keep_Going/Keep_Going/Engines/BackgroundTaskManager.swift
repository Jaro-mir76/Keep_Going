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
    let logger = Logger(subsystem: "Keep_Going", category: "BackgroundTasksMonitoring")
    
    private let operationQueue = OperationQueue()
    
    func registerGoalReminder() {
        logger.notice(">>> EXECUTING registerGoalReminder <<<")
        LoggingEngine.shared.appendLog(">>> EXECUTING registerGoalReminder <<<")

        for reminderPreference in Reminder.allCases {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: reminderPreference.backgroundTaskIdentifier, using: nil) { [self] task in
                handleGoalBackgroundReminderTask(task: task as! BGAppRefreshTask)
            }
        }
    }
    
    func scheduleGoalReminder() {
        logger.notice(">>> EXECUTING scheduleGoalReminder <<<")
        LoggingEngine.shared.appendLog(">>> EXECUTING scheduleGoalReminder <<<")

// MARK: cancel already scheduled tasks to ensure only still valid are there
        cancelScheduledRequests()
        
        let context = ModelContext(PersistentStorage.shared.modelContainer)
        let goalsFetch = FetchDescriptor<Goal>(predicate: #Predicate { $0.schedule == 0 } )
        do {
            let goals = try context.fetch(goalsFetch)
            for reminderPreference in Reminder.allCases {
                guard reminderPreference.time > Date() else { continue }
                let goals = goals.filter { $0.reminderPreference == reminderPreference && $0.done == false }
                if goals.count > 0 {
                    logger.notice("seems there are some goals to be reminded about, count: \(goals.count)")
                    LoggingEngine.shared.appendLog("seems there are some goals to be reminded about, count: \(goals.count)")

                    let request = BGAppRefreshTaskRequest(identifier: reminderPreference.backgroundTaskIdentifier)
                    request.earliestBeginDate = reminderPreference.time
                    do {
                        try BGTaskScheduler.shared.submit(request)
                    } catch {
                        print("Could not schedule background task: \(error)")
                    }
                }
            }
        } catch {
            print ("Could not fetch goals")
        }
// MARK: only debug purposes
        listScheduledRequests()
    }
    
    func handleGoalBackgroundReminderTask (task: BGAppRefreshTask){
        logger.notice(">>> EXECUTING handleGoalBackgroundReminderTask <<<")
        LoggingEngine.shared.appendLog(">>> EXECUTING handleGoalBackgroundReminderTask <<<")

        scheduleGoalReminder()
        let backgroundOperation = BackgroundGoalReminderActions(reminderTimeId: task.identifier)
        
        task.expirationHandler = {
            print ("iOS is interrupting execution - timeout")
            backgroundOperation.cancel()
        }
        
        backgroundOperation.completionBlock = {
            let success = !backgroundOperation.isCancelled
            task.setTaskCompleted(success: success)
        }
        operationQueue.addOperation(backgroundOperation)
    }
    
    func cancelScheduledRequests() {
        BGTaskScheduler.shared.getPendingTaskRequests { tasks in
            for task in tasks {
                BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: task.identifier)
            }
        }
    }
    
//    MARK - only for debug pruposes
    func listScheduledRequests() {
        print ("executing - listScheduledRequests")
        BGTaskScheduler.shared.getPendingTaskRequests { tasks in
            print ("tasks scheduled at that time: \(Date.now)")
            print ("tasks no. \(tasks.count)")
            for task in tasks {
                print ("task \(task)")
                print ("task identifier \(task.identifier)")
            }
        }
    }
}
