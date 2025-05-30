//
//  MapView.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 05/05/2025.
//

import SwiftUI
import MapKit

struct RiskZone: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let riskLevel: String
}

struct HeatMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -32.9575, longitude: -60.6394),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    // Simulación de zonas de riesgo — en el futuro se puede usar WeatherData real
    let riskZones: [RiskZone] = [
        RiskZone(coordinate: CLLocationCoordinate2D(latitude: -32.95, longitude: -60.64), riskLevel: "High"),
        RiskZone(coordinate: CLLocationCoordinate2D(latitude: -32.96, longitude: -60.63), riskLevel: "Medium"),
        RiskZone(coordinate: CLLocationCoordinate2D(latitude: -32.97, longitude: -60.65), riskLevel: "Low")
    ]

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: riskZones) { zone in
            MapAnnotation(coordinate: zone.coordinate) {
                Circle()
                    .fill(color(for: zone.riskLevel).opacity(0.4))
                    .frame(width: 80, height: 80)
            }
        }
        .navigationTitle("Mosquito Risk Heatmap")
        .ignoresSafeArea(edges: .bottom)
    }

    func color(for level: String) -> Color {
        switch level {
        case "High": return .red
        case "Medium": return .orange
        default: return .green
        }
    }
}


