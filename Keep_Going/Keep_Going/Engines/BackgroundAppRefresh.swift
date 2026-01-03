//
//  BackgroundAppRefresh.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 02.01.2026.
//

import Foundation
import os

class BackgroundAppRefresh: Operation, @unchecked Sendable {
    private let goalService: GoalService
    private let goalReminderScheduler: GoalReminderScheduler
    let logger = Logger(subsystem: "Keep_Going", category: "BackgroundTasksMonitoring")

    init(goalService: GoalService = GoalService(),
         goalReminderScheduler: GoalReminderScheduler = .shared) {
        self.goalService = goalService
        self.goalReminderScheduler = goalReminderScheduler
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
            await executeAppRefresh()
        }
    }
    
    private func executeAppRefresh() async {
        print (">>> EXECUTION of executeAppRefresh func <<<")
        LoggingEngine.shared.appendLog(">>> EXECUTION of executeAppRefresh func <<<")
        LoggingEngine.shared.appendLog("time: \(Date())")

// Refresh goals for the new day
        let goals = goalService.refreshGoals()
        goalService.updateAppBadge(goals: goals)

        LoggingEngine.shared.appendLog("BackgroundAppRefresh - refreshed \(goals.count) goals")

// Schedule first reminder for the new day if there are uncompleted goals
        let uncompletedTrainingGoals = goals.filter { $0.schedule == ScheduleCode.training.rawValue && $0.done == false }
        if !uncompletedTrainingGoals.isEmpty {
            await goalReminderScheduler.scheduleGoalReminder()
            LoggingEngine.shared.appendLog("BackgroundAppRefresh - scheduled reminder for \(uncompletedTrainingGoals.count) training goals")
        }

        LoggingEngine.shared.appendLog("BackgroundAppRefresh completed")

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
