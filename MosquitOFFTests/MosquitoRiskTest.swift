//
//  MosquitOFFTests.swift
//  MosquitOFFTests
//
//  Created by Astor Ludueña  on 07/08/2025.
//

import XCTest
@testable import MosquitOFF

final class MosquitOFFTests: XCTestCase {

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

    // Caso 4: Lluvia eleva el riesgo (low -> medium)
    func testRainIncreasesRisk() {
        let weather = WeatherData(
            temperature: 16,
            humidity: 40,
            condition: "Rain",
            precipitation: 6, // ≥ 5 mm
            windSpeed: 10,
            sunrise: Date(),
            sunset: Date()
        )

        let risk = MosquitoRisk.calculateRisk(from: weather)
        XCTAssertEqual(risk, .medium, "Esperaba que la lluvia aumente a MEDIO pero obtuve \(risk)")
    }

    // Caso 5: Viento fuerte baja riesgo a low
    func testStrongWindReducesRisk() {
        let weather = WeatherData(
            temperature: 30,
            humidity: 80,
            condition: "Sunny",
            precipitation: 0,
            windSpeed: 40, // ≥ 40 km/h
            sunrise: Date(),
            sunset: Date()
        )

        let risk = MosquitoRisk.calculateRisk(from: weather)
        XCTAssertEqual(risk, .low, "Esperaba que el viento fuerte reduzca a BAJO pero obtuve \(risk)")
    }

    // Caso 6: Viento moderado baja un nivel de riesgo
    func testModerateWindReducesRisk() {
        let weather = WeatherData(
            temperature: 30,
            humidity: 80,
            condition: "Sunny",
            precipitation: 0,
            windSpeed: 35, // entre 30 y 39
            sunrise: Date(),
            sunset: Date()
        )

        let risk = MosquitoRisk.calculateRisk(from: weather)
        XCTAssertEqual(risk, .medium, "Esperaba que el viento moderado reduzca a MEDIO pero obtuve \(risk)")
    }
}
