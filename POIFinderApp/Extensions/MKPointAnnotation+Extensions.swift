//
//  MKPointAnnotation+Extensions.swift
//  POIFinderApp
//
//  Created by waheedCodes on 17/02/2025.
//

import MapKit

extension MKPointAnnotation {
    static func createAnnotation(
        id: UUID = UUID(),
        title: String?,
        subtitle: String?,
        coordinate: CLLocationCoordinate2D
    ) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = coordinate
        return annotation
    }
}
