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
    
    func registerAppRefresh() {
        logger.notice(">>> EXECUTING registerAppRefresh <<<")
        LoggingEngine.shared.appendLog(">>> EXECUTING registerAppRefresh <<<")

        BGTaskScheduler.shared.register(forTaskWithIdentifier: AppStorageKeys.backgroundAppRefreshIdentifier, using: nil) { [self] task in
                handleBacgroundAppRefreshTask(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleAppRefresh() {
        let tomorrow = Calendar.current.startOfDay(for: Date()).addingTimeInterval(1.day + 5.minute)
        let request = BGAppRefreshTaskRequest(identifier: AppStorageKeys.backgroundAppRefreshIdentifier)
        request.earliestBeginDate = tomorrow
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background app refresh: \(error)")
        }
    }
    
    func handleBacgroundAppRefreshTask (task: BGAppRefreshTask){
        LoggingEngine.shared.appendLog(">>> EXECUTING handleBacgroundAppRefreshTask <<<")

        let backgroundOperation = BackgroundAppRefresh()
        
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
}
