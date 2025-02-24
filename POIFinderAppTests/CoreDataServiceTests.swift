//
//  CoreDataServiceTests.swift
//  POIFinderAppTests
//
//  Created by waheedCodes on 17/02/2025.
//

import XCTest
@testable import POIFinderApp
import CoreData

final class CoreDataServiceTests: XCTestCase {
    private var coreDataService: CoreDataService!
    private var mockContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        mockContext = PersistenceController.preview.container.viewContext
        coreDataService = CoreDataService(context: mockContext)
    }

    override func tearDown() {
        coreDataService = nil
        mockContext = nil
        super.tearDown()
    }

    func testSaveFavoriteLocation() {
        let favorite = PointOfInterests(context: mockContext)
        favorite.id = UUID()
        favorite.name = "Test Location"
        favorite.category = "Restaurant"
        favorite.address = "123 Test St"
        favorite.latitude = 37.33182
        favorite.longitude = -122.03118
        
        do {
            try coreDataService.saveFavoriteLocation(favorite)
            let favorites = try coreDataService.fetchFavoriteLocations()
            XCTAssertTrue(favorites.contains(where: { $0.name == "Test Location" }), "Saved location should exist in CoreData")
        } catch {
            XCTFail("Failed to save or fetch favorite location: \(error.localizedDescription)")
        }
    }

    func testFetchFavoriteLocations() {
        let favorite = PointOfInterests(context: mockContext)
        favorite.id = UUID()
        favorite.name = "Test Location"
        favorite.category = "Restaurant"
        favorite.address = "123 Test St"
        favorite.latitude = 37.33182
        favorite.longitude = -122.03118
        
        do {
            try coreDataService.saveFavoriteLocation(name: favorite)
            let favorites = try coreDataService.fetchFavoriteLocations()
            XCTAssertEqual(favorites.count, 1, "There should be one favorite location")
        } catch {
            XCTFail("Failed to fetch favorite locations: \(error.localizedDescription)")
        }
    }
}
