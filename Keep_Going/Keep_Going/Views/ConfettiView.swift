//
//  ConfettiView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 20.11.2025.
//

import SwiftUI

struct ConfettiView: View {
    @State private var particles: [Particle] = []
    var trigger: Bool

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Circle()
                    .fill(p.color)
                    .frame(width: 6, height: 6)
                    .position(p.position)
                    .animation(.easeOut(duration: 0.8), value: particles)
            }
        }
        .onChange(of: trigger) { oldvalue, newValue in
            if newValue { launchConfetti() }
        }
    }

    func launchConfetti() {
        particles = (0..<16).map { _ in
            Particle(
                id: UUID(),
                position: CGPoint(x: 180, y: 40),
                color: Color.appPrimaryAccent
            )
        }

        withAnimation {
            for i in particles.indices {
                particles[i].position.x += CGFloat.random(in: -60...60)
                particles[i].position.y += CGFloat.random(in: -120...0)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            particles.removeAll()
        }
    }
}

struct Particle: Identifiable, Equatable {
    let id: UUID
    var position: CGPoint
    let color: Color
}

#Preview {
    ConfettiView(trigger: true)
}
