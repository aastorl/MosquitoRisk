//
//  MosquitoRisk.swift
//  
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

        // TEMPERATURA optimizada para Rosario
        // Rosario: veranos 25-35°C, inviernos 8-18°C
        // Mosquitos Aedes aegypti más activos entre 20-32°C (óptimo: 25-30°C)
        if data.temperature >= 25 && data.temperature <= 32 {
            // Rango óptimo para mosquitos en Rosario (verano típico)
            if data.humidity >= 65 {
                baseRisk = .high
            } else if data.humidity >= 55 {
                baseRisk = .medium
            } else {
                baseRisk = .low
            }
        } else if data.temperature >= 20 && data.temperature < 25 {
            // Temperaturas cálidas pero no óptimas (primavera/otoño)
            if data.humidity >= 70 {
                baseRisk = .high
            } else if data.humidity >= 60 {
                baseRisk = .medium
            } else {
                baseRisk = .low
            }
        } else if data.temperature > 32 && data.temperature <= 38 {
            // Calor extremo de Rosario (reduce actividad de mosquitos)
            if data.humidity >= 70 {
                baseRisk = .medium  // Muy caluroso pero húmedo
            } else {
                baseRisk = .low  // Muy caluroso y seco
            }
        } else if data.temperature >= 15 && data.temperature < 20 {
            // Temperaturas frescas (otoño/primavera temprana)
            if data.humidity >= 75 {
                baseRisk = .medium
            } else {
                baseRisk = .low
            }
        } else {
            // Por debajo de 15°C o por encima de 38°C: muy bajo riesgo
            baseRisk = .low
        }

        // PRECIPITACIÓN ajustada para Rosario
        // Rosario tiene lluvias abundantes en verano (100-150mm mensuales)
        // Agua estancada = criaderos de mosquitos
        if data.precipitation >= 10 {
            // Lluvia fuerte reciente (último día)
            if baseRisk == .low {
                baseRisk = .medium
            } else if baseRisk == .medium {
                baseRisk = .high
            }
            // Si ya es high, se mantiene en high
        } else if data.precipitation >= 3 && data.precipitation < 10 {
            // Lluvia moderada
            if baseRisk == .low && data.humidity >= 60 {
                baseRisk = .medium
            }
        }

        // 🌬️ VIENTO ajustado para Rosario
        // Rosario tiene vientos moderados del Paraná, especialmente en verano
        // Vientos fuertes dificultan vuelo de mosquitos
        if data.windSpeed >= 35 {
            // Vientos muy fuertes: mosquitos no pueden volar bien
            return .low
        } else if data.windSpeed >= 25 {
            // Vientos moderados-fuertes: reduce actividad
            switch baseRisk {
            case .high: return .medium
            case .medium: return .low
            case .low: return .low
            }
        } else if data.windSpeed >= 15 {
            // Vientos moderados: ligera reducción
            if baseRisk == .high {
                return .medium
            }
        }
        // Vientos menores a 15 km/h: no afectan mucho

        return baseRisk
    }

    // Función auxiliar para obtener el mes actual (útil para ajustes estacionales)
    private static func getCurrentMonth() -> Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: Date())
    }

    // Función opcional: ajuste estacional para Rosario
    // No implementada --------------------------------
    static func seasonalAdjustment(for risk: RiskLevel) -> RiskLevel {
        let month = getCurrentMonth()
        
        // En Rosario:
        // Verano (Dic-Mar): meses 12, 1, 2, 3 - Mayor riesgo
        // Otoño (Abr-Jun): meses 4, 5, 6 - Riesgo moderado
        // Invierno (Jul-Sep): meses 7, 8, 9 - Menor riesgo
        // Primavera (Oct-Nov): meses 10, 11 - Riesgo creciente
        
        switch month {
        case 12, 1, 2, 3:  // Verano - pico de mosquitos
            // En verano, si el riesgo es medio, aumentarlo a alto
            return risk == .medium ? .high : risk
            
        case 7, 8, 9:  // Invierno - mínimo de mosquitos
            // En invierno, reducir un nivel el riesgo
            switch risk {
            case .high: return .medium
            case .medium: return .low
            case .low: return .low
            }
            
        default:  // Primavera y otoño
            return risk
        }
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


