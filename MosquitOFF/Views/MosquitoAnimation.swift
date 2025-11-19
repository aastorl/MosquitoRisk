//
//  MosquitoAnimation.swift - Versión Optimizada
//  
//

import SwiftUI

struct MosquitoAnimationView: View {
    let riskLevel: MosquitoRisk.RiskLevel
    @State private var mosquitoes: [RandomMosquito] = []
    
    var body: some View {
        ZStack {
            ForEach(mosquitoes) { mosquito in
                MosquitoParticle(mosquito: mosquito)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            generateMosquitoes()
        }
    }
    
    private func generateMosquitoes() {
        let count = mosquitoCount(for: riskLevel)
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        mosquitoes = (0..<count).map { index in
            RandomMosquito(
                id: UUID(),
                x: CGFloat.random(in: 30...(screenWidth - 30)),
                y: CGFloat.random(in: 100...(screenHeight - 200)),
                size: CGFloat.random(in: 16...22),
                delay: Double(index) * 0.3 + Double.random(in: 0...1.0)
            )
        }
    }
    
    private func mosquitoCount(for risk: MosquitoRisk.RiskLevel) -> Int {
        switch risk {
        case .low: return 0
        case .medium: return 6
        case .high: return 12
        }
    }
}

struct MosquitoParticle: View {
    let mosquito: RandomMosquito
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    
    var body: some View {
        Text("🦟")
            .font(.system(size: mosquito.size))
            .opacity(opacity)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .offset(x: offsetX, y: offsetY)
            .position(x: mosquito.x, y: mosquito.y)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + mosquito.delay) {
                    startAnimation()
                }
            }
    }
    
    private func startAnimation() {
        // Aparición suave
        withAnimation(.easeOut(duration: 0.8)) {
            opacity = 0.7
            scale = 1.0
        }
        
        // Movimiento sutil y aleatorio
        withAnimation(
            .easeInOut(duration: Double.random(in: 2.0...3.5))
            .repeatForever(autoreverses: true)
        ) {
            offsetX = CGFloat.random(in: -20...20)
            offsetY = CGFloat.random(in: -15...15)
        }
        
        // Desaparición después de un tiempo
        let lifespan = Double.random(in: 4.0...6.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + lifespan) {
            // Desaparición después de un tiempo
            let lifespan = Double.random(in: 4.0...6.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + lifespan - 2.0) { // Empezar 2 segundos antes
                withAnimation(.easeOut(duration: 2.0)) { // Fade más largo
                    opacity = 0.0
                    scale = 0.8 // Reducción menos brusca
                }
            }
        }
    }
}

struct RandomMosquito: Identifiable {
    let id: UUID
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let delay: Double
}






