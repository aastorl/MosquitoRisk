//
//  MapCircleView.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 03/06/2025.
//

import SwiftUI
import MapKit

struct StaticHeatMapView: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]
    let radius: CLLocationDistance = 300 // metros
    let riskLevels: [MosquitoRisk.RiskLevel]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        let region = MKCoordinateRegion(
            center: coordinates[0],
            span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
        )
        mapView.setRegion(region, animated: false)

        for (index, coordinate) in coordinates.enumerated() {
            let circle = MKCircle(center: coordinate, radius: radius)
            circle.title = riskLevels[index].rawValue // para saber el color
            mapView.addOverlay(circle)
        }

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let circle = overlay as? MKCircle else { return MKOverlayRenderer() }
            let renderer = MKCircleRenderer(circle: circle)

            switch circle.title {
            case MosquitoRisk.RiskLevel.high.rawValue:
                renderer.fillColor = UIColor.red.withAlphaComponent(0.3)
            case MosquitoRisk.RiskLevel.medium.rawValue:
                renderer.fillColor = UIColor.orange.withAlphaComponent(0.3)
            case MosquitoRisk.RiskLevel.low.rawValue:
                renderer.fillColor = UIColor.green.withAlphaComponent(0.3)
            default:
                renderer.fillColor = UIColor.gray.withAlphaComponent(0.3)
            }

            renderer.strokeColor = .clear
            return renderer
        }
    }
}

