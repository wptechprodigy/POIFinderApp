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
    
    // Flag to track if the continuation has been resumed
    private var isContinuationResumed = false
    
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
        
        // Mark the continuation as resumed
        isContinuationResumed = true
        continuation?.resume(returning: location)
    }
    
    // Error when fetching location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.locationManager.requestLocation()
                }
            case .denied:
                print("Location access denied by the user.")
            default:
                print("Other CoreLocation error: \(clError.localizedDescription)")
            }
        } else {
            print("Unknown error: \(error.localizedDescription)")
        }
        
        // Mark the continuation as resumed
        isContinuationResumed = true
        continuation?.resume(throwing: error)
    }
}
