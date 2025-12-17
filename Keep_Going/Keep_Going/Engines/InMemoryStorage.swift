//
//  InMemoryStorage.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 17.12.2025.
//

import Foundation
import SwiftData

class InMemoryStorage: ObservableObject, StorageService {
    static let shared: StorageService = InMemoryStorage()
    
    var modelContainer: ModelContainer = {
        let configurationMemory = ModelConfiguration(isStoredInMemoryOnly: true)
        var container: ModelContainer
        do {
            container = try ModelContainer(for: Goal.self, Status.self, configurations: configurationMemory)
            Task { @MainActor in
                for goal in GoalViewModel.exampleGoal() {
                    container.mainContext.insert(goal)
                }
                try container.mainContext.save()
            }
            return container
        } catch {
            fatalError("Could not create model container in memory either, error: \(error)")
        }
    }()
}
