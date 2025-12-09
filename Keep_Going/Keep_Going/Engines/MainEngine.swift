//
//  MainEngine.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 16.06.2025.
//

import Foundation
import SwiftUI
import TipKit

@Observable
class MainEngine {
    var doNotAskAgainForNotificationPermission: Bool = false
    let notificationService: NotificationService
    
    init(selectedGoal: Goal? = nil, notificationService: NotificationService = NotificationService()) {
        self.selectedGoal = selectedGoal
        self.notificationService = notificationService
        
        _showAppIntroduction = UserDefaults.standard.bool(forKey: AppStorageKeys.showAppIntroduction)
        if _showAppIntroduction {
            OnboardingProgress.hasAddedFirstGoal = false
            OnboardingProgress.hasEnteredGoalName = false
            OnboardingProgress.hasEnteredMotivation = false
            OnboardingProgress.hasSelectedSchedule = false
            OnboardingProgress.hasSetReminder = false
            OnboardingProgress.hasSavedFirstGoal = false
            OnboardingProgress.hasEditedGoal = false
            OnboardingProgress.hasMarkedGoalDone = false
            OnboardingProgress.hasCompletedOnboarding = false
        } else {
            OnboardingProgress.hasAddedFirstGoal = true
            OnboardingProgress.hasEnteredGoalName = true
            OnboardingProgress.hasEnteredMotivation = true
            OnboardingProgress.hasSelectedSchedule = true
            OnboardingProgress.hasSetReminder = true
            OnboardingProgress.hasSavedFirstGoal = true
            OnboardingProgress.hasEditedGoal = true
            OnboardingProgress.hasMarkedGoalDone = true
            OnboardingProgress.hasCompletedOnboarding = true
        }
    }
    
    var selectedGoal: Goal?
    var userIsEditingGoal: Bool = false
    var welcomeTab: Int = 1
    
    private var _showAppIntroduction: Bool
    var showAppIntroduction: Bool {
        get{
            return _showAppIntroduction
        }
        set{
            UserDefaults.standard.set(newValue, forKey: AppStorageKeys.showAppIntroduction)
            _showAppIntroduction = newValue
        }
    }
    
    private(set) var hasAddedFirstGoal: Bool = OnboardingProgress.wasItDone(OnboardingProgress.hasAddedFirstGoal)
    private(set) var hasEnteredGoalName: Bool = OnboardingProgress.wasItDone(OnboardingProgress.hasEnteredGoalName)
    private(set) var hasEnteredMotivation: Bool = OnboardingProgress.wasItDone(OnboardingProgress.hasEnteredMotivation)
    private(set) var hasSelectedSchedule: Bool = OnboardingProgress.wasItDone(OnboardingProgress.hasSelectedSchedule)
    private(set) var hasSetReminder: Bool = OnboardingProgress.wasItDone(OnboardingProgress.hasSetReminder)
    private(set) var hasSavedFirstGoal: Bool = OnboardingProgress.wasItDone(OnboardingProgress.hasSavedFirstGoal)
    private(set) var hasEditedGoal: Bool = OnboardingProgress.wasItDone(OnboardingProgress.hasEditedGoal)
    private(set) var hasMarkedGoalDone: Bool = OnboardingProgress.wasItDone(OnboardingProgress.hasMarkedGoalDone)
    private(set) var hasCompletedOnboarding: Bool = OnboardingProgress.wasItDone(OnboardingProgress.hasCompletedOnboarding)

    func markFirstGoalAdded() {
        hasAddedFirstGoal = true
        OnboardingProgress.hasAddedFirstGoal = true
    }
    func markGoalNameEntered() {
        hasEnteredGoalName = true
        OnboardingProgress.hasEnteredGoalName = true
    }
    func markMotivationEntered() {
        hasEnteredMotivation = true
        OnboardingProgress.hasEnteredMotivation = true
    }
    func markScheduleSelected() {
        hasSelectedSchedule = true
        OnboardingProgress.hasSelectedSchedule = true
    }
    func markReminderSet() {
        hasSetReminder = true
        OnboardingProgress.hasSetReminder = true
    }
    func markFirstGoalSaved() {
        hasSavedFirstGoal = true
        OnboardingProgress.hasSavedFirstGoal = true
    }
    func markGoalEdited() {
        hasEditedGoal = true
        OnboardingProgress.hasEditedGoal = true
    }
    func markMarkGoalDone() {
        hasMarkedGoalDone = true
        OnboardingProgress.hasMarkedGoalDone = true
    }
    func markOnboardingCompleted() {
        hasCompletedOnboarding = true
        OnboardingProgress.hasCompletedOnboarding = true
    }

    func conditionFulfilledFor(_ condition: Bool) -> Bool {
        return !condition && !hasCompletedOnboarding
    }
    
    var _userWantsNotifications = UserDefaults.standard.bool(forKey: AppStorageKeys.userWantsNotifications)
    var userWantsNotifications: Bool {
        get {
            return _userWantsNotifications
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppStorageKeys.userWantsNotifications)
            _userWantsNotifications = newValue
        }
    }

    
    var welcomePageVisible = false
    var appIconVisible = true
    
//    var hasNotificationPermission: Bool = false

    func requestNotificationPermission() async {
        let grant = await notificationService.requestNotificationPermission()
//        if grant {
//
//        }
    }
    
    
}
