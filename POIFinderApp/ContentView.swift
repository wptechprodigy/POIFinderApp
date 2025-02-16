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
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if let location = userLocation {
                Text("Your Location: \(location.latitude), \(location.longitude)")
            } else if let error = errorMessage {
                Text("Error: \(error)")
            } else {
                Text("Fetching location...")
            }
        }
        .task {
            do {
                let locationService = LocationService()
                userLocation = try await locationService.requestLocation()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    ContentView()
}
