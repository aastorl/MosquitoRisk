//
//  StaticHeatMapView.swift
//  MosquitOFF
//
//  Created by Astor Ludueña on 04/06/2025.
//

import SwiftUI
import MapKit

struct StaticHeatMapView: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]
    let radius: CLLocationDistance
    let riskLevels: [MosquitoRisk.RiskLevel]
    let center: CLLocationCoordinate2D
    @Binding var shouldCenterMap: Bool

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        // Mostrar la ubicación del usuario con un pin azul
        let userAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = center
        userAnnotation.title = "Tu ubicación"
        mapView.addAnnotation(userAnnotation)

        // Centrar el mapa en la ubicación del usuario
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
        )
        mapView.setRegion(region, animated: false)

        // Agregar círculos de riesgo
        for (index, coordinate) in coordinates.enumerated() {
            let circle = MKCircle(center: coordinate, radius: radius)
            circle.title = riskLevels[index].rawValue // Usamos title para identificar el nivel
            mapView.addOverlay(circle)
        }

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if shouldCenterMap {
            let region = MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
            )
            mapView.setRegion(region, animated: true)
            
            // Volvemos a false después de centrar
            DispatchQueue.main.async {
                shouldCenterMap = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let circle = overlay as? MKCircle else {
                return MKOverlayRenderer()
            }

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

        // Mostrar el pin del usuario
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "UserLocationPin"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if view == nil {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view?.canShowCallout = true
                (view as? MKPinAnnotationView)?.pinTintColor = .blue
            } else {
                view?.annotation = annotation
            }

            return view
        }
    }
}



