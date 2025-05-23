//
//  AnalyticsView.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import SwiftData
import Charts

/// Enhanced analytics view with interactive visualizations
struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Correlation.correlationCoefficient, order: .reverse) private var correlations: [Correlation]
    @Query private var meals: [Meal]
    @Query private var symptoms: [Symptom]
    
    @State private var selectedTimeRange = TimeRange.month
    @State private var showingSignificantOnly = true
    @State private var selectedChartType = ChartType.trends
    @State private var selectedSymptomCategory: Symptom.SymptomCategory?
    @State private var showingDetails = false
    
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
                        // Controls Section
                        controlsSection
                        
                        // Summary Stats
                        summaryStatsSection
                        
                        // Main Chart Area
                        mainChartSection
                        
                        // Secondary Insights
                        secondaryInsightsSection
                        
                        // Data Insights
                        if !filteredData.isEmpty {
                            dataInsightsSection
                        } else {
                            emptyStateView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingDetails.toggle() }) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(DesignSystem.Gradients.primary)
                    }
                }
            }
            .sheet(isPresented: $showingDetails) {
                AnalyticsHelpView()
            }
        }
    }
    
    // MARK: - Main Sections
    
    /// Controls for filtering and chart type selection
    private var controlsSection: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            // Time Range Selector
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            
            // Chart Type Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(ChartType.allCases, id: \.self) { type in
                        ChartTypeButton(
                            type: type,
                            isSelected: selectedChartType == type,
                            action: { selectedChartType = type }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    /// Summary statistics cards
    private var summaryStatsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.small) {
            InsightCard(
                title: "Total Meals",
                value: "\(filteredMeals.count)",
                subtitle: "in \(selectedTimeRange.rawValue.lowercased())",
                icon: "fork.knife",
                gradient: DesignSystem.Gradients.primary
            )
            
            InsightCard(
                title: "Symptoms Tracked",
                value: "\(filteredSymptoms.count)",
                subtitle: "Avg severity: \(String(format: "%.1f", averageSeverity))",
                icon: "heart.text.square",
                gradient: DesignSystem.Gradients.secondary
            )
            
            InsightCard(
                title: "Correlations Found",
                value: "\(significantCorrelations.count)",
                subtitle: "\(significantCorrelations.count) significant",
                icon: "link",
                gradient: DesignSystem.Gradients.accent
            )
            
            InsightCard(
                title: "Streak",
                value: "\(currentStreak)",
                subtitle: "days logging",
                icon: "flame.fill",
                gradient: DesignSystem.Gradients.success
            )
        }
    }
    
    /// Main chart display area
    private var mainChartSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            HStack {
                Text(selectedChartType.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if selectedChartType == .correlations {
                    Toggle("Significant Only", isOn: $showingSignificantOnly)
                        .toggleStyle(.switch)
                }
            }
            
            // Chart content based on selected type
            Group {
                switch selectedChartType {
                case .trends:
                    symptomTrendsChart
                case .correlations:
                    correlationMatrix
                case .foodBreakdown:
                    foodCategoryChart
                case .calendar:
                    symptomCalendarHeatmap
                }
            }
            .frame(minHeight: 300)
            .cardStyle()
        }
    }
    
    /// Secondary insights section
    private var secondaryInsightsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Insights & Patterns")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: DesignSystem.Spacing.small) {
                if let topTrigger = topFoodTrigger {
                    InsightRow(
                        icon: "exclamationmark.triangle.fill",
                        title: "Top Food Trigger",
                        subtitle: topTrigger.name,
                        value: "\(triggerFrequency(for: topTrigger))x",
                        color: .red
                    )
                }
                
                if let commonTime = mostCommonSymptomTime {
                    InsightRow(
                        icon: "clock.fill",
                        title: "Common Symptom Time",
                        subtitle: commonTime,
                        value: "",
                        color: .orange
                    )
                }
                
                InsightRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Worst Day of Week",
                    subtitle: worstDayOfWeek,
                    value: "",
                    color: .purple
                )
            }
        }
    }
    
    /// Data insights and correlations
    private var dataInsightsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Food-Symptom Correlations")
                .font(.title2)
                .fontWeight(.semibold)
            
            if filteredCorrelations.isEmpty {
                Text("Log more meals and symptoms to see correlations")
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(filteredCorrelations.prefix(5)) { correlation in
                        CorrelationInsightRow(correlation: correlation)
                    }
                }
            }
        }
    }
    
    // MARK: - Chart Views
    
    /// Symptom trends over time
    private var symptomTrendsChart: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            // Category filter for symptoms
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.small) {
                    CategoryFilterChip(
                        title: "All",
                        isSelected: selectedSymptomCategory == nil,
                        action: { selectedSymptomCategory = nil }
                    )
                    
                    ForEach(Symptom.SymptomCategory.allCases, id: \.self) { category in
                        CategoryFilterChip(
                            title: category.rawValue,
                            isSelected: selectedSymptomCategory == category,
                            action: { selectedSymptomCategory = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            Chart(trendData) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Severity", item.averageSeverity)
                )
                .foregroundStyle(DesignSystem.Gradients.secondary)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Date", item.date),
                    y: .value("Severity", item.averageSeverity)
                )
                .foregroundStyle(DesignSystem.Gradients.secondary.opacity(0.3))
            }
            .chartYScale(domain: 0...10)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: selectedTimeRange == .week ? 1 : 7)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 200)
        }
    }
    
    /// Correlation matrix visualization
    private var correlationMatrix: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            if filteredCorrelations.isEmpty {
                Text("No correlations found yet")
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart(filteredCorrelations) { correlation in
                    BarMark(
                        x: .value("Correlation", abs(correlation.correlationCoefficient)),
                        y: .value("Food-Symptom", "\(correlation.food?.name ?? "Unknown") → \(correlation.symptomType)")
                    )
                    .foregroundStyle(
                        correlation.correlationCoefficient > 0 ? 
                        DesignSystem.Gradients.secondary : DesignSystem.Gradients.success
                    )
                }
                .chartXScale(domain: 0...1)
                .frame(height: max(200, CGFloat(filteredCorrelations.count * 30)))
            }
        }
    }
    
    /// Food category breakdown
    private var foodCategoryChart: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Chart(foodCategoryData) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(item.color)
                .cornerRadius(4)
            }
            .frame(height: 250)
            
            // Legend
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.small) {
                ForEach(foodCategoryData) { item in
                    HStack(spacing: DesignSystem.Spacing.xxSmall) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 12, height: 12)
                        Text(item.category)
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        Spacer()
                        Text("\(item.count)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
            }
        }
    }
    
    /// Calendar heatmap for symptoms
    private var symptomCalendarHeatmap: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Daily symptom severity over time")
                .font(.subheadline)
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            CalendarHeatmapView(
                data: calendarData,
                timeRange: selectedTimeRange
            )
        }
    }
    
    /// Empty state when no data
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 60))
                .foregroundStyle(DesignSystem.Gradients.accent)
            
            Text("No Data Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start logging meals and symptoms to see insights and correlations")
                .font(.body)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
            
            GradientButton(
                title: "Log Your First Meal",
                icon: "plus.circle.fill",
                gradient: DesignSystem.Gradients.primary,
                action: {
                    // TODO: Navigate to meal logging
                }
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Helper Properties
    
    private var filteredData: [Any] {
        filteredMeals + filteredSymptoms
    }
    
    private var filteredMeals: [Meal] {
        meals.filter { meal in
            meal.timestamp >= startDate
        }
    }
    
    private var filteredSymptoms: [Symptom] {
        symptoms.filter { symptom in
            symptom.timestamp >= startDate &&
            (selectedSymptomCategory == nil || symptom.type.category == selectedSymptomCategory)
        }
    }
    
    private var filteredCorrelations: [Correlation] {
        let base = showingSignificantOnly ? correlations.filter { $0.isSignificant } : correlations
        return Array(base.prefix(20))
    }
    
    private var significantCorrelations: [Correlation] {
        correlations.filter { $0.isSignificant }
    }
    
    private var startDate: Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .threeMonths:
            return calendar.date(byAdding: .month, value: -3, to: now) ?? now
        }
    }
    
    private var averageSeverity: Double {
        guard !filteredSymptoms.isEmpty else { return 0 }
        let total = filteredSymptoms.reduce(0) { $0 + $1.severity }
        return total / Double(filteredSymptoms.count)
    }
    
    private var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        while true {
            let dayMeals = meals.filter { 
                calendar.startOfDay(for: $0.timestamp) == currentDate 
            }
            if dayMeals.isEmpty {
                break
            }
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            if streak > 365 { break } // Safety limit
        }
        
        return streak
    }
    
    private var trendData: [TrendDataPoint] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredSymptoms) { symptom in
            calendar.startOfDay(for: symptom.timestamp)
        }
        
        return grouped.compactMap { date, symptoms in
            let avgSeverity = symptoms.reduce(0) { $0 + $1.severity } / Double(symptoms.count)
            return TrendDataPoint(date: date, averageSeverity: avgSeverity)
        }.sorted { $0.date < $1.date }
    }
    
    private var foodCategoryData: [FoodCategoryData] {
        let categoryCount = Dictionary(grouping: filteredMeals.flatMap { $0.foodItems }) { item in
            item.food?.category ?? "Unknown"
        }.mapValues { $0.count }
        
        let colors: [Color] = [
            DesignSystem.Colors.primaryGradientStart,
            DesignSystem.Colors.secondaryGradientStart,
            DesignSystem.Colors.accentGradientStart,
            DesignSystem.Colors.successGradientStart,
            .purple, .brown, .cyan, .indigo
        ]
        
        return categoryCount.enumerated().map { index, item in
            FoodCategoryData(
                category: item.key,
                count: item.value,
                color: colors[index % colors.count]
            )
        }.sorted { $0.count > $1.count }
    }
    
    private var calendarData: [CalendarDataPoint] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredSymptoms) { symptom in
            calendar.startOfDay(for: symptom.timestamp)
        }
        
        return grouped.map { date, symptoms in
            let avgSeverity = symptoms.reduce(0) { $0 + $1.severity } / Double(symptoms.count)
            return CalendarDataPoint(date: date, severity: avgSeverity)
        }
    }
    
    private var topFoodTrigger: Food? {
        let foodCounts = Dictionary(grouping: significantCorrelations) { $0.food }
            .compactMapValues { correlations in correlations.first?.food }
            .keys
            .compactMap { $0 }
        
        return foodCounts.first
    }
    
    private func triggerFrequency(for food: Food) -> Int {
        significantCorrelations.filter { $0.food?.id == food.id }.count
    }
    
    private var mostCommonSymptomTime: String? {
        let hours = filteredSymptoms.map { 
            Calendar.current.component(.hour, from: $0.timestamp)
        }
        let hourCounts = Dictionary(grouping: hours) { $0 }.mapValues { $0.count }
        
        guard let mostCommonHour = hourCounts.max(by: { $0.value < $1.value })?.key else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(bySettingHour: mostCommonHour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    private var worstDayOfWeek: String {
        let daySymptoms = Dictionary(grouping: filteredSymptoms) { symptom in
            Calendar.current.component(.weekday, from: symptom.timestamp)
        }
        
        let avgSeverityByDay = daySymptoms.mapValues { symptoms in
            symptoms.reduce(0) { $0 + $1.severity } / Double(symptoms.count)
        }
        
        guard let worstDay = avgSeverityByDay.max(by: { $0.value < $1.value })?.key else {
            return "Unknown"
        }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.dateInterval(of: .weekOfYear, for: today)?.start
        let targetDate = calendar.date(byAdding: .day, value: worstDay - 1, to: weekday!) ?? today
        
        return dayFormatter.string(from: targetDate)
    }
}

// MARK: - Supporting Types and Views

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case threeMonths = "3 Months"
}

