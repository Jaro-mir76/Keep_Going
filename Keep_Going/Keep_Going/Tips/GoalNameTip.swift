//
//  GoalNameTip.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 05.12.2025.
//

import Foundation
import TipKit

struct GoalNameTip: Tip {
    var title: Text {
        Text("Give It a Name")
    }
    
    var message: Text? {
        Text("Choose a **short, clear name** that inspires you. Examples: \"Daily Reading\", \"Morning Yoga\", \"Learn Spanish\" 📝")
    }
    
    var image: Image? {
        Image(systemName: "character.cursor.ibeam")
    }
    
    var rules: [Rule] {
        [
            #Rule(OnboardingProgress.$hasEnteredGoalName) { $0 == false },
            #Rule(OnboardingProgress.$hasCompletedOnboarding) { $0 == false }
        ]
    }
    
    var options: [any TipOption] {
        [
            Tips.MaxDisplayCount(1)
        ]
    }
}
