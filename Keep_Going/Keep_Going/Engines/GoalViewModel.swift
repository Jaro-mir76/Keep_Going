//
//  GoalViewModel.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 27.10.2025.
//

import Foundation
import SwiftData

@MainActor
@Observable
class GoalViewModel {
    var goals: [Goal] = []
    let modelContainer: ModelContainer
    
    init() {
        modelContainer = PersistentStorage.shared.modelContainer
        fetchGoals()
    }
    
    func fetchGoals() {
        let requestAllGoals = FetchDescriptor<Goal>(predicate: nil, sortBy: [.init(\.done, order: .forward), .init(\.schedule, order: .forward), .init(\.name, order: .forward)])
        do {
            self.goals = try modelContainer.mainContext.fetch(requestAllGoals)
        } catch {
            print ("Could not fetch goals, error: \(error)")
        }
        for goal in goals {
            if !Calendar.current.isDateInToday(goal.date) {
                saveStatus(goal: goal)
                whatDoWeHaveToday(goal: goal)
            }
        }
    }
    
    private func beginningOfDay(of date: Date = Date()) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    private func timeDiffFromGMT() -> Double {
        let timezone = TimeZone.current
        return Double(timezone.secondsFromGMT())
    }
    
    func addGoal(goal: Goal) {
        modelContainer.mainContext.insert(goal)
        fetchGoals()
    }
    
    func deleteGoal(goal: Goal) {
        modelContainer.mainContext.delete(goal)
        fetchGoals()
    }
    
// function returning dates of trainings for remaing part of the week
    func trainingDaysSchedule(goal: Goal, forWeek: Date = Date()) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let componentsForFirstDayOfWeek = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: forWeek)
        let firstDayOfWeek = calendar.date(from: componentsForFirstDayOfWeek)!
        var trainingDays: [Date] = []
        
//    beginningOfToday is start of the day in current time zome because NSCalendar.current.startOfDay gives start of the day only in GMT time
        let today = beginningOfDay()
        for futureWeek in [0, 7, 14, 21, 28, 35]{
            guard goal.weeklySchedule != nil else {return []}
            for i in goal.weeklySchedule!{
                let trainingDate = Date(timeInterval: Double(i.rawValue).day, since: firstDayOfWeek + Double(futureWeek).day)
                if trainingDate.isLaterDay(than: today) {
                    trainingDays.append(trainingDate)
                }
            }
        }
        return trainingDays
    }
        
    // function returning dates of trainings for next 31 days
    func trainingDaysInterval(goal: Goal) -> [Date] {
        guard goal.interval != nil else { return [] }
        let today = Date.now
        var trainingDays: [Date] = []
        let range = 31 / goal.interval!
        for i in 0...range {
            let trainingDay = today.addingTimeInterval(TimeInterval(Double(goal.interval!) * Double(i).day))
            trainingDays.append(trainingDay)
        }
        return trainingDays
    }
        
    //    function is setting goal status to default value base on interval/schedule
    func whatDoWeHaveToday(goal: Goal) {
        if let _ = goal.interval {
            if isItTrainingDayInterval(goal: goal) {
                goal.schedule = ScheduleCode.training.rawValue
            }else {
                goal.schedule = ScheduleCode.freeDay.rawValue
            }
        }else {
            if isItTrainingDaySchedule(goal: goal) {
                goal.schedule = ScheduleCode.training.rawValue
            }else {
                goal.schedule = ScheduleCode.freeDay.rawValue
            }
        }
        goal.done = false
        goal.date = Calendar.current.startOfDay(for: Date.now)
    }
        
    func saveStatus(goal: Goal) {
        let goalStatus = Status(scheduleCode: ScheduleCode(rawValue: goal.schedule!)!, done: goal.done, date: goal.date)
        goal.history?.append(goalStatus)
    }
        
    func toggleTodaysStatus(goal: Goal) {
        if goal.done == false {
            goal.done = true
            goal.total += 1
            if isItStrike(goal: goal) {
                goal.strike += 1
            } else {
                goal.strike = 1
            }
            goal.strikeCheckDate = Date.now
        }else if goal.done == true{
            goal.done = false
            if goal.total > 0 {
                goal.total -= 1
                if goal.strike > 0 {
                    goal.strike -= 1
                }
                goal.strikeCheckDate = Date.now - 1.day
            }
        }
        fetchGoals()
    }
        
// I have to improve it because it is alaways checking entire hisotry which is not effective
    func isItStrike(goal: Goal) -> Bool {
        var strike = true
        if let history = goal.history {
            let statuses = history.filter({$0.date > goal.strikeCheckDate}).sorted(by: {$0.date > $1.date})
            for status in statuses {
                switch status.scheduleCode {
                case .training:
                    if status.done == false {
                        strike = false
                    }
                case .freeDay:
                    continue
                }
            }
        }
        goal.strikeCheckDate = Date.now
        return strike
    }
        
