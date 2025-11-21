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
    var goalStartDate: Date
//    requiredTime is in minutes
    var requiredTime: Int?
    var weeklySchedule: [WeekDay]?
    var interval: Int?
    var reminderPreference: Reminder?
    
//  For ease of dates comparing I'm using everywhere time of exact beginning to the day in current time zone
    var creationDate: Date
    @Relationship(deleteRule: .cascade)
    var history: [Status]?
    
//    total -> how many times it was done
    var total: Int
    
//    strike -> how many times it was done without missing any in between
    var strike: Int
    var strikeCheckDate: Date
    
//    becaue of strange reason can not use enum in Status and have to replace it with more primitive method
//    similar problem here: https://developer.apple.com/forums/thread/773564
//    @Relationship() var status: Status?
    var schedule: ScheduleCode.RawValue?
    var date: Date
    var done: Bool
    
    init(name: String, goalDescription: String, goalStartDate: Date = Date(), requiredTime: Int? = nil, weeklySchedule: [WeekDay]? = nil, interval: Int? = nil, reminderPreference: Reminder? = .afternoon, creationDate: Date = Date(), history: [Status]? = [], total: Int = 0, strike: Int = 0, strikeCheckDate: Date = Date(), schedule: ScheduleCode.RawValue? = nil, date: Date = Date(), done: Bool = false) {
        self.name = name
        self.goalDescription = goalDescription
        self.goalStartDate = Calendar.current.startOfDay(for: goalStartDate)
        self.requiredTime = requiredTime
        self.weeklySchedule = weeklySchedule
        self.interval = interval
        self.reminderPreference = reminderPreference
        self.creationDate = Calendar.current.startOfDay(for: creationDate)
        self.history = history
        self.total = total
        self.strike = strike
        self.strikeCheckDate = Calendar.current.startOfDay(for: strikeCheckDate)
        self.schedule = schedule
        self.date = Calendar.current.startOfDay(for: date)
        self.done = done
    }
}
