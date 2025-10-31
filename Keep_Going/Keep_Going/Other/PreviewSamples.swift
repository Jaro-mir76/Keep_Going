//
//  PreviewSamples.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 03/06/2025.
//

import Foundation
import SwiftData

struct PreviewSamples {
    
    static func makePreviewContext() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let modelContainer = try ModelContainer(for: Goal.self, Status.self, configurations: config)
        Task { @MainActor in
            modelContainer.mainContext.insert(GoalViewModel.exampleGoal()[0])
            modelContainer.mainContext.insert(GoalViewModel.exampleGoal()[1])
            modelContainer.mainContext.insert(GoalViewModel.exampleGoal()[2])
            modelContainer.mainContext.insert(GoalViewModel.exampleGoal()[3])
        }
        return modelContainer
    }
}
