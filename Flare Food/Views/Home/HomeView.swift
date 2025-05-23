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
    @State private var selectedMeal: Meal?
    @State private var selectedSymptom: Symptom?
    
    private var userProfile: UserProfile? {
        userProfiles.first
    }
    
    /// Calculate current streak from actual data
    private var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Combine all activity dates (meals and symptoms)
        let mealDates = recentMeals.map { calendar.startOfDay(for: $0.timestamp) }
        let symptomDates = recentSymptoms.map { calendar.startOfDay(for: $0.timestamp) }
        
        // Get unique dates with activity
        let allDates = Set(mealDates + symptomDates).sorted(by: >)
        
        guard !allDates.isEmpty else { return 0 }
        
        // Check if there's activity today or yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        guard allDates.contains(today) || allDates.contains(yesterday) else { return 0 }
        
        // Count consecutive days backwards from today
        var streak = 0
        var checkDate = today
        
        for date in allDates {
            if date == checkDate {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if date < checkDate {
                break
            }
        }
        
        return streak
    }
    
    var body: some View {
        NavigationStack {
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
            .sheet(item: $selectedMeal) { meal in
                MealDetailView(meal: meal)
            }
            .sheet(item: $selectedSymptom) { symptom in
                SymptomDetailView(symptom: symptom)
            }
        }
    }
    
    // MARK: - Sections
    
    /// Welcome section with greeting
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            GradientText(greeting, gradient: DesignSystem.Gradients.primary, font: .largeTitle.bold())
            
            if currentStreak > 0 {
                HStack(spacing: DesignSystem.Spacing.xxSmall) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(DesignSystem.Gradients.primary)
                    Text("\(currentStreak) day streak!")
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .font(.title3)
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
                value: "\(recentMeals.count)",
                icon: "fork.knife",
                gradient: DesignSystem.Gradients.primary
            )
            
            StatCard(
                title: "Symptoms Tracked",
                value: "\(recentSymptoms.count)",
                icon: "heart.text.square.fill",
                gradient: DesignSystem.Gradients.secondary
            )
        }
    }
    
    /// Recent activity section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
            
            if recentMeals.isEmpty && recentSymptoms.isEmpty {
                EmptyStateCard(
                    title: "No Activity Yet",
                    message: "Start by logging your first meal or symptom",
                    icon: "chart.bar.doc.horizontal"
                )
            } else {
                VStack(spacing: 12) {
                    // Recent Meals
                    if !recentMeals.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Recent Meals", systemImage: "clock")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ForEach(recentMeals.prefix(3)) { meal in
                                RecentMealCard(meal: meal) {
                                    selectedMeal = meal
                                }
                            }
                        }
                    }
                    
                    // Recent Symptoms
                    if !recentSymptoms.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Recent Symptoms", systemImage: "clock")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ForEach(recentSymptoms.prefix(3)) { symptom in
                                RecentSymptomCard(symptom: symptom) {
                                    selectedSymptom = symptom
                                }
                            }
                        }
                    }
                }
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
    
    /// Ensures a user profile exists
    private func ensureUserProfile() {
        if userProfiles.isEmpty {
            let profile = UserProfile()
            modelContext.insert(profile)
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
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
}

/// Recent meal card
struct RecentMealCard: View {
    let meal: Meal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: meal.type.icon)
                    .font(.title2)
                    .foregroundStyle(DesignSystem.Gradients.primary)
                    .frame(width: 44, height: 44)
                    .background(DesignSystem.Colors.cardBackground)
                    .cornerRadius(DesignSystem.CornerRadius.small)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.type.rawValue)
                        .font(.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    if !meal.foodItems.isEmpty {
                        Text(meal.foodItems.prefix(2).compactMap { $0.food?.name }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Text(meal.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .padding(DesignSystem.Spacing.small)
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Recent symptom card
struct RecentSymptomCard: View {
    let symptom: Symptom
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: symptom.type.category.icon)
                    .font(.title2)
                    .foregroundStyle(DesignSystem.Gradients.secondary)
                    .frame(width: 44, height: 44)
                    .background(DesignSystem.Colors.cardBackground)
                    .cornerRadius(DesignSystem.CornerRadius.small)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(symptom.type.rawValue)
                        .font(.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    HStack {
                        Text("Severity: \(Int(symptom.severity))/10")
                            .font(.caption)
                        
                        Circle()
                            .fill(severityGradient(for: symptom.severityLevel))
                            .frame(width: 8, height: 8)
                    }
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                Text(symptom.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .padding(DesignSystem.Spacing.small)
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
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