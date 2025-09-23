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

   // Nuevo método que recibe un diccionario con puntos por parque
   func fetchRiskZones(for parks: [String: [CLLocationCoordinate2D]]) {
       let group = DispatchGroup()
       var tempZones: [RiskZone] = []
       let lock = NSLock()

       for (parkName, coordinates) in parks {
           group.enter() // Una entrada por parque
           
           var risks: [MosquitoRisk.RiskLevel] = []
           let coordinateGroup = DispatchGroup()

           // Procesar todas las coordenadas de este parque
           for coordinate in coordinates {
               coordinateGroup.enter()
               weatherService.fetchWeather(lat: coordinate.latitude, lon: coordinate.longitude) { weather in
                   if let data = weather {
                       let risk = MosquitoRisk.calculateRisk(from: data)
                       lock.lock()
                       risks.append(risk)
                       lock.unlock()
                   }
                   coordinateGroup.leave()
               }
           }

           // Cuando terminan todas las coordenadas de este parque
           coordinateGroup.notify(queue: .global()) {
               let averageRisk = self.averageRisk(from: risks)
               let centerCoordinate = self.centerCoordinate(of: coordinates)
               let zone = RiskZone(coordinate: centerCoordinate, riskLevel: averageRisk)
               
               lock.lock()
               tempZones.append(zone)
               lock.unlock()
               
               group.leave() // Salir del grupo principal
           }
       }

       // Cuando terminan todos los parques
       group.notify(queue: .main) {
           self.riskZones = tempZones
       }
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
       let lat = coords.map { $0.latitude }.reduce(0, +) / Double(coords.count)
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




