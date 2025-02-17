//
//  MockData.swift
//  POIFinderApp
//
//  Created by waheedCodes on 17/02/2025.
//

import MapKit

struct MockData {
    static let mockAnnotations: [MKPointAnnotation] = [
        MKPointAnnotation(__coordinate: CLLocationCoordinate2D(latitude: 37.33182, longitude: -122.03118), title: "Apple HQ", subtitle: "Cupertino"),
        MKPointAnnotation(__coordinate: CLLocationCoordinate2D(latitude: 37.332, longitude: -122.031), title: "Cupertino Library", subtitle: "Cupertino")
    ]
    
    static let mockFavoriteAnnotations: [MKPointAnnotation] = [
        MKPointAnnotation(__coordinate: CLLocationCoordinate2D(latitude: 37.33182, longitude: -122.03118), title: "Apple HQ", subtitle: "Cupertino")
    ]
}
