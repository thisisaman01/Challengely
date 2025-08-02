//
//  ProfileCore.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//

import Foundation
import ComposableArchitecture
import SwiftUI

enum NotificationFrequency: String, Codable, Equatable, CaseIterable, Identifiable {
    case daily
    case weekly
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        }
    }
}

@Reducer
struct ProfileCore {
    @ObservableState
    struct State: Equatable {
        var userProfile = UserProfile()
        var isLoading = false
        var errorMessage: String?
        
        // Notification properties
        var notificationsEnabled: Bool = true
        var notificationTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        var notificationFrequency: NotificationFrequency = .daily
        var isTestingNotification: Bool = false
        
        var nextNotificationDisplay: String {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            return "\(notificationFrequency.description) at \(formatter.string(from: notificationTime))"
        }
    }
    
    enum Action: Equatable {
        case load
        case profileLoaded(UserProfile)
        case updateProfile(UserProfile)
        
        case toggleNotifications(Bool)
        case updateNotificationTime(Date)
        case updateNotificationFrequency(NotificationFrequency)
        
        case scheduleNotification
        case sendTestNotification
        case notificationScheduled(Result<Bool, Never>)
        case testNotificationSent(Result<Bool, Never>)
    }
    
    @Dependency(\.storage) var storage
    @Dependency(\.notification) var notification
    @Dependency(\.haptic) var haptic
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .load:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    if let profile = await storage.loadProfile() {
                        await send(.profileLoaded(profile))
                    }
                }
                
            case let .profileLoaded(profile):
                state.userProfile = profile
                state.isLoading = false
                return .none
                
            case let .updateProfile(profile):
                state.userProfile = profile
                return .run { _ in
                    await storage.saveProfile(profile)
                }
                
            case let .toggleNotifications(enabled):
                state.notificationsEnabled = enabled
                if enabled {
                    return .send(.scheduleNotification)
                }
                return .none
                
            case let .updateNotificationTime(newTime):
                state.notificationTime = newTime
                if state.notificationsEnabled {
                    return .send(.scheduleNotification)
                }
                return .none
                
            case let .updateNotificationFrequency(newFrequency):
                state.notificationFrequency = newFrequency
                if state.notificationsEnabled {
                    return .send(.scheduleNotification)
                }
                return .none
                
            case .scheduleNotification:
                // Copy needed properties out of 'state' so closure does not capture 'inout' state variable
                let notificationsEnabled = state.notificationsEnabled
                let notificationTime = state.notificationTime
                let notificationFrequency = state.notificationFrequency
                
                guard notificationsEnabled else { return .none }
                
                return .run { send in
                    let granted = await notification.requestPermission()
                    if granted {
                        switch notificationFrequency {
                        case .daily:
                            await notification.schedule(notificationTime, "Tap to see your daily challenge!")
                        case .weekly:
                            await notification.scheduleWeekly(notificationTime, "Tap to see your weekly challenge!")
                        }
                        await send(.notificationScheduled(.success(true)))
                    } else {
                        await send(.notificationScheduled(.success(false)))
                    }
                }
                
            case .sendTestNotification:
                let notificationsEnabled = state.notificationsEnabled
                guard notificationsEnabled else { return .none }
                
                state.isTestingNotification = true
                
                return .run { send in
                    let granted = await notification.requestPermission()
                    if granted {
                        // Schedule test notification for 1 minute from now
                        let testTime = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date().addingTimeInterval(60)
                        await notification.schedule(testTime, "🎯 Test notification from Challengely! Your notifications are working perfectly.")
                        await send(.testNotificationSent(.success(true)))
                    } else {
                        await send(.testNotificationSent(.success(false)))
                    }
                }
                
            case let .notificationScheduled(result):
                switch result {
                case .success(let granted):
                    if granted {
                        return .run { _ in await haptic.notification(.success) }
                    } else {
                        state.errorMessage = "Notification permission denied. Please enable notifications in Settings."
                        return .run { _ in await haptic.notification(.warning) }
                    }
                }
                return .none
                
            case let .testNotificationSent(result):
                state.isTestingNotification = false
                switch result {
                case .success(let granted):
                    if granted {
                        state.errorMessage = nil
                        return .run { _ in await haptic.notification(.success) }
                    } else {
                        state.errorMessage = "Unable to send test notification. Please check your notification settings."
                        return .run { _ in await haptic.notification(.error) }
                    }
                }
                return .none
            }
        }
    }
}
