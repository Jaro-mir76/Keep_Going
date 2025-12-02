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
    
    private var mainEngine = MainEngine()
    private lazy var goalViewModel = GoalViewModel(mainEngine: mainEngine)


    @Test("Next traing date for privided interval 2 -> true", arguments: [
        Date(timeIntervalSinceNow: -2.day),
        Date(timeIntervalSinceNow: -4.day),
        Date()
    ])
    mutating func nextTrainingDate4IntervalTrue(date: Date) {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let goal2daysInterval = Goal(name: "exampleGoalInterval2Days", goalMotivation: "example goal", interval: 2, creationDate: date)

        #expect(goalViewModel.isItTrainingDayInterval(goal: goal2daysInterval) == true)
    }
    
    @Test("Next traing date for privided interval 2 -> false", arguments: [
        Date(timeIntervalSinceNow: -1.day),
        Date(timeIntervalSinceNow: -3.day),
        Date(timeIntervalSinceNow: -15.day)
    ])
    mutating func nextTrainingDate4IntervalFalse(date: Date)  {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let schedule2daysIntervalVer = Goal(name: "exampleGoalInterval2Days", goalMotivation: "", goalStartDate: date, interval: 2, creationDate: date)
        
        #expect( goalViewModel.isItTrainingDayInterval(goal: schedule2daysIntervalVer) == false)
    }
    
    @Test("Training schedule is sorted from Monday to Sunday")
    mutating func trainingScheduleIsSorted() {
        let goalSchedule = Goal(name: "goalSchedule", goalMotivation: "", weeklySchedule: [])
        let newGoalParameters = Goal(name: "goalSchedule", goalMotivation: "", weeklySchedule: [.sunday, .monday, .friday])
        goalViewModel.updateWith(goal: goalSchedule, with: newGoalParameters)

        #expect(goalSchedule.weeklySchedule == [.monday, .friday, .sunday])
    }
    
    @Test("Next training dates for provided schedule [.monday] answer is not empty") mutating func nextTrainingDateforSchedule() {
//        Aim of this test is to ensure that we get dates even if in current week the is not more trainings according to pattern
        let pattern: [WeekDay] = [.monday]
        let goalSchedule = Goal(name: "goalSchedule", goalMotivation: "", weeklySchedule: pattern)
        
        let timezone = TimeZone.current
        let timeDifffromGMT = Double(timezone.secondsFromGMT())
        
        let previousWeek = NSCalendar.current.startOfDay(for: Date()) + timeDifffromGMT - 77.day
        
        #expect(goalViewModel.trainingDaysSchedule(goal: goalSchedule, startingFrom: previousWeek).first == nil)
    }
       
    @Test("Goal history save")
    mutating func goalHistorySaved() {
        //        before saving there should be no status
        let goalHistorySaveTest = Goal(name: "goalHistorySaveTest", goalMotivation: "", interval: 2, creationDate: Date(), schedule: ScheduleCode.training.rawValue, done: false)
        #expect(goalHistorySaveTest.history?.count == 0)
        
        //        after saving there should be status
        goalViewModel.saveStatus(goal: goalHistorySaveTest)
        
        #expect(goalHistorySaveTest.history?.count == 1)
        #expect(goalHistorySaveTest.history?.first?.scheduleCode.rawValue == ScheduleCode.training.rawValue)
        #expect(goalHistorySaveTest.history?.first?.done == false)
        
        // in case the same date old save should be replaced
        goalHistorySaveTest.done = true
        goalViewModel.saveStatus(goal: goalHistorySaveTest)
        #expect(goalHistorySaveTest.history?.first?.done == true)
        
        let yesterday = Calendar.current.startOfDay(for: Date(timeInterval: Double(-1).day, since: Date()))
        
        goalHistorySaveTest.done = false
        goalHistorySaveTest.date = yesterday
        goalViewModel.saveStatus(goal: goalHistorySaveTest)
        #expect(goalHistorySaveTest.history?.count == 2)
        #expect(goalHistorySaveTest.history?.first(where: {$0.date == yesterday})?.done == false)
        
        goalHistorySaveTest.done = true
        goalHistorySaveTest.date = yesterday
        goalViewModel.saveStatus(goal: goalHistorySaveTest)
        #expect(goalHistorySaveTest.history?.count == 2)
        #expect(goalHistorySaveTest.history?.first(where: {$0.date == yesterday})?.done == true)
    }
    
    @Test("Training days base on schedule")
    mutating func goalTrainingDaysScheduleTrue() {
        var goalStartDateComponents = DateComponents()
        goalStartDateComponents.year = 2025
        goalStartDateComponents.month = 11
        goalStartDateComponents.day = 5
        goalStartDateComponents.hour = 15
        goalStartDateComponents.minute = 30
        goalStartDateComponents.timeZone = .current
        let goalStartDate = Calendar.current.date(from: goalStartDateComponents)!
        let goalSchedule = Goal(name: "goalScheduleTest", goalMotivation: "", goalStartDate: goalStartDate, weeklySchedule: [.tuesday, .friday, .sunday], schedule: nil)
        let trainingDays = goalViewModel.trainingDaysSchedule(goal: goalSchedule, startingFrom: goalStartDate)
        
        #expect(trainingDays.count == 5)
    }
    
    @Test("Training day base on schedule")
    mutating func goalTrainingDayScheduleTrue() {
        var goalStartDateComponents = DateComponents()
        goalStartDateComponents.year = 2025
        goalStartDateComponents.month = 11
        goalStartDateComponents.day = 5
        goalStartDateComponents.hour = 15
        goalStartDateComponents.minute = 30
        goalStartDateComponents.timeZone = .current
        let goalStartDate = Calendar.current.date(from: goalStartDateComponents)!
        let goalSchedule = Goal(name: "goalScheduleTest", goalMotivation: "", goalStartDate: goalStartDate, weeklySchedule: [.tuesday, .friday, .sunday], schedule: nil)
        
//  checking if logic works correctly for old goals
        var testDateComponents = DateComponents()
        testDateComponents.year = 2025
        testDateComponents.month = 12
        testDateComponents.day = 23
        testDateComponents.hour = 15
        testDateComponents.minute = 30
        testDateComponents.timeZone = .current
        let testDate = Calendar.current.date(from: testDateComponents)!
        let beginningOfTestDate = Calendar.current.startOfDay(for: testDate)
        
        #expect(goalViewModel.trainingDaysSchedule(goal: goalSchedule, startingFrom: beginningOfTestDate).first == beginningOfTestDate)

//  checking if logic works correctly for goals planed in a future
        var testDate2Components = DateComponents()
        testDate2Components.year = 2025
        testDate2Components.month = 10
        testDate2Components.day = 1
        testDate2Components.hour = 15
        testDate2Components.minute = 30
        testDate2Components.timeZone = .current
        let testDate2 = Calendar.current.date(from: testDate2Components)!
        let beginningOfTestDate2 = Calendar.current.startOfDay(for: testDate2)
        
//  answer should be nil because function should not return any date if goal start date is more than 2 weeks in a future
        #expect(goalViewModel.trainingDaysSchedule(goal: goalSchedule, startingFrom: beginningOfTestDate2).first == nil)
    }
    
    @Test("Training day base on interval")
    mutating func goalTrainingDayIntervalTrue() {
        var goalStartDateComponents = DateComponents()
        goalStartDateComponents.year = 2025
        goalStartDateComponents.month = 11
        goalStartDateComponents.day = 5
        goalStartDateComponents.hour = 15
        goalStartDateComponents.minute = 30
        goalStartDateComponents.timeZone = .current
        let goalStartDate = Calendar.current.date(from: goalStartDateComponents)!
        let schedule2daysInterval = Goal(name: "exampleGoalInterval2Days", goalMotivation: "", goalStartDate: goalStartDate, interval: 2, creationDate: goalStartDate)
        
//  checking if logic works correctly for old goals
        var testDateComponents = DateComponents()
        testDateComponents.year = 2025
        testDateComponents.month = 12
        testDateComponents.day = 23
        testDateComponents.hour = 15
        testDateComponents.minute = 30
        testDateComponents.timeZone = .current
        let testDate = Calendar.current.date(from: testDateComponents)!
        let beginningOfTestDate = Calendar.current.startOfDay(for: testDate)
        
        print ("goal start date \(goalStartDate) \(schedule2daysInterval.goalStartDate)")
        print ("test date \(beginningOfTestDate) ")
        #expect(goalViewModel.isItTrainingDayInterval(goal: schedule2daysInterval, startingFrom: beginningOfTestDate) == true)

//  checking if logic works correctly for goals planed in a future
        var testDate2Components = DateComponents()
        testDate2Components.year = 2025
        testDate2Components.month = 10
        testDate2Components.day = 1
        testDate2Components.hour = 15
        testDate2Components.minute = 30
        testDate2Components.timeZone = .current
        let testDate2 = Calendar.current.date(from: testDate2Components)!
        let beginningOfTestDate2 = Calendar.current.startOfDay(for: testDate2)
        
//  answer should be false because date of checking is before goal start date
        #expect(goalViewModel.isItTrainingDayInterval(goal: schedule2daysInterval, startingFrom: beginningOfTestDate2) == false)
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
