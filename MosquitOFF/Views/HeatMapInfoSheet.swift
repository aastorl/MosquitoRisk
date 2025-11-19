//
//  HeatMapInfoSheet.swift
//  
//
//  Created by Astor Ludueña  on 03/07/2025.
//

import SwiftUI

struct HeatMapInfoSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Background gradient
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
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Mapa de Riesgo")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            .padding(.top, 50)
                        
                        Text("Evaluación en tiempo real basada en clima local")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    // Niveles de riesgo
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            RiskIndicator(color: .red, level: "Alto", icon: "exclamationmark.triangle.fill")
                            RiskIndicator(color: .orange, level: "Medio", icon: "exclamationmark.circle.fill")
                            RiskIndicator(color: .green, level: "Bajo", icon: "checkmark.circle.fill")
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Parametros
                    VStack(spacing: 16) {
                        Text("¿Qué analizamos?")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 12) {
                            FactorCard(
                                icon: "thermometer.medium",
                                title: "Temperatura",
                                description: "Óptimo 25-32°C para mosquitos en Rosario",
                                color: .white
                            )
                            
                            FactorCard(
                                icon: "humidity.fill",
                                title: "Humedad",
                                description: "El clima húmedo del litoral favorece su reproducción",
                                color: .white
                            )
                            
                            FactorCard(
                                icon: "cloud.rain.fill",
                                title: "Precipitaciones",
                                description: "Lluvias recientes crean criaderos de larvas",
                                color: .white
                            )
                            
                            FactorCard(
                                icon: "wind",
                                title: "Viento",
                                description: "Vientos fuertes dificultan su vuelo",
                                color: .white
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Update info
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .foregroundColor(.white)
                                .font(.title3)
                            Text("Actualización automática")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        Text("Cada zona se actualiza individualmente con datos meteorológicos en tiempo real")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                    .padding(.vertical, 14)
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
                    
                    // Close button
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
                    .padding(.bottom, 20)
                }
            }
        }
        .presentationDetents([.large])
    }
}

struct RiskIndicator: View {
    let color: Color
    let level: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
            }
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            Text(level)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(2.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct FactorCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .opacity(0.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HeatMapInfoSheet()
}
