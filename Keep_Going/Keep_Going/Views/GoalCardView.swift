//
//  GoalCardView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 04/06/2025.
//

import SwiftUI

struct GoalCardView: View {
    @Bindable var goal: Goal
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text(goal.name)
                HStack {
                    Text("Total: \(goal.total)")
                    if goal.inRow > 0 {
                        Text("Strike: \(goal.inRow)")
                    }
                }
            }
            Spacer()
            switch goal.goalStatus {
            case .done:
                Label("Todays status", systemImage: "checkmark.seal")
                    .labelStyle(.iconOnly)
                    .font(.title)
                    .frame(width: 60)
            case .freeDay:
                Label("Todays status", systemImage: "sun.max")
                    .labelStyle(.iconOnly)
                    .font(.title)
                    .frame(width: 60)
            case .scheduledNotDone:
                Label("Todays status", systemImage: "seal")
                    .labelStyle(.iconOnly)
                    .font(.title)
                    .frame(width: 60)
            case .none:
                Label("Todays status", systemImage: "sun.max")
                    .labelStyle(.iconOnly)
                    .font(.title)
                    .frame(width: 60)
            }
        }
    }
}

#Preview("Goal") {
    GoalCardView(goal: Goal.exampleGoal()[0])
}

#Preview("Goals") {
    GoalCardView(goal: Goal.exampleGoal()[0])
    GoalCardView(goal: Goal.exampleGoal()[1])
    GoalCardView(goal: Goal.exampleGoal()[3])
}
