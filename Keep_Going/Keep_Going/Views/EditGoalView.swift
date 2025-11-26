//
//  EditGoalView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 05/06/2025.
//

import SwiftUI

struct EditGoalView: View {
    
    enum FocusedField: Hashable {
        case name
        case description
    }
    
    let goal: Goal?
    private var windowTitle: String {
        goal == nil ? "New goal" : "Editing: \(goal!.name)"
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(MainEngine.self) private var mainEngine
    @Environment(GoalViewModel.self) private var goalViewModel
    
    @State private var showDatePicker = false
    @State private var tmpGoal = Goal(name: "", goalMotivation: "")
    @State private var scheduleType: ScheduleType = .interval
    @State private var weeklySchedule: [WeekDay] = []
    @State private var interval: Int = 1
    @State private var reminderTime: Reminder?
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(){
                    TextField("Goal name", text: $tmpGoal.name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .description
                        }
                    TextField("Your motivation", text: $tmpGoal.goalMotivation, axis: .vertical)
                        .submitLabel(.done)
                        .lineLimit(1...10)
                        .focused($focusedField, equals: .description)
                        .onChange(of: tmpGoal.goalMotivation) { oldValue, newValue in
                            if newValue.contains("\n") {
                                tmpGoal.goalMotivation = newValue.replacingOccurrences(of: "\n", with: " ")
                                focusedField = nil
                            }
                        }
                }
                Section {
                    HStack{
                        Text("Start date")
                            .font(.footnote)
                            .textCase(.uppercase)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(tmpGoal.goalStartDate.formatted(date: .numeric , time: .omitted))
                            .foregroundStyle(showDatePicker ? .red : .blue)
                            .onTapGesture(perform: {
                                withAnimation{
                                    showDatePicker.toggle()
                                }
                                focusedField = nil
                            })
                    }
                    .onTapGesture {
                        focusedField = nil
                    }
                    if showDatePicker {
                        DatePicker(
                                "Start Date",
                                selection: $tmpGoal.goalStartDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                    }
                }
                Section(content: {
                    HStack{
                        Picker("Schedule type", selection: $scheduleType) {
                            ForEach(ScheduleType.allCases) { frequency in
                                Text(frequency.rawValue)
                                    .tag(frequency)
                            }
                        }
                    }
                    .onTapGesture {
                        focusedField = nil
                    }
                }, footer: {
                    if scheduleType == .interval {
                        Text("Task will repeat every: \(interval) \(interval == 1 ? "day" : "days")")
                    } else if scheduleType == .weekly {
                        Text("Task will repeat every: \(footer())")
                    }
                })
                .onTapGesture {
                    focusedField = nil
                }
                Section() {
                    if scheduleType == .interval {
                        IntervalPicker(interval: $interval, onInteraction: {
                            focusedField = nil
                        })
                    } else if scheduleType == .weekly {
                        DaysPicker(schedule: $weeklySchedule, onInteraction: {
                            focusedField = nil
                        })
                    }
                }
                .onTapGesture {
                    focusedField = nil
                }
                Section() {
                    HStack{
                        Picker("Preferred reminder time", selection: $tmpGoal.reminderPreference) {
                            ForEach(Reminder.allCases) { time in
                                Text(time.rawValue)
                                    .tag(time)
                            }
                        }
                    }
                }
                .onTapGesture {
                    focusedField = nil
                }
                
                HStack{
                    Spacer()
                    Button {
                        if let goal {
                            mainEngine.selectedGoal = nil
                            goalViewModel.deleteGoal(goal: goal)
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
                        Task{
                            await save()
                            dismiss()
                            mainEngine.selectedGoal = nil
                        }
                    }
                    .disabled(tmpGoal.name == "" ? true : false)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Calcel") {
                        dismiss()
                        mainEngine.selectedGoal = nil
                    }
                }
            }
            .onAppear {
                if let goal {
                    goalViewModel.updateWith(goal: tmpGoal, with: goal)
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
    
    private func save() async {
        if let goal {
            if scheduleType == .interval {
                tmpGoal.interval = interval
                tmpGoal.weeklySchedule = nil
            } else if scheduleType == .weekly {
                tmpGoal.weeklySchedule = weeklySchedule
                tmpGoal.interval = nil
            }
            goalViewModel.updateWith(goal: goal, with: tmpGoal)
        }else {
            if scheduleType == .interval {
                tmpGoal.weeklySchedule = nil
                tmpGoal.interval = interval
            } else if scheduleType == .weekly {
                tmpGoal.interval = nil
                tmpGoal.weeklySchedule = weeklySchedule.sorted{$0.rawValue < $1.rawValue}
            }
            goalViewModel.whatDoWeHaveToday(goal: tmpGoal)
            goalViewModel.addGoal(goal: tmpGoal)
        }
        if !mainEngine.requestedNotificationPermission {
            await mainEngine.requestNotificationPermission()
        }
    }
}

#Preview("Edit Goal") {
    EditGoalView(goal: GoalViewModel.exampleGoal()[2])
        .environment(MainEngine())
        .environment(GoalViewModel())
}

#Preview("Add Goal") {
    EditGoalView(goal: nil)
        .environment(MainEngine())
        .environment(GoalViewModel())
}

