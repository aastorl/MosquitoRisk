//
//  HeatMapViewModel.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 03/06/2025.
//

import Foundation
import CoreLocation

class HeatMapViewModel: ObservableObject {
    @Published var riskZones: [RiskZone] = []
    private let weatherService = WeatherService()

    func fetchRiskZones(for coordinates: [CLLocationCoordinate2D]) {
        var results: [RiskZone] = []
        let group = DispatchGroup()

        for coordinate in coordinates {
            group.enter()
            weatherService.fetchWeather(lat: coordinate.latitude, lon: coordinate.longitude) { weather in
                if let data = weather {
                    let risk = MosquitoRisk.calculateRisk(from: data)
                    let zone = RiskZone(coordinate: coordinate, riskLevel: risk)
                    results.append(zone)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.riskZones = results
        }
    }
}

