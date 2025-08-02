//
//  ChatCore.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//

import Foundation
import ComposableArchitecture
import SwiftUICore

@Reducer
struct ChatCore {
    @ObservableState
    struct State: Equatable {
        var messages: [Message] = []
        var currentInput = ""
        var isTyping = false
        var characterCount = 0
        let maxCharacters = 500
        
        var canSend: Bool {
            !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            characterCount <= maxCharacters && !isTyping
        }
        
        var characterCountColor: Color {
            let ratio = Double(characterCount) / Double(maxCharacters)
            if ratio < 0.7 { return DS.Colors.success }
            if ratio < 0.9 { return DS.Colors.warning }
            return DS.Colors.error
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case inputChanged(String)
        case sendMessage
        case sendQuickReply(String)
        case aiResponseReceived(String)
        case startTyping
        case stopTyping
    }
    
    @Dependency(\.storage) var storage
    @Dependency(\.haptic) var haptic
    @Dependency(\.continuousClock) var clock
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.messages = storage.loadMessages()
                if state.messages.isEmpty {
                    state.messages = [
                        Message(text: "Hi! 👋 I'm your challenge assistant. How can I help you today?", isFromUser: false)
                    ]
                }
                return .none
                
            case .inputChanged(let text):
                let limited = String(text.prefix(state.maxCharacters))
                state.currentInput = limited
                state.characterCount = limited.count
                return .none
                
            case .sendMessage:
                return .send(.sendQuickReply(state.currentInput))
                
            case .sendQuickReply(let text):
                guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return .none
                }
                
                haptic.impact(.light)
                let userMessage = Message(text: text, isFromUser: true)
                state.messages.append(userMessage)
                state.currentInput = ""
                state.characterCount = 0
                
                storage.saveMessages(state.messages)
                
                return .send(.startTyping)
                
            case .startTyping:
                state.isTyping = true
                
                return .run { [lastMessage = state.messages.last?.text ?? ""] send in
                    try await clock.sleep(for: .seconds(Double.random(in: 1.5...3.0)))
                    let response = generateAIResponse(for: lastMessage)
                    await send(.aiResponseReceived(response))
                }
                
            case .aiResponseReceived(let response):
                state.isTyping = false
                let aiMessage = Message(text: response, isFromUser: false)
                state.messages.append(aiMessage)
                storage.saveMessages(state.messages)
                return .none
                
            case .stopTyping:
                state.isTyping = false
                return .none
            }
        }
    }
}

// AI Response Generator
private func generateAIResponse(for input: String) -> String {
    let lowercased = input.lowercased()
    
    if lowercased.contains("challenge") || lowercased.contains("what") {
        return "Today's challenge is designed just for you! Check the Challenge tab to see what awaits. 🎯"
    }
    
    if lowercased.contains("nervous") || lowercased.contains("scared") {
        return "It's totally normal to feel nervous! Remember, every expert was once a beginner. Start small and you've got this! 💪"
    }
    
    if lowercased.contains("motivation") || lowercased.contains("help") {
        return "You're already taking the first step by being here! That's amazing. What specific area would you like motivation for? 🌟"
    }
    
    if lowercased.contains("streak") {
        return "Streaks are powerful! 🔥 Every day you complete a challenge, you're building a better version of yourself. Keep going!"
    }
    
    if lowercased.contains("thank") {
        return "You're so welcome! I'm here whenever you need encouragement or guidance. You're doing great! ✨"
    }
    
    let responses = [
        "That's a great point! How are you feeling about today's challenge? 🤔",
        "I understand! Remember, progress over perfection. What's one small step you can take? 🚀",
        "You're doing amazing by just showing up! What would be most helpful right now? 💚",
        "Interesting! Tell me more about how you're feeling about your goals. 🎯",
        "I'm here to support you! Is there anything specific about challenges you'd like to know? 🤝"
    ]
    
    return responses.randomElement() ?? "Tell me more about that! I'm here to help. 😊"
}

