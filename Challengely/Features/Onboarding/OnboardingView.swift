//
//  OnboardingView.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//

//  ⚡ 🎯 🚀
import Foundation
import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    let store: StoreOf<OnboardingCore>
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                // Neon glass background
                NeonBackground()
                
                VStack(spacing: 0) {
                    VStack(spacing: DS.Spacing.l) {
                        HStack {
                            stepIndicator(viewStore.currentStep)
                            Spacer()
                            skipButton {
                                viewStore.send(.skipOnboarding)
                            }
                        }
                        
                        progressBar(currentStep: viewStore.currentStep)
                    }
                    .padding(.horizontal, DS.Spacing.l)
                    .padding(.top, DS.Spacing.m)
                    .padding(.bottom, DS.Spacing.xl)
                    
                    TabView(selection: Binding(
                        get: { viewStore.currentStep },
                        set: { _ in }
                    )) {
                        WelcomeStep()
                            .tag(0)
                        IntroStep()
                            .tag(1)
                        InterestsStep(
                            selected: viewStore.selectedInterests,
                            onTap: { category in viewStore.send(.selectInterest(category)) }
                        )
                        .tag(2)
                        DifficultyStep(
                            selected: viewStore.selectedDifficulty,
                            onTap: { difficulty in viewStore.send(.selectDifficulty(difficulty)) }
                        )
                        .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.spring(duration: 0.6), value: viewStore.currentStep)
                    
                    NavigationButtons(
                        currentStep: viewStore.currentStep,
                        canProceed: canProceed(for: viewStore),
                        onBack: { viewStore.send(.previousStep) },
                        onNext: {
                            if viewStore.currentStep == 3 {
                                viewStore.send(.completed)
                            } else {
                                viewStore.send(.nextStep)
                            }
                        }
                    )
                    .padding(.horizontal, DS.Spacing.l)
                    .padding(.bottom, DS.Spacing.l)
                }
            }
        }
    }
    
    private func canProceed(for viewStore: ViewStoreOf<OnboardingCore>) -> Bool {
        switch viewStore.currentStep {
        case 0, 1:
            return true
        case 2:
            return !viewStore.selectedInterests.isEmpty
        case 3:
            return viewStore.selectedDifficulty != .medium || viewStore.selectedDifficulty == .medium
        default:
            return false
        }
    }
    
    // Neon style components
    private func stepIndicator(_ currentStep: Int) -> some View {
        Text("Step \(currentStep + 1) of 4")
            .font(DS.Typography.caption.weight(.medium))
            .foregroundColor(DS.Colors.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.thinMaterial)
            .overlay(neonBorder)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: neonGlow, radius: 8)
    }
    
    private func skipButton(action: @escaping () -> Void) -> some View {
        Button("Skip", action: action)
            .font(DS.Typography.body.weight(.semibold))
            .foregroundColor(neonAccentColor)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(.thinMaterial)
            .overlay(neonAccentBorder)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: neonAccentGlow, radius: 10)
    }
    
    private func progressBar(currentStep: Int) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 6)
                .fill(.thinMaterial)
                .overlay(neonBorder)
                .frame(height: 10)
            
            RoundedRectangle(cornerRadius: 6)
                .fill(neonProgressGradient)
                .frame(height: 10)
                .scaleEffect(x: Double(currentStep) / 3.0, y: 1, anchor: .leading)
                .shadow(color: neonAccentGlow, radius: 8)
                .animation(.spring(duration: 0.8), value: currentStep)
        }
    }
    
    // Neon style properties
    private var neonBorder: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(neonBorderColor, lineWidth: 1)
    }
    
    private var neonAccentBorder: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(neonAccentColor, lineWidth: 1.5)
    }
    
    private var neonBorderColor: Color {
        colorScheme == .dark ? Color.cyan.opacity(0.4) : Color.blue.opacity(0.3)
    }
    
    private var neonAccentColor: Color {
        colorScheme == .dark ? Color.cyan : DS.Colors.primary
    }
    
    private var neonGlow: Color {
        colorScheme == .dark ? Color.cyan.opacity(0.3) : Color.blue.opacity(0.2)
    }
    
    private var neonAccentGlow: Color {
        colorScheme == .dark ? Color.cyan.opacity(0.4) : DS.Colors.primary.opacity(0.3)
    }
    
    private var neonProgressGradient: LinearGradient {
        LinearGradient(
            colors: [neonAccentColor, neonAccentColor.opacity(0.7)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Neon Background
struct NeonBackground: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var animate = false
    
    private var backgroundColors: [Color] {
        colorScheme == .dark ?
        [Color(red: 0.02, green: 0.05, blue: 0.12), Color(red: 0.05, green: 0.02, blue: 0.15)] :
        [Color(red: 0.96, green: 0.98, blue: 1.0), Color(red: 0.94, green: 0.96, blue: 0.99)]
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: backgroundColors,
                startPoint: animate ? .topLeading : .bottomTrailing,
                endPoint: animate ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)
            
            // Neon orbs
            NeonOrbs()
        }
        .onAppear { animate = true }
    }
}

