//
//  WeatherViewModelTest.swift
//  MosquitOFFTests
//
//  Created by Astor Ludueña  on 07/08/2025.
//

import XCTest
import Combine
import SwiftUI
import CoreLocation
@testable import MosquitOFF

final class WeatherViewModelTest: XCTestCase {

    var weatherVM: WeatherViewModel!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        weatherVM = WeatherViewModel()
    }

    override func tearDown() {
        weatherVM = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // Test de integración: verificar que mosquitoRisk se actualiza cuando weather cambia
    func testMosquitoRiskUpdatesWhenWeatherChanges() {
        // Verificamos que el riesgo inicial sea .low (weather es nil)
        XCTAssertEqual(weatherVM.mosquitoRisk, .low, "Riesgo inicial debería ser .low")

        // Datos de alto riesgo
        let highRiskWeather = WeatherData(
            temperature: 28,
            humidity: 80,
            condition: "Sunny",
            precipitation: 0,
            windSpeed: 10,
            sunrise: Date(),
            sunset: Date()
        )

        // Cambiar weather directamente (sin observar, test más simple)
        weatherVM.weather = highRiskWeather
        
        // Verificar que el riesgo calculado sea alto
        let currentRisk = weatherVM.mosquitoRisk
        XCTAssertEqual(currentRisk, .high, "Riesgo debería ser .high con temp=28 y humidity=80, pero obtuve \(currentRisk)")
        
        // Verificar que el weather se estableció correctamente
        XCTAssertEqual(weatherVM.weather?.temperature, 28, "Temperatura debería ser 28")
        XCTAssertEqual(weatherVM.weather?.humidity, 80, "Humedad debería ser 80")
    }

    // Test de colores de riesgo - funcionalidad única del ViewModel
    func testRiskColors() {
        // Riesgo bajo = verde
        weatherVM.weather = WeatherData(temperature: 15, humidity: 40, condition: "Clear", precipitation: 0, windSpeed: 10, sunrise: Date(), sunset: Date())
        XCTAssertEqual(weatherVM.riskColor, .green, "Riesgo bajo debería ser verde")

        // Riesgo medio = naranja
        weatherVM.weather = WeatherData(temperature: 20, humidity: 55, condition: "Cloudy", precipitation: 0, windSpeed: 10, sunrise: Date(), sunset: Date())
        XCTAssertEqual(weatherVM.riskColor, .orange, "Riesgo medio debería ser naranja")

        // Riesgo alto = rojo
        weatherVM.weather = WeatherData(temperature: 30, humidity: 80, condition: "Sunny", precipitation: 0, windSpeed: 10, sunrise: Date(), sunset: Date())
        XCTAssertEqual(weatherVM.riskColor, .red, "Riesgo alto debería ser rojo")
    }

    // Test de nombres de video según condición climática - funcionalidad única del ViewModel
    func testWeatherVideoNames() {
        // Crear fechas para simular día (hora actual entre sunrise y sunset)
        let now = Date()
        let calendar = Calendar.current
        
        // Sunrise en el pasado y sunset en el futuro para simular día
        let sunrise = calendar.date(byAdding: .hour, value: -2, to: now)! // 2 horas atrás
        let sunset = calendar.date(byAdding: .hour, value: 8, to: now)!   // 8 horas en el futuro

        // Test condición soleada/clara
        weatherVM.weather = WeatherData(
            temperature: 25,
            humidity: 60,
            condition: "Clear",
            precipitation: 0,
            windSpeed: 10,
            sunrise: sunrise,
            sunset: sunset
        )
        XCTAssertEqual(weatherVM.weatherVideoName, "sunny 3sec", "Condición clara debería usar video 'sunny 3sec'")

        // Test condición nublada
        weatherVM.weather = WeatherData(
            temperature: 25,
            humidity: 60,
            condition: "Cloudy",
            precipitation: 0,
            windSpeed: 10,
            sunrise: sunrise,
            sunset: sunset
        )
        XCTAssertEqual(weatherVM.weatherVideoName, "cloudy 3sec", "Condición nublada debería usar video 'cloudy 3sec'")

        // Test tormenta
        weatherVM.weather = WeatherData(
            temperature: 25,
            humidity: 60,
            condition: "Thunderstorm",
            precipitation: 10,
            windSpeed: 25,
            sunrise: sunrise,
            sunset: sunset
        )
        XCTAssertEqual(weatherVM.weatherVideoName, "storm 3sec", "Tormenta debería usar video 'storm 3sec'")

        // Test condición parcialmente clara
        weatherVM.weather = WeatherData(
            temperature: 25,
            humidity: 60,
            condition: "Partly Cloudy",
            precipitation: 0,
            windSpeed: 10,
            sunrise: sunrise,
            sunset: sunset
        )
        XCTAssertEqual(weatherVM.weatherVideoName, "Partially clear 3sec", "Condición parcialmente clara debería usar video 'Partially clear 3sec'")
    }

    // Test comportamiento nocturno en nombres de video
    func testNightTimeVideoNames() {
        // Crear fechas donde es de noche (hora actual fuera del rango sunrise-sunset)
        let now = Date()
        let calendar = Calendar.current
        
        // Sunrise en el futuro y sunset en el pasado para simular noche
        let sunrise = calendar.date(byAdding: .hour, value: 8, to: now)! // 8 horas en el futuro
        let sunset = calendar.date(byAdding: .hour, value: -2, to: now)!  // 2 horas atrás

        // Test condición clara de noche
        weatherVM.weather = WeatherData(
            temperature: 25,
            humidity: 60,
            condition: "Clear",
            precipitation: 0,
            windSpeed: 10,
            sunrise: sunrise,
            sunset: sunset
        )
        XCTAssertEqual(weatherVM.weatherVideoName, "Clear night 3sec", "Condición clara de noche debería usar video nocturno")

        // Test condición nublada de noche
        weatherVM.weather = WeatherData(
            temperature: 25,
            humidity: 60,
            condition: "Cloudy",
            precipitation: 0,
            windSpeed: 10,
            sunrise: sunrise,
            sunset: sunset
        )
        XCTAssertEqual(weatherVM.weatherVideoName, "Cloudy night 3sec", "Condición nublada de noche debería usar video nocturno")
    }

    // Test estado inicial del ViewModel
    func testInitialState() {
        XCTAssertNil(weatherVM.weather, "Weather inicial debería ser nil")
        XCTAssertEqual(weatherVM.mosquitoRisk, .low, "Riesgo inicial sin datos debería ser .low")
        XCTAssertEqual(weatherVM.authorizationStatus, .notDetermined, "Estado de autorización inicial debería ser .notDetermined")
        
        // Video por defecto sin datos
        let defaultVideo = weatherVM.weatherVideoName
        XCTAssertTrue(defaultVideo.contains("cloudy 3sec") || defaultVideo.contains("Cloudy night 3sec"),
                     "Sin datos de clima debería usar video nublado por defecto")
    }

    // Test manejo de datos nulos - comportamiento específico del ViewModel
    func testNilWeatherDataHandling() {
        // Establecer weather y luego volver a nil
        weatherVM.weather = WeatherData(temperature: 25, humidity: 70, condition: "Sunny", precipitation: 0, windSpeed: 15, sunrise: Date(), sunset: Date())
        XCTAssertEqual(weatherVM.mosquitoRisk, .high, "Debería haber riesgo alto")
        
        // Volver a nil
        weatherVM.weather = nil
        XCTAssertEqual(weatherVM.mosquitoRisk, .low, "Con weather nil, riesgo debería volver a .low")
        
        // Color por defecto
        XCTAssertEqual(weatherVM.riskColor, .green, "Con riesgo .low, color debería ser verde")
    }

    // Test de observability - verificar que las propiedades published funcionan
    func testPublishedPropertiesObservability() {
        let weatherExpectation = XCTestExpectation(description: "weather property is published")
        let authExpectation = XCTestExpectation(description: "authorization property is published")
        
        // Observar cambios en weather
        weatherVM.$weather
            .dropFirst() // Ignorar valor inicial nil
            .sink { _ in
                weatherExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Observar cambios en authorization status
        weatherVM.$authorizationStatus
            .dropFirst() // Ignorar valor inicial
            .sink { _ in
                authExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Simular cambios
        DispatchQueue.main.async {
            self.weatherVM.weather = WeatherData(temperature: 20, humidity: 50, condition: "Clear", precipitation: 0, windSpeed: 10, sunrise: Date(), sunset: Date())
            self.weatherVM.authorizationStatus = .authorizedWhenInUse
        }
        
        wait(for: [weatherExpectation, authExpectation], timeout: 1.0)
    }
}
