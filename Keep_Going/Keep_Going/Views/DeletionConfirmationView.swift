//
//  DeletionConfirmationView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 12.12.2025.
//

import SwiftUI

struct DeletionConfirmationView: View {
    @Environment(GoalViewModel.self) private var viewModel
    @Environment(MainEngine.self) private var mainEngine
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var goal: Goal
    
    var body: some View {
        VStack {
            Text("Do you really want to delete \(goal.name)?")
                .font(.title3)
            MyEqualWidthHstack {
                Button(action: {
                    viewModel.deletionConfirmationVisible = false
                    viewModel.showEditing = false
                    mainEngine.selectedGoal = nil
                    viewModel.deleteGoal(goal: goal)
                }, label: {
                    Text("Delete")
                        .frame(maxWidth: .infinity)
                        .padding(5)
                        .padding(.horizontal, 10)
                })
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .padding(.horizontal, 10)
                Button(action: {
                    viewModel.deletionConfirmationVisible = false
                }, label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                })
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 10)
            }
            .padding(10)
        }
    }
}

#Preview {
    @Previewable @State var mainEngine: MainEngine = {
        let engine = MainEngine()
        engine.selectedGoal = GoalViewModel.exampleGoal()[0]
        return engine
    }()
    DeletionConfirmationView(goal: GoalViewModel.exampleGoal()[0])
        .environment(GoalViewModel(mainEngine: mainEngine))
        .environment(mainEngine)
}