struct NeonOrbs: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var orb1 = CGSize.zero
    @State private var orb2 = CGSize.zero
    @State private var orb3 = CGSize.zero
    
    var body: some View {
        ZStack {
            Circle()
                .fill(neonOrb1Color)
                .frame(width: 220, height: 220)
                .blur(radius: 30)
                .offset(orb1)
                .animation(.easeInOut(duration: 14).repeatForever(autoreverses: true), value: orb1)
            
            Circle()
                .fill(neonOrb2Color)
                .frame(width: 160, height: 160)
                .blur(radius: 25)
                .offset(orb2)
                .animation(.easeInOut(duration: 11).repeatForever(autoreverses: true), value: orb2)
            
            Circle()
                .fill(neonOrb3Color)
                .frame(width: 120, height: 120)
                .blur(radius: 20)
                .offset(orb3)
                .animation(.easeInOut(duration: 9).repeatForever(autoreverses: true), value: orb3)
        }
        .onAppear {
            orb1 = CGSize(width: -130, height: -250)
            orb2 = CGSize(width: 170, height: 130)
            orb3 = CGSize(width: -70, height: 190)
        }
    }
    
    private var neonOrb1Color: Color {
        colorScheme == .dark ? Color.cyan.opacity(0.25) : Color.blue.opacity(0.15)
    }
    
    private var neonOrb2Color: Color {
        colorScheme == .dark ? Color.purple.opacity(0.2) : Color.purple.opacity(0.12)
    }
    
    private var neonOrb3Color: Color {
        colorScheme == .dark ? Color.pink.opacity(0.18) : Color.pink.opacity(0.1)
    }
}

// MARK: - Navigation Buttons
struct NavigationButtons: View {
    let currentStep: Int
    let canProceed: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: DS.Spacing.m) {
            if currentStep > 0 {
                backButton
            }
            
            Spacer()
            
            nextButton
        }
    }
    
    private var backButton: some View {
        Button(action: onBack) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .font(DS.Typography.headline)
            .foregroundColor(DS.Colors.textPrimary)
            .padding(.vertical, DS.Spacing.m)
            .padding(.horizontal, DS.Spacing.l)
            .background(.thinMaterial)
            .overlay(neonButtonBorder)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: neonButtonGlow, radius: 6)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var nextButton: some View {
        Button(action: onNext) {
            HStack(spacing: 8) {
                Text(currentStep == 3 ? "Get Started" : "Next")
                    .font(DS.Typography.headline.weight(.semibold))
                
                if currentStep == 3 {
                    Text("🚀")
                        .font(.system(size: 18))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .padding(.vertical, DS.Spacing.m)
            .padding(.horizontal, DS.Spacing.xl)
            .background(nextButtonBackground)
            .overlay(nextButtonBorder)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: nextButtonShadow, radius: nextButtonShadowRadius)
            .scaleEffect(canProceed ? 1.0 : 0.98)
        }
        .disabled(!canProceed)
        .buttonStyle(ScaleButtonStyle())
        .animation(.spring(duration: 0.3), value: canProceed)
    }
    
    private var neonButtonBorder: some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(neonBorderColor, lineWidth: 1)
    }
    
    private var nextButtonBackground: Color {
        canProceed ? DS.Colors.primary : DS.Colors.textSecondary.opacity(0.6)
    }
    
    private var nextButtonBorder: some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(
                canProceed ? Color.white.opacity(0.3) : Color.clear,
                lineWidth: 1
            )
    }
    
    private var neonBorderColor: Color {
        colorScheme == .dark ? Color.cyan.opacity(0.4) : Color.blue.opacity(0.3)
    }
    
    private var neonButtonGlow: Color {
        colorScheme == .dark ? Color.cyan.opacity(0.2) : Color.blue.opacity(0.15)
    }
    
    private var nextButtonShadow: Color {
        canProceed ? DS.Colors.primary.opacity(0.4) : Color.clear
    }
    
    private var nextButtonShadowRadius: CGFloat {
        canProceed ? 12 : 0
    }
}

