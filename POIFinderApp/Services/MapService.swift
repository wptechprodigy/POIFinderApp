//
//  MapService.swift
//  POIFinderApp
//
//  Created by waheedCodes on 16/02/2025.
//

import Foundation
import MapKit

protocol MapServiceProtocol {
    func searchNearbyPlaces(coordinate: CLLocationCoordinate2D, category: String) async throws -> [MKMapItem]
}

class MapService: MapServiceProtocol {
    func searchNearbyPlaces(coordinate: CLLocationCoordinate2D, category: String) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category
        request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)

            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            return response.mapItems
    }
}
