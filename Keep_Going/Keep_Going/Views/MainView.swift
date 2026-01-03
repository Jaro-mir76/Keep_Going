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
    @Environment(GoalViewModel.self) private var viewModel
    @State private var showSettings: Bool = false
    @State private var hasPermission = true
    @State private var isChecking = true
    
    private let addGoalTip = AddGoalTip()
    private let markAsDoneTip = MarkAsDoneTip()
    private let editGoalTip = EditGoalTip()
    
    let notificationDelegate = NotificationDelegate.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack{
            List {
                ForEach(viewModel.goals, id: \.id) { goal in
                    GoalCardView(goal: goal)
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                mainEngine.selectedGoal = goal
                                mainEngine.userIsEditingGoal = true
                                viewModel.showEditing = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                                    .labelStyle(.iconOnly)
                            }
                        }
                        .tint(.green)
                        .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .padding(.horizontal, 10)
            .background(content: {
                MyBackgroundView()
                    .ignoresSafeArea()
            })
            .toolbar{
                toolBarAddGoalButton
                toolBarSettingsButton
            }
            .sheet(isPresented: $viewModel.showEditing, onDismiss: {
                if mainEngine.userIsEditingGoal == true && !mainEngine.hasEditedGoalTip {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        mainEngine.tipsMarkGoalEdited()
                    }
                }
                mainEngine.userIsEditingGoal = false
            }, content: {
                EditGoalView()
            })
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .overlay(content: {
                if viewModel.goals.count == 0 {
                    addNewGoalMessage
                }
            })
            .onChange(of: scenePhase, { _, newValue in
                Task {
                    await viewModel.followScenePhaseChange(scenePhase: newValue)
                }
            })
            .refreshable {
                mainEngine.repositionBackground.toggle()
                viewModel.fetchGoals()
            }
        }
    }
    
    func addGoal() {
        viewModel.showEditing = true
    }
    
    @ToolbarContentBuilder
    private var toolBarAddGoalButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                addGoal()
            }, label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 45, style: .circular)
                        .frame(width: 36, height: 36)
                        .foregroundStyle(Color.buttonAccent)
                    Image(systemName: "plus")
                        .backgroundStyle(.black)
                }
            })
            .buttonStyle(.plain)
            .popoverTip(addGoalTip)
        }
    }
    
    @ToolbarContentBuilder
    private var toolBarSettingsButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showSettings = true
            }label: {
                Image(systemName: "gear")
            }
            .badge( viewModel.showWarningBadge ? "!" : nil )
        }
    }
    
    private var addNewGoalMessage: some View {
        VStack(spacing: 20) {
            Text("You don't have any goals yet.")
                .font(.title2)
                .multilineTextAlignment(.center)
            HStack {
                Text("Tap the")
                    .font(.title2)
                Image(systemName: "plus")
                    .background {
                        ZStack{
                            Circle()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(Color.buttonAccent)
                        }
                    }
                    .padding(5)
                Text("button to add one!")
                    .font(.title2)
            }
        }
        .padding(25)
        .background(content: {
            RoundedRectangle(cornerRadius: 25, style: .circular)
                .foregroundStyle(Color.buttonAccentText)
                .opacity(0.8)
        })
    }
}

#Preview {
    @Previewable @State var viewModel = GoalViewModel(previewOnly: true)
//    viewModel.addGoal(goal: GoalViewModel.exampleGoal()[1])
    viewModel.fetchGoals()
    
    return MainView()
        .environment(viewModel)
        .environment(MainEngine())
}

#Preview("No goals") {
    @Previewable @State var viewModel = {
        var viewModel = GoalViewModel(previewOnly: true)
        viewModel.goals.removeAll()
        return viewModel
    }()
    
    return MainView()
        .environment(viewModel)
        .environment(MainEngine())
}
