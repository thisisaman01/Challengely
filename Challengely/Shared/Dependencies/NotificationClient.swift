//
//  NotificationClient.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//

import Foundation
import UserNotifications
import ComposableArchitecture

struct NotificationClient {
    var requestPermission: @Sendable () async -> Bool
    var schedule: @Sendable (Date, String) async -> Void
    var scheduleWeekly: @Sendable (Date, String) async -> Void
}

extension NotificationClient: DependencyKey {
    static let liveValue = NotificationClient(
        requestPermission: {
            let center = UNUserNotificationCenter.current()
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                return false
            }
        },
        schedule: { date, body in
            let content = UNMutableNotificationContent()
            content.title = "Your daily challenge is ready!"
            content.body = body
            content.sound = .default

            var comps = Calendar.current.dateComponents([.hour, .minute], from: date)
            comps.second = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )
            try? await UNUserNotificationCenter.current().add(request)
        },
        scheduleWeekly: { date, body in
            let content = UNMutableNotificationContent()
            content.title = "Your weekly challenge is ready!"
            content.body = body
            content.sound = .default

            var comps = Calendar.current.dateComponents([.weekday, .hour, .minute], from: date)
            comps.second = 0
            // If weekday not present, default to Monday (2)
            if comps.weekday == nil {
                comps.weekday = 2
            }
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )
            try? await UNUserNotificationCenter.current().add(request)
        }
    )
}

extension DependencyValues {
    var notification: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}

