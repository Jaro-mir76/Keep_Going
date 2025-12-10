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
    static var hasAddedFirstGoal: Bool = true
    
    @Parameter
    static var hasEnteredGoalName: Bool = true
    
    @Parameter
    static var hasEnteredMotivation: Bool = true
    
    @Parameter
    static var hasSelectedSchedule: Bool = true
    
    @Parameter
    static var hasSetReminder: Bool = true
    
    @Parameter
    static var hasSavedFirstGoal: Bool = true
    
    @Parameter
    static var hasEditedGoal: Bool = true
    
    @Parameter
    static var hasMarkedGoalDone: Bool = true
    
    @Parameter
    static var hasCompletedOnboarding: Bool = true
}
