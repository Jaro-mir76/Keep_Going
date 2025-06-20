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
    var statusCode: StatusCode
    var date: Date
    
    init(statusCode: StatusCode, date: Date) {
        self.statusCode = statusCode
        self.date = date
    }
}

enum StatusCode: Int, CaseIterable, Codable {
    case scheduledNotDone = 0
    case freeDay = 1
    case done = 2
    
    var rawValue: Int {
        switch self {
        case .scheduledNotDone:
            return 0
        case .freeDay:
            return 1
        case .done:
            return 2
        }
    }
}
