//
//  GoalViewModel.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 27.10.2025.
//

import Foundation
import SwiftData
import UserNotifications
import SwiftUI

@MainActor
@Observable
class GoalViewModel {
    var mainEngine: MainEngine
    private var storageService: StorageService
    var modelContainer: ModelContainer {
        return storageService.modelContainer
    }
    
    var notificationDelegate: NotificationDelegate
    private var goalService: GoalService
    var permissionStatus: UNAuthorizationStatus = .notDetermined
    
    var goals: [Goal] = []
    private var latestGoalsRefreshDate: Date = Date()
    var showEditing: Bool = false
    var deletionConfirmationVisible: Bool = false
    
    var showWarningBadge: Bool = false
    
    init(mainEngine: MainEngine = MainEngine.shared, notificationDelegate: NotificationDelegate = .shared, storageService: StorageService = PersistentStorage.shared) {
        self.mainEngine = mainEngine
        self.notificationDelegate = notificationDelegate
        self.storageService = storageService
        self.goalService = GoalService(modelContainer: storageService.modelContainer)
        fetchGoals()
    }

    init(previewOnly: Bool, storageService: StorageService = InMemoryStorage.shared) {
        self.mainEngine = MainEngine.shared
        self.notificationDelegate = NotificationDelegate.shared
        self.storageService = storageService
        self.goalService = GoalService(modelContainer: storageService.modelContainer)
        fetchGoals()
    }
    
    func checkPermissions() async {
        permissionStatus = await notificationDelegate.checkNotificationPermission()
        if permissionStatus == .denied && mainEngine.userWantsNotifications {
            showWarningBadge = true
        } else {
            showWarningBadge = false
        }
    }
    
    func fetchGoals() {
        self.goals = goalService.fetchGoals()
        self.latestGoalsRefreshDate = Date()
    }
    
    func refreshIfNecesary(){
        if !latestGoalsRefreshDate.isSameDay(as: Date()){
            fetchGoals()
        }
    }

    private func timeDiffFromGMT() -> Double {
        let timezone = TimeZone.current
        return Double(timezone.secondsFromGMT())
    }
    
    func addGoal(goal: Goal) {
        goalService.addGoal(goal: goal)
        fetchGoals()
    }
    
    func cancelChanges() {
        mainEngine.selectedGoal = nil
    }
    
    func saveGoal(goal: Goal) async {
        if let editedGoal = mainEngine.selectedGoal {
            update(goal: editedGoal, with: goal)
        } else {
            addGoal(goal: goal)
        }
        
        if await notificationDelegate.checkNotificationPermission() == .notDetermined {
            await mainEngine.requestNotificationPermission()
        }
        
        if mainEngine.selectedGoal == nil && !mainEngine.hasAddedFirstGoalTip {
            mainEngine.tipsMarkFirstGoalAdded()
        }
        mainEngine.selectedGoal = nil
    }
    
    func update(goal: Goal, with otherGoal: Goal) {
        goalService.updateGoal(goal, with: otherGoal)
        fetchGoals()
    }
    
    func deleteGoal(goal: Goal) {
        goalService.deleteGoal(goal)
        fetchGoals()
    }
    
    func updateAppBadge() {
        goalService.updateAppBadge(goals: goals)
    }
        
    func toggleTodaysStatus(goal: Goal) {
        if goal.done == false {
            goal.done = true
            goal.total += 1
            if isItStrike(goal: goal) {
                goal.strike += 1
            } else {
                goal.strike = 1
            }
        }else if goal.done == true{
            goal.done = false
            if goal.total > 0 {
                goal.total -= 1
                if goal.strike > 0 {
                    goal.strike -= 1
                }
                goal.strikeCheckDate = Date.now - 1.day
            }
        }
        fetchGoals()
    }
        
    func isItStrike(goal: Goal) -> Bool {
        var strike = true
        if let history = goal.history {
            let statuses = history.filter({$0.date > goal.strikeCheckDate}).sorted(by: {$0.date > $1.date})
            for status in statuses {
                switch status.scheduleCode {
                case .training:
                    if status.done == false {
                        strike = false
                    }
                case .freeDay:
                    continue
                }
            }
        }
        goal.strikeCheckDate = Date.now
        return strike
    }
    
