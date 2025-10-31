//
//  extension Date.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 28.10.2025.
//

import Foundation

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: otherDate)
    }
    
    func isLaterDay(than otherDate: Date) -> Bool {
        let selfStart = Calendar.current.startOfDay(for: self)
        let otherDateStart = Calendar.current.startOfDay(for: otherDate)
        return selfStart > otherDateStart
    }
}
