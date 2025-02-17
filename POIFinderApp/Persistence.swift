//
//  Persistence.swift
//  POIFinderApp
//
//  Created by waheedCodes on 15/02/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    // Preview instance for SwiftUI previews
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        
        // Add mock data for previews (optional)
        let viewContext = result.container.viewContext
        for i in 1...5 {
            let favoriteLocation = PointOfInterests(context: viewContext)
            favoriteLocation.id = UUID()
            favoriteLocation.name = "Preview Location \(i)"
            favoriteLocation.category = "Restaurant"
            favoriteLocation.address = "123 Test St \(i)"
            favoriteLocation.latitude = 37.33182 + Double(i) * 0.01
            favoriteLocation.longitude = -122.03118 + Double(i) * 0.01
        }
        
        // Save the mock data
        do {
            try viewContext.save()
        } catch {
            print("Error saving mock data: \(error.localizedDescription)")
        }
        
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "POIFinderApp")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
}
