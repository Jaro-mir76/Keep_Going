//
//  ScheduleTests.swift
//  Keep_GoingTests
//
//  Created by Jaromir Jagieluk on 19/05/2025.
//
import Foundation
import Testing
@testable import Keep_Going

@MainActor
struct ScheduleTests {
    
    private var goalViewModel = GoalViewModel()
    private var mainEngine = MainEngine()

    @Test("Next traing date for privided interval 2 -> true", arguments: [
        Date(timeIntervalSinceNow: -2.day),
        Date(timeIntervalSinceNow: -4.day),
        Date()
    ])
    func nextTrainingDate4IntervalTrue(date: Date) {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let goal2daysInterval = Goal(name: "exampleGoalInterval2Days", goalDescription: "example goal", interval: 2, creationDate: date)

        #expect(goalViewModel.isItTrainingDayInterval(goal: goal2daysInterval) == true)
    }
    
    @Test("Next traing date for privided interval 2 -> false", arguments: [
        Date(timeIntervalSinceNow: -1.day),
        Date(timeIntervalSinceNow: -3.day),
        Date(timeIntervalSinceNow: -15.day)
    ])
    func nextTrainingDate4IntervalFalse(date: Date)  {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let schedule2daysIntervalVer = Goal(name: "exampleGoalInterval2Days", goalDescription: "",goalStartDate: date, interval: 2, creationDate: date)
        
        #expect( goalViewModel.isItTrainingDayInterval(goal: schedule2daysIntervalVer) == false)
    }
    
    @Test("Training schedule is sorted from Monday to Sunday")
    func trainingScheduleIsSorted() {
        let goalSchedule = Goal(name: "goalSchedule", goalDescription: "", weeklySchedule: [])
        let newGoalParameters = Goal(name: "goalSchedule", goalDescription: "", weeklySchedule: [.sunday, .monday, .friday])
        goalViewModel.updateWith(goal: goalSchedule, with: newGoalParameters)

        #expect(goalSchedule.weeklySchedule == [.monday, .friday, .sunday])
    }
    
    @Test("Next training dates for provided schedule [.monday] answer is not empty") func nextTrainingDateforSchedule() {
//        Aim of this test is to ensure that we get dates even if in current week the is not more trainings according to pattern
        let pattern: [WeekDay] = [.monday]
        let goalSchedule = Goal(name: "goalSchedule", goalDescription: "", weeklySchedule: pattern)
        
        let timezone = TimeZone.current
        let timeDifffromGMT = Double(timezone.secondsFromGMT())
        
        let previousWeek = NSCalendar.current.startOfDay(for: Date()) + timeDifffromGMT - 7.day
        
        #expect(goalViewModel.trainingDaysSchedule(goal: goalSchedule, startingFrom: previousWeek).first != nil)
    }
    
    @Test("Training dates based on interval")
    func nextTrainingDatesForInterval() {
        let goal2daysInterval = Goal(name: "goalInterval2Days", goalDescription: "", interval: 2, creationDate: Date())
        
        #expect(goalViewModel.trainingDaysInterval(goal: goal2daysInterval) != [])
        #expect(goalViewModel.trainingDaysInterval(goal: goal2daysInterval).count == 16)
    }
    
    @Test("Goal history save")
    func goalHistorySaved() {
//        before saving there should be no status
        let goalHistorySaveTest = Goal(name: "goalHistorySaveTest", goalDescription: "", interval: 2, creationDate: Date(), schedule: ScheduleCode.training.rawValue)
        #expect(goalHistorySaveTest.history?.count == 0)
        
//        after saving there should be status
        goalViewModel.saveStatus(goal: goalHistorySaveTest)
        
        #expect(goalHistorySaveTest.history?.count == 1)
    }
    
    @Test("Training days base od schedule")
    func goalTrainingDaysScheduleTrue() {
        var goalStartDateComponents = DateComponents()
        goalStartDateComponents.year = 2025
        goalStartDateComponents.month = 11
        goalStartDateComponents.day = 5
        goalStartDateComponents.hour = 15
        goalStartDateComponents.minute = 30
        goalStartDateComponents.timeZone = .current
        let goalStartDate = Calendar.current.date(from: goalStartDateComponents)!
        let goalSchedule = Goal(name: "goalScheduleTest", goalDescription: "", goalStartDate: goalStartDate, weeklySchedule: [.tuesday, .friday, .sunday], schedule: nil)
        let trainingDays = goalViewModel.trainingDaysSchedule(goal: goalSchedule, startingFrom: goalStartDate)
        
        #expect(trainingDays.count == 5)
    }
    
    @Test("Save goal to file", .disabled("to be implemented"))
    func saveGoalToFile() async throws {
//        after saving to file there should be file
//#error("to be implemented")
    }
    
    @Test("Read goal from file", .disabled("to be implemented"))
    func readGoalFromFile() async throws {
//        1. create goal with some history
//        2. save to file
//        3. remove goal
//        4. read from file -> there should be goal with the same history
//        #error("to be implemented")
    }
}
