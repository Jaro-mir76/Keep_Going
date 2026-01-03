//
//  GoalService.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 03.01.2026.
//

import Foundation
import SwiftData

class GoalService {
    private let modelContainer: ModelContainer
    private let notificationService: NotificationService

    init(modelContainer: ModelContainer = PersistentStorage.shared.modelContainer,
         notificationService: NotificationService = NotificationService()) {
        self.modelContainer = modelContainer
        self.notificationService = notificationService
    }

    private var goalsFetchDescriptor: FetchDescriptor<Goal> {
        FetchDescriptor<Goal>(
            predicate: nil,
            sortBy: [
                .init(\.done, order: .forward),
                .init(\.schedule, order: .forward),
                .init(\.name, order: .forward)
            ]
        )
    }

    func refreshGoals() -> [Goal] {
        let context = ModelContext(modelContainer)
        return fetchGoals(using: context)
    }

    func fetchGoals(using context: ModelContext) -> [Goal] {
        LoggingEngine.shared.appendLog("\(Date()) > GoalService -> fetchGoals <")

        do {
            var goals = try context.fetch(goalsFetchDescriptor)
            for goal in goals {
                if !Calendar.current.isDateInToday(goal.date) {
                    saveStatus(goal: goal)
                    if goal.schedule == ScheduleCode.training.rawValue, goal.done == false {
                        goal.strike = 0
                        goal.strikeCheckDate = Date()
                    }
                    whatDoWeHaveToday(goal: goal)
                }
            }

// Re-fetch to get sorted results after updates, for the moment I think this is the most efficient way
            goals = try context.fetch(goalsFetchDescriptor)
            return goals
        } catch {
            print("GoalService could not fetch goals, error: \(error)")
            return []
        }
    }

    func addGoal(goal: Goal, using context: ModelContext) {
        context.insert(goal)
        whatDoWeHaveToday(goal: goal)
    }

    func updateGoal(_ goal: Goal, with newData: Goal) {
        goal.name = newData.name
        goal.goalMotivation = newData.goalMotivation
        goal.goalStartDate = newData.goalStartDate
        goal.requiredTime = newData.requiredTime
        goal.scheduleType.type = newData.scheduleType.type
        goal.scheduleType.interval = newData.scheduleType.interval
        goal.scheduleType.weeklySchedule = newData.scheduleType.weeklySchedule.sorted(by: { $0.rawValue < $1.rawValue })
        goal.reminderPreference.hours = newData.reminderPreference.hours
        goal.reminderPreference.minutes = newData.reminderPreference.minutes

        whatDoWeHaveToday(goal: goal)

        if newData.done == true {
            goal.date = newData.date
            goal.done = newData.done
        }
    }

    func deleteGoal(_ goal: Goal, using context: ModelContext) {
        context.delete(goal)
    }

    func fetchUncompletedGoals() -> [Goal] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<Goal>(
            predicate: #Predicate { $0.schedule == 0 && $0.done == false }
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            print("GoalService could not fetch uncompleted training goals, error: \(error)")
            return []
        }
    }

    func updateAppBadge(goals: [Goal]) {
        let overdueGoals = goals.filter {
            $0.done == false &&
            $0.schedule == ScheduleCode.training.rawValue &&
            $0.reminderPreference.time.isItInPast
        }
        notificationService.updateAppBadge(goals: overdueGoals)
    }

    func saveStatus(goal: Goal) {
        let goalStatus = Status(
            scheduleCode: ScheduleCode(rawValue: goal.schedule!)!,
            done: goal.done,
            date: Calendar.current.startOfDay(for: goal.date)
        )
        let goalDateStart = Calendar.current.startOfDay(for: goal.date)
        if let firstFromSameDayIndex = goal.history?.firstIndex(where: { $0.date == goalDateStart }) {
            goal.history?.remove(at: firstFromSameDayIndex)
        }
        goal.history?.append(goalStatus)
    }

    func whatDoWeHaveToday(goal: Goal) {
        if goal.scheduleType.type == .interval {
            if isItTrainingDayInterval(goal: goal) {
                goal.schedule = ScheduleCode.training.rawValue
            } else {
                goal.schedule = ScheduleCode.freeDay.rawValue
            }
        } else {
            if isItTrainingDaySchedule(goal: goal) {
                goal.schedule = ScheduleCode.training.rawValue
            } else {
                goal.schedule = ScheduleCode.freeDay.rawValue
            }
        }
        goal.done = false
        goal.date = Calendar.current.startOfDay(for: Date.now)
    }

    func isItTrainingDayInterval(goal: Goal, startingFrom: Date = Date.now) -> Bool {
        guard (startingFrom.isLaterDay(than: goal.goalStartDate) || startingFrom.isSameDay(as: goal.goalStartDate)) else { return false }
        let hoursFromCreationDate = Calendar.current.dateComponents([.hour], from: goal.goalStartDate, to: beginningOfDay(startingFrom)).hour ?? 0

        var (daysFromCreationDate, reminder) = hoursFromCreationDate.quotientAndRemainder(dividingBy: 24)
        if reminder == 23 {
            daysFromCreationDate += 1
        }
        let (reminderInterval, _) = daysFromCreationDate.remainderReportingOverflow(dividingBy: goal.scheduleType.interval)
        if reminderInterval == 0 {
            return true
        }
        return false
    }

    func isItTrainingDaySchedule(goal: Goal) -> Bool {
        var scheduleStartDate: Date
        if Date().isLaterDay(than: goal.goalStartDate) {
            scheduleStartDate = beginningOfDay(Date())
        } else {
            scheduleStartDate = beginningOfDay(goal.goalStartDate)
        }
        if trainingDaysSchedule(goal: goal, startingFrom: scheduleStartDate).first == scheduleStartDate {
            return true
        }
        return false
    }

    func trainingDaysSchedule(goal: Goal, startingFrom: Date? = Date()) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let scheduleStartDate = beginningOfDay(startingFrom!)
        let componentsForFirstDayOfWeek = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: scheduleStartDate)
        let firstDayOfWeek = calendar.date(from: componentsForFirstDayOfWeek)!
        var trainingDays: [Date] = []

        for futureWeek in [0, 7] {
            for i in goal.scheduleType.weeklySchedule {
                let trainingDate = Date(timeInterval: Double(i.rawValue).day, since: firstDayOfWeek + Double(futureWeek).day)
                if trainingDate.isLaterDay(than: goal.goalStartDate) && trainingDate.isLaterDay(than: scheduleStartDate) || trainingDate.isSameDay(as: scheduleStartDate) {
                    trainingDays.append(trainingDate)
                }
            }
        }
        return trainingDays
    }

    private func beginningOfDay(_ date: Date = Date()) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
}
