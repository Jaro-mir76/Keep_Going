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
    
    private(set) var hasAddedFirstGoal: Bool {
        get { OnboardingProgress.hasAddedFirstGoal }
        set { OnboardingProgress.hasAddedFirstGoal = newValue }
    }
    private(set) var hasEnteredGoalName: Bool {
        get { OnboardingProgress.hasEnteredGoalName }
        set { OnboardingProgress.hasEnteredGoalName = newValue }
    }
    private(set) var hasEnteredMotivation: Bool {
        get { OnboardingProgress.hasEnteredMotivation }
        set { OnboardingProgress.hasEnteredMotivation = newValue }
    }
    private(set) var hasSelectedSchedule: Bool {
        get { OnboardingProgress.hasSelectedSchedule }
        set { OnboardingProgress.hasSelectedSchedule = newValue }
    }
    private(set) var hasSetReminder: Bool {
        get { OnboardingProgress.hasSetReminder }
        set { OnboardingProgress.hasSetReminder = newValue }
    }
    private(set) var hasSavedFirstGoal: Bool {
        get { OnboardingProgress.hasSavedFirstGoal }
        set { OnboardingProgress.hasSavedFirstGoal = newValue }
    }
    private(set) var hasEditedGoal: Bool {
        get { OnboardingProgress.hasEditedGoal }
        set { OnboardingProgress.hasEditedGoal = newValue }
    }
    private(set) var hasMarkedGoalDone: Bool {
        get { OnboardingProgress.hasMarkedGoalDone }
        set { OnboardingProgress.hasMarkedGoalDone = newValue }
    }
    private(set) var hasCompletedOnboarding: Bool {
        get { OnboardingProgress.hasCompletedOnboarding }
        set { OnboardingProgress.hasCompletedOnboarding = newValue }
    }
    
    func markFirstGoalAdded() {
        hasAddedFirstGoal = true
    }
    func markGoalNameEntered() {
        hasEnteredGoalName = true
    }
    func markMotivationEntered() {
        hasEnteredMotivation = true
    }
    func markScheduleSelected() {
        hasSelectedSchedule = true
    }
    func markReminderSet() {
        hasSetReminder = true
    }
    func markFirstGoalSaved() {
        hasSavedFirstGoal = true
    }
    func markGoalEdited() {
        hasEditedGoal = true
    }
    func markMarkGoalDone() {
        hasMarkedGoalDone = true
    }
    func markOnboardingCompleted() {
        hasCompletedOnboarding = true
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