enum ChartType: String, CaseIterable {
    case trends = "Trends"
    case correlations = "Correlations"
    case foodBreakdown = "Food Breakdown"
    case calendar = "Calendar"
    
    var title: String {
        switch self {
        case .trends: return "Symptom Trends"
        case .correlations: return "Food-Symptom Correlations"
        case .foodBreakdown: return "Meal Composition"
        case .calendar: return "Symptom Calendar"
        }
    }
    
    var icon: String {
        switch self {
        case .trends: return "chart.line.uptrend.xyaxis"
        case .correlations: return "link"
        case .foodBreakdown: return "chart.pie"
        case .calendar: return "calendar"
        }
    }
}

struct TrendDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let averageSeverity: Double
}

struct FoodCategoryData: Identifiable {
    let id = UUID()
    let category: String
    let count: Int
    let color: Color
}

struct CalendarDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let severity: Double
}

// MARK: - Supporting Views

struct ChartTypeButton: View {
    let type: ChartType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.xxSmall) {
                Image(systemName: type.icon)
                    .font(.title3)
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryText)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.small)
            .background(
                isSelected ? 
                DesignSystem.Gradients.primary : 
                Color.gray.opacity(0.2)
            )
            .cornerRadius(DesignSystem.CornerRadius.small)
        }
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(gradient)
                    .font(.title2)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(gradient)
            
            Text(title)
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            
            Spacer()
            
            if !value.isEmpty {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .glassBackground()
    }
}

