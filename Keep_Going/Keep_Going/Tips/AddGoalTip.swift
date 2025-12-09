//
//  AddGoalTip.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 05.12.2025.
//

import Foundation
import TipKit

struct AddGoalTip: Tip {
    var title: Text {
        Text("Start Your Journey")
    }
    
    var message: Text? {
        Text("Tap the **+** button to create your first small step toward a better you. Remember: small changes lead to big results! 🎯")
    }
    
    var image: Image? {
        Image(systemName: "plus.circle.fill")
    }
    
    var rules: [Rule] {
        [
            #Rule(OnboardingProgress.$hasAddedFirstGoal) { $0 == false },
            #Rule(OnboardingProgress.$hasCompletedOnboarding) { $0 == false }
        ]
    }
    
    var options: [any TipOption] {
        [
            Tips.MaxDisplayCount(3),
            Tips.IgnoresDisplayFrequency(false)
        ]
    }
}
