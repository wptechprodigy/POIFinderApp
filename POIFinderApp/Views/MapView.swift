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
    @Binding var favoriteAnnotations: [MKPointAnnotation]
    var onAnnotationTapped: (MKPointAnnotation) -> Void
    
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
        uiView.addAnnotations(annotations + favoriteAnnotations)
        print("Added annotations to the map.")
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
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            print("Annotation deselected.")
        }
    }
}

// Placeholder for Previews
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        // Use a placeholder view instead of the live MapView
        Rectangle()
            .fill(Color.blue)
            .frame(height: 300)
            .overlay(Text("Map Preview"))
    }
}
