//
//  Schedule.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 15/05/2025.
//

import Foundation
import SwiftData

@Model
class Goal {
    var name: String
    var goalDescription: String
//    requiredTime is in minutes
    var requiredTime: Int?
    var weeklySchedule: [WeekDay]?
    var interval: Int?
    private var unifiedStartDate: Date?
    @Transient
    var startDate: Date? {
        set {
            if newValue != nil {
                unifiedStartDate = self.beginningOfDay(of: newValue!)
            } else {
                unifiedStartDate = nil
            }
        }
        get {
            if unifiedStartDate == nil {
                return nil
            } else {
                return self.unifiedStartDate
            }
        }
    }
    @Relationship(deleteRule: .cascade) var history: [Status]?
//    total -> how many times it was done
    var total: Int
//    strike -> how many times it was done without missing any
    var strike: Int
    var strikeCheckDate: Date
    
//    becaue of strange reason can not use enum in Status and have to replace it with more primitive method
//    similar problem here: https://developer.apple.com/forums/thread/773564
//    @Relationship() var status: Status?
    var todaysStatus: StatusCode.RawValue?
    var todaysDate: Date?
    
//    computed variable goalStatus ...
    @Transient
    var goalStatus: StatusCode? {
        set {
            if newValue != nil {
//                self.status = Status(statusCode: newValue!, date: Date())
                self.todaysStatus = newValue?.rawValue
                self.todaysDate = Date()
            } else {
                self.todaysStatus = nil
                self.todaysDate = nil
            }
        }
        get {
            if self.todaysStatus == nil {
                whatDoWeHaveToday()
            }
            return StatusCode(rawValue: self.todaysStatus!)
        }
    }
    
    init(name: String, goalDescription: String, requiredTime: Int? = nil, weeklySchedule: [WeekDay]? = nil, interval: Int? = nil, startDate: Date? = Date(), history: [Status]? = nil, total: Int = 0, inRow: Int = 0, strikeCheckDate: Date = Date(), todaysStatus: StatusCode.RawValue? = nil, todaysDate: Date? = nil) {
        self.name = name
        self.goalDescription = goalDescription
        self.requiredTime = requiredTime
        self.weeklySchedule = weeklySchedule
        self.interval = interval
        let timeDiffFromGMT = Double(TimeZone.current.secondsFromGMT())
        self.unifiedStartDate = NSCalendar.current.startOfDay(for: startDate!) + timeDiffFromGMT
        self.history = history
        self.total = total
        self.strike = inRow
        self.strikeCheckDate = strikeCheckDate
        self.todaysStatus = todaysStatus
        self.todaysDate = todaysDate
    }
    
    private func beginningOfDay(of date: Date = Date()) -> Date {
        let timeDiffFromGMT = timeDiffFromGMT()
        return NSCalendar.current.startOfDay(for: date) + timeDiffFromGMT
    }
    
    private func timeDiffFromGMT() -> Double {
        let timezone = TimeZone.current
        return Double(timezone.secondsFromGMT())
    }
    
// function returning dates of trainings for remaing part of the week
    func trainingDaysSchedule(forWeek: Date = Date()) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let componentsForFirstDayOfWeek = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: forWeek)
        let firstDayOfWeek = calendar.date(from: componentsForFirstDayOfWeek)!
        let firstDayOfWeekCorrected = Date(timeInterval: timeDiffFromGMT(), since: firstDayOfWeek)
        var answer: [Date] = []
        
//    beginningOfToday is start of the day in current time zome because NSCalendar.current.startOfDay gives start of the day only in GMT time
        let beginningOfToday = beginningOfDay()
        for futureWeek in [0, 7, 14, 21, 28, 35]{
            guard self.weeklySchedule != nil else {return []}
            for i in self.weeklySchedule!{
                let trainingDate = Date(timeInterval: Double(i.rawValue).day, since: firstDayOfWeekCorrected + Double(futureWeek).day)
                if trainingDate >= beginningOfToday {
                    answer.append(trainingDate)
                }
            }
        }
        return answer
    }
    
    func trainingDaysInterval() -> [Date] {
        guard self.interval != nil else { return [] }
        let today = beginningOfDay()
        var trainingDays: [Date] = []
        var timeInterval: Double
        for day in 0...34 {
            timeInterval = (today + Double(day).day).timeIntervalSince(self.startDate!)
            if timeInterval.remainder(dividingBy: Double(self.interval!).day) == 0 {
                trainingDays.append(today + Double(day).day)
            }
        }
        return trainingDays
    }
    
