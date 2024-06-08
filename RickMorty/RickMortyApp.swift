//
//  RickMortyApp.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import SwiftUI

@main
struct RickMortyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
