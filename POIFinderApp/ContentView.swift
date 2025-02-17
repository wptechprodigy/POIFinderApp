//
//  ContentView.swift
//  POIFinderApp
//
//  Created by waheedCodes on 15/02/2025.
//

import SwiftUI
import MapKit
import Combine

struct ContentView: View {
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var annotations: [MKPointAnnotation] = []
    @State private var favoriteAnnotations: [MKPointAnnotation] = []
    @State private var errorMessage: String?

    @State private var selectedPlace: MKMapItem?
    @State private var isBottomSheetVisible = false
    @State private var bottomSheetOffset: CGFloat = UIScreen.main.bounds.height
    
    @State private var searchQuery: String = ""
    @StateObject private var searchService = SearchViewModel()
    
    // Publisher for debouncing search queries
    private let searchQueryPublisher = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    @StateObject private var locationService = LocationService()

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
                .safeAreaInset(edge: .top) {
                    VStack {
                        HStack {
                            TextField("Search places...", text: $searchQuery)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .onChange(of: searchQuery) { _, newValue in
                                    searchService.search(query: newValue)
                                }
                            
                            Button(action: {
                                searchQuery = ""
                                searchService.searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                }
                
                // Display Autocomplete Suggestions
                if !searchService.searchResults.isEmpty {
                    List(searchService.searchResults, id: \.subtitle) { result in
                        VStack(alignment: .leading) {
                            Text(result.title)
                                .font(.headline)
                            Text(result.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            handleSearchSelection(result)
                        }
                    }
                    .frame(height: 350)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 4)
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .top))
                }
                
                // Bottom Sheet
                if let place = selectedPlace, isBottomSheetVisible {
                    BottomSheet(place: place, isPresented: $isBottomSheetVisible)
                        .background(Color.red.opacity(0.8))
                        .offset(y: bottomSheetOffset)
                        .animation(.spring(), value: bottomSheetOffset)
                        .transition(.move(edge: .bottom))
                }
                
                // Error Alert
                if let errorMessage = errorMessage ?? locationService.errorMessage {
                    ErrorAlert(message: errorMessage, dismissAction: {
                        self.errorMessage = nil
                        locationService.errorMessage = nil
                    })
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
                    handle(error: error)
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
            searchService.setupSearchDebouncer()
        }
    }
    
    // Handle selection of an autocomplete suggestion
    private func handleSearchSelection(_ result: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                handle(error: error)
            }
            
            if let mapItems = response?.mapItems {
                self.annotations = mapItems.map { item in
                    let annotation = MKPointAnnotation()
                    annotation.title = item.name
                    annotation.subtitle = item.placemark.title
                    annotation.coordinate = item.placemark.coordinate
                    return annotation
                }
            }
        }
        
        searchQuery = "" // Clear the search query
        searchService.searchResults = [] // Clear the suggestions
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
        } catch {
            handle(error: error)
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
            handle(error: error)
            return nil
        }
    }
    
    // Centralized Error Handler
    private func handle(error: Error) {
        if let mkError = error as? MKError {
            // Handle MapKit-specific errors
            switch mkError.code {
            case .loadingThrottled:
                errorMessage = "Too many requests. Please try again later."
            default:
                errorMessage = "A MapKit error occurred: \(mkError.localizedDescription)"
            }
        } else if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                errorMessage = "Location access denied. Please enable location services in Settings."
            case .locationUnknown:
                errorMessage = "Unable to determine your location. Please try again."
            default:
                errorMessage = "An error occurred: \(clError.localizedDescription)"
            }
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(SearchViewModel())
        .preferredColorScheme(.light)
}
