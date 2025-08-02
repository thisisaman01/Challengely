//
//  MainView.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//

import SwiftUI
import ComposableArchitecture

struct MainView: View {
    @Bindable var store: StoreOf<MainCore>
    
    var body: some View {
        TabView(selection: Binding(
            get: { store.selectedTab },
            set: { store.send(.tabSelected($0)) }
        )) {
            ChallengeView(store: store.scope(state: \.challenge, action: MainCore.Action.challenge))
                .tabItem {
                    Image(systemName: MainCore.State.Tab.challenge.icon)
                    Text(MainCore.State.Tab.challenge.title)
                }
                .tag(MainCore.State.Tab.challenge)
            
            ChatView(store: store.scope(state: \.chat, action: MainCore.Action.chat))
                .tabItem {
                    Image(systemName: MainCore.State.Tab.chat.icon)
                    Text(MainCore.State.Tab.chat.title)
                }
                .tag(MainCore.State.Tab.chat)
            
            ProfileView(store: store.scope(state: \.profile, action: MainCore.Action.profile))
                .tabItem {
                    Image(systemName: MainCore.State.Tab.profile.icon)
                    Text(MainCore.State.Tab.profile.title)
                }
                .tag(MainCore.State.Tab.profile)
                
            AnalyticsDashboardView(store: store.scope(state: \.analytics, action: MainCore.Action.analytics))
                .tabItem {
                    Image(systemName: MainCore.State.Tab.analytics.icon)
                    Text(MainCore.State.Tab.analytics.title)
                }
                .tag(MainCore.State.Tab.analytics)
        }
        .accentColor(DS.Colors.primary)
    }
}
