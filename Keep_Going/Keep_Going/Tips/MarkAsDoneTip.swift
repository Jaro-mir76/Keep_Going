//
//  MarkAsDoneTip.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 08.12.2025.
//

import Foundation
import TipKit

struct MarkAsDoneTip: Tip {
    var title: Text {
        Text("Mark as Complete")
    }
    
    var message: Text? {
        Text("Long press the **checkmark** when you complete your goal. Watch your streak grow! 🔥")
    }
    
    var image: Image? {
        Image(systemName: "checkmark.circle.fill")
    }
    
    var rules: [Rule] {
        [
            #Rule(OnboardingProgress.$hasMarkedGoalDone) { $0 == false },
            #Rule(OnboardingProgress.$hasEditedGoal) { $0 == true },
            #Rule(OnboardingProgress.$hasCompletedOnboarding) { $0 == false }
        ]
    }
    
    var options: [any TipOption] {
        [
            Tips.MaxDisplayCount(2)
        ]
    }
}
