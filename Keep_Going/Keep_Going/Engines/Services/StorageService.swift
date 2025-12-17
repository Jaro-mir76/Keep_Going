//
//  StorageService.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 17.12.2025.
//

import Foundation
import SwiftData

protocol StorageService {
    static var shared: StorageService { get }
    var modelContainer: ModelContainer { get }
}