struct CorrelationInsightRow: View {
    let correlation: Correlation
    
    var body: some View {
        HStack {
            Image(systemName: correlation.direction == .positive ? "arrow.up.right" : "arrow.down.right")
                .foregroundColor(correlation.direction == .positive ? .red : .green)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(correlation.food?.name ?? "Unknown") → \(correlation.symptomType)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(correlation.strength.rawValue.capitalized + " " + correlation.direction.description.lowercased())
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            
            Spacer()
            
            if correlation.isSignificant {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(DesignSystem.Gradients.success)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .glassBackground()
    }
}

struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, DesignSystem.Spacing.small)
                .padding(.vertical, DesignSystem.Spacing.xxSmall)
                .background(
                    isSelected ?
                    DesignSystem.Gradients.primary :
                    Color.gray.opacity(0.2)
                )
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryText)
                .cornerRadius(DesignSystem.CornerRadius.small)
        }
    }
}

struct CalendarHeatmapView: View {
    let data: [CalendarDataPoint]
    let timeRange: TimeRange
    
    var body: some View {
        // Simplified calendar heatmap
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
            ForEach(calendarDays, id: \.self) { day in
                let dataPoint = data.first { Calendar.current.isDate($0.date, inSameDayAs: day) }
                
                Rectangle()
                    .fill(colorForSeverity(dataPoint?.severity ?? 0))
                    .frame(height: 30)
                    .cornerRadius(4)
                    .overlay(
                        Text("\(Calendar.current.component(.day, from: day))")
                            .font(.caption2)
                            .foregroundColor(.white)
                    )
            }
        }
    }
    
    private var calendarDays: [Date] {
        let calendar = Calendar.current
        let now = Date()
        let daysBack = timeRange == .week ? 7 : (timeRange == .month ? 30 : 90)
        
        return (0..<daysBack).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: -dayOffset, to: now)
        }.reversed()
    }
    
    private func colorForSeverity(_ severity: Double) -> Color {
        switch severity {
        case 0: return Color.gray.opacity(0.2)
        case 0.1..<3: return Color.green.opacity(0.6)
        case 3..<6: return Color.yellow.opacity(0.8)
        case 6..<8: return Color.orange.opacity(0.8)
        default: return Color.red.opacity(0.8)
        }
    }
}

