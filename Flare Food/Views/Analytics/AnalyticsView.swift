//
//  AnalyticsView.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import SwiftData
import Charts

/// Analytics view showing correlations and insights
struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Correlation.correlationCoefficient, order: .reverse) private var correlations: [Correlation]
    @Query private var meals: [Meal]
    @Query private var symptoms: [Symptom]
    
    @State private var selectedTimeRange = TimeRange.week
    @State private var showingSignificantOnly = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.clear,
                        DesignSystem.Colors.accentGradientStart.opacity(0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.large) {
                        // Time Range Selector
                        timeRangeSelector
                        
                        // Summary Stats
                        summaryStats
                        
                        // Correlations Heat Map
                        if !filteredCorrelations.isEmpty {
                            correlationsSection
                        } else {
                            emptyStateView
                        }
                        
                        // Activity Timeline
                        activityTimelineSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Sections
    
    /// Time range selector
    private var timeRangeSelector: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }
    
    /// Summary statistics
    private var summaryStats: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            StatCard(
                title: "Avg Daily Meals",
                value: String(format: "%.1f", averageDailyMeals),
                icon: "fork.knife",
                gradient: DesignSystem.Gradients.primary
            )
            
            StatCard(
                title: "Avg Daily Symptoms",
                value: String(format: "%.1f", averageDailySymptoms),
                icon: "heart.text.square",
                gradient: DesignSystem.Gradients.secondary
            )
        }
    }
    
    /// Correlations section
    private var correlationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Food-Symptom Correlations")
                    .font(.headline)
                
                Spacer()
                
                Toggle("Significant Only", isOn: $showingSignificantOnly)
                    .toggleStyle(.switch)
            }
            
            VStack(spacing: 12) {
                ForEach(filteredCorrelations.prefix(10)) { correlation in
                    CorrelationRow(correlation: correlation)
                }
            }
            
            if filteredCorrelations.count > 10 {
                Text("Showing top 10 of \(filteredCorrelations.count) correlations")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    /// Activity timeline section
    private var activityTimelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Timeline")
                .font(.headline)
            
            if !timelineData.isEmpty {
                Chart(timelineData) { item in
                    BarMark(
                        x: .value("Date", item.date),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(item.type == .meal ? Color.orange : Color.pink)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
            } else {
                Text("No activity data available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
    
    /// Empty state view
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Correlations Yet")
                .font(.headline)
            
            Text("Log meals and symptoms for at least 2 weeks to see meaningful correlations")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
    
    // MARK: - Helper Properties
    
    /// Filtered correlations based on settings
    private var filteredCorrelations: [Correlation] {
        if showingSignificantOnly {
            return correlations.filter { $0.isSignificant }
        }
        return correlations
    }
    
    /// Average daily meals
    private var averageDailyMeals: Double {
        guard !meals.isEmpty else { return 0 }
        let days = Set(meals.map { Calendar.current.startOfDay(for: $0.timestamp) }).count
        return Double(meals.count) / max(Double(days), 1)
    }
    
    /// Average daily symptoms
    private var averageDailySymptoms: Double {
        guard !symptoms.isEmpty else { return 0 }
        let days = Set(symptoms.map { Calendar.current.startOfDay(for: $0.timestamp) }).count
        return Double(symptoms.count) / max(Double(days), 1)
    }
    
    /// Timeline data for chart
    private var timelineData: [TimelineItem] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch selectedTimeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        }
        
        // Filter data within range
        let filteredMeals = meals.filter { $0.timestamp >= startDate }
        let filteredSymptoms = symptoms.filter { $0.timestamp >= startDate }
        
        // Group by day
        var mealsByDay: [Date: Int] = [:]
        var symptomsByDay: [Date: Int] = [:]
        
        for meal in filteredMeals {
            let day = calendar.startOfDay(for: meal.timestamp)
            mealsByDay[day, default: 0] += 1
        }
        
        for symptom in filteredSymptoms {
            let day = calendar.startOfDay(for: symptom.timestamp)
            symptomsByDay[day, default: 0] += 1
        }
        
        // Create timeline items
        var items: [TimelineItem] = []
        
        for (date, count) in mealsByDay {
            items.append(TimelineItem(date: date, count: count, type: .meal))
        }
        
        for (date, count) in symptomsByDay {
            items.append(TimelineItem(date: date, count: count, type: .symptom))
        }
        
        return items.sorted { $0.date < $1.date }
    }
}

// MARK: - Supporting Types

/// Time range options
enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case threeMonths = "3 Months"
}

/// Timeline item for chart
struct TimelineItem: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let type: ItemType
    
    enum ItemType {
        case meal
        case symptom
    }
}

/// Correlation row view
struct CorrelationRow: View {
    let correlation: Correlation
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(correlation.food?.name ?? "Unknown Food")
                    .font(.headline)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                HStack {
                    Text(correlation.symptomType)
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    
                    if correlation.isSignificant {
                        Label("Significant", systemImage: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(DesignSystem.Gradients.success)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Correlation strength indicator
                HStack(spacing: 3) {
                    ForEach(0..<5) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                index < strengthBars ? 
                                strengthGradient : 
                                LinearGradient(colors: [Color.gray.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: 6, height: 20)
                    }
                }
                
                Text(correlation.direction.description)
                    .font(.caption2)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .glassBackground()
    }
    
    private var strengthBars: Int {
        switch correlation.strength {
        case .weak: return 1
        case .moderate: return 3
        case .strong: return 5
        }
    }
    
    private var strengthGradient: LinearGradient {
        switch correlation.direction {
        case .positive: return DesignSystem.Gradients.secondary
        case .negative: return DesignSystem.Gradients.success
        case .none: return LinearGradient(colors: [Color.gray], startPoint: .top, endPoint: .bottom)
        }
    }
}

// MARK: - Preview

#Preview {
    AnalyticsView()
        .modelContainer(for: [
            Food.self,
            Meal.self,
            FoodItem.self,
            Symptom.self,
            Correlation.self,
            UserProfile.self,
            MealReminderTime.self
        ], inMemory: true)
}