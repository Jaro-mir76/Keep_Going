//
//  NotificationPermissionTip.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 08.12.2025.
//

import Foundation
import TipKit

struct NotificationPermissionTip: Tip {
    var title: Text {
        Text("Enable Notifications")
    }
    
    var message: Text? {
        Text("Allow notifications to receive reminders for your goals. You can customize reminder times for each goal!")
    }
    
    var image: Image? {
        Image(systemName: "bell.badge.fill")
    }
    
    var options: [any TipOption] {
        [
            Tips.MaxDisplayCount(2)
        ]
    }
}
