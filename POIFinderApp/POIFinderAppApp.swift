//
//  POIFinderAppApp.swift
//  POIFinderApp
//
//  Created by waheedCodes on 15/02/2025.
//

import SwiftUI

@main
struct POIFinderAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
