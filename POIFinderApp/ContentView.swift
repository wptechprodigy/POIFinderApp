//
//  ContentView.swift
//  POIFinderApp
//
//  Created by waheedCodes on 15/02/2025.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var annotations: [MKPointAnnotation] = []
    @State private var errorMessage: String?

    @State private var selectedPlace: MKMapItem? // Selected POI
    @State private var isShowingDetailsModal = false // Controls modal visibility

    var body: some View {
        ZStack {
            // Map View
            MapView(annotations: $annotations) { annotation in
                // Find the corresponding MKMapItem for the tapped annotation
                if let place = findPlace(for: annotation) {
                    selectedPlace = place
                    isShowingDetailsModal = true
                    print("Modal should now be visible.")
                }
            }
            .edgesIgnoringSafeArea(.all)

            // Details Modal
            if let place = selectedPlace, isShowingDetailsModal {
                DetailsModalView(place: place, isPresented: $isShowingDetailsModal)
                    .transition(.move(edge: .bottom)) // Slide-up animation
            }
        }
        .task {
            do {
                // Fetch the user's location
                let locationService = LocationService()
                userLocation = try await locationService.requestLocation()

                // Search for nearby places
                if let location = userLocation {
                    let mapService = MapService()
                    let places = try await mapService.searchNearbyPlaces(coordinate: location, category: "restaurants")

                    // Convert places to annotations
                    annotations = places.map { place in
                        let annotation = MKPointAnnotation()
                        annotation.title = place.name
                        annotation.subtitle = place.placemark.title
                        annotation.coordinate = place.placemark.coordinate
                        return annotation
                    }
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // Helper function to find the corresponding MKMapItem for an annotation
    private func findPlace(for annotation: MKPointAnnotation) -> MKMapItem? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = annotation.title
        request.region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)

        let search = MKLocalSearch(request: request)
        var result: MKMapItem?
        search.start { response, _ in
            result = response?.mapItems.first
        }
        return result
    }
}

#Preview {
    ContentView()
}
