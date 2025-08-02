//
//  ContentView.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    @Bindable var store: StoreOf<AppCore>
    
    var body: some View {
        Group {
            if store.isOnboardingComplete {
                MainView(store: store.scope(state: \.main, action: \.main))
            } else {
                OnboardingView(store: store.scope(state: \.onboarding, action: \.onboarding))
            }
        }
        .animation(DS.Animation.spring, value: store.isOnboardingComplete)
    }
}

#Preview {
    ContentView(store: Store(initialState: AppCore.State()) {
        AppCore()
    })
}
