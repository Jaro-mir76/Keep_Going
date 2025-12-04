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

        BGTaskScheduler.shared.register(forTaskWithIdentifier: AppStorageKeys.reminderIdentifier, using: nil) { [self] task in
                handleGoalBackgroundReminderTask(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleGoalReminder() {
        logger.notice(">>> EXECUTING scheduleGoalReminder <<<")
        LoggingEngine.shared.appendLog(">>> EXECUTING scheduleGoalReminder <<<")

// MARK: cancel already scheduled tasks to ensure only still valid are there
        cancelScheduledRequests()
        
        let context = ModelContext(PersistentStorage.shared.modelContainer)
        let goalsFetch = FetchDescriptor<Goal>(predicate: #Predicate { $0.schedule == 0 && $0.done == false } )
        do {
            let goals = try context.fetch(goalsFetch)
            var filteredGoals: [Goal] = []
            for hour in Reminder.Hours.allCases {
                guard hour.time.isItSameHourOrLater else { continue }
                
                for minutes in Reminder.Minutes.allCases {
                    var components = Calendar.current.dateComponents([.day, .month, .year, .second], from: Date())
                    components.hour = hour.rawValue
                    components.minute = minutes.rawValue
                    
                    let time = Calendar.current.date(from: components) ?? Date()
                    guard time.isItInFuture else {continue}
                    filteredGoals = goals.filter { $0.reminderPreference.hours == hour && $0.reminderPreference.minutes == minutes}
                    if filteredGoals.count > 0 {
//                        logger.notice("seems there are some goals to be reminded about, count: \(filteredGoals.count)")
                        LoggingEngine.shared.appendLog("seems there are some goals to be reminded about, count: \(filteredGoals.count) for \(hour.rawValue):\(minutes.rawValue)")
                    
                        let request = BGAppRefreshTaskRequest(identifier: AppStorageKeys.reminderIdentifier)
                        request.earliestBeginDate = time
                        do {
                            try BGTaskScheduler.shared.submit(request)
                        } catch {
                            print("Could not schedule background task: \(error)")
                        }
                        break
                    }
                }
                guard filteredGoals.count == 0 else { break }
            }
            
        } catch {
            print ("Could not fetch goals")
        }
// MARK: only debug purposes
        listScheduledRequests()
    }
    
    func handleGoalBackgroundReminderTask (task: BGAppRefreshTask){
//        logger.notice(">>> EXECUTING handleGoalBackgroundReminderTask <<<")
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
        LoggingEngine.shared.appendLog("executing - listScheduledRequests")
        BGTaskScheduler.shared.getPendingTaskRequests { tasks in
            print ("tasks scheduled at: \(Date.now)")
            print ("number of tasks: \(tasks.count)")
            LoggingEngine.shared.appendLog("tasks scheduled at: \(Date.now)")
            LoggingEngine.shared.appendLog("number of tasks: \(tasks.count)")
            for task in tasks {
                print ("task \(task)")
                print ("task identifier \(task.identifier)")
                LoggingEngine.shared.appendLog("task \(task)")
                LoggingEngine.shared.appendLog("task identifier \(task.identifier)")
            }
        }
    }
}
