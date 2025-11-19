//
//  StaticHeatMapView.swift
//  
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
    let userLocation: CLLocationCoordinate2D?
    let locationNames: [String] // 👈 Nuevo parámetro para los nombres
    @Binding var shouldCenterMap: Bool

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        // Configurar zoom y desplazamiento
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        // Centrar en Rosario
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
        )
        mapView.setRegion(region, animated: false)

        // Agregar círculos de riesgo
        for (index, coordinate) in coordinates.enumerated() {
            let circle = MKCircle(center: coordinate, radius: radius)
            circle.title = riskLevels[index].rawValue
            mapView.addOverlay(circle)
            
            // AGREGAR ANOTACIÓN CON NOMBRE
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = locationNames[index] // Usar el nombre correspondiente
            mapView.addAnnotation(annotation)
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
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let identifier = "LocationPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            if let markerView = annotationView as? MKMarkerAnnotationView,
               let title = annotation.title ?? "" {
                
                // LISTA EXPLÍCITA DE ISLAS
                let islas = ["Banquito de San Andres", "Isla La Invernada", "Paraná Viejo"]
                
                if islas.contains(title) {
                    // ISLAS - Palmera color azul/verde
                    markerView.markerTintColor = .systemTeal
                    markerView.glyphImage = UIImage(systemName: "beach.umbrella.fill")
                } else {
                    // PARQUES - Árbol color verde
                    markerView.markerTintColor = .systemGreen
                    markerView.glyphImage = UIImage(systemName: "tree.fill")
                }
                
                markerView.glyphTintColor = .white
            }
            
            return annotationView
        }
    }
}



