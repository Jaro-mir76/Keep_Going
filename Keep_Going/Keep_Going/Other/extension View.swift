//
//  extension View.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 20.11.2025.
//

import Foundation
import SwiftUI

extension View {
    func bounceOnTap() -> some View {
        self.modifier(BounceModifier())
    }
}

struct BounceModifier: ViewModifier {
    @State private var pressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(pressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.4), value: pressed)
            .onTapGesture {
                pressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    pressed = false
                }
            }
    }
}
