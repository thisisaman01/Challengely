//
//  ChallengeCore.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//
import SwiftUI
import ComposableArchitecture

@Reducer
struct ChallengeCore {
    @ObservableState
    struct State: Equatable {
        var profile = UserProfile()
        var todaysChallenge: Challenge?
        var challengeState: ChallengeState = .locked
        var timeRemaining: TimeInterval = 0
        var isTimerRunning = false
        var showConfetti = 0
        
        enum ChallengeState: Equatable {
            case locked, revealed, inProgress, completed
        }
        
        var formattedTime: String {
            let minutes = Int(timeRemaining) / 60
            let seconds = Int(timeRemaining) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
        
        var isCompletedToday: Bool {
            guard let lastCompletion = profile.lastCompletionDate else { return false }
            return Calendar.current.isDate(lastCompletion, inSameDayAs: Date())
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case revealChallenge
        case acceptChallenge
        case timerTick
        case completeChallenge
        case shareChallenge
        case refreshChallenge
    }
    
    @Dependency(\.storage) var storage
    @Dependency(\.haptic) var haptic
    @Dependency(\.continuousClock) var clock
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let profile = storage.loadProfile() {
                    state.profile = profile
                }
                
                // Get today's challenge
                let filteredChallenges = Challenge.samples.filter { challenge in
                    state.profile.interests.isEmpty || state.profile.interests.contains(challenge.category)
                }
                
                let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
                state.todaysChallenge = filteredChallenges[dayIndex % filteredChallenges.count]
                
                // Check if already completed today
                if state.isCompletedToday {
                    state.challengeState = .completed
                } else {
                    state.challengeState = .locked
                }
                return .none
                
            case .revealChallenge:
                haptic.impact(.medium)
                state.challengeState = .revealed
                return .none
                
            case .acceptChallenge:
                haptic.notification(.success)
                state.challengeState = .inProgress
                state.timeRemaining = state.todaysChallenge?.estimatedTime ?? 600
                state.isTimerRunning = true
                
                // Your requested timer logic
                return .run { send in
                    while true {
                        await send(.timerTick, animation: .none)
                        try await clock.sleep(for: .seconds(1))
                    }
                }
                
            case .timerTick:
                guard state.isTimerRunning && state.timeRemaining > 0 else {
                    state.isTimerRunning = false
                    return .send(.completeChallenge)
                }
                state.timeRemaining -= 1
                return .none
                
            case .completeChallenge:
                // Prevent multiple completions on same day
                guard !state.isCompletedToday else { return .none }
                
                haptic.notification(.success)
                state.challengeState = .completed
                state.isTimerRunning = false
                state.showConfetti += 1
                
                // Updatedd profile with streak logic
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                
                if let lastCompletion = state.profile.lastCompletionDate {
                    let lastCompletionDay = calendar.startOfDay(for: lastCompletion)
                    let daysBetween = calendar.dateComponents([.day], from: lastCompletionDay, to: today).day ?? 0
                    
                    if daysBetween == 1 {
                        // Consecutive day - increment streak
                        state.profile.streakCount += 1
                    } else if daysBetween > 1 {
                        // Streak broken - reset to 1
                        state.profile.streakCount = 1
                    }
                    // Same day (daysBetween == 0) - don't change streak
                } else {
                    // First ever completion
                    state.profile.streakCount = 1
                }
                
                state.profile.lastCompletionDate = Date()
                if let challengeId = state.todaysChallenge?.id {
                    state.profile.completedChallenges.append(challengeId)
                }
                
                storage.saveProfile(state.profile)
                return .none
                
            case .shareChallenge:
                // TODO: Implement native share functionality
                return .none
                
            case .refreshChallenge:
                return .send(.onAppear)
            }
        }
    }
}

extension ChallengeCore.State.ChallengeState {
    var displayName: String {
        switch self {
        case .locked: return "Locked"
        case .revealed: return "Ready"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }
    var color: Color {
        switch self {
        case .locked: return DS.Colors.textSecondary
        case .revealed: return DS.Colors.warning
        case .inProgress: return DS.Colors.primary
        case .completed: return DS.Colors.success
        }
    }
}
