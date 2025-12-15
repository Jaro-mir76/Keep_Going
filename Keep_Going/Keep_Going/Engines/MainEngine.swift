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
    static let shared = MainEngine()
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
    
    private(set) var hasAddedFirstGoalTip: Bool {
        get { OnboardingProgress.hasAddedFirstGoal }
        set { OnboardingProgress.hasAddedFirstGoal = newValue }
    }
    private(set) var hasEnteredGoalNameTip: Bool {
        get { OnboardingProgress.hasEnteredGoalName }
        set { OnboardingProgress.hasEnteredGoalName = newValue }
    }
    private(set) var hasEnteredMotivationTip: Bool {
        get { OnboardingProgress.hasEnteredMotivation }
        set { OnboardingProgress.hasEnteredMotivation = newValue }
    }
    private(set) var hasSelectedScheduleTip: Bool {
        get { OnboardingProgress.hasSelectedSchedule }
        set { OnboardingProgress.hasSelectedSchedule = newValue }
    }
    private(set) var hasSetReminderTip: Bool {
        get { OnboardingProgress.hasSetReminder }
        set { OnboardingProgress.hasSetReminder = newValue }
    }
    private(set) var hasSavedFirstGoalTip: Bool {
        get { OnboardingProgress.hasSavedFirstGoal }
        set { OnboardingProgress.hasSavedFirstGoal = newValue }
    }
    private(set) var hasEditedGoalTip: Bool {
        get { OnboardingProgress.hasEditedGoal }
        set { OnboardingProgress.hasEditedGoal = newValue }
    }
    private(set) var hasMarkedGoalDoneTip: Bool {
        get { OnboardingProgress.hasMarkedGoalDone }
        set { OnboardingProgress.hasMarkedGoalDone = newValue }
    }
    private(set) var hasCompletedOnboardingTip: Bool {
        get { OnboardingProgress.hasCompletedOnboarding }
        set { OnboardingProgress.hasCompletedOnboarding = newValue }
    }
    
    func tipsMarkFirstGoalAdded() {
        hasAddedFirstGoalTip = true
    }
    func tipsMarkGoalNameEntered() {
        hasEnteredGoalNameTip = true
    }
    func tipsMarkMotivationEntered() {
        hasEnteredMotivationTip = true
    }
    func tipsMarkScheduleSelected() {
        hasSelectedScheduleTip = true
    }
    func tipsMarkReminderSet() {
        hasSetReminderTip = true
    }
    func tipsMarkFirstGoalSaved() {
        hasSavedFirstGoalTip = true
    }
    func tipsMarkGoalEdited() {
        hasEditedGoalTip = true
    }
    func tipsMarkMarkGoalDone() {
        if !hasMarkedGoalDoneTip {
            hasMarkedGoalDoneTip = true
            tipsMarkOnboardingCompleted()
            showAppIntroduction = false
        }
    }
    func tipsMarkOnboardingCompleted() {
        hasCompletedOnboardingTip = true
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
    
    var repositionBackground: Bool = false
    
//    var hasNotificationPermission: Bool = false

    func requestNotificationPermission() async {
        let grant = await notificationService.requestNotificationPermission()
//        if grant {
//
//        }
    }
    
    
}
