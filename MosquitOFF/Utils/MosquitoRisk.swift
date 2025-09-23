//
//  MosquitoRisk.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 27/05/2025.
//

import Foundation
import SwiftUI

struct MosquitoRisk {
    
    enum RiskLevel: String {
        case low = "Bajo"
        case medium = "Medio"
        case high = "Alto"
    }

    static func calculateRisk(from data: WeatherData) -> RiskLevel {
        var baseRisk: RiskLevel

        // Rango más flexible para Rosario: verano húmedo
        if (data.temperature >= 22 && data.temperature <= 40) && (data.humidity >= 60) {
            baseRisk = .high
        } else if (data.temperature >= 18 && data.temperature < 22) && (data.humidity >= 50) {
            baseRisk = .medium
        } else {
            baseRisk = .low
        }

        // 🌧️ Precipitación: más agua = más riesgo
        if data.precipitation >= 5 {
            if baseRisk == .low {
                baseRisk = .medium
            } else if baseRisk == .medium {
                baseRisk = .high
            }
        }

        // 🌬️ Viento (en km/h): mucho viento ahuyenta mosquitos
        if data.windSpeed >= 40 {
            return .low
        } else if data.windSpeed >= 30 {
            switch baseRisk {
            case .high: return .medium
            case .medium: return .low
            case .low: return .low
            }
        }

        return baseRisk
    }

    // Mantener la función original para compatibilidad
    static func riskColor(for level: RiskLevel) -> String {
        switch level {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "green"
        }
    }
}


