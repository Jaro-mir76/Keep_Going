//
//  GoalCardView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 04/06/2025.
//

import SwiftUI

struct GoalCardView: View {
    @Environment(GoalViewModel.self) private var viewModel
    @Bindable var goal: Goal
    @State private var descriptionLimit: Int = 1
    @State private var animateCheckmark: Bool = false
    @State private var isPressed: Bool = false
    
    private var backgroundColor: Color {
        switch (goal.schedule, goal.reminderPreference.time.isItInPast) {
        case (ScheduleCode.training.rawValue, false):
            return Color.taskActiveBackground
        case (ScheduleCode.training.rawValue, true):
            return Color.taskOverdueBackground
        case (ScheduleCode.freeDay.rawValue, _):
            return Color.taskInactiveBackground
        case (_, _):
            return Color.gray
        }
    }
    private var borderColor: Color {
        switch (goal.schedule, goal.reminderPreference.time.isItInPast) {
        case (ScheduleCode.training.rawValue, false):
            return Color.taskActiveBorder.opacity(0.4)
        case (ScheduleCode.training.rawValue, true):
            return Color.taskOverdueBorder.opacity(0.4)
        case (ScheduleCode.freeDay.rawValue, _):
            return Color.taskInactiveBorder.opacity(0.7)
        case (_, _):
            return Color.gray
        }
    }
    private var foregraundColor: Color {
        switch (goal.schedule, goal.reminderPreference.time.isItInPast) {
        case (ScheduleCode.training.rawValue, false):
            return Color.taskActiveForeground
        case (ScheduleCode.training.rawValue, true):
            return Color.taskOverdueForeground
        case (ScheduleCode.freeDay.rawValue, _):
            return Color.taskInactiveForeground
        case (_, _):
            return Color.gray
        }
    }
    
    private let markAsDoneTip = MarkAsDoneTip()
    private let editGoalTip = EditGoalTip()
    
    var body: some View {
        HStack {
            VStack{}
            .popoverTip(editGoalTip, arrowEdge: .leading)
            VStack(alignment: .leading){
                HStack(alignment: .center) {
                    Text(goal.name)
                        .font(.title2)
                    Spacer()
                    VStack(alignment: .trailing) {
                        if goal.strike > 1 {
                            HStack {
                                Text("Strike:")
                                    .font(.caption)
                                Text(goal.strike.description)
                                    .font(.callout)
                            }
                        }
                        HStack {
                            Text("Total:")
                                .font(.caption)
                            Text(goal.total.description)
                                .font(.callout)
                        }
                    }
                }
                
                if goal.goalMotivation != "" {
                    Text(goal.goalMotivation)
                        .font(.footnote)
                        .lineLimit(descriptionLimit)
                }
            }
            .onTapGesture {
                descriptionLimit = (descriptionLimit == 1 ? 5 : 1)
            }
            HStack {
                switch (goal.done, goal.schedule) {
                case (true, _):
                    ZStack {
                        statusIcon(label: "Todays status", systemImage: "checkmark.seal")
                            .foregroundStyle(Color.statusDone)
                            .symbolEffect(.bounce.up.byLayer, options: .nonRepeating, value: animateCheckmark)
                            .task {
                                animateCheckmark = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    animateCheckmark = false
                                }
                            }
                    }
                case (false, ScheduleCode.training.rawValue):
                    ZStack {
                        statusIcon(label: "Todays status", systemImage: "seal")
                            .foregroundStyle(goal.reminderPreference.time.isItInPast ? Color.statusOverdue : Color.statusNotDone)
                    }
                    .popoverTip(markAsDoneTip, arrowEdge: .trailing)
                case (false, _):
                    ZStack {
                        statusIcon(label: "Todays status", systemImage: "sun.max")
                            .foregroundStyle(Color.statusNotToday)
                    }
                    .popoverTip(markAsDoneTip, arrowEdge: .trailing)
                }
            }
            .scaleEffect(isPressed ? 1.3 : 1)
        }
        .padding(10)
        .background(content: {
            ZStack {
                UnevenRoundedRectangle(cornerRadii: .init(topLeading: 30, bottomLeading: 30, bottomTrailing: 30, topTrailing: 30))
                    .stroke(borderColor, lineWidth: 2)
                    .fill(backgroundColor)
                    .opacity(0.8)
                    
            }
            .padding(2)
        })
        .onLongPressGesture(minimumDuration: 0.7) {
            withAnimation {
                viewModel.toggleTodaysStatus(goal: goal)
                viewModel.mainEngine.tipsMarkMarkGoalDone()
            }
            #if os(iOS)
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            #endif
        } onPressingChanged: { active in
            active == true ? withAnimation { isPressed.toggle() } :
            withAnimation { isPressed.toggle() }
        }
    }
    
    private func statusIcon(label: String, systemImage: String) -> some View {
        ZStack {
            Circle()
                .frame(width: 45, height: 45)
                .foregroundStyle(Color.appBackground)
            Label(label, systemImage: systemImage)
                .labelStyle(.iconOnly)
                .font(.title)
        }
    }
}

#Preview("Goal") {
    var mainEngine = MainEngine()
    GoalCardView(goal: GoalViewModel.exampleGoal()[0])
        .environment(GoalViewModel(mainEngine: mainEngine))
}

#Preview("Goals") {
    var mainEngine = MainEngine()
        GoalCardView(goal: GoalViewModel.exampleGoal()[0])
            .environment(GoalViewModel(mainEngine: mainEngine))
        GoalCardView(goal: GoalViewModel.exampleGoal()[1])
            .environment(GoalViewModel(mainEngine: mainEngine))
        GoalCardView(goal: GoalViewModel.exampleGoal()[2])
            .environment(GoalViewModel(mainEngine: mainEngine))
}

