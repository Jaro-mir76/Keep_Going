//
//  ScheduleTests.swift
//  Keep_GoingTests
//
//  Created by Jaromir Jagieluk on 19/05/2025.
//
import Foundation
import Testing
@testable import Keep_Going

struct ScheduleTests {
    
//    static func beginingOfToday() -> Date {
//        let timezone = TimeZone.current
//        let timeDiffFromGMT = Double(timezone.secondsFromGMT())
//        return NSCalendar.current.startOfDay(for: Date()) + timeDiffFromGMT
//    }
//    
//
////    let beginingOfToday = NSCalendar.current.startOfDay(for: Date()) + timeDiffFromGMT
//    let exampleGoalInterval2 = Goal(name: "Salsa",
//                                    goalDescription: "5 min. of training every daily will make you muy bueno salsero.",
//                                    requiredTime: 5,
//                                    weeklySchedule: nil,
//                                    interval: 1,
//                                    startDate: Date(timeInterval: -20.day, since: beginingOfToday()),
//                                    history: [
//                                       Status(statusCode: .done, date: Date(timeInterval: -1.day, since: beginingOfToday())),
//                                       Status(statusCode: .done, date: Date(timeInterval: 0.day, since: beginingOfToday()))
//                                    ],
//                                    total: 1,
//                                    inRow: 1)

    @Test("Next traing date for privided interval 2 -> true", arguments: [
        Date(timeIntervalSinceNow: -2.day),
        Date(timeIntervalSinceNow: -4.day),
        Date()
    ])
    func nextTrainingDate4IntervalTrue(date: Date) {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let goal2daysInterval = Goal(name: "exampleGoalInterval2Days", goalDescription: "example goal", interval: 2, startDate: date)
        print ("startDate: \(date)")
        #expect(goal2daysInterval.isItTrainingDayInterval() == true)
    }
    
    @Test("Next traing date for privided interval 2 -> false", arguments: [
        Date(timeIntervalSinceNow: -1.day),
        Date(timeIntervalSinceNow: -3.day),
        Date(timeIntervalSinceNow: -15.day)
    ])
    func nextTrainingDate4IntervalFalse(date: Date) {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let schedule2daysIntervalVer = Goal(name: "exampleGoalInterval2Days", goalDescription: "", interval: 2, startDate: date)
        #expect(schedule2daysIntervalVer.isItTrainingDayInterval() == false)
    }
    
    @Test("Training schedule is sorted from Monday to Sunday")
    func trainingScheduleIsSorted() {
        let goalSchedule = Goal(name: "goalSchedule", goalDescription: "", weeklySchedule: [])
        let newGoalParameters = Goal(name: "goalSchedule", goalDescription: "", weeklySchedule: [.sunday, .monday, .friday])
        goalSchedule.updateWith(newGoalParameters)
        #expect(goalSchedule.weeklySchedule == [.monday, .friday, .sunday])
    }
    
    @Test("Next training dates for provided schedule [.monday] answer is not empty") func nextTrainingDateforSchedule() {
//        Aim of this test is to ensure that we get dates even if in current week the is not more trainings according to pattern
        let pattern: [WeekDay] = [.monday]
        let goalSchedule = Goal(name: "goalSchedule", goalDescription: "", weeklySchedule: pattern)
        
        let timezone = TimeZone.current
        let timeDifffromGMT = Double(timezone.secondsFromGMT())
        
        let previousWeek = NSCalendar.current.startOfDay(for: Date()) + timeDifffromGMT - 7.day
        
        #expect(goalSchedule.trainingDaysSchedule(forWeek: previousWeek).first != nil)
    }
    
    @Test("Training dates based on interval")
    func nextTrainingDatesForInterval() {
        let goal2daysInterval = Goal(name: "goalInterval2Days", goalDescription: "", interval: 2, startDate: Date())
        #expect(goal2daysInterval.trainingDaysInterval() != [])
        #expect(goal2daysInterval.trainingDaysInterval().count == 18)
    }
    
    @Test("Goal history save", .disabled("to be implemented"))
    func goalHistorySaved() {
//        before saving there should be no status
        
//        after saving there should be status

//        #error("to be implemented")
    }
    
    @Test("Goal history update", .disabled("to be implemented"))
    func goalHistoryUpdate() {
//        before update there should be 1 record in history, after update there should be still 1 redord but with new status
//#error("to be implemented")
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
