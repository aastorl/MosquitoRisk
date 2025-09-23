//
//  WeatherViewModel.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 05/05/2025.
//

import Foundation
import Combine
import SwiftUI
import CoreLocation

class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherData?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let weatherService = WeatherService()
    private var locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    private var lastCoordinate: (lat: Double, lon: Double)?
    private var lastRiskLevel: MosquitoRisk.RiskLevel?
    
    init() {
        // Solicitar permisos de notificaciones al inicializar
        NotificationManager.shared.requestPermission()
        
        locationManager.$authorizationStatus
            .receive(on: RunLoop.main)
            .sink { status in
                print("Location authorization changed to: \(status.rawValue)")
                self.authorizationStatus = status
            }
            .store(in: &cancellables)
        
        locationManager.$authorizationStatus
            .receive(on: RunLoop.main)
            .assign(to: &$authorizationStatus)
        
        // Suscribirse a ubicación para actualizar coordenadas y hacer fetch del clima
        locationManager.$location
            .compactMap { $0 } // Ignorar nil
            .map { location in (lat: location.latitude, lon: location.longitude) }
            .sink { [weak self] coords in
                guard let self = self else { return }
                self.lastCoordinate = coords
                self.fetchWeather(lat: coords.lat, lon: coords.lon)
            }
            .store(in: &cancellables)
    }
    
    func fetchWeather(lat: Double, lon: Double) {
        weatherService.fetchWeather(lat: lat, lon: lon) { [weak self] weather in
            DispatchQueue.main.async {
                guard let self = self, let weather = weather else { return }
                self.weather = weather
                
                // Calcular riesgo y enviar notificación contextual si cambió
                let currentRisk = self.mosquitoRisk
                if self.lastRiskLevel != currentRisk {
                    self.lastRiskLevel = currentRisk
                    NotificationManager.shared.sendMosquitoRiskNotification(
                        riskLevel: currentRisk,
                        weather: weather
                    )
                }
            }
        }
    }
    
    func retryFetch() {
        guard let coord = lastCoordinate else { return }
        fetchWeather(lat: coord.lat, lon: coord.lon)
    }
    
    var mosquitoRisk: MosquitoRisk.RiskLevel {
        guard let data = weather else { return .low }
        return MosquitoRisk.calculateRisk(from: data)
    }
    
    var riskColor: Color {
        switch mosquitoRisk {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
    
    private func isNightTime() -> Bool {
        guard let weather = weather else { return false }
        let now = Date()
        return now < weather.sunrise || now > weather.sunset
    }
    
    var weatherVideoName: String {
        guard let condition = weather?.condition.lowercased() else { return isNightTime() ? "Cloudy night 3sec" : "cloudy 3sec" }
        let isNight = isNightTime()
        if condition.contains("clear") {
            return isNight ? "Clear night 3sec" : "sunny 3sec"
        }
        if condition.contains("partly") || condition.contains("partially") {
            return isNight ? "Cloudy night 3sec" : "Partially clear 3sec"
        }
        if condition.contains("storm") || condition.contains("thunder") {
            return isNight ? "Storm Night 3sec" : "storm 3sec"
        }
        if condition.contains("cloud") {
            return isNight ? "Cloudy night 3sec" : "cloudy 3sec"
        }
        return isNight ? "Cloudy night 3sec" : "cloudy 3sec"
    }
}
