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
        var components = DateComponents()
        
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
        components.timeZone = .current
        let time = Calendar.current.date(from: components) ?? Date.now
        return time
    }
}
