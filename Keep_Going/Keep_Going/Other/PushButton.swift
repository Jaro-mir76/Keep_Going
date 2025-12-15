//
//  PushButton.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 14.10.2025.
//

import SwiftUI

enum PushButtonEnum {
    case next, done, skip
    
    var label: String {
        switch self {
        case .next: return "Next"
        case .done: return "Done"
        case .skip: return "Skip"
        }
    }
    
    var icon: String {
        switch self {
        case .next: return "chevron.right"
        case .done: return "checkmark"
        case .skip: return "chevron.right.2"
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
        .buttonStyle(.borderless)
        .buttonBorderShape(.roundedRectangle)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(content: {
            RoundedRectangle(cornerRadius: 25, style: .circular)
                .foregroundStyle(Color.background)
                .opacity(0.8)
        })
    }
}

#Preview {
    PushButton(function: .next, execute: {})
}
