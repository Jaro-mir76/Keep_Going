//
//  BackgroundTaskManager.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 21.10.2025.
//

import Foundation
import BackgroundTasks

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    let backgroundTaskIdentifier = "com.keepgoing.background.goals.reminder"
    private let operationQueue = OperationQueue()
    
    func registerGoalReminder() {
        print ("execution of registerGoalReminder")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { [self] task in
            print ("executing closure that trigger secheduled task")

            handleGoalBackgroundReminderTask(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleGoalReminder() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 180 * 60)
        print ("execution of scheduleGoalReminder")
        do {
            try BGTaskScheduler.shared.submit(request)
            print ("execution of scheduleGoalReminder - request submited")
            listScheduledRequests()
        } catch {
            print("Could not schedule background task: \(error)")
        }
    }
    
    func handleGoalBackgroundReminderTask (task: BGAppRefreshTask){
        print ("executing - handleGoalBackgroundReminderTask with task: \(task.description)")
        scheduleGoalReminder()
        
        let backgroundOperation = BackgroundGoalReminderActions()
        
        task.expirationHandler = {
            print ("iOS is interrupting execution - timeout")
            backgroundOperation.cancel()
        }
        
        backgroundOperation.completionBlock = {
            let success = !backgroundOperation.isCancelled
            task.setTaskCompleted(success: success)
            print(success ? "Background task successfully finished" : "Background task failed")
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
            }
        }
    }
}
