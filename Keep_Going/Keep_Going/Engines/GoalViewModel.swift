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
    var permissionStatus: UNAuthorizationStatus = .notDetermined
    
    var goals: [Goal] = []
    private var latestGoalsRefreshDate: Date = Date()
    var deletionConfirmationVisible: Bool = false
    
    var showWarningBadge: Bool = false
    
    init(mainEngine: MainEngine = MainEngine.shared, notificationDelegate: NotificationDelegate = .shared, storageService: StorageService = PersistentStorage.shared) {
        self.mainEngine = mainEngine
        self.notificationDelegate = notificationDelegate
        self.storageService = storageService
        fetchGoals()
    }
    
    init(previewOnly: Bool, storageService: StorageService = InMemoryStorage.shared) {
        self.mainEngine = MainEngine.shared
        self.notificationDelegate = NotificationDelegate.shared
        self.storageService = storageService
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
        LoggingEngine.shared.appendLog("\(Date()) > func -> fetchGoals <")
        let requestAllGoals = FetchDescriptor<Goal>(predicate: nil, sortBy: [.init(\.done, order: .forward), .init(\.schedule, order: .forward), .init(\.name, order: .forward)])
        do {
            self.goals = try modelContainer.mainContext.fetch(requestAllGoals)
        } catch {
            print ("Could not fetch goals, error: \(error)")
        }
        for goal in goals {
            if !Calendar.current.isDateInToday(goal.date) {
                saveStatus(goal: goal)
//              if at that moment (it is already new day) goal is not done then strike is lost
                if goal.schedule == ScheduleCode.training.rawValue, goal.done == false {
                    goal.strike = 0
                    goal.strikeCheckDate = Date()
                }
                whatDoWeHaveToday(goal: goal)
            }
        }
//  I fetch goals again because at that moment - goals status have been updated - and they are not sorted in desired way, and I think sort of this level is the most efficient
        do {
            self.goals = try modelContainer.mainContext.fetch(requestAllGoals)
        } catch {
            print ("Could not fetch goals, error: \(error)")
        }
        self.latestGoalsRefreshDate = Date()
    }
    
    func refreshIfNecesary(){
        LoggingEngine.shared.appendLog("\(Date()) > func -> refreshIfNecesary <")
        if !latestGoalsRefreshDate.isSameDay(as: Date()){
            fetchGoals()
            LoggingEngine.shared.appendLog("\(Date()) > func - refreshIfNecesary -> fetchGoals <")
        }
    }
    
    private func beginningOfDay(_ date: Date = Date()) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    private func timeDiffFromGMT() -> Double {
        let timezone = TimeZone.current
        return Double(timezone.secondsFromGMT())
    }
    
    func addGoal(goal: Goal) {
        modelContainer.mainContext.insert(goal)
        whatDoWeHaveToday(goal: goal)
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
    
    func update (goal: Goal, with otherGoal: Goal) {
        goal.name = otherGoal.name
        goal.goalMotivation = otherGoal.goalMotivation
        goal.goalStartDate = otherGoal.goalStartDate
        goal.requiredTime = otherGoal.requiredTime
        goal.scheduleType.type = otherGoal.scheduleType.type
        goal.scheduleType.interval = otherGoal.scheduleType.interval
        goal.scheduleType.weeklySchedule = otherGoal.scheduleType.weeklySchedule.sorted(by: { $0.rawValue < $1.rawValue })
        goal.reminderPreference.hours = otherGoal.reminderPreference.hours
        goal.reminderPreference.minutes = otherGoal.reminderPreference.minutes
        
        whatDoWeHaveToday(goal: goal)
        if otherGoal.done == true {
            goal.date = otherGoal.date
            goal.done = otherGoal.done
        }
        self.fetchGoals()
    }
    
    func deleteGoal(goal: Goal) {
        modelContainer.mainContext.delete(goal)
        fetchGoals()
    }
    
    func updateAppBadge() {
        let overdueGoals = goals.filter { $0.done == false && $0.schedule == ScheduleCode.training.rawValue && $0.reminderPreference.time.isItInPast }
        notificationDelegate.notificationService.updateAppBadge(goals: overdueGoals)
    }
    
// function returning dates of trainings for remaing part of the week
    func trainingDaysSchedule(goal: Goal, startingFrom: Date? = Date()) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let scheduleStartDate = beginningOfDay(startingFrom!)
        let componentsForFirstDayOfWeek = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: scheduleStartDate)
        let firstDayOfWeek = calendar.date(from: componentsForFirstDayOfWeek)!
        var trainingDays: [Date] = []
        
        for futureWeek in [0, 7]{
            for i in goal.scheduleType.weeklySchedule{
                let trainingDate = Date(timeInterval: Double(i.rawValue).day, since: firstDayOfWeek + Double(futureWeek).day)
                if trainingDate.isLaterDay(than: goal.goalStartDate) && trainingDate.isLaterDay(than: scheduleStartDate) || trainingDate.isSameDay(as: scheduleStartDate){
                    trainingDays.append(trainingDate)
                }
            }
        }
        return trainingDays
    }
        
    //    function is setting goal status to default value base on interval/schedule
    func whatDoWeHaveToday(goal: Goal) {
        if goal.scheduleType.type == .interval {
            if isItTrainingDayInterval(goal: goal) {
                goal.schedule = ScheduleCode.training.rawValue
            }else {
                goal.schedule = ScheduleCode.freeDay.rawValue
            }
        }else {
            if isItTrainingDaySchedule(goal: goal) {
                goal.schedule = ScheduleCode.training.rawValue
            }else {
                goal.schedule = ScheduleCode.freeDay.rawValue
            }
        }
        goal.done = false
        goal.date = Calendar.current.startOfDay(for: Date.now)
    }
        
    func saveStatus(goal: Goal) {
        let goalStatus = Status(scheduleCode: ScheduleCode(rawValue: goal.schedule!)!, done: goal.done, date: Calendar.current.startOfDay(for: goal.date))
        let goalDateStart = Calendar.current.startOfDay(for: goal.date)
        if let firstFromSameDayIndex = goal.history?.firstIndex(where: { $0.date == goalDateStart
        }) {
            goal.history?.remove(at: firstFromSameDayIndex)
        }
        goal.history?.append(goalStatus)
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
        
// function returning true if today is training day (based on interval)
    func isItTrainingDayInterval(goal: Goal, startingFrom: Date = Date.now) -> Bool {
        guard (startingFrom.isLaterDay(than: goal.goalStartDate) || startingFrom.isSameDay(as: goal.goalStartDate)) else {return false}
        let hoursFromCreationDate = Calendar.current.dateComponents([.hour], from: goal.goalStartDate, to: beginningOfDay(startingFrom)).hour ?? 0
        
//       checking reminder, if it's 23 (it means there was time change Winter > Summer and we have to increase result by 1
        
        var (daysFromCreationDate, reminder) = hoursFromCreationDate.quotientAndRemainder(dividingBy: 24)
        if reminder == 23 {
            daysFromCreationDate += 1
        }
        let (reminderInterval, _) = daysFromCreationDate.remainderReportingOverflow(dividingBy: goal.scheduleType.interval)
        if reminderInterval == 0 {
            return true
        }
        return false
    }
        
// function returning true if today is training day (based on schedule)
    func isItTrainingDaySchedule(goal: Goal) -> Bool {
        var scheduleStartDate: Date
        if Date().isLaterDay(than: goal.goalStartDate) {
            scheduleStartDate = beginningOfDay(Date())
        } else {
            scheduleStartDate = beginningOfDay(goal.goalStartDate)
        }
        if trainingDaysSchedule(goal: goal, startingFrom: scheduleStartDate).first == scheduleStartDate {
            return true
        }
        return false
    }
    
    func followScenePhaseChange(scenePhase: ScenePhase) {
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
            BackgroundTaskManager.shared.scheduleGoalReminder()
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
