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
    
    init(selectedGoal: Goal? = nil) {
        self.selectedGoal = selectedGoal
    }
}
