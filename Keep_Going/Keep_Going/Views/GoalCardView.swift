//
//  GoalCardView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 04/06/2025.
//

import SwiftUI

struct GoalCardView: View {
    @Bindable var goal: Goal
    @State private var descriptionLimit: Int = 1
    
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                HStack(alignment: .bottom) {
                    Text(goal.name)
                        .font(.title2)
                    Spacer()
                    if goal.strike > 1 {
                        Text("Strike:")
                            .font(.caption)
                        Text(goal.strike.description)
                            .font(.callout)
                    }
                    Text("Total:")
                        .font(.caption)
                    Text(goal.total.description)
                        .font(.callout)
                }
                Text(goal.goalDescription)
                    .font(.footnote)
                    .lineLimit(descriptionLimit)
            }
            .onTapGesture {
                descriptionLimit = (descriptionLimit == 1 ? 5 : 1)
            }
            if goal.done == true {
                Label("Todays status", systemImage: "checkmark.seal")
                    .labelStyle(.iconOnly)
                    .font(.title)
                    .frame(width: 60)
            } else if goal.schedule == ScheduleCode.training.rawValue {
                Label("Todays status", systemImage: "seal")
                    .labelStyle(.iconOnly)
                    .font(.title)
                    .frame(width: 60)
            } else if goal.schedule == ScheduleCode.freeDay.rawValue {
                Label("Todays status", systemImage: "sun.max")
                    .labelStyle(.iconOnly)
                    .font(.title)
                    .frame(width: 60)
            }
        }
    }
}

#Preview("Goal") {
    GoalCardView(goal: GoalViewModel.exampleGoal()[0])
}

#Preview("Goals") {
    GoalCardView(goal: GoalViewModel.exampleGoal()[0])
    GoalCardView(goal: GoalViewModel.exampleGoal()[1])
    GoalCardView(goal: GoalViewModel.exampleGoal()[3])
}
