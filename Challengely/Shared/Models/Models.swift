//
//  Models.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//
import Foundation
import SwiftUI

struct Challenge: Codable, Equatable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: Category
    let difficulty: Difficulty
    let estimatedTime: TimeInterval
    
    enum Category: String, CaseIterable, Codable {
        case fitness = "fitness"
        case creativity = "creativity"
        case mindfulness = "mindfulness"
        case learning = "learning"
        case social = "social"
        
        var emoji: String {
            switch self {
            case .fitness: return "💪"
            case .creativity: return "🎨"
            case .mindfulness: return "🧘"
            case .learning: return "📚"
            case .social: return "👥"
            }
        }
        
        var displayName: String {
            switch self {
            case .fitness: return "Fitness"
            case .creativity: return "Creativity"
            case .mindfulness: return "Mindfulness"
            case .learning: return "Learning"
            case .social: return "Social"
            }
        }
    }
    
    enum Difficulty: String, CaseIterable, Codable {
        case easy = "easy"
        case medium = "medium"
        case hard = "hard"
        
        var displayName: String {
            return rawValue.capitalized
        }
        
        var color: Color {
            switch self {
            case .easy: return DS.Colors.success
            case .medium: return DS.Colors.warning
            case .hard: return DS.Colors.error
            }
        }
    }
}

struct UserProfile: Codable, Equatable {
    var interests: Set<Challenge.Category> = []
    var difficulty: Challenge.Difficulty = .medium
    var streakCount: Int = 0
    var completedChallenges: [UUID] = []
    var lastCompletionDate: Date?
    
    init() {}
}


struct Message: Codable, Equatable , Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp = Date()
}

// Sample Data
extension Challenge {
    static let samples: [Challenge] = [
        Challenge(
            title: "Morning Meditation",
            description: "Start your day with a 10-minute mindfulness session to center yourself and set positive intentions.",
            category: .mindfulness,
            difficulty: .easy,
            estimatedTime: 600
        ),
        Challenge(
            title: "Creative Writing Sprint",
            description: "Write continuously for 15 minutes about anything that comes to mind. Let your creativity flow without judgment.",
            category: .creativity,
            difficulty: .medium,
            estimatedTime: 900
        ),
        Challenge(
            title: "HIIT Workout",
            description: "Complete a 20-minute high-intensity interval training session to boost your energy and strengthen your body.",
            category: .fitness,
            difficulty: .hard,
            estimatedTime: 1200
        ),
        Challenge(
            title: "Learn Something New",
            description: "Spend 25 minutes learning about a topic that interests you through videos, articles, or podcasts.",
            category: .learning,
            difficulty: .medium,
            estimatedTime: 1500
        ),
        Challenge(
            title: "Connect with Someone",
            description: "Reach out to a friend or family member you haven't spoken to in a while. Have a meaningful conversation.",
            category: .social,
            difficulty: .easy,
            estimatedTime: 900
        ),
        Challenge(
            title: "Digital Art Creation",
            description: "Create a digital artwork or design using your favorite app. Express yourself through colors and shapes.",
            category: .creativity,
            difficulty: .hard,
            estimatedTime: 1800
        )
    ]
}
