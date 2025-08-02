//
//  OnboardingCore.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//
import Foundation
import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct OnboardingCore {
    @ObservableState
    struct State: Equatable {
        var currentStep = 0
        var selectedInterests: Set<Challenge.Category> = []
        var selectedDifficulty: Challenge.Difficulty = .medium
        var isComplete = false
    }
    
    enum Action {
        case nextStep
        case previousStep
        case skipOnboarding
        case selectInterest(Challenge.Category)
        case selectDifficulty(Challenge.Difficulty)
        case completed
    }

    @Dependency(\.storage) var storage
    @Dependency(\.notification) var notification
    @Dependency(\.haptic) var haptic
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextStep:
                haptic.impact(.light)
                if state.currentStep < 3 {
                    state.currentStep += 1
                } else {
                    return .send(.completed)
                }
                return .none
                
            case .previousStep:
                if state.currentStep > 0 {
                    state.currentStep -= 1
                }
                return .none
                
            case .skipOnboarding:
                state.selectedInterests = Set(Challenge.Category.allCases)
                return .send(.completed)
                
            case .selectInterest(let interest):
                haptic.impact(.light)
                if state.selectedInterests.contains(interest) {
                    state.selectedInterests.remove(interest)
                } else {
                    state.selectedInterests.insert(interest)
                }
                return .none
                
            case .selectDifficulty(let difficulty):
                haptic.impact(.light)
                state.selectedDifficulty = difficulty
                return .none
                
            case .completed:
                state.isComplete = true
                var profile = UserProfile()
                profile.interests = state.selectedInterests
                profile.difficulty = state.selectedDifficulty
                
                return .run { [profile = profile] send in
                    await storage.saveProfile(profile)
                    
                    // Request notification permission & schedule daily reminder
                    let granted = await notification.requestPermission()
                    if granted {
                        let date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
                        await notification.schedule(date, "Tap to see your daily challenge!")
                    }
                }
            }
        }
    }
}
