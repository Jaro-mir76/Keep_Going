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
    
    var isItSameHourOrLater: Bool {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        guard let dateHour = dateComponents.hour else {return false}
        let todaysDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        guard let currentHour = todaysDateComponents.hour else {return false}
        return dateHour >= currentHour
    }
    
    var isItInFuture: Bool {
        return self >= Date()
    }
    
    var isItInPast: Bool {
        return self < Date()
    }
}
