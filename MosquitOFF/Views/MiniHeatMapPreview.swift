//
//  MiniHeatMapPreview.swift
//  MosquitOFF
//
//  Created by Astor Ludueña on 03/07/2025.
//

import SwiftUI
import MapKit

struct MiniHeatMapPreview: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -32.944162, longitude: -60.647046), // Centro de Rosario
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    var body: some View {
        Map(coordinateRegion: $region, interactionModes: [], showsUserLocation: false)
            .cornerRadius(16)
    }
}

#Preview {
    MiniHeatMapPreview()
}
