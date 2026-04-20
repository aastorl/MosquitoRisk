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
                VStack(spacing: 24) {
                    Text("¿Cómo se calcula el riesgo?")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.top, 48)   // ← bajá todo subiendo este valor
                        .foregroundColor(.white)
                    
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

                    // Animación Lottie
                    // scaleEffect → tamaño | padding(.top) → distancia del card de arriba
                    LottieView(animationName: "mosquito-risk")
                        .frame(height: 120)
                        .scaleEffect(2.0)
                        .padding(.top, 65)    // ← distancia del card de texto
                        .padding(.bottom, 48) // espacio final
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    RiskInfoSheetView()
}







