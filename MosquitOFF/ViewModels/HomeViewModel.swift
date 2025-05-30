//
//  HomeViewModel.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 22/05/2025.
//

import Foundation
import Combine
import CoreLocation

class HomeViewModel: ObservableObject {
    @Published var weather: WeatherData?
    @Published var reports: [Report] = []
    @Published var showToast = false

    private let weatherVM = WeatherViewModel()
    private let reportManager = ReportManager()
    private let locationManager = LocationManager()

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadReports()
        bindWeather()
        NotificationManager.shared.requestPermission()
        NotificationManager.shared.scheduleDailyReminder()
    }

    private func bindWeather() {
        weatherVM.$weather
            .receive(on: RunLoop.main)
            .assign(to: \.weather, on: self)
            .store(in: &cancellables)
    }

    func loadReports() {
        reports = reportManager.loadReports()
    }

    func addReport() {
        let location = locationManager.location
        let newReport = Report(
            type: "Mosquito",
            description: "Mosquito avistado en la zona",
            timestamp: Date(),
            latitude: location?.latitude,
            longitude: location?.longitude
        )
        reports.append(newReport)
        reportManager.saveReports(reports)
        showToast = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showToast = false
        }
    }

    func mosquitoRisk(for data: WeatherData) -> String {
        let temp = data.temperature
        let humidity = data.humidity
        let precipitation = data.precipitation

        if temp >= 25 && humidity >= 60 && precipitation > 1.0 {
            return "High"
        } else if temp >= 20 && humidity >= 40 {
            return "Medium"
        } else {
            return "Low"
        }
    }
}

