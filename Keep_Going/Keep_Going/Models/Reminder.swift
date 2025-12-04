//
//  Reminder.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 31.10.2025.
//

import Foundation
import SwiftData

//enum Reminder: String, CaseIterable, Identifiable, Codable {
//    case morning
//    case midDay
//    case afternoon
//    case evening
//    
//    var id: Self { self }
//    
//    var time: Date {
//        var components = Calendar.current.dateComponents([.day, .month, .year], from: Date())
//        
//        switch self {
//        case .morning:
//            components.hour = 8
//            components.minute = 00
//        case .midDay:
//            components.hour = 12
//            components.minute = 00
//        case .afternoon:
//            components.hour = 17
//            components.minute = 00
//        case .evening:
//            components.hour = 21
//            components.minute = 00
//        }
//        let reminderTime = Calendar.current.date(from: components) ?? Date()
//        return reminderTime
//    }
//    
//    var backgroundTaskIdentifier: String {
//        switch self {
//        case .morning:
//            return "com.keepgoing.background.goals.reminder.morning"
//        case .midDay:
//            return "com.keepgoing.background.goals.reminder.midDay"
//        case .afternoon:
//            return "com.keepgoing.background.goals.reminder.afternoon"
//        case .evening:
//            return "com.keepgoing.background.goals.reminder.evening"
//        }
//    }
//}

@Model
class Reminder {
    enum Hours: Int, CaseIterable, Identifiable {
        case zero, one, two, three, four, five, six, seven, eight, nine, ten, eleven, twelve, thirteen, fourteen, fifteen, sixteen, seventeen, eighteen, nineteen, twenty, twentyOne, twentyTwo, twentyThree
        
        var id: Self { self }
        
//  It returns date prepared based on current date just with hour from Hours value
        var time: Date {
            var components = Calendar.current.dateComponents([.day, .month, .year, .minute, .second], from: Date())
            components.hour = self.rawValue
            let time = Calendar.current.date(from: components) ?? Date()
            return time
        }
    }
    
    enum Minutes: Int, CaseIterable, Identifiable {
        case zero = 0
        case five = 5
        case ten = 10
        case fifteen = 15
        case twenty = 20
        case twentyFive = 25
        case thirty = 30
        case thirtyFive = 35
        case forty = 40
        case fortyFive = 45
        case fifty = 50
        case fiftyFive = 55
        
        var id: Self { self }
    }
    
    private var hoursRawValue: Int
    private var minutesRawValue: Int
    
    @Transient
    var hours: Hours {
        get {
            return Hours(rawValue: hoursRawValue) ?? .eight
        }
        set {
            self.hoursRawValue = newValue.rawValue
        }
    }
    @Transient
    var minutes: Minutes {
        get {
            return Minutes(rawValue: minutesRawValue) ?? .zero
        }
        set {
            self.minutesRawValue = newValue.rawValue
        }
    }
    
    init(hours: Hours = .eight , minutes: Minutes = .zero) {
        self.hoursRawValue = hours.rawValue
        self.minutesRawValue = minutes.rawValue
    }
    @Transient
    var time: Date {
        var components = Calendar.current.dateComponents([.day, .month, .year], from: Date())

        components.hour = hours.rawValue
        components.minute = minutes.rawValue
        
        let reminderTime = Calendar.current.date(from: components) ?? Date()
        return reminderTime
    }
}
