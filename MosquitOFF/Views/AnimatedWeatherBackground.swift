//
//  AnimatedWeatherBackground.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 22/05/2025.
//

import SwiftUI

struct AnimatedWeatherBackground: View {
    let condition: String
    let isNight: Bool

    var body: some View {
        ZStack {
            currentLottieAnimation
                .transition(.opacity)
                .animation(.easeInOut(duration: 1.0), value: condition)

            Color.black.opacity(0.3) // Profundidad para destacar el contenido
        }
        .ignoresSafeArea()
    }

    private var currentLottieAnimation: some View {
        LottieView(animationName: animationNameForCondition())
    }

    private func animationNameForCondition() -> String {
        if isNight {
            return "night_bg"
        }

        switch condition.lowercased() {
        case "sunny": return "sunny_bg"
        case "rainy": return "rainy_day_bg"
        default: return "sunny_bg" // fallback
        }
    }
}