//    function is changing goal status to default value base on interval/schedule
    func whatDoWeHaveToday() {
        if let _ = self.interval {
            if isItTrainingDayInterval() {
                self.goalStatus = .scheduledNotDone
            }else {
                self.goalStatus = .freeDay
            }
        }else {
            if isItTrainingDaySchedule() {
                self.goalStatus = .scheduledNotDone
            }else {
                self.goalStatus = .freeDay
            }
        }
    }
    
    func saveStatus(status: Status) {
        self.history?.append(status)
    }
    
    func toggleTodaysStatus() {
        if self.goalStatus == .scheduledNotDone || self.goalStatus == .freeDay {
            self.goalStatus = .done
            self.total += 1
            if isItStrike() {
                self.strike += 1
            } else {
                self.strike = 1
            }
            self.strikeCheckDate = beginningOfDay()
        }else if self.goalStatus == .done{
            whatDoWeHaveToday()
            if self.total > 0 {
                self.total -= 1
                if self.strike > 0 {
                    self.strike -= 1
                }
                self.strikeCheckDate = beginningOfDay() - 1.day
            }
        }
    }
    
// I have to improve it because it is alaways checking entire hisotry which is not effective
    func isItStrike() -> Bool {
        var strike = true
        if let history = self.history {
            let statuses = history.filter({$0.date > self.strikeCheckDate}).sorted(by: {$0.date > $1.date})
            for status in statuses {
                switch status.statusCode {
                case .done:
                    continue
                case .scheduledNotDone:
                    strike = false
                case .freeDay:
                    continue
                }
            }
        }
        return strike
    }
    
// function returning true if today is training day (based on interval)
    func isItTrainingDayInterval() -> Bool {
        if interval != nil {
            let today = beginningOfDay()
            let beginningOfIntervalDate = beginningOfDay(of: self.startDate!)
            let timeInterval = today.timeIntervalSince(beginningOfIntervalDate)
            return timeInterval.remainder(dividingBy: Double(self.interval!).day) == 0 ? true : false
        }
        return false
    }
    
// function returning true if today is training day (based on schedule)
    func isItTrainingDaySchedule() -> Bool {
        let today = beginningOfDay()
        if trainingDaysSchedule().first == today {
            return true
        }
        return false
    }
    
    func updateWith (_ newGoal: Goal) {
        self.name = newGoal.name
        self.goalDescription = newGoal.goalDescription
        self.requiredTime = newGoal.requiredTime
        self.weeklySchedule = newGoal.weeklySchedule?.sorted(by: { $0.rawValue < $1.rawValue })
        self.interval = newGoal.interval
        if newGoal.todaysStatus == StatusCode.done.rawValue {
            self.todaysDate = newGoal.todaysDate
            self.todaysStatus = newGoal.todaysStatus
        } else {
            whatDoWeHaveToday()
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
                 startDate: Date(timeInterval: -20.day, since: beginingOfToday),
                 history: [
                    Status(statusCode: .freeDay, date: Date(timeInterval: -1.day, since: beginingOfToday)),
                    Status(statusCode: .freeDay, date: Date(timeInterval: -2.day, since: beginingOfToday)),
                    Status(statusCode: .done, date: Date(timeInterval: -3.day, since: beginingOfToday)),
                    Status(statusCode: .scheduledNotDone, date: Date(timeInterval: -4.day, since: beginingOfToday))
                 ],
                 total: 2,
                 inRow: 1),
            Goal(name: "Read",
                 goalDescription: "Read 10 pages every second day and you'll read.... a lot every year.",
                 requiredTime: nil,
                 weeklySchedule: nil,
                 interval: 3,
                 startDate: Date(timeInterval: -20.day, since: beginingOfToday),
                 history: [
                    Status(statusCode: .freeDay, date: Date(timeInterval: -1.day, since: beginingOfToday)),
                    Status(statusCode: .scheduledNotDone, date: Date(timeInterval: -2.day, since: beginingOfToday)),
                    Status(statusCode: .done, date: Date(timeInterval: -3.day, since: beginingOfToday)),
                    Status(statusCode: .freeDay, date: Date(timeInterval: 0.day, since: beginingOfToday))
                ],
                 total: 5,
                 inRow: 0),
            Goal(name: "Spanish",
                 goalDescription: "10 min daily and soon you'll speak like like Antoni Banderas.",
                 requiredTime: 5,
                 weeklySchedule: [.tuesday, .thursday],
                 interval: nil,
                 startDate: Date(timeInterval: -20.day, since: beginingOfToday),
                 history: [
                    Status(statusCode: .done, date: Date(timeInterval: -1.day, since: beginingOfToday))
                 ],
                 total: 1,
                 inRow: 1),
            Goal(name: "Japanese",
                 goalDescription: "10 min daily and soon you'll speak like Bruce Lee.",
                 requiredTime: 5,
                 weeklySchedule: [.monday, .wednesday, .friday],
                 interval: nil,
                 startDate: Date(timeInterval: -20.day, since: beginingOfToday),
                 history: [
                    Status(statusCode: .done, date: Date(timeInterval: 0.day, since: beginingOfToday))
                 ],
                 total: 1,
                 inRow: 1,
                 todaysStatus: StatusCode.done.rawValue,
                todaysDate: Date())
        ]
    }
}
