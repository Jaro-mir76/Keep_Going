//
//  extension Color.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 19.11.2025.
//

import SwiftUI

// MARK: I've changed approach to colors but left it here just in case I need it for something else
//extension Color {
//    init?(hex: String) {
//// in case you use more than 6 characters (RRGGBB)
//        guard hex.count == 6 else { return nil }
//
//        var rgbValue: UInt64 = 0
//        guard Scanner(string: hex).scanHexInt64(&rgbValue) else { return nil }
//
//        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
//        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
//        let b = Double(rgbValue & 0x0000FF) / 255.0
//
//        self = Color(red: r, green: g, blue: b)
//    }
//}
