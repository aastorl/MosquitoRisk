//
//  RiskInfoSheetView.swift
//  
//
//  Created by Astor Ludueña on 16/06/2025.
//

import SwiftUI

struct RiskInfoSheetView: View {
    var body: some View {
        ZStack {
            // Fondo con degradado
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8),
                    Color.cyan.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 45) {
                    Spacer()
                    Text("¿Cómo se calcula el riesgo?")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                        .foregroundColor(.white) // fuerza el color blanco
                    
                        VStack(alignment: .leading, spacing: 12) {
                        Text("Estimamos la presencia de mosquitos usando:")
                            .font(.body)

                        Label("• Temperatura", systemImage: "thermometer")
                        Label("• Humedad", systemImage: "drop.fill")
                        Label("• Volumen de lluvia", systemImage: "cloud.rain.fill")
                        Label("• Velocidad del viento", systemImage: "wind")

                        Divider()

                        Text("""
                        Si estas condiciones favorecen la actividad de los mosquitos (clima cálido, húmedo, lluvioso y poco viento), verás un riesgo Alto o Medio. De lo contrario, será Bajo.
                        """)
                        .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)

                    // Animación Lottie más abajo
                    LottieView(animationName: "mosquito-risk")
                        .frame(height: 220)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

#Preview {
    RiskInfoSheetView()
}







