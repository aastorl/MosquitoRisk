//
//  RiskInfoSheetView.swift
//  MosquitOFF
//
//  Created by Astor Ludueña on 16/06/2025.
//

import SwiftUI

struct RiskInfoSheetView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("¿Cómo se calcula el riesgo?")
                .font(.title2)
                .bold()
                .frame(height: 100)
            
            

            VStack(alignment: .leading, spacing: 12) {
                Text("Estimamos la presencia de mosquitos usando:")
                Label("• Temperatura", systemImage: "thermometer")
                Label("• Humedad", systemImage: "drop.fill")
                Label("• Volumen de lluvia", systemImage: "cloud.rain.fill")
                Label("• Velocidad del viento", systemImage: "wind")

                Divider()

                Text("""
                Si estas condiciones favorecen la actividad de los mosquitos (clima cálido, húmedo, lluvioso y poco viento), verás un riesgo **Alto** o **Medio**. De lo contrario, será **Bajo**.
                """)
                .multilineTextAlignment(.leading)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)

            Spacer()

            // Lottie animación al fondo visual (parte inferior)
            LottieView(animationName: "mosquito-risk")
                .frame(height: 250)
                
        }
        .padding()
        
    }
}

#Preview {
    RiskInfoSheetView()
}



