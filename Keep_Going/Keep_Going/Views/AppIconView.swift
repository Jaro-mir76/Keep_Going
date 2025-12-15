//
//  AppIconView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 31.10.2025.
//

import SwiftUI

struct AppIconView: View {
    @Environment(\.colorScheme) private var systemColorScheme
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .circular)
                    .frame(width: 170, height: 170)
                    .foregroundStyle(Color.appAccentOrange)
                    .shadow(color: .black, radius: 5, x: 5, y: 5)
                    .opacity(0.9)
                
                Image(systemName: "figure.stairs")
                    .font(.system(size: 100))
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 5, x: 1, y: 1)
            }
            Spacer()
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(content: {
            MyBackgroundView()
                .ignoresSafeArea()
        })
//        .background(Color.appBackground)
    }
}

#Preview {
    AppIconView()
}
