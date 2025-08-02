//
//  ChatView.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//
import Foundation
import SwiftUI
import ComposableArchitecture

struct ChatView: View {
    @Bindable var store: StoreOf<ChatCore>
    @FocusState private var isInputFocused: Bool
    @State private var shouldAutoScroll = true
    @State private var hasInitiallyScrolled = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    GeometryReader { outerGeo in
                        ScrollView {
                            LazyVStack(spacing: DS.Spacing.s) {
                                ForEach(store.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                                if store.isTyping {
                                    TypingIndicator()
                                        .id("typing")
                                }
                                Color.clear
                                    .frame(height: 1)
                                    .id("bottom")
                            }
                            .padding(DS.Spacing.m)
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(
                                        key: ScrollOffsetPreferenceKey.self,
                                        value: geo.frame(in: .named("scrollView")).minY
                                    )
                                }
                            )
                        }
                        .coordinateSpace(name: "scrollView")
                        .scrollDismissesKeyboard(.interactively)
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                            // Only allow auto-scroll if the user is at or near bottom (within 50pt)
                            shouldAutoScroll = offset >= -50
                        }
                        .onChange(of: store.messages.count) { old, new in
                            // Only scroll if user is at bottom
                            scrollToBottomIfNeeded(proxy: proxy, animated: false)
                        }
                        .onChange(of: store.isTyping) { _, _ in
                            scrollToBottomIfNeeded(proxy: proxy, animated: false)
                        }
                        .onAppear {
                            // Only scroll without animation when the view first loads
                            if !hasInitiallyScrolled && !store.messages.isEmpty {
                                scrollToBottomIfNeeded(proxy: proxy, animated: false)
                                hasInitiallyScrolled = true
                            }
                        }
                        .onTapGesture { dismissKeyboard() }
                    }
                }
                if !store.messages.isEmpty {
                    QuickReplies { reply in
                        store.send(.sendQuickReply(reply))
                        dismissKeyboard()
                    }
                }
                ChatInput(
                    text: Binding(
                        get: { store.currentInput },
                        set: { store.send(.inputChanged($0)) }
                    ),
                    characterCount: store.characterCount,
                    maxCount: store.maxCharacters,
                    countColor: store.characterCountColor,
                    canSend: store.canSend,
                    onSend: {
                        store.send(.sendMessage)
                        dismissKeyboard()
                        shouldAutoScroll = true
                    }
                )
                .focused($isInputFocused)
            }
            .navigationTitle("Chat Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { dismissKeyboard() }
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.primary)
                }
            }
        }
        .onAppear { store.send(.onAppear) }
    }

    private func scrollToBottomIfNeeded(proxy: ScrollViewProxy, animated: Bool) {
        guard shouldAutoScroll else { return }
        DispatchQueue.main.async {
            proxy.scrollTo("bottom", anchor: .bottom) // No animation
        }
    }

    private func dismissKeyboard() {
        isInputFocused = false
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Supporting Views

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 60)
                
                VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                    Text(message.text)
                        .font(DS.Typography.body)
                        .foregroundColor(.white)
                        .padding(DS.Spacing.m)
                        .background(DS.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Text(formatTime(message.timestamp))
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
            } else {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(message.text)
                        .font(DS.Typography.body)
                        .foregroundColor(DS.Colors.textPrimary)
                        .padding(DS.Spacing.m)
                        .background(DS.Colors.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Text(formatTime(message.timestamp))
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
                
                Spacer(minLength: 60)
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        ))
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TypingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack {
            HStack(spacing: DS.Spacing.xs) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(DS.Colors.textSecondary)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animating ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animating
                        )
                }
            }
            .padding(DS.Spacing.m)
            .background(DS.Colors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Spacer(minLength: 60)
        }
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        ))
        .onAppear {
            animating = true
        }
        .onDisappear {
            animating = false
        }
    }
}

struct QuickReplies: View {
    let onTap: (String) -> Void
    
    private let replies = [
        "Any tips?",
        "I'm feeling nervous",
        "How to stay motivated?",
        "What's today's challenge?",
        "I need help"
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.s) {
                ForEach(replies, id: \.self) { reply in
                    Button(reply) {
                        onTap(reply)
                    }
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.primary)
                    .padding(.horizontal, DS.Spacing.m)
                    .padding(.vertical, DS.Spacing.s)
                    .background(DS.Colors.primary.opacity(0.1))
                    .clipShape(Capsule())
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, DS.Spacing.m)
        }
        .padding(.bottom, DS.Spacing.s)
    }
}

struct ChatInput: View {
    @Binding var text: String
    let characterCount: Int
    let maxCount: Int
    let countColor: Color
    let canSend: Bool
    let onSend: () -> Void
    
    @State private var textHeight: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(alignment: .bottom, spacing: DS.Spacing.s) {
                ZStack(alignment: .topLeading) {
                    // Background for dynamic height
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .stroke(Color(.systemGray4), lineWidth: 1)
                        .frame(height: max(40, min(textHeight, 120)))
                    
                    TextField("Type a message...", text: $text, axis: .vertical)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .lineLimit(1...6)
                        .background(
                            // Invisible text to measure height
                            Text(text.isEmpty ? "Placeholder" : text)
                                .font(.body)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear
                                            .onAppear {
                                                textHeight = geometry.size.height
                                            }
                                            .onChange(of: text) { _, _ in
                                                textHeight = geometry.size.height
                                            }
                                    }
                                )
                                .opacity(0)
                        )
                        .onSubmit {
                            if canSend {
                                onSend()
                            }
                        }
                }
                
                Button {
                    onSend()
                } label: {
                    Image(systemName: canSend ? "arrow.up.circle.fill" : "arrow.up.circle")
                        .font(.title2)
                        .foregroundColor(canSend ? DS.Colors.primary : DS.Colors.textSecondary)
                        .scaleEffect(canSend ? 1.1 : 1.0)
                        .animation(.spring(duration: 0.3), value: canSend)
                }
                .disabled(!canSend)
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(DS.Spacing.m)
            
            // Character count
            HStack {
                Spacer()
                Text("\(characterCount)/\(maxCount)")
                    .font(DS.Typography.caption)
                    .foregroundColor(countColor)
                    .animation(.easeInOut(duration: 0.2), value: countColor)
            }
            .padding(.horizontal, DS.Spacing.m)
            .padding(.bottom, DS.Spacing.s)
        }
        .background(DS.Colors.background)
        .animation(.easeInOut(duration: 0.2), value: textHeight)
    }
}
