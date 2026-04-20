//
//  HeatMapView.swift
//  
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
    @State private var showLocationAlert = false
    @State private var selectedZone: RiskZone? = nil   // zona tapeada en el mapa

    // Coordenadas del centro de Rosario, Santa Fe, Argentina
    private let rosarioCenter = CLLocationCoordinate2D(latitude: -32.9442, longitude: -60.6505)

    // Diccionario con MÚLTIPLES PUNTOS por isla para mayor precisión
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
        "Independencia": [
            CLLocationCoordinate2D(latitude: -32.9591, longitude: -60.6600),
            CLLocationCoordinate2D(latitude: -32.9588, longitude: -60.6595)
        ],
        "Parque Scalabrini Ortiz": [
            CLLocationCoordinate2D(latitude: -32.9300, longitude: -60.6676),
            CLLocationCoordinate2D(latitude: -32.9298, longitude: -60.6670)
        ],
        "Parque Alem": [
            CLLocationCoordinate2D(latitude: -32.9095, longitude: -60.6780),
            CLLocationCoordinate2D(latitude: -32.9093, longitude: -60.6775)
        ],
        
        // 🏝️ ISLAS CON MÚLTIPLES PUNTOS PARA MAYOR PRECISIÓN
        "Banquito de San Andres": [
            // Punto norte de la isla
            CLLocationCoordinate2D(latitude: -32.96900, longitude: -60.59690),
            // Punto central
            CLLocationCoordinate2D(latitude: -32.97095, longitude: -60.59690),
            // Punto sur
            CLLocationCoordinate2D(latitude: -32.97290, longitude: -60.59690),
            // Punto este (costa hacia el río)
            CLLocationCoordinate2D(latitude: -32.97095, longitude: -60.59490)
        ],
        
        "Isla La Invernada": [
            // Extremo norte
            CLLocationCoordinate2D(latitude: -32.90610, longitude: -60.64590),
            // Norte-centro
            CLLocationCoordinate2D(latitude: -32.90760, longitude: -60.64590),
            // Centro
            CLLocationCoordinate2D(latitude: -32.90910, longitude: -60.64590),
            // Sur-centro
            CLLocationCoordinate2D(latitude: -32.91060, longitude: -60.64590),
            // Extremo sur
            CLLocationCoordinate2D(latitude: -32.91210, longitude: -60.64590),
            // Punto oeste (hacia Rosario)
            CLLocationCoordinate2D(latitude: -32.90910, longitude: -60.64790)
        ],
        
        "Paraná Viejo": [
            // Extremo norte de la isla
            CLLocationCoordinate2D(latitude: -32.88140, longitude: -60.64790),
            // Norte-centro
            CLLocationCoordinate2D(latitude: -32.88290, longitude: -60.64790),
            // Centro principal
            CLLocationCoordinate2D(latitude: -32.88440, longitude: -60.64790),
            // Sur-centro
            CLLocationCoordinate2D(latitude: -32.88590, longitude: -60.64790),
            // Extremo sur
            CLLocationCoordinate2D(latitude: -32.88740, longitude: -60.64790),
            // Punto este (interior de la isla)
            CLLocationCoordinate2D(latitude: -32.88440, longitude: -60.64590)
        ]
    ]

    let radius: CLLocationDistance = 400

    var body: some View {
        if viewModel.riskZones.count == parks.count {
            ZStack {
                StaticHeatMapView(
                    coordinates: viewModel.riskZones.map { $0.coordinate },
                    radius: radius,
                    riskLevels: viewModel.riskZones.map { $0.riskLevel },
                    center: rosarioCenter,
                    userLocation: locationManager.location,
                    locationNames: viewModel.orderedNames,
                    riskZones: viewModel.riskZones,
                    shouldCenterMap: $shouldCenterMap,
                    selectedZone: $selectedZone
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    // Botón de información
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
                    .offset(y: -15)

                    Spacer()

                    // Botón de centrar
                    HStack {
                        Spacer()
                        Button(action: {
                            shouldCenterMap = true
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: locationManager.location != nil ? "location.fill" : "location.slash")
                                    .font(.system(size: 16))
                                Text("Rosario")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $showRiskInfo) {
                HeatMapInfoSheet()
            }
            .sheet(item: $selectedZone) { zone in
                ZoneDetailSheet(zone: zone)
            }
            .alert("Ubicación no disponible", isPresented: $showLocationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("No se pudo obtener tu ubicación. El mapa se centrará en Rosario.")
            }
            .onAppear {
                locationManager.requestLocation()
            }

        } else {
            ProgressView("Cargando mapa y niveles de riesgo...")
                .onAppear {
                    viewModel.fetchRiskZones(for: parks)
                    locationManager.requestLocation()
                }
        }
    }
}

#Preview {
    HeatMapView()
}








