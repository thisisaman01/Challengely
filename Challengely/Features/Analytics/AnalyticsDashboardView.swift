//
//  AnalyticsDashboardView.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//

import SwiftUI
import ComposableArchitecture
import Charts

@Reducer
struct AnalyticsCore {
    @ObservableState
    struct State: Equatable {
        var completedChallenges: [Challenge] = []
        var streakHistory: [Int] = []
    }
    
    enum Action: Equatable {
        case onAppear
        case reloadData
        case updateData([Challenge], [Int])
    }
    
    @Dependency(\.storage) var storage
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear, .reloadData:
                return .run { send in
                    // Use loadProfile() instead of loadUserProfile()
                    if let profile = storage.loadProfile() {
                        let completed = profile.completedChallenges.compactMap { id in
                            Challenge.samples.first(where: { $0.id == id })
                        }
                        // Generate realistic streak history for last 7 days
                        let streakHistory = generateStreakHistory(currentStreak: profile.streakCount)
                        await send(.updateData(completed, streakHistory))
                    }
                }
                
            case .updateData(let completed, let streaks):
                state.completedChallenges = completed
                state.streakHistory = streaks
                return .none
            }
        }
    }
    
    // Helper function to generate realistic streak history
    private func generateStreakHistory(currentStreak: Int) -> [Int] {
        var history: [Int] = []
        let daysToShow = 7
        
        for i in (0..<daysToShow).reversed() {
            if i == 0 {
                // Today's streak
                history.append(currentStreak)
            } else if i <= currentStreak {
                // Previous days in current streak
                history.append(currentStreak - i)
            } else {
                // Days before current streak started
                history.append(0)
            }
        }
        
        return history
    }
}

struct AnalyticsDashboardView: View {
    @Bindable var store: StoreOf<AnalyticsCore>

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Stats
                    HStack(spacing: 20) {
                        StatCard(
                            title: "Completed",
                            value: "\(store.completedChallenges.count)",
                            icon: "checkmark.circle.fill",
                            color: DS.Colors.success
                        )
                        
                        StatCard(
                            title: "Current Streak",
                            value: "\(store.streakHistory.last ?? 0)",
                            icon: "flame.fill",
                            color: .orange
                        )
                    }
                    
                    // Chart Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("7-Day Streak Progress")
                            .font(DS.Typography.title)
                            .bold()
                        
                        StreakChartView(streaks: store.streakHistory)
                            .frame(height: 200)
                            .padding()
                            .background(DS.Colors.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Category Breakdown
                    if !store.completedChallenges.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Challenge Categories")
                                .font(DS.Typography.title)
                                .bold()
                            
                            CategoryBreakdownView(challenges: store.completedChallenges)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .onAppear {
                store.send(.onAppear)
            }
            .refreshable {
                store.send(.reloadData)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(DS.Typography.largeTitle)
                .bold()
                .foregroundColor(DS.Colors.textPrimary)
            
            Text(title)
                .font(DS.Typography.caption)
                .foregroundColor(DS.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(DS.Colors.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StreakChartView: View {
    let streaks: [Int]
    
    var body: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(Array(streaks.enumerated()), id: \.offset) { idx, value in
                    BarMark(
                        x: .value("Day", dayLabel(for: idx)),
                        y: .value("Streak", value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DS.Colors.primary.opacity(0.7), DS.Colors.primary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                }
            }
            .chartYScale(domain: 0...(streaks.max() ?? 1))
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        } else {
            VStack {
                Text("📊")
                    .font(.largeTitle)
                Text("Chart requires iOS 16+")
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func dayLabel(for index: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        let date = calendar.date(byAdding: .day, value: -(streaks.count - 1 - index), to: today) ?? today
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Mon, Tue, etc.
        return formatter.string(from: date)
    }
}

struct CategoryBreakdownView: View {
    let challenges: [Challenge]
    
    private var categoryStats: [(Challenge.Category, Int)] {
        let grouped = Dictionary(grouping: challenges, by: \.category)
        return grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(categoryStats, id: \.0) { category, count in
                HStack {
                    Text(category.emoji)
                        .font(.title3)
                    
                    Text(category.displayName)
                        .font(DS.Typography.body)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Spacer()
                    
                    Text("\(count)")
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(DS.Colors.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}
