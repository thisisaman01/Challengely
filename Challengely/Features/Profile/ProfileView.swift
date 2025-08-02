//
//  ProfileView.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    @Bindable var store: StoreOf<ProfileCore>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                Form {
                    // Profile info
                    Section("Your Profile") {
                        ProfileInfoRow(title: "Interests", value: formattedInterests(viewStore.userProfile.interests))
                        ProfileInfoRow(title: "Difficulty", value: viewStore.userProfile.difficulty.displayName)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Streak")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                HStack {
                                    Text("\(viewStore.userProfile.streakCount)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(DS.Colors.primary)
                                    Text("🔥")
                                        .font(.title2)
                                }
                            }
                            Spacer()
                        }
                    }
                    
                    // Enhanced Notification Management
                    Section("Notification Settings") {
                        Toggle("Enable Daily Reminders", isOn: viewStore.binding(
                            get: { $0.notificationsEnabled },
                            send: ProfileCore.Action.toggleNotifications
                        ))
                        
                        if viewStore.notificationsEnabled {
                            DatePicker("Reminder Time",
                                     selection: viewStore.binding(
                                        get: { $0.notificationTime },
                                        send: ProfileCore.Action.updateNotificationTime
                                     ),
                                     displayedComponents: [.hourAndMinute])
                            
                            Picker("Frequency", selection: viewStore.binding(
                                get: { $0.notificationFrequency },
                                send: ProfileCore.Action.updateNotificationFrequency
                            )) {
                                ForEach(NotificationFrequency.allCases) { freq in
                                    Text(freq.description).tag(freq)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            HStack {
                                Image(systemName: "bell.badge")
                                    .foregroundColor(DS.Colors.primary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Next notification")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(viewStore.nextNotificationDisplay)
                                        .font(.body)
                                        .foregroundColor(DS.Colors.primary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    // Quick Actions
                    Section("Quick Actions") {
                        Button(action: {
                            viewStore.send(.sendTestNotification)
                        }) {
                            HStack {
                                if viewStore.isTestingNotification {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "bell.circle.fill")
                                        .foregroundColor(DS.Colors.success)
                                }
                                Text(viewStore.isTestingNotification ? "Sending..." : "Send Test Notification")
                                Spacer()
                                if !viewStore.isTestingNotification {
                                    Text("in 1 min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .disabled(!viewStore.notificationsEnabled || viewStore.isTestingNotification)
                        
                        if viewStore.notificationsEnabled {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                Text("Test notification will arrive in 1 minute")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.large)
                .overlay {
                    if viewStore.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.25))
                    }
                }
                .alert("Notification Status", isPresented: Binding(
                    get: { viewStore.errorMessage != nil },
                    set: { _ in }
                )) {
                    Button("OK", role: .cancel) { }
                } message: {
                    if let message = viewStore.errorMessage {
                        Text(message)
                    }
                }
                .onAppear {
                    viewStore.send(.load)
                }
            }
        }
    }
    
    private func formattedInterests(_ interests: Set<Challenge.Category>) -> String {
        if interests.isEmpty {
            return "No interests selected"
        }
        return interests.map { $0.displayName }.sorted().joined(separator: ", ")
    }
}

// Helper view for consistent profile info display
struct ProfileInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
            Spacer()
        }
    }
}

