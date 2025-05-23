//
//  HomeView.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import SwiftData

/// Home dashboard view
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Meal.timestamp, order: .reverse) private var recentMeals: [Meal]
    @Query(sort: \Symptom.timestamp, order: .reverse) private var recentSymptoms: [Symptom]
    @Query private var userProfiles: [UserProfile]
    
    @State private var showingMealLogger = false
    @State private var showingSymptomTracker = false
    
    private var userProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.clear,
                        DesignSystem.Colors.primaryGradientStart.opacity(0.1),
                        DesignSystem.Colors.primaryGradientEnd.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.large) {
                        // Welcome Section
                        welcomeSection
                        
                        // Stats Section
                        statsSection
                        
                        // Recent Activity
                        recentActivitySection
                        
                        // Quick Actions
                        quickActionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                ensureUserProfile()
            }
            .sheet(isPresented: $showingMealLogger) {
                MealLoggingSheet()
            }
            .sheet(isPresented: $showingSymptomTracker) {
                SymptomTrackingSheet()
            }
        }
    }
    
    // MARK: - Sections
    
    /// Welcome section with greeting
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            GradientText(greeting, gradient: DesignSystem.Gradients.primary, font: .largeTitle.bold())
            
            if let profile = userProfile {
                if profile.currentStreak > 0 {
                    HStack(spacing: DesignSystem.Spacing.xxSmall) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(DesignSystem.Gradients.primary)
                        Text("\(profile.currentStreak) day streak!")
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    .font(.title3)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DesignSystem.Spacing.small)
    }
    
    /// Stats overview section
    private var statsSection: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            StatCard(
                title: "Meals Logged",
                value: "\(userProfile?.totalMealsLogged ?? 0)",
                icon: "fork.knife",
                gradient: DesignSystem.Gradients.primary
            )
            
            StatCard(
                title: "Symptoms Tracked",
                value: "\(userProfile?.totalSymptomsLogged ?? 0)",
                icon: "heart.text.square.fill",
                gradient: DesignSystem.Gradients.secondary
            )
        }
    }
    
    /// Recent activity section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            HStack {
                Text("Recent Activity")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink(destination: TabView {
                    MealsListView()
                        .tabItem {
                            Label("Meals", systemImage: "fork.knife")
                        }
                    
                    SymptomsListView()
                        .tabItem {
                            Label("Symptoms", systemImage: "heart.text.square")
                        }
                }) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.Colors.primaryGradientStart)
                }
            }
            
            if recentMeals.isEmpty && recentSymptoms.isEmpty {
                EmptyActivityCard()
            } else {
                // Combined timeline
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.medium) {
                        ForEach(combinedRecentActivity.prefix(5)) { item in
                            RecentActivityCard(item: item)
                                .frame(width: 280)
                        }
                    }
                }
                
                // Summary stats
                HStack(spacing: DesignSystem.Spacing.small) {
                    ActivitySummaryChip(
                        title: "Today's Meals",
                        count: todaysMealsCount,
                        icon: "fork.knife",
                        gradient: DesignSystem.Gradients.primary
                    )
                    
                    ActivitySummaryChip(
                        title: "Today's Symptoms",
                        count: todaysSymptomsCount,
                        icon: "heart.text.square",
                        gradient: DesignSystem.Gradients.secondary
                    )
                }
                .padding(.top, DesignSystem.Spacing.xSmall)
            }
        }
    }
    
    /// Quick actions section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
            
            HStack(spacing: 16) {
                QuickActionButton(
                    title: "Log Meal",
                    icon: "plus.circle.fill",
                    color: .orange,
                    action: {
                        showingMealLogger = true
                    }
                )
                
                QuickActionButton(
                    title: "Track Symptom",
                    icon: "heart.text.square.fill",
                    color: .pink,
                    action: {
                        showingSymptomTracker = true
                    }
                )
            }
        }
    }
    
    // MARK: - Helper Properties
    
    /// Dynamic greeting based on time of day
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }
    
    /// Combined recent activity items
    private var combinedRecentActivity: [ActivityItem] {
        var items: [ActivityItem] = []
        
        // Add recent meals
        items.append(contentsOf: recentMeals.prefix(5).map { ActivityItem.meal($0) })
        
        // Add recent symptoms
        items.append(contentsOf: recentSymptoms.prefix(5).map { ActivityItem.symptom($0) })
        
        // Sort by timestamp
        return items.sorted { item1, item2 in
            switch (item1, item2) {
            case (.meal(let meal1), .meal(let meal2)):
                return meal1.timestamp > meal2.timestamp
            case (.symptom(let symptom1), .symptom(let symptom2)):
                return symptom1.timestamp > symptom2.timestamp
            case (.meal(let meal), .symptom(let symptom)):
                return meal.timestamp > symptom.timestamp
            case (.symptom(let symptom), .meal(let meal)):
                return symptom.timestamp > meal.timestamp
            }
        }
    }
    
    /// Today's meals count
    private var todaysMealsCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return recentMeals.filter { meal in
            calendar.isDate(meal.timestamp, inSameDayAs: today)
        }.count
    }
    
    /// Today's symptoms count
    private var todaysSymptomsCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return recentSymptoms.filter { symptom in
            calendar.isDate(symptom.timestamp, inSameDayAs: today)
        }.count
    }
    
    /// Ensures a user profile exists
    private func ensureUserProfile() {
        if userProfiles.isEmpty {
            let profile = UserProfile()
            modelContext.insert(profile)
        }
    }
}

