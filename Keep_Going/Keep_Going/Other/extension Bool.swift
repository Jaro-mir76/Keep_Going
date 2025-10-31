//
//  extension Bool.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 28.10.2025.
//

import Foundation

extension Bool: @retroactive Comparable {
    public static func <(lhs: Self, rhs: Self) -> Bool {
        !lhs && rhs
    }
}
