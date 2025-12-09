//
//  ScheduleTypeTip.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 08.12.2025.
//

import Foundation
import TipKit

struct ScheduleTypeTip: Tip {
    var title: Text {
        Text("Choose Your Rhythm")
    }
    
    var message: Text? {
        Text("Select how often you want to practice:\n• **Interval**: Every N days\n• **Weekly**: Specific days of the week\n\nStart small - you can always increase later! 📅")
    }
    
    var image: Image? {
        Image(systemName: "calendar.badge.clock")
    }
    
    var rules: [Rule] {
        [
            #Rule(OnboardingProgress.$hasEnteredMotivation) { $0 == true },
            #Rule(OnboardingProgress.$hasSelectedSchedule) { $0 == false },
            #Rule(OnboardingProgress.$hasCompletedOnboarding) { $0 == false }
        ]
    }
    
    var options: [any TipOption] {
        [
            Tips.MaxDisplayCount(1)
        ]
    }
}
