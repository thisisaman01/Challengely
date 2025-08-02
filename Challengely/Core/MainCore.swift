//
//  MainCore.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//
import Foundation
import ComposableArchitecture

@Reducer
struct MainCore {
    @ObservableState
    struct State: Equatable {
        
        enum Tab: String, Equatable, CaseIterable, Identifiable {
            case challenge, chat, profile, analytics
            var id: String { rawValue }
            var title: String {
                switch self {
                case .challenge: return "Challenge"
                case .chat: return "Chat"
                case .profile: return "Profile"
                case .analytics: return "Analytics"
                }
            }
            var icon: String {
                switch self {
                case .challenge: return "target"
                case .chat: return "message"
                case .profile: return "person.circle"
                case .analytics: return "chart.bar"
         
                }
            }
        }
        var selectedTab: Tab = .challenge
        var challenge = ChallengeCore.State()
        var chat = ChatCore.State()
        var profile = ProfileCore.State()
        var analytics = AnalyticsCore.State()
//        var builder = ChallengeBuilderCore.State()
    }
    enum Action: Equatable {
        case tabSelected(State.Tab)
        case challenge(ChallengeCore.Action)
        case chat(ChatCore.Action)
        case profile(ProfileCore.Action)
        case analytics(AnalyticsCore.Action)
//        case builder(ChallengeBuilderCore.Action)
    }
    var body: some Reducer<State, Action> {
        Scope(state: \.challenge, action: /Action.challenge) { ChallengeCore() }
        Scope(state: \.chat, action: /Action.chat) { ChatCore() }
        Scope(state: \.profile, action: /Action.profile) { ProfileCore() }
        Scope(state: \.analytics, action: /Action.analytics) { AnalyticsCore() }
//        Scope(state: \.builder, action: /Action.builder) { ChallengeBuilderCore() }
        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
            case .challenge, .chat, .profile, .analytics:
                return .none
            }
        }
    }
}