// function returning true if today is training day (based on interval)
    func isItTrainingDayInterval(goal: Goal) -> Bool {
        guard goal.interval != nil else {return false}
        let hoursFromCreationDate = Calendar.current.dateComponents([.hour], from: goal.creationDate!, to: beginningOfDay()).hour ?? 0
        
//       checking reminder, if it's 23 (it means there was time change Winter > Summer and we have to increase result by 1
        var (daysFromCreationDate, reminder) = hoursFromCreationDate.quotientAndRemainder(dividingBy: 24)
        if reminder == 23 {
            daysFromCreationDate += 1
        }
        let (reminderInterval, _) = daysFromCreationDate.remainderReportingOverflow(dividingBy: goal.interval!)
        return reminderInterval == 0 ? true : false
    }
        
// function returning true if today is training day (based on schedule)
    func isItTrainingDaySchedule(goal: Goal) -> Bool {
        let today = beginningOfDay()
        if trainingDaysSchedule(goal: goal).first == today {
            return true
        }
        return false
    }
        
    func updateWith (goal: Goal, with newGoal: Goal) {
        goal.name = newGoal.name
        goal.goalDescription = newGoal.goalDescription
        goal.requiredTime = newGoal.requiredTime
        goal.weeklySchedule = newGoal.weeklySchedule?.sorted(by: { $0.rawValue < $1.rawValue })
        goal.interval = newGoal.interval
        if newGoal.done == true {
            goal.date = newGoal.date
            goal.schedule = newGoal.schedule
            goal.done = newGoal.done
        } else {
            whatDoWeHaveToday(goal: goal)
        }
    }
    
    static func exampleGoal() -> [Goal] {
        let timezone = TimeZone.current
        let timeDiffFromGMT = Double(timezone.secondsFromGMT())
        let beginingOfToday = NSCalendar.current.startOfDay(for: Date()) + timeDiffFromGMT
        return [
            Goal(name: "Salsa",
                 goalDescription: "5 min. of training every daily will make you muy bueno salsero.",
                 requiredTime: 5,
                 weeklySchedule: nil,
                 interval: 1,
                 creationDate: Date(timeInterval: -20.day, since: Date.now),
                 history: [
                    Status(scheduleCode: .freeDay, done: false, date: Date(timeInterval: -1.day, since: beginingOfToday)),
                    Status(scheduleCode: .freeDay, done: false,  date: Date(timeInterval: -2.day, since: beginingOfToday)),
                    Status(scheduleCode: .training, done: true, date: Date(timeInterval: -3.day, since: beginingOfToday)),
                    Status(scheduleCode: .training, done: true, date: Date(timeInterval: -4.day, since: beginingOfToday))
                 ],
                 total: 2,
                 strike: 1,
                 strikeCheckDate: Date(timeInterval: -1.day, since: beginingOfToday),
                 schedule: ScheduleCode.training.rawValue,
                 date: Date(timeInterval: -1.day, since: beginingOfToday),
                 done: false),
            Goal(name: "Read",
                 goalDescription: "Read 10 pages every second day and you'll read.... a lot every year.",
                 requiredTime: nil,
                 weeklySchedule: nil,
                 interval: 3,
                 creationDate: Date(timeInterval: -20.day, since: Date.now),
                 history: [
                    Status(scheduleCode: .freeDay, done: false, date: Date(timeInterval: -1.day, since: beginingOfToday)),
                    Status(scheduleCode: .training, done: true, date: Date(timeInterval: -2.day, since: beginingOfToday)),
                    Status(scheduleCode: .training, done: true, date: Date(timeInterval: -3.day, since: beginingOfToday)),
                    Status(scheduleCode: .freeDay, done: false, date: Date(timeInterval: 0.day, since: beginingOfToday))
                ],
                 total: 5,
                 strike: 1,
                 strikeCheckDate: Date(timeInterval: -1.day, since: beginingOfToday),
                 schedule: ScheduleCode.training.rawValue,
                 date: Date(timeInterval: -1.day, since: beginingOfToday),
                 done: false),
            Goal(name: "Spanish",
                 goalDescription: "10 min daily and soon you'll speak like like Antoni Banderas.",
                 requiredTime: 5,
                 weeklySchedule: [.tuesday, .thursday],
                 interval: nil,
                 creationDate: Date(timeInterval: -20.day, since: Date.now),
                 history: [
                    Status(scheduleCode: .training, done: true, date: Date(timeInterval: -1.day, since: beginingOfToday))
                 ],
                 total: 1,
                 strike: 1,
                 strikeCheckDate: Date(timeInterval: -1.day, since: beginingOfToday),
                 schedule: ScheduleCode.training.rawValue,
                 date: Date(timeInterval: -1.day, since: beginingOfToday),
                 done: false),
            Goal(name: "Japanese",
                 goalDescription: "10 min daily and soon you'll speak like Bruce Lee.",
                 requiredTime: 5,
                 weeklySchedule: [.monday, .wednesday, .friday],
                 interval: nil,
                 creationDate: Date(timeInterval: -20.day, since: Date.now),
                 history: [
                    Status(scheduleCode: .training, done: true, date: Date(timeInterval: 0.day, since: beginingOfToday))
                 ],
                 total: 1,
                 strike: 1,
                 strikeCheckDate: Date(timeInterval: -1.day, since: beginingOfToday),
                 schedule: ScheduleCode.training.rawValue,
                 date: Date(timeInterval: -1.day, since: beginingOfToday),
                 done: false)
        ]
    }
}
