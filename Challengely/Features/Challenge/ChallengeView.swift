//
//  ChallengeView.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//

import SwiftUI
import ComposableArchitecture

struct ChallengeView: View {
    @Bindable var store: StoreOf<ChallengeCore>
    @State private var showShareCard = false
    @State private var showMotivationalConfetti = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.l) {
                    // Streak Ribbon shown for 2+ days streak
                    if store.profile.streakCount > 1 {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                            Text("🔥 \(store.profile.streakCount) Day Streak!")
                                .font(.title3.bold())
                                .foregroundColor(.orange)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .transition(.scale)
                        .animation(.spring(), value: store.profile.streakCount)
                    }

                    HeaderView(
                        streakCount: store.profile.streakCount,
                        state: store.challengeState
                    )

                    if let challenge = store.todaysChallenge {
                        ChallengeCard(
                            challenge: challenge,
                            state: store.challengeState,
                            timeRemaining: store.timeRemaining,
                            formattedTime: store.formattedTime,
                            onReveal: { store.send(.revealChallenge) },
                            onAccept: {
                                store.send(.acceptChallenge)
                            },
                            onComplete: {
                                store.send(.completeChallenge)
                                
                                // Trigger confetti and haptic for streak extension
                                if store.profile.streakCount > 1 {
                                    showMotivationalConfetti = true
                                    Task {
                                        try await Task.sleep(nanoseconds: UInt64(3.0 * 1_000_000_000)) // 3 sec delay
                                        showMotivationalConfetti = false
                                    }
                                }
                            },
                            onShare: {
                                showShareCard = true
                            }
                        )
                    } else {
                        Text("No challenge available for today.")
                            .foregroundColor(DS.Colors.textSecondary)
                            .font(DS.Typography.body)
                            .padding()
                    }
                }
                .padding(DS.Spacing.m)
            }
            .refreshable {
                store.send(.refreshChallenge)
            }
            .navigationTitle("Today's Challenge")
            .confetti(show: store.showConfetti > 0)
            .confetti(show: showMotivationalConfetti)
            .sheet(isPresented: $showShareCard) {
                if let challenge = store.todaysChallenge {
                    ShareSheet(
                        items: [ShareCardViewRenderer.render(
                            view: ShareCardView(challenge: challenge, streak: store.profile.streakCount)
                        )]
                    )
                }
            }
            .animation(.easeInOut, value: showShareCard)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - Header View

struct HeaderView: View {
    let streakCount: Int
    let state: ChallengeCore.State.ChallengeState

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Current Streak")
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.textSecondary)

                HStack(spacing: 4) {
                    Text("\(streakCount)")
                        .font(DS.Typography.title)
                        .foregroundColor(DS.Colors.primary)
                    Text("🔥")
                }
            }
            Spacer()
            StatusBadge(state: state)
        }
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let state: ChallengeCore.State.ChallengeState

    var body: some View {
        Text(state.displayName)
            .font(DS.Typography.caption)
            .foregroundColor(.white)
            .padding(.horizontal, DS.Spacing.s)
            .padding(.vertical, DS.Spacing.xs)
            .background(state.color)
            .clipShape(Capsule())
    }
}

// MARK: - Challenge Card and Subviews

struct ChallengeCard: View {
    let challenge: Challenge
    let state: ChallengeCore.State.ChallengeState
    let timeRemaining: TimeInterval
    let formattedTime: String
    let onReveal: () -> Void
    let onAccept: () -> Void
    let onComplete: () -> Void
    let onShare: () -> Void

    var body: some View {
        VStack(spacing: DS.Spacing.l) {
            Group {
                if state == .locked {
                    LockedContent(onReveal: onReveal)
                } else {
                    RevealedContent(challenge: challenge)
                }
            }
            .animation(DS.Animation.spring, value: state)

            if state == .inProgress {
                TimerView(formattedTime: formattedTime)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            ActionButtons(
                state: state,
                onAccept: onAccept,
                onComplete: onComplete,
                onShare: onShare
            )
        }
        .padding(DS.Spacing.l)
        .background(DS.Colors.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct LockedContent: View {
    let onReveal: () -> Void

    var body: some View {
        VStack(spacing: DS.Spacing.l) {
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(DS.Colors.textSecondary)

            Text("Today's Challenge")
                .font(DS.Typography.title)

            Text("Tap to reveal your personalized challenge")
                .font(DS.Typography.body)
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Button("Reveal Challenge") {
                onReveal()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

struct RevealedContent: View {
    let challenge: Challenge

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            HStack {
                CategoryBadge(category: challenge.category)
                Spacer()
                DifficultyBadge(difficulty: challenge.difficulty)
            }

            VStack(alignment: .leading, spacing: DS.Spacing.s) {
                Text(challenge.title)
                    .font(DS.Typography.title)

                Text(challenge.description)
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.textSecondary)
            }

            HStack {
                Image(systemName: "clock")
                    .foregroundColor(DS.Colors.textSecondary)
                Text("~\(Int(challenge.estimatedTime / 60)) min")
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CategoryBadge: View {
    let category: Challenge.Category

    var body: some View {
        Text(category.displayName)
            .font(DS.Typography.caption)
            .padding(.horizontal, DS.Spacing.s)
            .padding(.vertical, DS.Spacing.xs)
            .background(DS.Colors.primary.opacity(0.1))
            .clipShape(Capsule())
    }
}

struct DifficultyBadge: View {
    let difficulty: Challenge.Difficulty

    var body: some View {
        Text(difficulty.displayName)
            .font(DS.Typography.caption)
            .foregroundColor(.white)
            .padding(.horizontal, DS.Spacing.s)
            .padding(.vertical, DS.Spacing.xs)
            .background(difficulty.color)
            .clipShape(Capsule())
    }
}

struct TimerView: View {
    let formattedTime: String

    var body: some View {
        VStack(spacing: 6) {
            Text("Time Remaining")
                .font(DS.Typography.caption)
                .foregroundColor(DS.Colors.textSecondary)

            Text(formattedTime)
                .font(DS.Typography.largeTitle)
                .foregroundColor(DS.Colors.primary)
                .monospacedDigit()
        }
        .padding(DS.Spacing.m)
        .background(DS.Colors.primary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ActionButtons: View {
    let state: ChallengeCore.State.ChallengeState
    let onAccept: () -> Void
    let onComplete: () -> Void
    let onShare: () -> Void

    var body: some View {
        switch state {
        case .revealed:
            Button("Accept Challenge", action: onAccept)
                .buttonStyle(SuccessButtonStyle())

        case .inProgress:
            Button("Mark Complete", action: onComplete)
                .buttonStyle(PrimaryButtonStyle())

        case .completed:
            Button("Share Achievement", action: onShare)
                .buttonStyle(SuccessButtonStyle())

        case .locked:
            EmptyView()
        }
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DS.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(DS.Spacing.m)
            .background(DS.Colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

struct SuccessButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DS.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(DS.Spacing.m)
            .background(DS.Colors.success)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

// MARK: - Share Sheet Helper (Add this once globally)

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Confetti View & Extension

struct ConfettiView: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            ForEach(0..<20) { i in
                Text("🎉")
                    .font(.largeTitle)
                    .offset(
                        x: animate ? .random(in: -200...200) : 0,
                        y: animate ? .random(in: -400...400) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 2.0).delay(Double(i) * 0.1),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

extension View {
    func confetti(show: Bool) -> some View {
        self.overlay(show ? ConfettiView() : nil)
    }
}
