//
//  ChallengelyApp.swift
//  Challengely
//
//  Created by Admin on 01/08/25.
//

import SwiftUI

@main
struct ChallengelyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
