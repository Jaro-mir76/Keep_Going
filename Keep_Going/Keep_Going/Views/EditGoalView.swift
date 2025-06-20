//
//  EditGoalView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 05/06/2025.
//

import SwiftUI

struct EditGoalView: View {
    let goal: Goal?
    private var windowTitle: String {
        goal == nil ? "New goal" : "Editing: \(goal!.name)"
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationManager.self) private var navigationManager
    
    @State private var tmpGoal = Goal(name: "", goalDescription: "")
    @State private var scheduleType: Frequency = .interval
    @State private var weeklySchedule: [WeekDay] = []
    @State private var interval: Int = 1
    
    var body: some View {
        NavigationStack {
            Form {
                Section(){
                    TextField("Goal name", text: $tmpGoal.name)
                    TextField("Goal description", text: $tmpGoal.goalDescription, axis: .vertical)
                        .lineLimit(1...10)
                }
                Section(content: {
                    HStack{
                        Picker("Frequency", selection: $scheduleType) {
                            ForEach(Frequency.allCases) { frequency in
                                Text(frequency.rawValue)
                                    .tag(frequency)
                            }
                        }
                    }
                }, footer: {
                    if scheduleType == .interval {
                        Text("Task will repeat every: \(interval) \(interval == 1 ? "day" : "days")")
                    } else if scheduleType == .weekly {
                        Text("Task will repeat every: \(footer())")
                    }
                })
                Section() {
                    if scheduleType == .interval {
                        IntervalPicker(interval: $interval)
                    } else if scheduleType == .weekly {
                        DaysPicker(schedule: $weeklySchedule)
                    }
                }
                if let history = goal?.history {
                    Section {
                        List{
                            ForEach(history.sorted(by: {$0.date > $1.date}), id: \.date) { status in
                                Text("date: \(status.date) status: \(status.statusCode)")
                            }
                            if let goal = goal, goal.isItStrike() {
                                Text("So far this is strike so keep going! 😎")
                            }
                        }
                    } header: {
                        Text("History")
                    }
                }
                HStack{
                    Spacer()
                    Button {
                        if let goal {
                            navigationManager.selectedGoal = nil
                            modelContext.delete(goal)
                            dismiss()
                        } else {
                            dismiss()
                        }
                    } label: {
                        Label("Delete goal", systemImage: "x.circle")
                            .labelStyle(.titleOnly)
                            .tint(.red)
                    }
                    Spacer()
                }
            }
            .toolbar{
                ToolbarItem(placement: .principal) {
                    Text(windowTitle)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                        navigationManager.selectedGoal = nil
                    }
                    .disabled(tmpGoal.name == "" ? true : false)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Calcel") {
                        dismiss()
                        navigationManager.selectedGoal = nil
                    }
                }
            }
            .onAppear {
                if let goal {
                    tmpGoal.name = goal.name
                    tmpGoal.goalDescription = goal.goalDescription
                    tmpGoal.requiredTime = goal.requiredTime
                    tmpGoal.todaysDate = goal.todaysDate
                    tmpGoal.todaysStatus = goal.todaysStatus
                    if goal.interval != nil {
                        interval = goal.interval!
                        scheduleType = .interval
                    }else if goal.weeklySchedule != nil {
                        scheduleType = .weekly
                        weeklySchedule = goal.weeklySchedule!
                    }
                }
            }
        }
    }
    private func footer() -> String {
        var str: String = ""
        var counter: Int = 0
        for day in WeekDay.allCases {
            if weeklySchedule.contains(day) {
                str.append(day.name)
                counter += 1
                if counter < weeklySchedule.count {
                    str.append(", ")
                }
            }
        }
        return str
    }
    private func save() {
        if let goal {
            if scheduleType == .interval {
                tmpGoal.interval = interval
                tmpGoal.weeklySchedule = nil
            } else if scheduleType == .weekly {
                tmpGoal.weeklySchedule = weeklySchedule
                tmpGoal.interval = nil
            }
            goal.updateWith(tmpGoal)
        }else {
//            it is to ensure that only correct schedule/interval is there and the other is nil
            if scheduleType == .interval {
                tmpGoal.weeklySchedule = nil
                tmpGoal.interval = interval
            } else if scheduleType == .weekly {
                tmpGoal.interval = nil
                tmpGoal.weeklySchedule = weeklySchedule.sorted{$0.rawValue < $1.rawValue}
            }
            tmpGoal.whatDoWeHaveToday()
            modelContext.insert(tmpGoal)
        }
    }
}

#Preview("Edit Goal") {
    EditGoalView(goal: Goal.exampleGoal()[2])
        .environment(NavigationManager())
}

#Preview("Add Goal") {
    EditGoalView(goal: nil)
        .environment(NavigationManager())
}
