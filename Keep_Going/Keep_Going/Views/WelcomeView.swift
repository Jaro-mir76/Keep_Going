//
//  WelcomeView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 13.10.2025.
//

import SwiftUI

let gradientColors: [Color] = [.gradientTop, .gradientBottom]

struct WelcomeView: View {
    @Environment(MainEngine.self) private var mainEngine
    
    var body: some View {
        @Bindable var mainEngine = mainEngine
        ZStack {
            TabView (selection: $mainEngine.welcomeTab) {
                WelcomePage()
                    .tag(1)
                FeaturesPage()
                    .tag(2)
                HowToPage()
                    .tag(3)
            }
            .background(Gradient(colors: gradientColors))
            .tabViewStyle(.page)
            NextSkipDoneButtonsView()
        }
    }
}

#Preview {
    WelcomeView()
        .environment(MainEngine())
}

#Preview("Welcome Page") {
    WelcomePage()
        .environment(MainEngine())
}

#Preview("Features") {
    FeaturesPage()
        .environment(MainEngine())
}

#Preview("HowTo") {
    HowToPage()
        .environment(MainEngine())
}

struct WelcomePage: View {
    @Environment(MainEngine.self) private var mainEngine
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .circular)
                    .frame(width: 170, height: 170)
                    .foregroundStyle(.yellow)
                    .shadow(color: .black, radius: 5, x: 5, y: 5)
                    .opacity(0.9)

                Image(systemName: "figure.stairs")
                    .font(.system(size: 100))
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 5, x: 1, y: 1)
            }
            Text("Welcome to")
                .font(.title)
                .padding([.top], 40)
                .foregroundStyle(.black)
            Text("Keep Going")
                .font(.system(size: 35, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 5, x: 1, y: 1)
            Spacer()
            Spacer()
        }
//        .padding(.bottom, 00)
    }
}

struct FeaturesPage: View {
    @Environment(MainEngine.self) private var mainEngine
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Features")
                        .font(.title)
                        .padding(.top, 80)
                        .foregroundStyle(.black)

                    FeaturesCard(icon: "bolt.fill", description: "Transform into the person you've always wanted to be.")
                    FeaturesCard(icon: "sparkles", description: "Master your time. Master your life.")
                    FeaturesCard(icon: "sun.max", description: "Wake up excited. Go to bed fulfilled.")
                    Spacer()
                    
                }
                .padding()
            }
        }
    }
}

struct HowToPage: View {
    @Environment(MainEngine.self) private var mainEngine
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 30) {
                    Text("How to do it")
                        .font(.title)
                        .padding(.top, 80)
                        .foregroundStyle(.black)

                    FeaturesCard(icon: "target", description: "Define your goals. What do you want to achieve?")
                    FeaturesCard(icon: "timer", description: "Schedule micro-tasks — quick wins that fit your day.")
                    FeaturesCard(icon: "chart.line.uptrend.xyaxis", description: "Build momentum. Small actions. Big results.")
                    Spacer()
                }
                .padding()
            }
        }
    }
}

struct FeaturesCard: View {
    var icon: String
    var description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .frame(width: 50)
                .padding(.trailing)
            Text(description)
            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.green)
                .opacity(0.8)
                .shadow(color: .black, radius: 5, x: 3, y: 3)
//                .brightness(-0.1)
        }
        .foregroundStyle(.white)
    }
}

struct NextSkipDoneButtonsView: View {
    @Environment(MainEngine.self) private var mainEngine
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if mainEngine.welcomeTab < 3 {
                    PushButton(function: .skip, execute: {
                        mainEngine.welcomePageVisible = false
                        mainEngine.showWelcomePageDuringAppStart = false
                    })
                        .padding(.trailing, 40)
                        .padding(.top, 40)
                }
            }
            Spacer()
            HStack {
                Spacer()
                if mainEngine.welcomeTab < 3 {
                    PushButton(function: .next, execute: {
                        mainEngine.welcomeTab += 1
                    })
                        .padding(.trailing, 40)
                        .padding(.bottom, 40)
                } else if mainEngine.welcomeTab == 3 {
                    PushButton(function: .done, execute: {
                        mainEngine.welcomePageVisible = false
                        mainEngine.showWelcomePageDuringAppStart = false
                    })
                    .padding(.trailing, 40)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}
