//
//  BackgroundTaskManager.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 21.10.2025.
//

import Foundation
import BackgroundTasks
import SwiftData

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    private let operationQueue = OperationQueue()
    
    func registerGoalReminder() {
        for reminderPreference in Reminder.allCases {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: reminderPreference.backgroundTaskIdentifier, using: nil) { [self] task in
                handleGoalBackgroundReminderTask(task: task as! BGAppRefreshTask)
            }
        }
    }
    
    func scheduleGoalReminder() {
        let context = ModelContext(PersistentStorage.shared.modelContainer)
        let goalsFetch = FetchDescriptor<Goal>(predicate: #Predicate { $0.schedule == 0 } )
        do {
            let goals = try context.fetch(goalsFetch)
            for reminderPreference in Reminder.allCases {
                guard reminderPreference.time > Date() else { continue }
                let goals = goals.filter { $0.reminderPreference == reminderPreference && $0.done == false }
//                print ("REminder preference: \(reminderPreference.rawValue) - goals count: \(goals.count)")
                if goals.count > 0 {
                    let request = BGAppRefreshTaskRequest(identifier: reminderPreference.backgroundTaskIdentifier)
//                    print ("reminder.time: \(reminderPreference.time)")
                    request.earliestBeginDate = reminderPreference.time
                    do {
//                        print ("scheduling task for \(reminderPreference.backgroundTaskIdentifier)")
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
//        print ("executing - handleGoalBackgroundReminderTask with task: \(task.description)")
        scheduleGoalReminder()
        let backgroundOperation = BackgroundGoalReminderActions(reminderTime: task.identifier)
        
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
