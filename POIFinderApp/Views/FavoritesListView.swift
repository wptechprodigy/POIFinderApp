//
//  FavoritesListView.swift
//  POIFinderApp
//
//  Created by waheedCodes on 17/02/2025.
//

import SwiftUI
import MapKit

struct FavoritesListView: View {
    @Binding var favoriteAnnotations: [MKPointAnnotation]

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
    }
}

// Extension to generate a unique ID for annotations
extension MKPointAnnotation {
    var uniqueID: String {
        "\(coordinate.latitude)-\(coordinate.longitude)"
    }
}

#Preview {
    FavoritesListView(favoriteAnnotations: .constant([]))
}
