//
//  ReminderTimePickerView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 04.12.2025.
//

import SwiftUI

struct ReminderTimePickerView: View {
    @State private var showTimeWheel = false
    @Binding var goal: Goal
    
    var body: some View {
        HStack {
            Text("Preferred reminder time")
                .font(.footnote)
                .textCase(.uppercase)
                .foregroundColor(.gray)
            Spacer()
            Text ("\(goal.reminderPreference.hours.rawValue < 10 ? "0": "")\(goal.reminderPreference.hours.rawValue):\(goal.reminderPreference.minutes.rawValue < 10 ? "0": "" )\(goal.reminderPreference.minutes.rawValue)")
                .foregroundStyle(showTimeWheel ? .red : .black)
                .onTapGesture {
                    withAnimation{
                        showTimeWheel.toggle()
                    }
                }
        }
        if showTimeWheel {
            HStack{
                Picker("Time Wheel Hours", selection: $goal.reminderPreference.hours) {
                    ForEach(Reminder.Hours.allCases) { taskDuration in
                        HStack(){
                            Spacer()
                            Text("\(taskDuration.rawValue < 10 ? "0": "")\(taskDuration.rawValue)")
                                .frame(maxWidth: 40)
                                .tag(taskDuration)
                        }
                    }
                }
                .pickerStyle(.wheel)
                Picker("Time Wheel Minutes", selection: $goal.reminderPreference.minutes) {
                    ForEach(Reminder.Minutes.allCases) { taskDuration in
                        HStack(){
                            Text("\(taskDuration.rawValue < 10 ? "0": "")\(taskDuration.rawValue)")
                                .frame(maxWidth: 40)
                                .tag(taskDuration)
                            Spacer()
                        }
                    }
                }
                .pickerStyle(.wheel)
            }
        }
    }
}

#Preview {
    var mainEngine = MainEngine()
    ReminderTimePickerView(goal: .constant(GoalViewModel.exampleGoal()[1]))
}
