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
    
    init() {
        // Customize the tab bar appearance
        UITabBar.appearance().backgroundColor = UIColor.clear
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