    func followScenePhaseChange(scenePhase: ScenePhase) async {
        switch scenePhase {
        case .active:
            refreshIfNecesary()
            Task {
                await checkPermissions()
            }
        case .inactive:
            return
        case .background:
            updateAppBadge()
            if !goals.filter({ $0.done == false}).isEmpty {
                await BackgroundTaskManager.shared.scheduleGoalReminder()
            }
        @unknown default:
            break
        }
    }
    
    static func exampleGoal() -> [Goal] {
        let timezone = TimeZone.current
        let timeDiffFromGMT = Double(timezone.secondsFromGMT())
        let beginingOfToday = NSCalendar.current.startOfDay(for: Date()) + timeDiffFromGMT
        return [
            Goal(name: "Salsa",
                 goalMotivation: "5 min. of training every daily will make you muy bueno salsero.",
                 requiredTime: 5,
                 scheduleType: ScheduleType(type: .interval, interval: 1),
                 creationDate: Date(timeInterval: -20.day, since: Date.now),
                 history: [
                    Status(scheduleCode: .freeDay, done: false, date: Date(timeInterval: -1.day, since: beginingOfToday)),
                    Status(scheduleCode: .freeDay, done: false,  date: Date(timeInterval: -2.day, since: beginingOfToday)),
                    Status(scheduleCode: .training, done: true, date: Date(timeInterval: -3.day, since: beginingOfToday)),
                    Status(scheduleCode: .training, done: true, date: Date(timeInterval: -4.day, since: beginingOfToday))
                 ],
                 total: 2,
                 strike: 1,
                 strikeCheckDate: Date(timeInterval: -1.day, since: beginingOfToday),
                 schedule: ScheduleCode.training.rawValue,
                 date: Date(timeInterval: -1.day, since: beginingOfToday),
                 done: true),
            Goal(name: "Read - goal with long name to test.",
                 goalMotivation: "Read 10 pages every second day and you'll read.... a lot every year.",
                 requiredTime: nil,
                 scheduleType: ScheduleType(type: .interval, interval: 3),
                 reminderPreference: Reminder(hours: .twentyThree, minutes: .fiftyFive),
                 creationDate: Date(timeInterval: -20.day, since: Date.now),
                 history: [
                    Status(scheduleCode: .freeDay, done: false, date: Date(timeInterval: -1.day, since: beginingOfToday)),
                    Status(scheduleCode: .training, done: true, date: Date(timeInterval: -2.day, since: beginingOfToday)),
                    Status(scheduleCode: .training, done: true, date: Date(timeInterval: -3.day, since: beginingOfToday)),
                    Status(scheduleCode: .freeDay, done: false, date: Date(timeInterval: 0.day, since: beginingOfToday))
                ],
                 total: 5,
                 strike: 4,
                 strikeCheckDate: Date(timeInterval: -1.day, since: beginingOfToday),
                 schedule: ScheduleCode.training.rawValue,
                 date: Date(timeInterval: -1.day, since: beginingOfToday),
                 done: false),
            Goal(name: "Spanish",
                 goalMotivation: "",
                 requiredTime: 5,
                 scheduleType: ScheduleType(type: .weekly, weeklySchedule: [.tuesday, .thursday]),
                 creationDate: Date(timeInterval: -20.day, since: Date.now),
                 history: [
                    Status(scheduleCode: .training, done: true, date: Date(timeInterval: -1.day, since: beginingOfToday))
                 ],
                 total: 1,
                 strike: 1,
                 strikeCheckDate: Date(timeInterval: -1.day, since: beginingOfToday),
                 schedule: ScheduleCode.freeDay.rawValue,
                 date: Date(timeInterval: -1.day, since: beginingOfToday),
                 done: false),
            Goal(name: "Japanese",
                 goalMotivation: "10 min daily and soon you'll speak like Bruce Lee.",
                 requiredTime: 5,
                 scheduleType: ScheduleType(type: .weekly, weeklySchedule: [.monday, .wednesday, .friday]),
                 creationDate: Date(timeInterval: -20.day, since: Date.now),
                 history: [
                    Status(scheduleCode: .training, done: true, date: Date(timeInterval: 0.day, since: beginingOfToday))
                 ],
                 total: 2,
                 strike: 2,
                 strikeCheckDate: Date(timeInterval: -1.day, since: beginingOfToday),
                 schedule: ScheduleCode.training.rawValue,
                 date: Date(timeInterval: -1.day, since: beginingOfToday),
                 done: false)
        ]
    }
}
