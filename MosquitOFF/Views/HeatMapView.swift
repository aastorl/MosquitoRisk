//
//  MapView.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 05/05/2025.
//

import SwiftUI
import MapKit

struct HeatMapView: View {
    @StateObject private var viewModel = HeatMapViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -32.9575, longitude: -60.6394),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    let coordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: -32.9500, longitude: -60.6400),
        CLLocationCoordinate2D(latitude: -32.9510, longitude: -60.6300),
        CLLocationCoordinate2D(latitude: -32.9520, longitude: -60.6200),
        CLLocationCoordinate2D(latitude: -32.9530, longitude: -60.6500),
        CLLocationCoordinate2D(latitude: -32.9540, longitude: -60.6600)
    ]

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: viewModel.riskZones) { zone in
            MapAnnotation(coordinate: zone.coordinate) {
                Circle()
                    .fill(color(for: zone.riskLevel).opacity(0.4))
                    .frame(width: 80, height: 80)
            }
        }
        .onAppear {
            viewModel.fetchRiskZones(for: coordinates)
        }
        .navigationTitle("Mosquito Risk Heatmap")
        .ignoresSafeArea(edges: .bottom)
    }

    func color(for level: MosquitoRisk.RiskLevel) -> Color {
        switch level {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}


