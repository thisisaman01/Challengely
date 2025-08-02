//
//  Dependencies.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//

import Foundation
import ComposableArchitecture
import UIKit

struct HapticClient {
    var impact: (UIImpactFeedbackGenerator.FeedbackStyle) -> Void
    var notification: (UINotificationFeedbackGenerator.FeedbackType) -> Void
}

extension HapticClient: DependencyKey {
    static let liveValue = HapticClient(
        impact: { style in
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        },
        notification: { type in
            UINotificationFeedbackGenerator().notificationOccurred(type)
        }
    )
    
    static let testValue = HapticClient(
        impact: { _ in },
        notification: { _ in }
    )
}

struct StorageClient {
    var saveProfile: (UserProfile) -> Void
    var loadProfile: () -> UserProfile?
    var saveMessages: ([Message]) -> Void
    var loadMessages: () -> [Message]
}

extension StorageClient: DependencyKey {
    static let liveValue = StorageClient(
        saveProfile: { profile in
            if let data = try? JSONEncoder().encode(profile) {
                UserDefaults.standard.set(data, forKey: "profile")
            }
        },
        loadProfile: {
            guard let data = UserDefaults.standard.data(forKey: "profile"),
                  let profile = try? JSONDecoder().decode(UserProfile.self, from: data)
            else { return nil }
            return profile
        },
        saveMessages: { messages in
            if let data = try? JSONEncoder().encode(messages) {
                UserDefaults.standard.set(data, forKey: "messages")
            }
        },
        loadMessages: {
            guard let data = UserDefaults.standard.data(forKey: "messages"),
                  let messages = try? JSONDecoder().decode([Message].self, from: data)
            else { return [] }
            return messages
        }
    )
    
    static let testValue = StorageClient(
        saveProfile: { _ in },
        loadProfile: { UserProfile() },
        saveMessages: { _ in },
        loadMessages: { [] }
    )
}

extension DependencyValues {
    var haptic: HapticClient {
        get { self[HapticClient.self] }
        set { self[HapticClient.self] = newValue }
    }
    
    var storage: StorageClient {
        get { self[StorageClient.self] }
        set { self[StorageClient.self] = newValue }
    }
}
