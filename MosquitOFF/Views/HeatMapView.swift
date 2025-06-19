//
//  HeatMapView.swift
//  MosquitOFF
//
//  Created by Astor Ludueña on 05/05/2025.
//

import SwiftUI
import MapKit

struct HeatMapView: View {
    @StateObject private var viewModel = HeatMapViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var shouldCenterMap = false

    let coordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: -32.957245, longitude: -60.623553), // Parque Urquiza
        CLLocationCoordinate2D(latitude: -32.932412, longitude: -60.646578), // Parque de las Colectividades
        CLLocationCoordinate2D(latitude: -32.909576, longitude: -60.678004), // Parque Alem
        CLLocationCoordinate2D(latitude: -32.930025, longitude: -60.667628), // Parque Scalabrini Ortiz
        CLLocationCoordinate2D(latitude: -32.932412, longitude: -60.646578), // Costanera
        CLLocationCoordinate2D(latitude: -32.959189, longitude: -60.660016)  // Independencia
    ]

    let radius: CLLocationDistance = 400

    var body: some View {
        if let userLocation = locationManager.location,
           viewModel.riskZones.count == coordinates.count {

            ZStack {
                StaticHeatMapView(
                    coordinates: coordinates,
                    radius: radius,
                    riskLevels: viewModel.riskZones.map { $0.riskLevel },
                    center: userLocation,
                    shouldCenterMap: $shouldCenterMap
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            shouldCenterMap = true
                        }) {
                            Image(systemName: "location.fill")
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }

        } else {
            ProgressView("Cargando mapa y niveles de riesgo...")
                .onAppear {
                    viewModel.fetchRiskZones(for: coordinates)
                }
        }
    }
}









