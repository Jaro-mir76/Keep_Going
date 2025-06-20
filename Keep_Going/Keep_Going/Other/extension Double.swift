//
//  extension Double.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 15/05/2025.
//

import Foundation

// Helper in calculation seconds in minutes, hours, days
extension Double {
    var minute: Double {return self * 60}
    var hour: Double {return self * 60 * 60}
    var day: Double {return self * 60 * 60 * 24}
}
