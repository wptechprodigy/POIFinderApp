//
//  LocationService.swift
//  POIFinderApp
//
//  Created by waheedCodes on 15/02/2025.
//

import Foundation
import CoreLocation

protocol LocationServiceProtocol {
    func requestLocation() async throws -> CLLocationCoordinate2D
}

class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // Request user's location
    func requestLocation() async throws -> CLLocationCoordinate2D {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
    }
    
    // Location is successfully fetched: safe to call
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        continuation?.resume(returning: location)
    }
    
    // Error when fetching location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
    }
}
