//
//  HeatMapInfoSheet.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 03/07/2025.
//

import SwiftUI

struct HeatMapInfoSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Background gradient coherente con la app
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.red.opacity(4),
                    Color.orange.opacity(4),
                    Color.green.opacity(4),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("Mapa de Riesgo")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .padding(.top, -20)
                    
                    Text("Colores indican la intensidad del riesgo de mosquitos.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        .padding(.horizontal, 10)
                }
                .padding(.top, -16)
                
                // Risk levels explanation
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        RiskIndicator(color: .red, level: "Alto")
                        RiskIndicator(color: .orange, level: "Medio")
                        RiskIndicator(color: .green, level: "Bajo")
                    }
                    .padding(.horizontal, 20)
                }
                
                
                // Description
                Text("Los datos se actualizan individualmente y de forma automática en espacios verdes, como el parque Urquiza, Alem y otras zonas transitadas de la ciudad.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    .padding(.horizontal, 20)
                
                
                
                
                // Close button - AGRANDADO
                Button(action: {
                    dismiss()
                }) {
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
        .presentationDetents([.fraction(0.5)])
    }
}

struct RiskIndicator: View {
    let color: Color
    let level: String
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 24, height: 24)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            
            Text(level)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .opacity(0.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HeatMapView()
}
