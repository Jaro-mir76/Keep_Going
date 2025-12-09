//
//  ReminderTimeTip.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 08.12.2025.
//

import Foundation
import TipKit

struct ReminderTimeTip: Tip {
    var title: Text {
        Text("Set Your Reminder")
    }
    
    var message: Text? {
        Text("Choose when you'd like to be reminded. Pick a time when you're most likely to have a few minutes free. 🔔")
    }
    
    var image: Image? {
        Image(systemName: "bell.badge.fill")
    }
    
    var rules: [Rule] {
        [
            #Rule(OnboardingProgress.$hasSelectedSchedule) { $0 == true },
            #Rule(OnboardingProgress.$hasSetReminder) { $0 == false },
            #Rule(OnboardingProgress.$hasCompletedOnboarding) { $0 == false }
        ]
    }
    
    var options: [any TipOption] {
        [
            Tips.MaxDisplayCount(1)
        ]
    }
}
