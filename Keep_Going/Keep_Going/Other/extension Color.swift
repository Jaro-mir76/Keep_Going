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

extension Color {
    // MARK: - Backgrounds
    static let appBackground = Color("background")
    static let appBackgroundSecondary = Color("backgroundSecondary")
    static let appBackgroundTertiary = Color("backgroundTertiary")
    
    // MARK: - Text Colors
    static let appTextPrimary = Color("textPrimary")
    static let appTextSecondary = Color("textSecondary")
    static let appTextTertiary = Color("textTertiary")
    
    // MARK: - Accent Colors
    static let appAccentOrange = Color("accentOrange")
    static let appAccentBlue = Color("accentBlue")
    static let appAccentGreen = Color("accentGreen")
    static let appAccentYellow = Color("accentYellow")
    static let appAccentPurple = Color("accentPurple")
    
    // MARK: - Task States
    static let appTaskActive = Color("taskActive")
    static let appTaskActiveBorder = Color("taskActiveBorder")
    static let appTaskCompleted = Color("taskCompleted")
    static let appTaskCompletedCheck = Color("taskCompletedCheck")
    static let appTaskInactive = Color("taskInactive")
    static let appTaskInactiveBorder = Color("taskInactiveBorder")
    static let appTaskDelayed = Color("taskDelayed")
    
    // MARK: - UI Elements
    static let appBorder = Color("border")
    static let appBorderLight = Color("borderLight")
    static let appButtonSecondaryBorder = Color("buttonSecondaryBorder")
    
    // MARK: - Progress & Stats
    static let appProgressBackground = Color("progressBackground")
    static let appProgressFill = Color("progressFill")
    
    // MARK: - Notifications
    static let appNotificationSuccessBg = Color("notificationSuccessBg")
    static let appNotificationSuccessText = Color("notificationSuccessText")
    
    // MARK: - Background Icons (with opacity)
    static let appIconTarget = Color("accentBlue")
    static let appIconStar = Color("accentYellow")
    static let appIconHeart = Color(red: 1.0, green: 0.42, blue: 0.42)
    static let appIconTrophy = Color("accentPurple")

}
