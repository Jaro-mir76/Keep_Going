//
//  Frequency.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 05/06/2025.
//

import Foundation

enum Frequency: String, CaseIterable, Identifiable {
    case interval
    case weekly
    
    var id: Self { self }
}
