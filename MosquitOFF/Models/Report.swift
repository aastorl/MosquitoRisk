//
//  Report.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 06/05/2025.
//

import Foundation

struct Report: Identifiable, Encodable, Decodable {
    var id = UUID()  // ID único para cada reporte
    var type: String  // Tipo de reporte, puede ser 'Mosquito' o 'Dengue'
    var description: String  // Descripción del reporte
    var timestamp: Date  // Fecha y hora en que se envió el reporte
    var latitude: Double?
    var longitude: Double?
}