// MARK: - Welcome Step
struct WelcomeStep: View {
    @State private var animateEmoji = false
    @State private var animateGlow = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: DS.Spacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(neonWelcomeGlow)
                    .frame(width: 140, height: 140)
                    .blur(radius: 25)
                    .scaleEffect(animateGlow ? 1.3 : 0.9)
                
                Text("🎯")
                    .font(.system(size: 100))
                    .scaleEffect(animateEmoji ? 1.1 : 1.0)
                    .shadow(color: neonEmojiGlow, radius: 10)
            }
            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animateEmoji)
            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: animateGlow)
            .onAppear {
                animateEmoji = true
                animateGlow = true
            }
            
            VStack(spacing: DS.Spacing.l) {
                Text("Welcome to Challengely")
                    .font(DS.Typography.largeTitle.weight(.bold))
                    .foregroundColor(DS.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Transform your daily routine with personalized challenges that inspire growth and build lasting habits.")
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .padding(.horizontal, DS.Spacing.l)
            
            Spacer()
        }
    }
    
    private var neonWelcomeGlow: Color {
        colorScheme == .dark ? Color.cyan.opacity(0.3) : Color.blue.opacity(0.2)
    }
    
    private var neonEmojiGlow: Color {
        colorScheme == .dark ? Color.yellow.opacity(0.6) : Color.orange.opacity(0.4)
    }
}

// MARK: - Intro Step
struct IntroStep: View {
    var body: some View {
        VStack(spacing: DS.Spacing.xl) {
            Text("Here's what you'll get")
                .font(DS.Typography.title.weight(.bold))
                .foregroundColor(DS.Colors.textPrimary)
                .padding(.top, DS.Spacing.xl)
            
            Spacer()
            
            VStack(spacing: DS.Spacing.l) {
                FeatureRow(icon: "target", title: "Daily Challenges", desc: "Get one personalized challenge each day", accentColor: .cyan)
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Track Progress", desc: "Build streaks and celebrate achievements", accentColor: .purple)
                FeatureRow(icon: "message.circle", title: "AI Assistant", desc: "Get guidance and motivation when you need it", accentColor: .pink)
            }
            .padding(.horizontal, DS.Spacing.l)
            
            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let desc: String
    let accentColor: Color
    @State private var animate = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: DS.Spacing.m) {
            iconBackground
            
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(title)
                    .font(DS.Typography.headline.weight(.semibold))
                    .foregroundColor(DS.Colors.textPrimary)
                
                Text(desc)
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, DS.Spacing.s)
        .onAppear { animate = true }
    }
    
    private var iconBackground: some View {
        Image(systemName: icon)
            .font(.title2.weight(.semibold))
            .foregroundColor(accentColor)
            .frame(width: 48, height: 48)
            .background(.thinMaterial)
            .overlay(neonIconBorder)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: neonIconGlow, radius: 8)
            .scaleEffect(animate ? 1.05 : 1.0)
            .animation(.spring(duration: 0.6).delay(0.1), value: animate)
    }
    
    private var neonIconBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(accentColor.opacity(0.5), lineWidth: 1)
    }
    
    private var neonIconGlow: Color {
        accentColor.opacity(colorScheme == .dark ? 0.4 : 0.2)
    }
}

