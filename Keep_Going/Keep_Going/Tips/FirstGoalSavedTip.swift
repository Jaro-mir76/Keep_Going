//
//  FirstGoalCompleteTip.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 08.12.2025.
//

import Foundation
import TipKit

struct FirstGoalSavedTip: Tip {
    var title: Text {
        Text("You're All Set! 🎉")
    }
    
    var message: Text? {
        Text("Your first goal is ready! Tap **Save** and start your journey. Remember: consistency beats perfection!")
    }
    
    var image: Image? {
        Image(systemName: "checkmark.seal.fill")
    }
    
    var rules: [Rule] {
        [
            #Rule(OnboardingProgress.$hasSetReminder) { $0 == true },
            #Rule(OnboardingProgress.$hasSavedFirstGoal) { $0 == false },
            #Rule(OnboardingProgress.$hasCompletedOnboarding) { $0 == false }
        ]
    }
    
    var options: [any TipOption] {
        [
            Tips.MaxDisplayCount(1)
        ]
    }
}
