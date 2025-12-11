//
//  Frequency.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 05/06/2025.
//

import Foundation
import SwiftData

@Model
class ScheduleType {
    
    enum ScheduleTypes: String, CaseIterable, Identifiable, Codable {
        case interval
        case weekly
        
        var id: Self { self }
    }
    
    init(type: ScheduleTypes, interval: Int = 1, weeklySchedule: [WeekDay] = []) {
        self.typeRawValue = type.rawValue
        self.interval = interval
        self.weeklySchedule = weeklySchedule
    }
    
    private var typeRawValue: String
    @Transient
    var type: ScheduleTypes {
        get {
            ScheduleTypes(rawValue: typeRawValue) ?? .interval
        }
        set {
            typeRawValue = newValue.rawValue
        }
    }
    
    var interval: Int
    var weeklySchedule: [WeekDay]
}
