//
//  WeekDay.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 02/06/2025.
//

import Foundation

enum WeekDay: Int, CaseIterable, Identifiable, Codable, Hashable {
    
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var id: Int { self.rawValue }
    
    var name: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
}
