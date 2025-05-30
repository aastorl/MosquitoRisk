//
//  MosquitoAnimation.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 28/05/2025.
//

import SwiftUI

struct MosquitoAnimationView: View {
    let riskLevel: MosquitoRisk.RiskLevel
    @State private var mosquitoes: [Mosquito] = []

    var body: some View {
        ZStack {
            ForEach(mosquitoes) { mosquito in
                Text("🦟")
                    .font(.system(size: mosquito.size))
                    .position(x: mosquito.x, y: mosquito.y)
                    .opacity(opacity(for: mosquito.y))
                    .blur(radius: 0.3)
                    .shadow(color: .black.opacity(0.1), radius: 1)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            spawnMosquitoes()
        }
    }

    func opacity(for y: CGFloat) -> Double {
        let fadeStartY: CGFloat = 50
        if y < -100 {
            return 0
        } else if y > fadeStartY {
            return 0.7
        } else {
            return Double((y + 100) / (fadeStartY + 100)) * 0.7
        }
    }

    func spawnMosquitoes() {
        let mosquitoCount: Int
        switch riskLevel {
        case .low:
            mosquitoCount = 2
        case .medium:
            mosquitoCount = 6
        case .high:
            mosquitoCount = 14
        }

        for i in 0..<mosquitoCount {
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height

            let startX = CGFloat.random(in: 0...screenWidth)
            let startY = screenHeight + CGFloat(i * 40)
            let driftX = CGFloat.random(in: -50...50)
            let wobbleAmplitude = CGFloat.random(in: 8...14)
            let wobbleSpeed = Double.random(in: 2.5...4.5)
            let size = CGFloat.random(in: 18...24)
            let duration = Double.random(in: 4.0...6.5)

            let id = UUID()
            var mosquito = Mosquito(
                id: id,
                x: startX,
                y: startY,
                baseX: startX + driftX,
                wobbleAmplitude: wobbleAmplitude,
                wobbleSpeed: wobbleSpeed,
                size: size,
                startTime: Date().timeIntervalSinceReferenceDate
            )

            mosquitoes.append(mosquito)

            withAnimation(.linear(duration: duration)) {
                if let index = mosquitoes.firstIndex(where: { $0.id == id }) {
                    mosquitoes[index].y = -120
                }
            }

            let timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { t in
                guard let index = mosquitoes.firstIndex(where: { $0.id == id }) else {
                    t.invalidate()
                    return
                }

                let time = Date().timeIntervalSinceReferenceDate - mosquitoes[index].startTime
                let oscillation = mosquito.wobbleAmplitude * CGFloat(sin(time * mosquito.wobbleSpeed))
                mosquitoes[index].x = mosquito.baseX + oscillation

                if mosquitoes[index].y < -130 {
                    mosquitoes.remove(at: index)
                    t.invalidate()
                }
            }

            RunLoop.main.add(timer, forMode: .common)
        }
    }
}

struct Mosquito: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var baseX: CGFloat
    var wobbleAmplitude: CGFloat
    var wobbleSpeed: Double
    var size: CGFloat
    var startTime: TimeInterval
}








