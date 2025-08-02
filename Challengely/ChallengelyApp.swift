//
//  ChallengelyApp.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct ChallengelyApp: App {
    static let store = Store(initialState: AppCore.State()) {
        AppCore()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: ChallengelyApp.store)
        }
    }
}
