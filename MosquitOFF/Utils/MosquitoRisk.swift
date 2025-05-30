//
//  MosquitoRisk.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 27/05/2025.
//


import Foundation

struct MosquitoRisk {
    
    enum RiskLevel: String {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
    
    static func calculateRisk(from data: WeatherData) -> RiskLevel {
        var baseRisk: RiskLevel

        switch (data.temperature, data.humidity) {
        case (25...40, 60...100):
            baseRisk = .high
        case (20..<25, 40..<60):
            baseRisk = .medium
        default:
            baseRisk = .low
        }

        // Ajustar según el viento
        if data.windSpeed >= 35 {
            return .low
        } else if data.windSpeed >= 25 {
            switch baseRisk {
            case .high:
                return .medium
            case .medium:
                return .low
            case .low:
                return .low
            }
        }

        return baseRisk
    }
    
    static func riskColor(for level: RiskLevel) -> String {
        switch level {
        case .high:
            return "red"
        case .medium:
            return "orange"
        case .low:
            return "green"
        }
    }
}

