//
//  ReportView.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 05/05/2025.
//

// Deprecated

import SwiftUI

struct ReportView: View {
    @State private var type: String = ""  // Tipo de reporte
    @State private var description: String = ""  // Descripción del reporte
    private let reportManager = ReportManager()  // Servicio para guardar reportes
    
    var body: some View {
        VStack {
            TextField("Tipo de reporte (Ej. Mosquito/Dengue)", text: $type)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Descripción del reporte", text: $description)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Enviar Reporte") {
                let report = Report(type: type, description: description, timestamp: Date())
                reportManager.saveReports([report])  // Guardamos el reporte
                type = ""
                description = ""  // Limpiamos los campos
            }
            .padding()
            .buttonStyle(BorderedButtonStyle())
            
            Spacer()
        }
        .padding()
        .navigationTitle("Enviar Reporte")
    }
}