// MARK: - Interests Step
struct InterestsStep: View {
    let selected: Set<Challenge.Category>
    let onTap: (Challenge.Category) -> Void
    
    var body: some View {
        VStack(spacing: DS.Spacing.xl) {
            headerSection
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DS.Spacing.m) {
                ForEach(Challenge.Category.allCases, id: \.self) { category in
                    InterestCard(
                        category: category,
                        isSelected: selected.contains(category),
                        onTap: { onTap(category) }
                    )
                }
            }
            .padding(.horizontal, DS.Spacing.l)
            
            Spacer()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: DS.Spacing.l) {
            Text("What interests you?")
                .font(DS.Typography.largeTitle.weight(.bold))
                .foregroundColor(DS.Colors.textPrimary)
            
            Text("Choose the areas you'd like to explore. You can always change this later.")
                .font(DS.Typography.body)
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, DS.Spacing.l)
        .padding(.top, DS.Spacing.xl)
    }
}

struct InterestCard: View {
    let category: Challenge.Category
    let isSelected: Bool
    let onTap: () -> Void
    @State private var animate = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DS.Spacing.s) {
                Text(category.emoji)
                    .font(.system(size: 44))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .shadow(color: neonEmojiShadow, radius: isSelected ? 8 : 0)
                
                Text(category.displayName)
                    .font(DS.Typography.headline.weight(.medium))
                    .foregroundColor(isSelected ? .white : DS.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .background(cardBackground)
            .overlay(cardBorder)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .scaleEffect(isSelected ? 1.05 : (animate ? 1.02 : 1.0))
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
            .animation(.spring(duration: 0.4), value: isSelected)
            .animation(.easeInOut(duration: 0.2), value: animate)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { pressing in
            animate = pressing
        } perform: {
            onTap()
        }
    }
    
    private var cardBackground: some View {
        Group {
            if isSelected {
                DS.Colors.primary
            } else {
                Color.clear.background(.thinMaterial)
            }
        }
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 18)
            .stroke(borderColor, lineWidth: borderWidth)
    }
    
    private var borderColor: Color {
        if isSelected {
            return Color.white.opacity(0.4)
        } else {
            return colorScheme == .dark ? Color.cyan.opacity(0.3) : Color.blue.opacity(0.2)
        }
    }
    
    private var borderWidth: CGFloat {
        isSelected ? 2 : 1
    }
    
    private var shadowColor: Color {
        if isSelected {
            return DS.Colors.primary.opacity(0.4)
        } else {
            return colorScheme == .dark ? Color.cyan.opacity(0.2) : Color.blue.opacity(0.1)
        }
    }
    
    private var shadowRadius: CGFloat {
        isSelected ? 12 : 6
    }
    
    private var shadowOffset: CGFloat {
        isSelected ? 6 : 3
    }
    
    private var neonEmojiShadow: Color {
        colorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.3)
    }
}

// MARK: - Difficulty Step
struct DifficultyStep: View {
    let selected: Challenge.Difficulty
    let onTap: (Challenge.Difficulty) -> Void
    
    var body: some View {
        VStack(spacing: DS.Spacing.xl) {
            headerSection
            
            VStack(spacing: DS.Spacing.m) {
                ForEach(Challenge.Difficulty.allCases, id: \.self) { difficulty in
                    DifficultyCard(
                        difficulty: difficulty,
                        isSelected: selected == difficulty,
                        onTap: { onTap(difficulty) }
                    )
                }
            }
            .padding(.horizontal, DS.Spacing.l)
            
            Spacer()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: DS.Spacing.l) {
            Text("Choose your level")
                .font(DS.Typography.largeTitle.weight(.bold))
                .foregroundColor(DS.Colors.textPrimary)
            
            Text("How challenging would you like your daily tasks to be?")
                .font(DS.Typography.body)
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, DS.Spacing.l)
        .padding(.top, DS.Spacing.xl)
    }
}

