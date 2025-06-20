//
//  ContentView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 15/05/2025.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var context
    @Environment(NavigationManager.self) private var navigationManager
    @Query(sort: [SortDescriptor(\Goal.todaysStatus), SortDescriptor(\Goal.todaysDate, order: .reverse)]) private var goals: [Goal]
    @State private var showEditing: Bool = false
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(goals, id: \.id) { goal in
                    GoalCardView(goal: goal)
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                withAnimation {
                                    goal.toggleTodaysStatus()
                                }
                            } label: {
                                Label(goal.todaysStatus == StatusCode.done.rawValue ? "Done" : "Not done", systemImage: goal.todaysStatus == StatusCode.done.rawValue ?  "seal.fill" : "checkmark.seal.fill")
                                    .labelStyle(.iconOnly)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                navigationManager.selectedGoal = goal
                                showEditing = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                        .tint(.green)
                }
            }
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "plus") {
                        //                        showEditing = true
                        var tmpGoal = Goal.exampleGoal()[0]
//                        context.append(Goal.exampleGoal()[0])
                        print ("tmpGoal addes \(tmpGoal)")
                        context.insert(tmpGoal)
                        context.insert(Goal.exampleGoal()[1])
                    }
                }
            }
            .sheet(isPresented: $showEditing) {
                EditGoalView(goal: navigationManager.selectedGoal)
            }
        }
    }
}

#Preview {
    MainView()
        .modelContainer(try! PreviewSamples.makePreviewContext())
        .environment(NavigationManager())
}
