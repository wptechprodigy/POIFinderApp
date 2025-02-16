//
//  MapView.swift
//  POIFinderApp
//
//  Created by waheedCodes on 16/02/2025.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var annotations: [MKPointAnnotation]
    var onAnnotationTapped: (MKPointAnnotation) -> Void // Callback for annotation taps
    
    // Specific region to emulate since testing is done, at the moment, on the simulator
    let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.33182, longitude: -122.03118),
        latitudinalMeters: 1000,
        longitudinalMeters: 1000
    )
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true    // Enable zooming
        mapView.isScrollEnabled = true  // Enable scrolling
        mapView.setRegion(region, animated: true)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        // Handle annotation selection
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? MKPointAnnotation {
                parent.onAnnotationTapped(annotation)
            }
        }
    }
}
