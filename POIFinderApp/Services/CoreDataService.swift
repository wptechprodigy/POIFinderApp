//
//  CoreDataService.swift
//  POIFinderApp
//
//  Created by waheedCodes on 17/02/2025.
//

import CoreData

class CoreDataService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // Save a favorite location
    func saveFavoriteLocation(name: String, category: String, address: String, latitude: Double, longitude: Double) throws {
        let favoriteLocation = PointOfInterests(context: context)
        favoriteLocation.id = UUID()
        favoriteLocation.name = name
        favoriteLocation.category = category
        favoriteLocation.address = address
        favoriteLocation.latitude = latitude
        favoriteLocation.longitude = longitude

        try context.save()
        print("Saved favorite location: \(name)")
    }

    // Fetch all favorite locations
    func fetchFavoriteLocations() throws -> [PointOfInterests] {
        let request: NSFetchRequest<PointOfInterests> = PointOfInterests.fetchRequest()
        let favorites = try context.fetch(request)
        print("Fetched \(favorites.count) favorite locations.")
        return favorites
    }
}
