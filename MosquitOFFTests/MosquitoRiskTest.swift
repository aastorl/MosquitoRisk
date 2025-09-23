//
//  MosquitOFFTests.swift
//  MosquitOFFTests
//
//  Created by Astor Ludueña  on 07/08/2025.
//

import XCTest
@testable import MosquitOFF

final class MosquitRiskTest: XCTestCase {

    // Caso 1: Riesgo alto por temperatura y humedad
    func testHighRiskBase() {
        let weather = WeatherData(
            temperature: 28,
            humidity: 80,
            condition: "Sunny",
            precipitation: 0,
            windSpeed: 10,
            sunrise: Date(),
            sunset: Date()
        )

        let risk = MosquitoRisk.calculateRisk(from: weather)
        XCTAssertEqual(risk, .high, "Esperaba riesgo ALTO pero obtuve \(risk)")
    }

    // Caso 2: Riesgo medio por temperatura y humedad
    func testMediumRiskBase() {
        let weather = WeatherData(
            temperature: 20,
            humidity: 55,
            condition: "Cloudy",
            precipitation: 0,
            windSpeed: 10,
            sunrise: Date(),
            sunset: Date()
        )

        let risk = MosquitoRisk.calculateRisk(from: weather)
        XCTAssertEqual(risk, .medium, "Esperaba riesgo MEDIO pero obtuve \(risk)")
    }

    // Caso 3: Riesgo bajo por clima seco y frío
    func testLowRiskBase() {
        let weather = WeatherData(
            temperature: 15,
            humidity: 40,
            condition: "Cloudy",
            precipitation: 0,
            windSpeed: 10,
            sunrise: Date(),
            sunset: Date()
        )

        let risk = MosquitoRisk.calculateRisk(from: weather)
        XCTAssertEqual(risk, .low, "Esperaba riesgo BAJO pero obtuve \(risk)")
    }

    // Caso 4: Lluvia eleva el riesgo (medium -> high)
    func testRainIncreasesRiskToHigh() {
        let weather = WeatherData(
            temperature: 19, // Temperatura en rango medio (18-21)
            humidity: 55,    // Humedad ≥50 para riesgo medio
            condition: "Rain",
            precipitation: 6, // ≥ 5 mm eleva el riesgo
            windSpeed: 10,
            sunrise: Date(),
            sunset: Date()
        )

        let risk = MosquitoRisk.calculateRisk(from: weather)
        XCTAssertEqual(risk, .high, "Esperaba que la lluvia eleve de MEDIO a ALTO pero obtuve \(risk)")
    }

    // Caso 5: Lluvia eleva riesgo bajo a medio
    func testRainIncreasesLowToMedium() {
        let weather = WeatherData(
            temperature: 16, // Temperatura fuera de rangos alto/medio
            humidity: 45,    // Humedad baja
            condition: "Rain",
            precipitation: 6, // ≥ 5 mm eleva el riesgo
            windSpeed: 10,
            sunrise: Date(),
            sunset: Date()
        )

        let risk = MosquitoRisk.calculateRisk(from: weather)
        XCTAssertEqual(risk, .medium, "Esperaba que la lluvia eleve de BAJO a MEDIO pero obtuve \(risk)")
    }

    // Caso 6: Viento fuerte fuerza riesgo a bajo
    func testStrongWindForcesLowRisk() {
        let weather = WeatherData(
            temperature: 30,
            humidity: 80,
            condition: "Sunny",
            precipitation: 0,
            windSpeed: 40, // ≥ 40 km/h fuerza riesgo bajo
            sunrise: Date(),
            sunset: Date()
        )

        let risk = MosquitoRisk.calculateRisk(from: weather)
        XCTAssertEqual(risk, .low, "Esperaba que el viento fuerte fuerce riesgo BAJO pero obtuve \(risk)")
    }

    // Caso 7: Viento moderado reduce un nivel de riesgo
    func testModerateWindReducesRisk() {
        let weather = WeatherData(
            temperature: 30,
            humidity: 80,
            condition: "Sunny",
            precipitation: 0,
            windSpeed: 35, // entre 30-39 km/h reduce un nivel
            sunrise: Date(),
            sunset: Date()
        )

        let risk = MosquitoRisk.calculateRisk(from: weather)
        XCTAssertEqual(risk, .medium, "Esperaba que el viento moderado reduzca de ALTO a MEDIO pero obtuve \(risk)")
    }

    // Caso 8: Casos límite - temperatura exacta en umbral
    func testBoundaryTemperature22() {
        let weather = WeatherData(
            temperature: 22, // exactamente en el límite para alto
            humidity: 60,    // exactamente en el límite para alto
            condition: "Sunny",
            precipitation: 0,
            windSpeed: 10,
            sunrise: Date(),
            sunset: Date()
        )

        let risk = MosquitoRisk.calculateRisk(from: weather)
        XCTAssertEqual(risk, .high, "Esperaba riesgo ALTO en temperatura límite 22°C pero obtuve \(risk)")
    }

    // Caso 9: Temperatura justo debajo del umbral alto
    func testTemperatureJustBelowHighThreshold() {
        let weather = WeatherData(
            temperature: 21.9, // justo debajo de 22
            humidity: 65,
            condition: "Sunny",
            precipitation: 0,
            windSpeed: 10,
            sunrise: Date(),
            sunset: Date()
        )

        let risk = MosquitoRisk.calculateRisk(from: weather)
        XCTAssertEqual(risk, .low, "Esperaba riesgo BAJO cuando temperatura está justo debajo del umbral pero obtuve \(risk)")
    }

    // Caso 10: Combinación compleja - alta temperatura, lluvia y viento moderado
    func testComplexCombination() {
        let weather = WeatherData(
            temperature: 30,  // Alto
            humidity: 80,     // Alto
            condition: "Rain",
            precipitation: 8, // Lluvia intensa (no debería cambiar alto)
            windSpeed: 35,    // Viento moderado que reduce un nivel
            sunrise: Date(),
            sunset: Date()
        )

        let risk = MosquitoRisk.calculateRisk(from: weather)
        // Base: alto, lluvia: sigue alto, viento moderado: reduce a medio
        XCTAssertEqual(risk, .medium, "Esperaba riesgo MEDIO por combinación compleja pero obtuve \(risk)")
    }
}