struct AnalyticsHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                    Text("Understanding Your Analytics")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        HelpSection(
                            title: "Trends Chart",
                            description: "Shows how your symptom severity changes over time. Look for patterns related to specific days or events.",
                            icon: "chart.line.uptrend.xyaxis"
                        )
                        
                        HelpSection(
                            title: "Correlations",
                            description: "Identifies which foods might trigger your symptoms. Positive correlations suggest a food increases symptoms.",
                            icon: "link"
                        )
                        
                        HelpSection(
                            title: "Food Breakdown",
                            description: "Shows the distribution of food categories in your diet. Helps identify if you're getting variety.",
                            icon: "chart.pie"
                        )
                        
                        HelpSection(
                            title: "Calendar View",
                            description: "Heatmap showing daily symptom severity. Darker colors indicate worse symptom days.",
                            icon: "calendar"
                        )
                    }
                    
                    Text("Tips for Better Insights")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        BulletPoint("Log meals and symptoms consistently for at least 2 weeks")
                        BulletPoint("Be specific about food items and portions")
                        BulletPoint("Track symptoms within 2-24 hours of meals")
                        BulletPoint("Note severity levels accurately on the 0-10 scale")
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HelpSection: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.medium) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(DesignSystem.Gradients.primary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
        .padding()
        .glassBackground()
    }
}

struct BulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.small) {
            Text("•")
                .foregroundColor(DesignSystem.Colors.primaryGradientStart)
            Text(text)
                .font(.body)
                .foregroundColor(DesignSystem.Colors.secondaryText)
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