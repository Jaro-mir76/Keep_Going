//
//  EditGoalView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 05/06/2025.
//

import SwiftUI
import TipKit

struct EditGoalView: View {
    
    enum FocusedField: Hashable {
        case name
        case description
    }
    
//    let goal: Goal?
    private var windowTitle: String {
        mainEngine.selectedGoal == nil ? "New goal" : "Editing: \(mainEngine.selectedGoal!.name)"
    }
    
    private let goalNameTip = GoalNameTip()
    private let goalMotivationTip = GoalMotivationTip()
    private let scheduleTypeTip = ScheduleTypeTip()
    private let reminderTimeTip = ReminderTimeTip()
    private let firstGoalCompleteTip = FirstGoalSavedTip()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(MainEngine.self) private var mainEngine
    @Environment(GoalViewModel.self) private var viewModel
    
    @State private var showDatePicker = false
    @State private var tmpGoal = Goal(name: "", goalMotivation: "", scheduleType: ScheduleType(type: .interval, interval: 1))
    @State private var reminderTime: Reminder?
    let notificationDelegate = NotificationDelegate.shared
    
    @FocusState private var focusedField: FocusedField?
    @State private var shouldShowReminderTip = false
    @Namespace private var reminderSection

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                
                Form {
                    Section(){
                        TextField("Goal name", text: $tmpGoal.name)
                            .popoverTip(goalNameTip)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .description
                                if !tmpGoal.name.isEmpty && !mainEngine.hasEnteredGoalName {
                                    mainEngine.tipsMarkGoalNameEntered()
                                }
                            }
                        TextField("Your motivation", text: $tmpGoal.goalMotivation, axis: .vertical)
                            .popoverTip(goalMotivationTip)
                            .submitLabel(.done)
                            .lineLimit(1...10)
                            .focused($focusedField, equals: .description)
                            .onChange(of: tmpGoal.goalMotivation) { oldValue, newValue in
                                if newValue.contains("\n") {
                                    tmpGoal.goalMotivation = newValue.replacingOccurrences(of: "\n", with: "")
                                    focusedField = nil
                                    if !mainEngine.hasEnteredMotivation {
                                        mainEngine.tipsMarkMotivationEntered()
                                    }
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
                            Picker("Schedule type", selection: $tmpGoal.scheduleType.type) {
                                ForEach(ScheduleType.ScheduleTypes.allCases) { frequency in
                                    Text(frequency.rawValue)
                                        .tag(frequency)
                                }
                            }
                            .onChange(of: tmpGoal.scheduleType.type) { _, _ in
                                if !mainEngine.hasSelectedSchedule {
                                    mainEngine.tipsMarkScheduleSelected()
                                }
                            }
                        }
                        .popoverTip(scheduleTypeTip)
                        .onTapGesture {
                            focusedField = nil
                        }
                    }, footer: {
                        Text(footer())
                    })
                    .onTapGesture {
                        focusedField = nil
                    }
                    Section() {
                        if tmpGoal.scheduleType.type == .interval {
                            IntervalPicker(interval: $tmpGoal.scheduleType.interval, onInteraction: {
                                focusedField = nil
                            })
                        } else if tmpGoal.scheduleType.type == .weekly {
                            DaysPicker(schedule: $tmpGoal.scheduleType.weeklySchedule, onInteraction: {
                                focusedField = nil
                            })
                        }
                    }
                    .onChange(of: tmpGoal.scheduleType.type) { _, _ in
                        if !mainEngine.hasSelectedSchedule {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    proxy.scrollTo(reminderSection, anchor: .top)
                                    shouldShowReminderTip = true
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        focusedField = nil
                    }
                    Section() {
                        ReminderTimePickerView(goal: $tmpGoal)
                            .id(reminderSection)
                            .popoverTip(shouldShowReminderTip ? reminderTimeTip : nil)
                            .onChange(of: tmpGoal.reminderPreference.hours) { _, _ in
                                if !mainEngine.hasSetReminder {
                                    mainEngine.tipsMarkReminderSet()
                                }
                            }
                            .onChange(of: tmpGoal.reminderPreference.minutes) { _, _ in
                                if !mainEngine.hasSetReminder {
                                    mainEngine.tipsMarkReminderSet()
                                }
                            }
                    }
                    .onTapGesture {
                        focusedField = nil
                    }
                    
                    HStack{
                        Spacer()
                        Button {
                            if let goal = mainEngine.selectedGoal {
                                mainEngine.selectedGoal = nil
                                viewModel.deleteGoal(goal: goal)
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
                .scrollDismissesKeyboard(.immediately)
                .toolbar{
                    ToolbarItem(placement: .principal) {
                        Text(windowTitle)
                    }
                    toolBarSaveButton
                    toolBarCancelButton
                }
                .onAppear {
                    if let goal = mainEngine.selectedGoal {
                        viewModel.update(goal: tmpGoal, with: goal)
                    }
                }
            }
        }
    }
    private func footer() -> String {
        var str: String = ""
        var counter: Int = 0

        if tmpGoal.scheduleType.type == .interval {
            str = "Task will repeat every: \(tmpGoal.scheduleType.interval) \(tmpGoal.scheduleType.interval == 1 ? "day" : "days")"
        } else if tmpGoal.scheduleType.type == .weekly {
            str = "Task will repeat every: "
            for day in WeekDay.allCases {
                if tmpGoal.scheduleType.weeklySchedule.contains(day) {
                    str.append(day.name)
                    counter += 1
                    if counter < tmpGoal.scheduleType.weeklySchedule.count {
                        str.append(", ")
                    }
                }
            }
        }
        return str
    }
    
    private func save() async {
        await viewModel.saveGoal(goal: tmpGoal)
        dismiss()
    }
    
    @ToolbarContentBuilder
    private var toolBarSaveButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                Task{
                    await save()
                }
            }
            .disabled(tmpGoal.name == "" ? true : false)
            .popoverTip(firstGoalCompleteTip)
        }
    }
    
    @ToolbarContentBuilder
    private var toolBarCancelButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
                viewModel.cancelChanges()
                
            }
        }
    }
}

#Preview("Edit Goal") {
    @Previewable @State var mainEngine: MainEngine = {
        let engine = MainEngine()
        engine.selectedGoal = GoalViewModel.exampleGoal()[1]
        return engine
    }()
    EditGoalView()
        .environment(MainEngine())
        .environment(GoalViewModel(mainEngine: mainEngine))
}

#Preview("Add Goal") {
    var mainEngine = MainEngine()
    EditGoalView()
        .environment(MainEngine())
        .environment(GoalViewModel(mainEngine: mainEngine))
}
