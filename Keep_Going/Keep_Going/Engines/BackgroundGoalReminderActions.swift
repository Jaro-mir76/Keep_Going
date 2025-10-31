//
//  BackgroundGoalReminderActions.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 21.10.2025.
//

import Foundation
import SwiftData

class BackgroundGoalReminderActions: Operation, @unchecked Sendable{
    let notificationService: NotificationService
    
    init(notificationService: NotificationService = NotificationService()) {
        self.notificationService = notificationService
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

//        Task.detached {
        let contex = ModelContext(PersistentStorage.shared.modelContainer)
//        }
        let goalsFetch = FetchDescriptor<Goal>(predicate: #Predicate { $0.schedule == 0 } )
        do {
            let goals = try contex.fetch(goalsFetch)
            for goal in goals {
                print ("Background - goal: \(goal.name)")
            }
            await notificationService.scheduleNotification(title: "Keep Going - reminder", message: "Hey, you have still \(goals.count) \(goals.count > 1 ? "goals" : "goal") you planed for today. Maybe you have a minute now?")
        } catch {
            print ("Could not fetch goals")
        }
        self.finish()
    }
    
    private func finish() {
        print ("execution of finish()")

        _executing = false
        _finished = true
    }
    
    override func cancel() {
//        Logs.shared.add("execution of cancel()")
        print ("execution of cancel()")
        super.cancel()
        finish()
    }
}
