//
//  MyBackgroundView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 14.12.2025.
//

import SwiftUI

struct MyBackgroundView: View {
    @Environment(MainEngine.self) private var mainEngine
    @State private var backgroundGenerator = BackgroundGenerator()
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(backgroundGenerator.entries.indices, id:\.self) { index in
                    let entry = backgroundGenerator.entries[index]
                    entry.symbol
                        .opacity(0.1)
                        .position(x: proxy.size.width * entry.x, y: proxy.size.height * entry.y)
                }
            }
            .onChange(of: mainEngine.repositionBackground) { oldValue, newValue in
                if newValue {
                    withAnimation(.easeInOut(duration: 2)) {
                        backgroundGenerator.reposition()
                    }
                    mainEngine.repositionBackground.toggle()
                }
            }
        }
        .font(.system(size: 24))
        .contentShape(Rectangle())
        .drawingGroup()
        .background(Color.appBackground)
    }
}

#Preview {
    MyBackgroundView()
        .environment(MainEngine())
}