// MARK: - Supporting Types

/// Enum to represent activity items
enum ActivityItem: Identifiable {
    case meal(Meal)
    case symptom(Symptom)
    
    var id: String {
        switch self {
        case .meal(let meal):
            return "meal-\(meal.id)"
        case .symptom(let symptom):
            return "symptom-\(symptom.id)"
        }
    }
}

// MARK: - Supporting Views

/// Statistics card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(gradient)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(gradient)
            
            Text(title)
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.medium)
        .glassBackground()
    }
}

/// Enhanced recent activity card
struct RecentActivityCard: View {
    let item: ActivityItem
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                // Header
                HStack {
                    // Icon
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(gradient)
                        .frame(width: 50, height: 50)
                        .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
                    
                    Spacer()
                    
                    // Time
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(timestamp, style: .time)
                            .font(.headline)
                        Text(relativeTime)
                            .font(.caption)
                    }
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                // Title
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                // Details
                detailsView
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                // Footer
                footerView
            }
            .padding(DesignSystem.Spacing.medium)
            .frame(maxWidth: .infinity)
            .glassBackground()
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity) {
            // On press
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
    
    private var destinationView: some View {
        Group {
            switch item {
            case .meal(let meal):
                MealDetailView(meal: meal)
            case .symptom(let symptom):
                SymptomDetailView(symptom: symptom)
            }
        }
    }
    
    private var icon: String {
        switch item {
        case .meal(let meal):
            return meal.type.icon
        case .symptom(let symptom):
            return symptom.type.icon
        }
    }
    
    private var gradient: LinearGradient {
        switch item {
        case .meal:
            return DesignSystem.Gradients.primary
        case .symptom:
            return DesignSystem.Gradients.secondary
        }
    }
    
    private var timestamp: Date {
        switch item {
        case .meal(let meal):
            return meal.timestamp
        case .symptom(let symptom):
            return symptom.timestamp
        }
    }
    
    private var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    private var title: String {
        switch item {
        case .meal(let meal):
            return meal.type.rawValue
        case .symptom(let symptom):
            return symptom.type.rawValue
        }
    }
    
    @ViewBuilder
    private var detailsView: some View {
        switch item {
        case .meal(let meal):
            if !meal.foodItems.isEmpty {
                Text(meal.foodItems.prefix(3).compactMap { $0.food?.name }.joined(separator: " • "))
                    .lineLimit(2)
            }
        case .symptom(let symptom):
            HStack(spacing: DesignSystem.Spacing.small) {
                Label("\(Int(symptom.severity))/10", systemImage: "gauge")
                
                Circle()
                    .fill(severityGradient(for: symptom.severityLevel))
                    .frame(width: 8, height: 8)
                
                Text("•")
                
                Text(symptom.type.category.rawValue)
            }
        }
    }
    
    @ViewBuilder
    private var footerView: some View {
        HStack {
            switch item {
            case .meal(let meal):
                if meal.photoData != nil {
                    Label("Photo", systemImage: "camera.fill")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.primaryGradientStart)
                }
                if let notes = meal.notes, !notes.isEmpty {
                    Label("Notes", systemImage: "note.text")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.primaryGradientStart)
                }
            case .symptom(let symptom):
                if let duration = symptom.durationMinutes {
                    Label("\(duration) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryGradientStart)
                }
                if symptom.notes != nil {
                    Label("Notes", systemImage: "note.text")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryGradientStart)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
    }
    
    private func severityGradient(for level: Symptom.SeverityLevel) -> LinearGradient {
        switch level {
        case .mild:
            return DesignSystem.Gradients.success
        case .moderate:
            return DesignSystem.Gradients.accent
        case .severe:
            return DesignSystem.Gradients.primary
        case .verySevere:
            return DesignSystem.Gradients.secondary
        }
    }
}

/// Activity summary chip
struct ActivitySummaryChip: View {
    let title: String
    let count: Int
    let icon: String
    let gradient: LinearGradient
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: icon)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                Text("\(count)")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
        .padding(.vertical, DesignSystem.Spacing.xSmall)
        .frame(maxWidth: .infinity)
        .glassBackground()
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .stroke(gradient.opacity(0.3), lineWidth: 1)
        )
    }
}

/// Empty activity card
struct EmptyActivityCard: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundStyle(DesignSystem.Gradients.accent)
            
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Text("No Activity Yet")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Start tracking your meals and symptoms to see patterns")
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xLarge)
        .glassBackground()
    }
}

/// Quick action button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.xxSmall) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.medium)
            .background(
                color == .orange ? DesignSystem.Gradients.primary : DesignSystem.Gradients.secondary
            )
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .shadow(color: color.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
    }
}

/// Empty state card
struct EmptyStateCard: View {
    let title: String
    let message: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
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