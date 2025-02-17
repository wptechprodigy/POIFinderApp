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
            List(favoriteAnnotations, id: \.coordinate.latitude) { annotation in
                VStack(alignment: .leading) {
                    Text(annotation.title ?? "Unknown Place")
                        .font(.headline)
                    Text(annotation.subtitle ?? "No Address")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoritesListView(favoriteAnnotations: .constant([]))
}
