//
//  NavigationManager.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 16.06.2025.
//

import Foundation

@Observable
class NavigationManager {
    var selectedGoal: Goal?
    var welcomeTab: Int = 1
    var welcomePageSeen: Bool = false
    
    init(selectedGoal: Goal? = nil) {
        self.selectedGoal = selectedGoal
    }
}
