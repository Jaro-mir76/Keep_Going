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
                        RoundedRectangle(cornerRadius: 30, style: .circular)
                            .frame(width: 45, height: 45)
                            .foregroundStyle(Color.appTaskCompleted)
                        Label("Todays status", systemImage: "checkmark.seal")
                            .labelStyle(.iconOnly)
                            .font(.title)
                            .foregroundStyle(Color.appTaskCompletedCheck)
                            .symbolEffect(.bounce.up.byLayer, options: .nonRepeating, value: animateCheckmark)
                            .task {
                                animateCheckmark = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    animateCheckmark = false
                                }
                            }
                        //                        .frame(width: 60)
                    }

                case (false, ScheduleCode.training.rawValue):
                    ZStack {
                        RoundedRectangle(cornerRadius: 30, style: .circular)
                            .frame(width: 45, height: 45)
                            .foregroundStyle(Color.appTaskActive)
                        Label("Todays status", systemImage: "seal")
                            .labelStyle(.iconOnly)
                            .font(.title)
                    }
                    .popoverTip(markAsDoneTip, arrowEdge: .trailing)
                case (false, _):
                    ZStack {
                        RoundedRectangle(cornerRadius: 30, style: .circular)
                            .frame(width: 45, height: 45)
                            .foregroundStyle(Color.appTaskInactive)
                        Label("Todays status", systemImage: "sun.max")
                            .labelStyle(.iconOnly)
                            .font(.title)
                    }
                    .popoverTip(markAsDoneTip, arrowEdge: .trailing)
                }
                
            }
        }
        .scaleEffect(isPressed ? 1.05 : 1)
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
}

#Preview("Goal") {
    var mainEngine = MainEngine()
    List {
        GoalCardView(goal: GoalViewModel.exampleGoal()[0])
            .environment(GoalViewModel(mainEngine: mainEngine))

    }
}

#Preview("Goals") {
    var mainEngine = MainEngine()
    List {
        GoalCardView(goal: GoalViewModel.exampleGoal()[0])
            .environment(GoalViewModel(mainEngine: mainEngine))
        GoalCardView(goal: GoalViewModel.exampleGoal()[1])
            .environment(GoalViewModel(mainEngine: mainEngine))
        GoalCardView(goal: GoalViewModel.exampleGoal()[2])
            .environment(GoalViewModel(mainEngine: mainEngine))
    }
    
}
