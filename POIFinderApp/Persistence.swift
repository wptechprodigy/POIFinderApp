//
//  Persistence.swift
//  POIFinderApp
//
//  Created by waheedCodes on 15/02/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "POIFinderApp")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load CoreData stack: \(error)")
            }
        }
    }
}
