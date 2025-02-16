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

    var body: some View {
        VStack {
            if let error = errorMessage {
                Text("Error: \(error)")
            } else {
                MapView(annotations: $annotations)
                    .edgesIgnoringSafeArea(.all)
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
}

#Preview {
    ContentView()
}
