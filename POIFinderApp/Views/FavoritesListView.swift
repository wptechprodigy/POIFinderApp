//
//  FavoritesListView.swift
//  POIFinderApp
//
//  Created by waheedCodes on 17/02/2025.
//

import SwiftUI
import MapKit
import CoreData

struct FavoritesListView: View {
    @Binding var favoriteAnnotations: [MKPointAnnotation]
    private let coreDataService: CoreDataService
    
    init(favoriteAnnotations: Binding<[MKPointAnnotation]>, context: NSManagedObjectContext) {
        self._favoriteAnnotations = favoriteAnnotations
        self.coreDataService = CoreDataService(context: context)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(favoriteAnnotations, id: \.title) { annotation in
                    VStack(alignment: .leading) {
                        Text(annotation.title ?? "Unknown Place")
                            .font(.headline)
                        Text(annotation.subtitle ?? "No Address")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Favorites")
        }
        .onAppear {
            loadFavoriteLocations()
        }
    }
    
    // Load favorite locations from Core Data
    private func loadFavoriteLocations() {
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
            print("Failed to fetch favorite locations: \(error.localizedDescription)")
        }
    }
}

// Extension to generate a unique ID for annotations
extension MKPointAnnotation {
    var uniqueID: String {
        "\(coordinate.latitude)-\(coordinate.longitude)"
    }
}

#Preview {
    @State var annotations: [MKPointAnnotation] = []
    return FavoritesListView(favoriteAnnotations: $annotations, context: PersistenceController.preview.container.viewContext)
}
