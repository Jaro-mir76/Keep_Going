//
//  WelcomeView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 13.10.2025.
//

import SwiftUI

let gradientColors: [Color] = [.gradientTop, .gradientBottom]

struct WelcomeView: View {
    @Environment(NavigationManager.self) private var navigationManager
    
    var body: some View {
        @Bindable var navigationManager = navigationManager
        TabView (selection: $navigationManager.welcomeTab) {
            WelcomePage()
                .tag(1)
            FeaturesPage()
                .tag(2)
            HowToPage()
                .tag(3)
        }
        .background(Gradient(colors: gradientColors))
        .tabViewStyle(.page)
    }
}

#Preview {
    WelcomeView()
        .environment(NavigationManager())
}

#Preview("Features") {
    FeaturesPage()
        .environment(NavigationManager())
}

#Preview("HowTo") {
    HowToPage()
        .environment(NavigationManager())
}

struct WelcomePage: View {
    @Environment(NavigationManager.self) private var navigationManager
    
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
//                .foregroundStyle(.white)
            Text("Keep Going")
                .font(.system(size: 35, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 5, x: 1, y: 1)
            Spacer()
            Spacer()
            HStack {
                Spacer()
                PushButton(function: .next, execute: {
                    navigationManager.welcomeTab = 2
                })
                    .padding(.trailing, 40)
                    .padding(.bottom, 40)
            }
        }
//        .padding(.bottom, 00)
    }
}

struct FeaturesPage: View {
    @Environment(NavigationManager.self) private var navigationManager
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Features")
                        .font(.title)
                        .padding(.top, 80)
                    
                    FeaturesCard(icon: "bolt.fill", description: "Transform into the person you've always wanted to be.")
                    FeaturesCard(icon: "sparkles", description: "Master your time. Master your life.")
                    FeaturesCard(icon: "sun.max", description: "Wake up excited. Go to bed fulfilled.")
                    Spacer()
                    
                }
                .padding()
            }
            HStack {
                Spacer()
                PushButton(function: .next, execute: {
                    navigationManager.welcomeTab = 3
                })
                .padding(.trailing, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

struct HowToPage: View {
    @Environment(NavigationManager.self) private var navigationManager
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 30) {
                    Text("How to do it")
                        .font(.title)
                        .padding(.top, 80)
                    
                    FeaturesCard(icon: "target", description: "Define your goals. What do you want to achieve?")
                    FeaturesCard(icon: "timer", description: "Schedule micro-tasks — quick wins that fit your day.")
                    FeaturesCard(icon: "chart.line.uptrend.xyaxis", description: "Build momentum. Small actions. Big results.")
                    Spacer()
                }
                .padding()
            }
            HStack {
                Spacer()
                PushButton(function: .done, execute: {
                        navigationManager.welcomePageSeen = true
                })
                .padding(.trailing, 40)
                .padding(.bottom, 40)
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
