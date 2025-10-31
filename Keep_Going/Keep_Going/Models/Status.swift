//
//  Status.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 21/05/2025.
//

import Foundation
import SwiftData

@Model
class Status {
    var scheduleCode: ScheduleCode
    var done: Bool
    var date: Date
    
    init(scheduleCode: ScheduleCode, done: Bool, date: Date) {
        self.scheduleCode = scheduleCode
        self.done = done
        self.date = date
    }
}

enum ScheduleCode: Int, CaseIterable, Codable {
    case training = 0
    case freeDay = 1
//    case done = 2
    
    var rawValue: Int {
        switch self {
        case .training:
            return 0
        case .freeDay:
            return 1
//        case .done:
//            return 2
        }
    }
}
