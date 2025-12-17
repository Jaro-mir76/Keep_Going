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
//                for goal in GoalViewModel.exampleGoal() {
//                    container.mainContext.insert(goal)
//                }
//                container.mainContext.insert(GoalViewModel.exampleGoal()[0])
                try container.mainContext.save()
            }
//            Task { @MainActor in
//                print ("goals in memory: \(try container.mainContext.fetchCount(FetchDescriptor<Goal>()))")
//            }
            return container
        } catch {
            fatalError("Could not create model container in memory either, error: \(error)")
        }
    }()
}
