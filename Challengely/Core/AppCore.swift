//
//  AppCore.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppCore {
    @ObservableState
    struct State: Equatable {
        var isOnboardingComplete = false
        var onboarding = OnboardingCore.State()
        var main = MainCore.State()
        
        init() {
            self.isOnboardingComplete = UserDefaults.standard.bool(forKey: "onboarding_complete")
        }
    }
    
    enum Action {
        case onboarding(OnboardingCore.Action)
        case main(MainCore.Action)
        case onboardingCompleted
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingCore()
        }
        
        Scope(state: \.main, action: \.main) {
            MainCore()
        }
        
        Reduce { state, action in
            switch action {
            case .onboardingCompleted:
                state.isOnboardingComplete = true
                UserDefaults.standard.set(true, forKey: "onboarding_complete")
                return .none
                
            case .onboarding(.completed):
                return .send(.onboardingCompleted)
                
            case .onboarding, .main:
                return .none
            }
        }
    }
}
