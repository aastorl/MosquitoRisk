//
//  HomeViewModel.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 22/05/2025.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var weather: WeatherData?
    @Published var mosquitoRisk: MosquitoRisk.RiskLevel = .low

    private let weatherVM = WeatherViewModel()
    private var cancellables = Set<AnyCancellable>()

    init() {
        bindWeather()
        NotificationManager.shared.requestPermission()
        // Eliminado: NotificationManager.shared.scheduleDailyReminder()
    }

    private func bindWeather() {
        weatherVM.$weather
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                guard let self, let data else { return }
                self.weather = data
                let calculatedRisk = MosquitoRisk.calculateRisk(from: data)
                self.mosquitoRisk = calculatedRisk

                // Enviar notificación solo si el riesgo es alto
                NotificationManager.shared.sendDengueRiskNotificationIfHigh(riskLevel: calculatedRisk)
            }
            .store(in: &cancellables)
    }
}



