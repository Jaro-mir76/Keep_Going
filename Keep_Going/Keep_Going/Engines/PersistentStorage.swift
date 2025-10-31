//
//  PersistentStorage.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 21.10.2025.
//

import Foundation
import SwiftData

class PersistentStorage: ObservableObject {
    static let shared = PersistentStorage()
    
    lazy var modelContainer: ModelContainer = {
        let configurationDisk = ModelConfiguration(isStoredInMemoryOnly: false)
        var container: ModelContainer
        do {
            container = try ModelContainer(for: Goal.self, Status.self, configurations: configurationDisk)
            return container
        } catch {
            print("Could not create Model container on disk, error: \(error)")
            print("Trying to create model container in memory.")
            let configurationMemory = ModelConfiguration(isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: Goal.self, Status.self, configurations: configurationMemory)
            }catch {
                fatalError("Could not create model container in memory either, error: \(error)")
            }
        }
    }()
}
