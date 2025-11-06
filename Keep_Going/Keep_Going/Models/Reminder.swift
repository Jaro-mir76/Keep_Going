//
//  Reminder.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 31.10.2025.
//

import Foundation
import SwiftData

enum Reminder: String, CaseIterable, Identifiable, Codable {
    case morning
    case midDay
    case afternoon
    case evening
    
    var id: Self { self }
    
    var time: Date {
        var components = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        
        switch self {
        case .morning:
            components.hour = 8
            components.minute = 00
        case .midDay:
            components.hour = 12
            components.minute = 00
        case .afternoon:
            components.hour = 17
            components.minute = 00
        case .evening:
            components.hour = 21
            components.minute = 00
        }
        let reminderTime = Calendar.current.date(from: components) ?? Date()
        return reminderTime
    }
    
    var backgroundTaskIdentifier: String {
        switch self {
        case .morning:
            return "com.keepgoing.background.goals.reminder.morning"
        case .midDay:
            return "com.keepgoing.background.goals.reminder.midDay"
        case .afternoon:
            return "com.keepgoing.background.goals.reminder.afternoon"
        case .evening:
            return "com.keepgoing.background.goals.reminder.evening"
        }
    }
}
