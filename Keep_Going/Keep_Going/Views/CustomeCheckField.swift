//
//  CustomeCheckField.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 16/05/2025.
//

import SwiftUI

struct CustomeCheckField: View {
    var value: Bool
    var body: some View {
        ZStack {
            Label("", systemImage: "circle")
                .labelStyle(.iconOnly)
                .offset(x: -2, y: 2)
            if value {
                Label("Marked", systemImage: "checkmark")
                    .labelStyle(.iconOnly)
                    .font(.title)
            }
        }
        .frame(width: 20, height: 20, alignment: .center)
    }
}

#Preview {
    CustomeCheckField(value: true)
}
#Preview {
    CustomeCheckField(value: false)
}
