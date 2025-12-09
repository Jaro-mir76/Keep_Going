//
//  EditGoalTip.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 08.12.2025.
//

import Foundation
import TipKit

struct EditGoalTip: Tip {
    var title: Text {
        Text("Edit Anytime")
    }
    
    var message: Text? {
        Text("Swipe right on any goal to edit or adjust your schedule. Adapt as you grow! ✏️")
    }
    
    var image: Image? {
        Image(systemName: "pencil.circle.fill")
    }
    
    var rules: [Rule] {
        [
            #Rule(OnboardingProgress.$hasEditedGoal) { $0 == false },
            #Rule(OnboardingProgress.$hasAddedFirstGoal) { $0 == true },
            #Rule(OnboardingProgress.$hasCompletedOnboarding) { $0 == false }
        ]
    }
    
    var options: [any TipOption] {
        [
            Tips.MaxDisplayCount(1)
        ]
    }
}