struct DifficultyCard: View {
    let difficulty: Challenge.Difficulty
    let isSelected: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var difficultyDescription: String {
        switch difficulty {
        case .easy: return "Light activities, 5-15 minutes"
        case .medium: return "Moderate challenges, 15-30 minutes"
        case .hard: return "Intensive tasks, 30+ minutes"
        }
    }
    
    var difficultyIcon: String {
        switch difficulty {
        case .easy: return "leaf.fill"
        case .medium: return "flame.fill"
        case .hard: return "bolt.fill"
        }
    }
    
    var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DS.Spacing.m) {
                difficultyIconView
                
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(difficulty.rawValue.capitalized)
                        .font(DS.Typography.headline.weight(.semibold))
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Text(difficultyDescription)
                        .font(DS.Typography.body)
                        .foregroundColor(DS.Colors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    checkmarkIcon
                }
            }
            .padding(DS.Spacing.m)
            .background(.thinMaterial)
            .overlay(cardBorder)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
            .animation(.spring(duration: 0.4), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var difficultyIconView: some View {
        Image(systemName: difficultyIcon)
            .font(.title2.weight(.semibold))
            .foregroundColor(difficultyColor)
            .frame(width: 44, height: 44)
            .background(.thinMaterial)
            .overlay(iconBorder)
            .clipShape(Circle())
            .shadow(color: iconGlow, radius: 8)
            .scaleEffect(isSelected ? 1.1 : 1.0)
    }
    
    private var checkmarkIcon: some View {
        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(DS.Colors.primary)
            .font(.title2)
            .shadow(color: DS.Colors.primary.opacity(0.6), radius: 4)
            .transition(.scale.combined(with: .opacity))
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 18)
            .stroke(cardBorderColor, lineWidth: cardBorderWidth)
    }
    
    private var iconBorder: some View {
        Circle()
            .stroke(difficultyColor.opacity(0.5), lineWidth: 1)
    }
    
    private var cardBorderColor: Color {
        if isSelected {
            return DS.Colors.primary.opacity(0.6)
        } else {
            return colorScheme == .dark ? Color.cyan.opacity(0.3) : Color.blue.opacity(0.2)
        }
    }
    
    private var cardBorderWidth: CGFloat {
        isSelected ? 2 : 1
    }
    
    private var shadowColor: Color {
        if isSelected {
            return DS.Colors.primary.opacity(0.3)
        } else {
            return colorScheme == .dark ? Color.cyan.opacity(0.15) : Color.blue.opacity(0.08)
        }
    }
    
    private var shadowRadius: CGFloat {
        isSelected ? 10 : 4
    }
    
    private var shadowOffset: CGFloat {
        isSelected ? 5 : 2
    }
    
    private var iconGlow: Color {
        difficultyColor.opacity(colorScheme == .dark ? 0.4 : 0.2)
    }
}

// MARK: - Button Styles
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}


































// legacy without glass ui wotking


/// 1 final working

