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
    @State private var favoriteAnnotations: [MKPointAnnotation] = []
    @State private var errorMessage: String?

    @State private var selectedPlace: MKMapItem?
    @State private var isBottomSheetVisible = false
    @State private var bottomSheetOffset: CGFloat = UIScreen.main.bounds.height

    var body: some View {
        TabView {
            ZStack {
                // Map View
                MapView(annotations: $annotations, favoriteAnnotations: $favoriteAnnotations) { annotation in
                    Task {
                        if let place = await findPlace(for: annotation) {
                            selectedPlace = place
                            showBottomSheet()
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // Bottom Sheet
                if let place = selectedPlace, isBottomSheetVisible {
                    BottomSheet(place: place, isPresented: $isBottomSheetVisible)
                        .background(Color.red.opacity(0.8))
                        .offset(y: bottomSheetOffset)
                        .animation(.spring(), value: bottomSheetOffset)
                        .transition(.move(edge: .bottom))
                }
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
            .onTapGesture {
                if isBottomSheetVisible {
                    hideBottomSheet()
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
            
            // Second Tab: Favorites List
            FavoritesListView(favoriteAnnotations: $favoriteAnnotations)
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
        }
        .onAppear {
            loadFavoriteLocations()
        }
    }

    // Show the bottom sheet
    private func showBottomSheet() {
        isBottomSheetVisible = true
        bottomSheetOffset = 0
    }

    // Hide the bottom sheet
    private func hideBottomSheet() {
        bottomSheetOffset = UIScreen.main.bounds.height
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isBottomSheetVisible = false
        }
    }
    
    private func loadFavoriteLocations() {
        let coreDataService = CoreDataService(context: PersistenceController.shared.container.viewContext)
        
        do {
            let favorites = try coreDataService.fetchFavoriteLocations()
            favoriteAnnotations = favorites.map { favorite in
                let annotation = MKPointAnnotation()
                annotation.title = favorite.name
                annotation.subtitle = favorite.address
                annotation.coordinate = CLLocationCoordinate2D(latitude: favorite.latitude, longitude: favorite.longitude)
                return annotation
            }
            print("Loaded \(favoriteAnnotations.count) favorite annotations.")
        } catch {
            print("Error loading favorite locations: \(error.localizedDescription)")
        }
    }
    
    // Helper function to find the corresponding MKMapItem for an annotation
    private func findPlace(for annotation: MKPointAnnotation) async -> MKMapItem? {
        guard let title = annotation.title else {
            return nil
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = title
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)

        do {
            let response = try await MKLocalSearch(request: request).start()
            if let item = response.mapItems.first {
                return item
            } else {
                let placemark = MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = annotation.title ?? "Unknown Place"
                return mapItem
            }
        } catch {
            print("Error finding place: \(error.localizedDescription)")
            return nil
        }
    }
}

#Preview {
    ContentView()
}
