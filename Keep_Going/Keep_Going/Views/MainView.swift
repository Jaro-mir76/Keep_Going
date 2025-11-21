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
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
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
                                    .labelStyle(.iconOnly)
                            }
                        }
                        .tint(.green)
                        .listRowBackground(Color.appTaskActive)
                        .listRowSeparatorTint(Color.appBorder)
                }
            }
            .scrollContentBackground(.hidden)
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
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        addGoal()
                    }, label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 45, style: .circular)
                                .frame(width: 36, height: 36)
                                .foregroundStyle(Color.appAccentOrange)
                            Image(systemName: "plus")
                                .backgroundStyle(.black)
                        }
                    })
                    .buttonStyle(.plain)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    }label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .background(Color.appBackground)
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
        .environment(GoalViewModel(previewOnly: true))
}
