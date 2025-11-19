//
//  IntroSheetView.swift
//  
//
//  Created by Astor Ludueña on 16/06/2025.
//

import SwiftUI

struct IntroSheetView: View {
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Background gradient coherente con la app
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.red.opacity(0.8),
                    Color.orange.opacity(0.7),
                    Color.green.opacity(0.6),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("¡Bienvenido a MosquitoRisk!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .multilineTextAlignment(.center)
                        .padding(.top, -20)
                }
                .padding(.top, -16)
                
                // Main content
                VStack(spacing: 20) {
                    Text("Esta app está optimizada específicamente para el clima subtropical húmedo de Rosario, Santa Fe. Los cálculos de riesgo consideran las condiciones típicas de la región.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                        .padding(.horizontal, 24)
                    
                    // Features info card
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "location.circle.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            
                            Text("Optimizado para Rosario y alrededores")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .opacity(0.5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 24)
                }
                
                // Close button
                Button(action: onDismiss) {
                    Text("Entendido")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.ultraThinMaterial)
                                .opacity(0.8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, -50)
                
            }
        }
        .presentationDetents([.fraction(0.59)])
    }
}



