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
            VStack{
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
                TextField(text: $goal.goalDescription, axis: .vertical, label: {})
                    .lineLimit(descriptionLimit)
                    .font(.footnote)
                    .disabled(true)
            }
            .onTapGesture {
                descriptionLimit = (descriptionLimit == 1 ? 5 : 1)
            }
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
