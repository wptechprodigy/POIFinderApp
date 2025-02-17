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

class LocationService: NSObject, ObservableObject, LocationServiceProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var errorMessage: String?
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    
    // Flag to track if the continuation has been resumed
    private var isContinuationResumed = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        requestPermission()
    }
    
    // Check the current authorization status
    private func checkAuthorizationStatus() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            // Request permission if not determined
            locationManager.requestWhenInUseAuthorization()
            return false
        case .denied, .restricted:
            // Show an error message if access is denied or restricted
            errorMessage = "Location access denied. Please enable location services in Settings."
            return false
        case .authorizedWhenInUse, .authorizedAlways:
            // Proceed with location updates if authorized
            return true
        @unknown default:
            return false
        }
    }
    
    // Delegate method: Called when the authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        _ = checkAuthorizationStatus()
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Request the user's location
    func requestLocation() async throws -> CLLocationCoordinate2D {
        // Check if we have permission to access location
        guard checkAuthorizationStatus() else {
            throw NSError(domain: "LocationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location access not granted"])
        }
        
        // Use a continuation to wait for the location result
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            locationManager.requestLocation()
        }
    }
    
    // Location is successfully fetched
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
            DispatchQueue.main.async {
                self.userLocation = location
                self.continuation?.resume(returning: location)
                self.continuation = nil
            }
        }
    }
    
    // Error when fetching location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Unable to determine your location. Please try again."
            self.continuation?.resume(throwing: error)
            self.continuation = nil
        }
    }
}
