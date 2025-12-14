//
//  MyBackgroundView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 14.12.2025.
//

import SwiftUI

struct MyBackgroundView: View {
    var color: Color = .blue
    @State private var backgroundGenerator = BackgroundGenerator()
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(backgroundGenerator.entries.indices, id:\.self) { index in
                    let entry = backgroundGenerator.entries[index]
                    entry.symbol
                        .opacity(0.2)                        .scaleEffect(entry.selected ? 4 : 1)
                        .position(x: proxy.size.width * entry.x, y: proxy.size.height * entry.y)
//                        .onTapGesture {
//                            withAnimation {
//                                backgroundGenerator.entries[index].selected.toggle()
//                            }
//                        }
//                        .accessibilityAction {
//                            backgroundGenerator.entries[index].selected.toggle()
//                        }
                }
            }
        }
        .font(.system(size: 24))
        .contentShape(Rectangle())
//        .onTapGesture {
//            withAnimation(.easeInOut(duration: 2)) {
//                backgroundGenerator.reposition()
//            }
//        }
//        .accessibilityAction(named: "Reposition") {
//            backgroundGenerator.reposition()
//        }
        .drawingGroup()
    }
}

#Preview {
    MyBackgroundView()
}
