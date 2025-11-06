//
//  ContentView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 15/05/2025.
//

import SwiftUI
import SwiftData
import BackgroundTasks

struct MainView: View {
    @Environment(MainEngine.self) private var mainEngine
    @Environment(GoalViewModel.self) private var goalViewModel
    @State private var showEditing: Bool = false
    @State private var showSettings: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(goalViewModel.goals, id: \.id) { goal in
                    GoalCardView(goal: goal)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                withAnimation {
                                    goalViewModel.toggleTodaysStatus(goal: goal)
                                }
                            } label: {
                                Label(goal.done == true ? "Done" : "Not done", systemImage: goal.done == true ? "seal.fill" : "checkmark.seal.fill")
                                    .labelStyle(.iconOnly)
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                mainEngine.selectedGoal = goal
                                showEditing = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                        .tint(.green)
                }
            }
            .onChange(of: scenePhase, { _, newValue in
                switch newValue {
                    case .active:
                        goalViewModel.refreshIfNecesary()
                    case .inactive:
                        return
                    case .background:
                        BackgroundTaskManager.shared.scheduleGoalReminder()
                    @unknown default:
                    break
                }
            })
            .background(Gradient(colors: gradientColors))
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "plus") {
                        addGoal()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    }label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .background(Gradient(colors: gradientColors))
            .sheet(isPresented: $showEditing) {
                EditGoalView(goal: mainEngine.selectedGoal)
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    
    func addGoal() {
        showEditing = true
    }
}

#Preview {
    MainView()
        .environment(MainEngine())
        .environment(GoalViewModel())
}