//
//import Foundation
//import SwiftUI
//import ComposableArchitecture
//
//struct OnboardingView: View {
//    let store: StoreOf<OnboardingCore>
//
//    var body: some View {
//        WithViewStore(self.store, observe: { $0 }) { viewStore in
//            ZStack {
//                LinearGradient(
//                    colors: [DS.Colors.background, DS.Colors.primary.opacity(0.05)],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea()
//
//                VStack(spacing: 0) {
//                    VStack(spacing: DS.Spacing.l) {
//                        HStack {
//                            Text("Step \(viewStore.currentStep + 1) of 4")
//                                .font(DS.Typography.caption)
//                                .foregroundColor(DS.Colors.textSecondary)
//                            Spacer()
//                            Button("Skip") {
//                                viewStore.send(.skipOnboarding)
//                            }
//                            .font(DS.Typography.body)
//                            .foregroundColor(DS.Colors.primary)
//                        }
//
//                        ProgressView(value: Double(viewStore.currentStep) / 3.0)
//                            .progressViewStyle(LinearProgressViewStyle(tint: DS.Colors.primary))
//                            .scaleEffect(x: 1, y: 2, anchor: .center)
//                            .animation(.spring(duration: 0.8), value: viewStore.currentStep)
//                    }
//                    .padding(.horizontal, DS.Spacing.l)
//                    .padding(.top, DS.Spacing.m)
//                    .padding(.bottom, DS.Spacing.xl)
//
//                    TabView(selection: Binding(
//                        get: { viewStore.currentStep },
//                        set: { _ in }
//                    )) {
//                        WelcomeStep()
//                            .tag(0)
//                        IntroStep()
//                            .tag(1)
//                        InterestsStep(
//                            selected: viewStore.selectedInterests,
//                            onTap: { category in viewStore.send(.selectInterest(category)) }
//                        )
//                        .tag(2)
//                        DifficultyStep(
//                            selected: viewStore.selectedDifficulty,
//                            onTap: { difficulty in viewStore.send(.selectDifficulty(difficulty)) }
//                        )
//                        .tag(3)
//                    }
//                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//                    .animation(.spring(duration: 0.6), value: viewStore.currentStep)
//
//                    NavigationButtons(
//                        currentStep: viewStore.currentStep,
//                        canProceed: canProceed(for: viewStore), // Fixed logic
//                        onBack: { viewStore.send(.previousStep) },
//                        onNext: {
//                            if viewStore.currentStep == 3 {
//                                viewStore.send(.completed) // Fixed completion action
//                            } else {
//                                viewStore.send(.nextStep)
//                            }
//                        }
//                    )
//                    .padding(.horizontal, DS.Spacing.l)
//                    .padding(.bottom, DS.Spacing.l)
//                }
//            }
//        }
//    }
//
//    // Helper function to determine if user can proceed
//    private func canProceed(for viewStore: ViewStoreOf<OnboardingCore>) -> Bool {
//        switch viewStore.currentStep {
//        case 0, 1: // Welcome and Intro steps - always can proceed
//            return true
//        case 2: // Interests step - need at least one interest
//            return !viewStore.selectedInterests.isEmpty
//        case 3: // Difficulty step - need a difficulty selected
//            return viewStore.selectedDifficulty != .medium || viewStore.selectedDifficulty == .medium // Always true since medium is default
//        default:
//            return false
//        }
//    }
//}
//
//struct NavigationButtons: View {
//    let currentStep: Int
//    let canProceed: Bool
//    let onBack: () -> Void
//    let onNext: () -> Void
//
//    var body: some View {
//        HStack(spacing: DS.Spacing.m) {
//            if currentStep > 0 {
//                Button(action: onBack) {
//                    HStack {
//                        Image(systemName: "chevron.left")
//                        Text("Back")
//                    }
//                    .font(DS.Typography.headline)
//                    .foregroundColor(DS.Colors.textSecondary)
//                    .padding(.vertical, DS.Spacing.m)
//                    .padding(.horizontal, DS.Spacing.l)
//                    .background(DS.Colors.cardBg)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                }
//                .buttonStyle(ScaleButtonStyle())
//            }
//
//            Spacer()
//
//            Button(action: onNext) {
//                Text(currentStep == 3 ? "Get Started 🚀" : "Next")
//                    .font(DS.Typography.headline)
//                    .foregroundColor(.white)
//                    .padding(.vertical, DS.Spacing.m)
//                    .padding(.horizontal, DS.Spacing.xl)
//                    .background(
//                        canProceed ? DS.Colors.primary : DS.Colors.textSecondary
//                    )
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//            }
//            .disabled(!canProceed)
//            .buttonStyle(ScaleButtonStyle())
//            .animation(.spring(duration: 0.3), value: canProceed)
//        }
//    }
//}
//
//struct WelcomeStep: View {
//    @State private var animateEmoji = false
//
//    var body: some View {
//        VStack(spacing: DS.Spacing.xl) {
//            Spacer()
//
//            Text("🎯")
//                .font(.system(size: 100))
//                .scaleEffect(animateEmoji ? 1.1 : 1.0)
//                .animation(.bouncy(duration: 2.0).repeatForever(autoreverses: true), value: animateEmoji)
//                .onAppear { animateEmoji = true }
//
//            VStack(spacing: DS.Spacing.l) {
//                Text("Welcome to Challengely")
//                    .font(DS.Typography.largeTitle)
//                    .foregroundColor(DS.Colors.textPrimary)
//                    .multilineTextAlignment(.center)
//
//                Text("Transform your daily routine with personalized challenges that inspire growth and build lasting habits.")
//                    .font(DS.Typography.body)
//                    .foregroundColor(DS.Colors.textSecondary)
//                    .multilineTextAlignment(.center)
//                    .lineLimit(nil)
//            }
//            .padding(.horizontal, DS.Spacing.l)
//
//            Spacer()
//        }
//    }
//}
//
//struct IntroStep: View {
//    var body: some View {
//        VStack(spacing: DS.Spacing.xl) {
//            Text("Here's what you'll get")
//                .font(DS.Typography.title)
//                .foregroundColor(DS.Colors.textPrimary)
//                .padding(.top, DS.Spacing.xl)
//
//            Spacer()
//
//            VStack(spacing: DS.Spacing.l) {
//                FeatureRow(icon: "target", title: "Daily Challenges", desc: "Get one personalized challenge each day")
//                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Track Progress", desc: "Build streaks and celebrate achievements")
//                FeatureRow(icon: "message.circle", title: "AI Assistant", desc: "Get guidance and motivation when you need it")
//            }
//            .padding(.horizontal, DS.Spacing.l)
//
//            Spacer()
//        }
//    }
//}
//
//struct FeatureRow: View {
//    let icon: String
//    let title: String
//    let desc: String
//    @State private var animate = false
//
//    var body: some View {
//        HStack(spacing: DS.Spacing.m) {
//            Image(systemName: icon)
//                .font(.title2)
//                .foregroundColor(DS.Colors.primary)
//                .frame(width: 40, height: 40)
//                .background(DS.Colors.primary.opacity(0.1))
//                .clipShape(Circle())
//                .scaleEffect(animate ? 1.05 : 1.0)
//                .animation(.spring(duration: 0.6).delay(0.1), value: animate)
//
//            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
//                Text(title)
//                    .font(DS.Typography.headline)
//                    .foregroundColor(DS.Colors.textPrimary)
//
//                Text(desc)
//                    .font(DS.Typography.body)
//                    .foregroundColor(DS.Colors.textSecondary)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//
//            Spacer()
//        }
//        .padding(.vertical, DS.Spacing.s)
//        .onAppear { animate = true }
//    }
//}
//
//struct InterestsStep: View {
//    let selected: Set<Challenge.Category>
//    let onTap: (Challenge.Category) -> Void
//
//    var body: some View {
//        VStack(spacing: DS.Spacing.xl) {
//            VStack(spacing: DS.Spacing.l) {
//                Text("What interests you?")
//                    .font(DS.Typography.largeTitle)
//                    .foregroundColor(DS.Colors.textPrimary)
//
//                Text("Choose the areas you'd like to explore. You can always change this later.")
//                    .font(DS.Typography.body)
//                    .foregroundColor(DS.Colors.textSecondary)
//                    .multilineTextAlignment(.center)
//            }
//            .padding(.horizontal, DS.Spacing.l)
//            .padding(.top, DS.Spacing.xl)
//
//            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DS.Spacing.m) {
//                ForEach(Challenge.Category.allCases, id: \.self) { category in
//                    InterestCard(
//                        category: category,
//                        isSelected: selected.contains(category),
//                        onTap: { onTap(category) }
//                    )
//                }
//            }
//            .padding(.horizontal, DS.Spacing.l)
//
//            Spacer()
//        }
//    }
//}
//
//struct InterestCard: View {
//    let category: Challenge.Category
//    let isSelected: Bool
//    let onTap: () -> Void
//    @State private var animate = false
//
//    var body: some View {
//        Button(action: onTap) {
//            VStack(spacing: DS.Spacing.s) {
//                Text(category.emoji)
//                    .font(.system(size: 40))
//
//                Text(category.displayName)
//                    .font(DS.Typography.headline)
//                    .foregroundColor(isSelected ? .white : DS.Colors.textPrimary)
//                    .multilineTextAlignment(.center)
//            }
//            .frame(maxWidth: .infinity)
//            .frame(height: 120)
//            .background(
//                isSelected ? DS.Colors.primary : DS.Colors.cardBg
//            )
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(
//                        isSelected ? DS.Colors.primary : DS.Colors.textSecondary.opacity(0.2),
//                        lineWidth: 2
//                    )
//            )
//            .scaleEffect(isSelected ? 1.05 : (animate ? 1.02 : 1.0))
//            .shadow(
//                color: isSelected ? DS.Colors.primary.opacity(0.3) : .clear,
//                radius: 8,
//                x: 0,
//                y: 4
//            )
//            .animation(.spring(duration: 0.4), value: isSelected)
//            .animation(.easeInOut(duration: 0.2), value: animate)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .onLongPressGesture(minimumDuration: 0) { pressing in
//            animate = pressing
//        } perform: {
//            onTap()
//        }
//    }
//}
//
//struct DifficultyStep: View {
//    let selected: Challenge.Difficulty
//    let onTap: (Challenge.Difficulty) -> Void
//
//    var body: some View {
//        VStack(spacing: DS.Spacing.xl) {
//            VStack(spacing: DS.Spacing.l) {
//                Text("Choose your level")
//                    .font(DS.Typography.largeTitle)
//                    .foregroundColor(DS.Colors.textPrimary)
//
//                Text("How challenging would you like your daily tasks to be?")
//                    .font(DS.Typography.body)
//                    .foregroundColor(DS.Colors.textSecondary)
//                    .multilineTextAlignment(.center)
//            }
//            .padding(.horizontal, DS.Spacing.l)
//            .padding(.top, DS.Spacing.xl)
//
//            VStack(spacing: DS.Spacing.m) {
//                ForEach(Challenge.Difficulty.allCases, id: \.self) { difficulty in
//                    DifficultyCard(
//                        difficulty: difficulty,
//                        isSelected: selected == difficulty,
//                        onTap: { onTap(difficulty) }
//                    )
//                }
//            }
//            .padding(.horizontal, DS.Spacing.l)
//
//            Spacer()
//        }
//    }
//}
//
//struct DifficultyCard: View {
//    let difficulty: Challenge.Difficulty
//    let isSelected: Bool
//    let onTap: () -> Void
//
//    var difficultyDescription: String {
//        switch difficulty {
//        case .easy: return "Light activities, 5-15 minutes"
//        case .medium: return "Moderate challenges, 15-30 minutes"
//        case .hard: return "Intensive tasks, 30+ minutes"
//        }
//    }
//
//    var body: some View {
//        Button(action: onTap) {
//            HStack(spacing: DS.Spacing.m) {
//                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
//                    Text(difficulty.rawValue.capitalized)
//                        .font(DS.Typography.headline)
//                        .foregroundColor(DS.Colors.textPrimary)
//
//                    Text(difficultyDescription)
//                        .font(DS.Typography.body)
//                        .foregroundColor(DS.Colors.textSecondary)
//                }
//
//                Spacer()
//
//                if isSelected {
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundColor(DS.Colors.primary)
//                        .font(.title2)
//                        .transition(.scale.combined(with: .opacity))
//                }
//            }
//            .padding(DS.Spacing.m)
//            .background(DS.Colors.cardBg)
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(
//                        isSelected ? DS.Colors.primary : DS.Colors.textSecondary.opacity(0.2),
//                        lineWidth: 2
//                    )
//            )
//            .scaleEffect(isSelected ? 1.02 : 1.0)
//            .shadow(
//                color: isSelected ? DS.Colors.primary.opacity(0.2) : .clear,
//                radius: 6,
//                x: 0,
//                y: 3
//            )
//            .animation(.spring(duration: 0.4), value: isSelected)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//}
//
//struct ScaleButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
//            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
//    }
//}
//





