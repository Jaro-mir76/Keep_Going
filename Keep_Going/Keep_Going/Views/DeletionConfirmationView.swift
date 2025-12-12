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
        VStack{
            Text("Are you sure you want to delete \(goal.name)?")
            .font(.title3)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                
            Text("Deleting \(goal.name) will remove it permanently!")
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Divider()
            MyEqualWidthHstack {
                Spacer()
                Button("Delete") {
                    viewModel.deletionConfirmationVisible = false
                    mainEngine.selectedGoal = nil
                    viewModel.deleteGoal(goal: goal)
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                Spacer()
                Button("Cancel") {
                    viewModel.deletionConfirmationVisible = false
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding(.top, 7)
        }
        .frame(minHeight: 110)
        .padding(15)
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
}
