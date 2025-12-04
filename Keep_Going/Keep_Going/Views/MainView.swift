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
                    .badge( viewModel?.showWarningBadge ?? false ? "!" : nil )
                }
            }
            .background(Color.appBackground)
            .sheet(isPresented: $showEditing) {
                EditGoalView(goal: mainEngine.selectedGoal)
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .onChange(of: scenePhase, { _, newValue in
                switch newValue {
                case .active:
                    viewModel?.refreshIfNecesary()
                    Task {
                        await viewModel?.checkPermissions()
                    }
                case .inactive:
                    return
                case .background:
                    viewModel?.updateAppBadge()
                    BackgroundTaskManager.shared.scheduleGoalReminder()
                @unknown default:
                    break
                }
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
}

#Preview {
    @Previewable @State var viewModel = GoalViewModel(previewOnly: true)
    MainView()
        .environment(MainEngine())

}
