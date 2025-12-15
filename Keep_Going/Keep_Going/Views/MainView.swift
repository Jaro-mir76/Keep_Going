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
    @State private var viewModel: GoalViewModel?
    @State private var showEditing: Bool = false
    @State private var showSettings: Bool = false
    @State private var hasPermission = true
    @State private var isChecking = true
    
    private let addGoalTip = AddGoalTip()
    private let markAsDoneTip = MarkAsDoneTip()
    private let editGoalTip = EditGoalTip()
    
    let notificationDelegate = NotificationDelegate.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(viewModel?.goals ?? [], id: \.id) { goal in
                    GoalCardView(goal: goal)
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                mainEngine.selectedGoal = goal
                                mainEngine.userIsEditingGoal = true
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
            .background(content: {
                MyBackgroundView()
                    .ignoresSafeArea()
            })
            .scrollContentBackground(.hidden)
            .toolbar{
                toolBarAddGoalButton
                toolBarSettingsButton
            }
//            .background(Color.appBackground)
            .sheet(isPresented: $showEditing, onDismiss: {
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
                if viewModel?.goals.count == 0 {
                    addNewGoalMessage
                }
            })
            .onChange(of: scenePhase, { _, newValue in
                viewModel?.followScenePhaseChange(scenePhase: newValue)
            })
        }
        .environment(viewModel)
        .onAppear(perform: {
            viewModel = GoalViewModel(mainEngine: mainEngine)
        })
    }
    
    func addGoal() {
        showEditing = true
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
                        .foregroundStyle(Color.appAccentOrange)
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
            .badge( viewModel?.showWarningBadge ?? false ? "!" : nil )
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
                                .foregroundStyle(Color.appAccentOrange)
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
                .foregroundStyle(Color.background)
        })
    }
}

#Preview {
    @Previewable @State var viewModel = GoalViewModel(previewOnly: true)
    MainView()
        .environment(MainEngine())

}
