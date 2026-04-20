//
//  WeatherViewModel.swift
//  
//
//  Created by Astor Ludueña  on 05/05/2025.
//

import Foundation
import Combine
import SwiftUI
internal import CoreLocation

class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherData?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var hasNetworkError: Bool = false  // NUEVO: Estado de error de red
    @Published private(set) var currentCoordinate: CLLocationCoordinate2D?
    
    private let weatherService = WeatherService()
    private var locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    private var lastCoordinate: (lat: Double, lon: Double)?
    private var lastRiskLevel: MosquitoRisk.RiskLevel?
    private var fetchTimer: Timer?  // NUEVO: Timer para timeout
    
    private let rosarioCenter = CLLocation(latitude: -32.944162, longitude: -60.650539)
    private let rosarioCoverageRadiusMeters: CLLocationDistance = 35_000
    
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
                self.currentCoordinate = CLLocationCoordinate2D(latitude: coords.lat, longitude: coords.lon)
                self.fetchWeather(lat: coords.lat, lon: coords.lon)
            }
            .store(in: &cancellables)
    }
    
    func fetchWeather(lat: Double, lon: Double) {
        // NUEVO: Resetear error al intentar fetch
        hasNetworkError = false
        
        // NUEVO: Iniciar timeout de 10 segundos
        fetchTimer?.invalidate()
        fetchTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if self.weather == nil {
                print("⚠️ Timeout: No se recibieron datos del clima en 10 segundos")
                DispatchQueue.main.async {
                    self.hasNetworkError = true
                }
            }
        }
        
        weatherService.fetchWeather(lat: lat, lon: lon) { [weak self] weather in
            guard let self = self else { return }
            
            // NUEVO: Invalidar timer si la respuesta llegó
            self.fetchTimer?.invalidate()
            
            DispatchQueue.main.async {
                if let weather = weather {
                    // ✅ Éxito: tenemos datos
                    self.weather = weather
                    self.hasNetworkError = false
                    
                    // Calcular riesgo y enviar notificación contextual si cambió
                    let currentRisk = self.mosquitoRisk
                    if self.lastRiskLevel != currentRisk {
                        self.lastRiskLevel = currentRisk
                        NotificationManager.shared.sendMosquitoRiskNotification(
                            riskLevel: currentRisk,
                            weather: weather
                        )
                    }
                } else {
                    // Error: la API no devolvió datos
                    print("⚠️ Error: WeatherService devolvió nil")
                    self.hasNetworkError = true
                }
            }
        }
    }
    
    func retryFetch() {
        hasNetworkError = false
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
    
    var isOutsideRosarioArea: Bool {
        guard let currentCoordinate else { return false }
        let userLocation = CLLocation(
            latitude: currentCoordinate.latitude,
            longitude: currentCoordinate.longitude
        )
        let distance = userLocation.distance(from: rosarioCenter)
        return distance > rosarioCoverageRadiusMeters
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
    
    deinit {
        fetchTimer?.invalidate()
    }
}
