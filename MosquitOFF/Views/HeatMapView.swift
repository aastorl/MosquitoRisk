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
    @State private var showRiskInfo = false

    // Diccionario con múltiples puntos por parque
    let parks: [String: [CLLocationCoordinate2D]] = [
        "Parque Urquiza": [
            CLLocationCoordinate2D(latitude: -32.9572, longitude: -60.6235),
            CLLocationCoordinate2D(latitude: -32.9575, longitude: -60.6228),
            CLLocationCoordinate2D(latitude: -32.9570, longitude: -60.6240)
        ],
        "Parque de las Colectividades": [
            CLLocationCoordinate2D(latitude: -32.9324, longitude: -60.6465),
            CLLocationCoordinate2D(latitude: -32.9326, longitude: -60.6458)
        ],
        "Parque Alem": [
            CLLocationCoordinate2D(latitude: -32.9095, longitude: -60.6780),
            CLLocationCoordinate2D(latitude: -32.9093, longitude: -60.6775)
        ],
        "Parque Scalabrini Ortiz": [
            CLLocationCoordinate2D(latitude: -32.9300, longitude: -60.6676),
            CLLocationCoordinate2D(latitude: -32.9298, longitude: -60.6670)
        ],
        "Independencia": [
            CLLocationCoordinate2D(latitude: -32.9591, longitude: -60.6600),
            CLLocationCoordinate2D(latitude: -32.9588, longitude: -60.6595)
        ]
    ]

    let radius: CLLocationDistance = 400

    var body: some View {
        if let userLocation = locationManager.location,
           viewModel.riskZones.count == parks.count {

            ZStack {
                StaticHeatMapView(
                    coordinates: viewModel.riskZones.map { $0.coordinate },
                    radius: radius,
                    riskLevels: viewModel.riskZones.map { $0.riskLevel },
                    center: userLocation,
                    shouldCenterMap: $shouldCenterMap
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    // Botón centrado debajo del notch
                    Button(action: {
                        showRiskInfo = true
                    }) {
                        Label("¿Qué es esto?", systemImage: "info.circle.fill")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .shadow(radius: 3)
                    }
                    .safeAreaPadding(.top)
                    .offset(y: -15) // Ajustá el valor según cómo lo querés de cerca del notch

                    Spacer()

                    // Botón de centrar mapa abajo a la derecha
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
            .sheet(isPresented: $showRiskInfo) {
                HeatMapInfoSheet()
            }

        } else {
            ProgressView("Cargando mapa y niveles de riesgo...")
                .onAppear {
                    viewModel.fetchRiskZones(for: parks)
                }
        }
    }
}

#Preview {
    HeatMapView()
}









