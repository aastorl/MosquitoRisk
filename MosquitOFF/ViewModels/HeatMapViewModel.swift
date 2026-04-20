//
//  HeatMapViewModel.swift
//  
//
//  Created by Astor Ludueña  on 03/06/2025.
//

import Foundation
internal import CoreLocation
import Combine

class HeatMapViewModel: ObservableObject {
   @Published var riskZones: [RiskZone] = []
   @Published var orderedNames: [String] = []
   private let weatherService = WeatherService()

   func fetchRiskZones(for parks: [String: [CLLocationCoordinate2D]]) {
       let group = DispatchGroup()
       var tempZones: [(index: Int, name: String, zone: RiskZone)] = []
       let lock = NSLock()
       
       let sortedParks = parks.sorted { $0.key < $1.key }
       
       for (index, parkEntry) in sortedParks.enumerated() {
           let (parkName, coordinates) = parkEntry
           group.enter()
           
           var risks: [MosquitoRisk.RiskLevel] = []
           var weatherSamples: [WeatherData] = []
           let coordinateGroup = DispatchGroup()

           for coordinate in coordinates {
               coordinateGroup.enter()
               weatherService.fetchWeather(lat: coordinate.latitude, lon: coordinate.longitude) { weather in
                   if let data = weather {
                       let risk = MosquitoRisk.calculateRisk(from: data)
                       lock.lock()
                       risks.append(risk)
                       weatherSamples.append(data)
                       lock.unlock()
                   }
                   coordinateGroup.leave()
               }
           }

           coordinateGroup.notify(queue: .global()) {
               let averageRisk = self.averageRisk(from: risks)
               let avgWeather = self.averageWeather(from: weatherSamples)
               let centerCoordinate = self.centerCoordinate(of: coordinates)
               let zone = RiskZone(
                   coordinate: centerCoordinate,
                   riskLevel: averageRisk,
                   name: parkName,
                   weather: avgWeather
               )
               
               lock.lock()
               tempZones.append((index: index, name: parkName, zone: zone))
               lock.unlock()
               
               group.leave()
           }
       }

       group.notify(queue: .main) {
           let sorted = tempZones.sorted { $0.index < $1.index }
           self.riskZones = sorted.map { $0.zone }
           self.orderedNames = sorted.map { $0.name }
       }
   }

   // Promedio de weather de múltiples coordenadas del mismo parque
   private func averageWeather(from samples: [WeatherData]) -> WeatherData? {
       guard !samples.isEmpty else { return nil }
       let count = Double(samples.count)
       return WeatherData(
           temperature:   samples.map(\.temperature).reduce(0, +)   / count,
           humidity:      samples.map(\.humidity).reduce(0, +)       / count,
           condition:     samples.first?.condition ?? "",
           precipitation: samples.map(\.precipitation).reduce(0, +)  / count,
           windSpeed:     samples.map(\.windSpeed).reduce(0, +)       / count,
           sunrise:       samples.first?.sunrise ?? Date(),
           sunset:        samples.first?.sunset  ?? Date()
       )
   }

   private func averageRisk(from risks: [MosquitoRisk.RiskLevel]) -> MosquitoRisk.RiskLevel {
       guard !risks.isEmpty else { return .low }
       let values = risks.map { $0.numericValue }
       let average = values.reduce(0, +) / Double(values.count)
       switch average {
       case 0..<1.5: return .low
       case 1.5..<2.5: return .medium
       default: return .high
       }
   }

   private func centerCoordinate(of coords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
       let lat = coords.map { $0.latitude }.reduce(0, +)  / Double(coords.count)
       let lon = coords.map { $0.longitude }.reduce(0, +) / Double(coords.count)
       return CLLocationCoordinate2D(latitude: lat, longitude: lon)
   }
}

private extension MosquitoRisk.RiskLevel {
   var numericValue: Double {
       switch self {
       case .low: return 1.0
       case .medium: return 2.0
       case .high: return 3.0
       }
   }
}



