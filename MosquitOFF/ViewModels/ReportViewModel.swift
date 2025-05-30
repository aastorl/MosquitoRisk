//
//  ReportViewModel.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 05/05/2025.
//

// Deprecated

import Foundation
import CoreLocation
import Combine

class ReportViewModel: ObservableObject {
    @Published var level: String = "Medium"
    @Published var comment: String = ""
    @Published var location: CLLocationCoordinate2D?

    private var locationManager = LocationManager()

    init() {
        locationManager.$location
            .compactMap { $0 }
            .first()
            .sink { [weak self] coord in
                self?.location = coord
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    func submitReport() {
        guard let location = location else { return }

        // Aca se puede conectar con FirebaseService más adelante
        print("""
        📝 Report Sent:
        Level: \(level)
        Comment: \(comment)
        Lat: \(location.latitude), Lon: \(location.longitude)
        """)
        
        // Reiniciar después de enviar
        level = "Medium"
        comment = ""
    }
}

