//
//  ReportMapView.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 21/05/2025.
//

// Deprecated

import SwiftUI
import MapKit

struct ReportMapView: View {
    var reports: [Report]

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -32.95, longitude: -60.65), // Rosario por defecto
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: reports.compactMap { $0.toMapItem() }) { item in
            MapMarker(coordinate: item.coordinate, tint: .red)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Mapa de Reportes")
    }
}

extension Report {
    func toMapItem() -> IdentifiableLocation? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return IdentifiableLocation(id: id, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
    }
}

struct IdentifiableLocation: Identifiable {
    var id: UUID
    var coordinate: CLLocationCoordinate2D
}

