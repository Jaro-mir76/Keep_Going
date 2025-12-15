//
//  NotificationSettingsView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 27.11.2025.
//

import SwiftUI

struct NotificationSettingsView: View {
    @Environment(MainEngine.self) private var mainEngine
    @Environment(\.scenePhase) private var scenePhase
    @Environment(SettingsViewModel.self) private var viewModel
        
    var body: some View {
        @Bindable var viewModel = viewModel
        Toggle("Notifications", isOn: $viewModel.userWantsNotifications)
        HStack {
            Text("Status:")
            Spacer()
            Text(statusText)
        }
        .onAppear(perform: {
            Task {
                await viewModel.checkPermissions()
            }
        })
        .onChange(of: viewModel.userWantsNotifications) {
            Task { await viewModel.checkPermissions() }
        }
        .onChange(of: scenePhase, { oldValue, newValue in
            if newValue == .active {
                Task {
                    await viewModel.checkPermissions()
                }
            }
        })
        .alert("No permission for notifications", isPresented: $viewModel.showPermissionAlert) {
            Button("Open settings") {
                viewModel.notificationDelegate.openAppSettings()
            }
            Button("Cancel", role: .cancel) {
                viewModel.userWantsNotifications = false
            }
        } message: {
            Text("Turn on notifications in iOS Settings, so you can receive notifcations about your goals.")
        }
    }
    
    private var statusText: String {
        viewModel.isLoading ? "Checking..." : viewModel.detailedSettings?.statusDescription ?? "Checking..."
    }
}

#Preview {
    var mainEngine = MainEngine()
    NotificationSettingsView()
        .environment(MainEngine())
        .environment(SettingsViewModel())
}
