//
//  OnboardingProgress.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 08.12.2025.
//

import Foundation
import TipKit

enum OnboardingProgress {
    @Parameter
    static var hasAddedFirstGoal: Bool = false
    
    @Parameter
    static var hasEnteredGoalName: Bool = false
    
    @Parameter
    static var hasEnteredMotivation: Bool = false
    
    @Parameter
    static var hasSelectedSchedule: Bool = false
    
    @Parameter
    static var hasSetReminder: Bool = false
    
    @Parameter
    static var hasSavedFirstGoal: Bool = false
    
    @Parameter
    static var hasEditedGoal: Bool = false
    
    @Parameter
    static var hasMarkedGoalDone: Bool = false
    
    @Parameter
    static var hasCompletedOnboarding: Bool = false
    
    static func wasItDone(_ variable: Bool) -> Bool {
        hasCompletedOnboarding == true ? true : variable
    }
}
