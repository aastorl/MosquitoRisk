//
//  HomeViewModelTest.swift
//  MosquitOFFTests
//
//  Created by Astor Ludueña  on 07/08/2025.
//

import XCTest
import Combine
@testable import MosquitOFF

final class HomeViewModelTest: XCTestCase {

    var homeVM: HomeViewModel!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        homeVM = HomeViewModel()
    }

    override func tearDown() {
        homeVM = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testMosquitoRiskUpdatesWhenWeatherChanges() {
        let expectation = XCTestExpectation(description: "mosquitoRisk updates when weather changes")

        // Observamos el mosquitoRisk para ver si cambia
        homeVM.$mosquitoRisk
            .dropFirst() // Ignorar el valor inicial
            .sink { risk in
                // Esperamos que el riesgo sea high según los datos que le pasamos
                if risk == .high {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Simulamos que el WeatherViewModel cambió su weather con datos de alto riesgo
        let highRiskWeather = WeatherData(
            temperature: 28,
            humidity: 80,
            condition: "Sunny",
            precipitation: 0,
            windSpeed: 10,
            sunrise: Date(),
            sunset: Date()
        )

        // Accedemos al WeatherViewModel interno para setear el weather manualmente
        homeVM.weatherVM.weather = highRiskWeather

        wait(for: [expectation], timeout: 1.0)
    }
}

