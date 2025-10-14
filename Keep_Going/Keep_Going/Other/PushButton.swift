//
//  PushButton.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 14.10.2025.
//

import SwiftUI

enum PushButtonEnum {
    case next, done
    
    var label: String {
        switch self {
        case .next: return "Next"
        case .done: return "Done"
        }
    }
    
    var icon: String {
        switch self {
        case .next: return "chevron.right"
        case .done: return "checkmark"
        }
    }
}

struct PushButton: View {
    var function: PushButtonEnum
    var execute: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                execute()
            }
            
        } label: {
            Label(function.label, systemImage: function.icon)
                .labelStyle(.titleOnly)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle)
    }
}

#Preview {
    PushButton(function: .next, execute: {})
}
