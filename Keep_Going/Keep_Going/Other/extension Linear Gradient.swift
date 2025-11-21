//
//  extension Linear Gradient.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 20.11.2025.
//

import Foundation
import SwiftUI

extension LinearGradient {

    static var primary: LinearGradient {
        LinearGradient(
            colors: [
                Color("GradientPrimaryStart"),
                Color("GradientPrimaryEnd")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var warm: LinearGradient {
        LinearGradient(
            colors: [
                Color("GradientWarmStart"),
                Color("GradientWarmEnd")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var cool: LinearGradient {
        LinearGradient(
            colors: [
                Color("GradientCoolStart"),
                Color("GradientCoolEnd")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
