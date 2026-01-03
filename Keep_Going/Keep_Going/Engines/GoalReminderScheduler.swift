//
//  GoalReminderScheduler.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 02.01.2026.
//

import Foundation
import SwiftData

class GoalReminderScheduler {
    static let shared = GoalReminderScheduler()
    private let goalService: GoalService
    private let notificationService: NotificationService

    init(goalService: GoalService = GoalService(),
         notificationService: NotificationService = NotificationService()) {
        self.goalService = goalService
        self.notificationService = notificationService
    }

    func scheduleGoalReminder() async {
        LoggingEngine.shared.appendLog(">>> EXECUTING scheduleGoalReminder <<<")

        let goals = goalService.fetchUncompletedGoals()

        guard !goals.isEmpty else {
            LoggingEngine.shared.appendLog("No uncompleted training goals to schedule reminders for")
            return
        }

        var filteredGoals: [Goal] = []
        for hour in Reminder.Hours.allCases {
            guard hour.time.isItSameHourOrLater else { continue }

            for minutes in Reminder.Minutes.allCases {
                var components = Calendar.current.dateComponents([.day, .month, .year, .second], from: Date())
                components.hour = hour.rawValue
                components.minute = minutes.rawValue

                let time = Calendar.current.date(from: components) ?? Date()
                guard time.isItInFuture else { continue }

                filteredGoals = goals.filter { $0.reminderPreference.hours == hour && $0.reminderPreference.minutes == minutes }
                if filteredGoals.count > 0 {
                    LoggingEngine.shared.appendLog("Goals to remind about: \(filteredGoals.count) for \(hour.rawValue):\(minutes.rawValue)")

                    let backlog = goals.filter { $0.reminderPreference.time.isItInPast }
                    let reminderDelay = time.timeIntervalSinceNow
                    await notificationService.scheduleGoalReminder(for: filteredGoals, backlog: backlog, delayInSeconds: reminderDelay)
                    return
                }
            }
        }

        LoggingEngine.shared.appendLog("No future reminders to schedule for today")
    }
}
