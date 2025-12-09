//
//  GoalMotivatorTip.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 05.12.2025.
//

import Foundation
import TipKit

struct GoalMotivationTip: Tip {
    var title: Text {
        Text("Add Your \"Why\"")
    }
    
    var message: Text? {
        Text("Write down **why this matters** to you. This will appear in reminders to keep you motivated when you need it most! 💪")
    }
    
    var image: Image? {
        Image(systemName: "heart.text.square.fill")
    }
    
    var rules: [Rule] {
        [
            #Rule(OnboardingProgress.$hasEnteredGoalName) { $0 == true },
            #Rule(OnboardingProgress.$hasEnteredMotivation) { $0 == false },
            #Rule(OnboardingProgress.$hasCompletedOnboarding) { $0 == false }
        ]
    }
    
    var options: [any TipOption] {
        [
            Tips.MaxDisplayCount(1)
        ]
    }
}
