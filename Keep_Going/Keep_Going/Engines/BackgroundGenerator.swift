//
//  BackgroundGenerator.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 14.12.2025.
//

import Foundation
import SwiftUI

private let symbols = ["🌱", "🎯", "☀️", "💪🏻", "📘", "🩷"]

struct BackgroundGenerator {
    var entries: [Element] = []
    var count: Int
    
    init(count: Int = 75) {
        self.count = count
        
        for _ in 0..<count {
            entries.append(Element())
        }
        reposition()
    }
    
    mutating func reposition() {
        for index in entries.indices {
            entries[index].reposition()
        }
    }
}

struct Element {
    var x: Double
    var y: Double
    var symbolIndex: Int
    
    init() {
        x = Double.random(in: 0...1)
        y = Double.random(in: 0...1)
        symbolIndex = Int.random(in: 0..<symbols.count)
    }
    
    var symbol: Text {
        Text ("\(symbols[symbolIndex])")
    }
    
    mutating func reposition() {
        x = Double.random(in: 0...1)
        y = Double.random(in: 0...1)
    }
}
