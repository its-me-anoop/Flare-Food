//
//  BeveragesListView.swift
//  Flare Food
//
//  Created by Anoop Jose on 23/05/2025.
//

import SwiftUI
import SwiftData

/// List view for viewing beverage intake history
struct BeveragesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserProfile> { $0.isActive }) private var activeProfiles: [UserProfile]
    @Query(sort: \FluidEntry.timestamp, order: .reverse) private var allBeverageEntries: [FluidEntry]
    
    @State private var showingAddSheet = false
    @State private var selectedEntry: FluidEntry?
    @State private var selectedTimeRange: TimeRange = .today
    @State private var showCaffeinatedOnly = false
    
    private var activeProfile: UserProfile? {
        activeProfiles.first
    }
    
    /// Beverages filtered by active profile
    private var beverageEntries: [FluidEntry] {
        guard let profileId = activeProfile?.id else { return [] }
        return allBeverageEntries.filter { $0.profileId == profileId }
    }
    
    enum TimeRange: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
        case all = "All Time"
        
        var startDate: Date {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .today:
                return calendar.startOfDay(for: now)
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: now)!
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: now)!
            case .all:
                return Date.distantPast
            }
        }
    }
    
    private var filteredEntries: [FluidEntry] {
        beverageEntries.filter { entry in
            let matchesTimeRange = entry.timestamp >= selectedTimeRange.startDate
            let matchesCaffeineFilter = !showCaffeinatedOnly || entry.caffeineContent != nil
            return matchesTimeRange && matchesCaffeineFilter
        }
    }
    
    private var totalFluid: Double {
        filteredEntries.reduce(0) { $0 + $1.amount }
    }
    
    private var totalEffectiveHydration: Double {
        filteredEntries.reduce(0) { $0 + $1.effectiveHydration }
    }
    
    private var totalCaffeine: Int {
        Int(filteredEntries.reduce(0) { $0 + ($1.caffeineContent ?? 0) })
    }
    
    private var dailyHydrationGoal: Double {
        2000 // 2L default goal
    }
    
    private var dailyCaffeineLimit: Double {
        400 // 400mg FDA recommended daily limit
    }
    
    private var todayProgress: Double {
        let todayEntries = beverageEntries.filter { entry in
            Calendar.current.isDateInToday(entry.timestamp)
        }
        return todayEntries.reduce(0) { $0 + $1.effectiveHydration }
    }
    
    private var todayCaffeine: Double {
        let todayEntries = beverageEntries.filter { entry in
            Calendar.current.isDateInToday(entry.timestamp)
        }
        return todayEntries.reduce(0) { $0 + ($1.caffeineContent ?? 0) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    // Summary Section
                    summarySection
                    
                    // Entries Section
                    if filteredEntries.isEmpty {
                        EmptyStateCard(
                            title: "No Beverages",
                            message: showCaffeinatedOnly ? "No caffeinated beverages logged" : "Start tracking your hydration",
                            icon: "drop"
                        )
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    } else {
                        entriesSection
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton(
                            icon: "plus",
                            gradient: DesignSystem.Gradients.accent
                        ) {
                            showingAddSheet = true
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Beverages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileNavigationButton()
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                BeverageLoggingSheet()
            }
            .sheet(item: $selectedEntry) { entry in
                BeverageDetailView(entry: entry)
            }
        }
    }
    
    // MARK: - Sections
    
    private var summarySection: some View {
        Section {
            VStack(spacing: DesignSystem.Spacing.medium) {
                // Time Range Picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // Filter Toggle
                Toggle("Caffeinated Only", isOn: $showCaffeinatedOnly)
                    .tint(.brown)
                
                // Today's Progress
                if selectedTimeRange == .today {
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        HydrationProgressView(
                            current: todayProgress,
                            goal: dailyHydrationGoal
                        )
                        
                        if todayCaffeine > 0 {
                            CaffeineProgressView(
                                current: todayCaffeine,
                                limit: dailyCaffeineLimit
                            )
                        }
                    }
                }
                
                // Stats
                HStack(spacing: DesignSystem.Spacing.small) {
                    VStack(spacing: DesignSystem.Spacing.xxSmall) {
                        Text("Total Volume")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                        
                        Text(formatAmount(totalFluid))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignSystem.Gradients.accent)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                        .frame(height: 30)
                    
                    VStack(spacing: DesignSystem.Spacing.xxSmall) {
                        Text("Hydration")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                        
                        Text(formatAmount(totalEffectiveHydration))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignSystem.Gradients.accent)
                    }
                    .frame(maxWidth: .infinity)
                    
                    if totalCaffeine > 0 {
                        Divider()
                            .frame(height: 30)
                        
                        VStack(spacing: DesignSystem.Spacing.xxSmall) {
                            Text("Caffeine")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                            
                            Text("\(totalCaffeine)mg")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [Color.brown, Color.brown.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, DesignSystem.Spacing.small)
        }
    }
    
    private var entriesSection: some View {
        Section("Entries") {
            ForEach(filteredEntries) { entry in
                BeverageEntryRow(entry: entry) {
                    selectedEntry = entry
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        deleteEntry(entry)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatAmount(_ amount: Double) -> String {
        if amount >= 1000 {
            return String(format: "%.1fL", amount / 1000)
        }
        return String(format: "%.0fml", amount)
    }
    
    private func deleteEntry(_ entry: FluidEntry) {
        modelContext.delete(entry)
        do {
            try modelContext.save()
        } catch {
            print("Error deleting beverage entry: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct BeverageEntryRow: View {
    let entry: FluidEntry
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: entry.type.icon)
                    .font(.title2)
                    .foregroundStyle(entry.type.isCaffeinated ? 
                        LinearGradient(
                            gradient: Gradient(colors: [Color.brown, Color.brown.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) : DesignSystem.Gradients.accent
                    )
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.displayName)
                        .font(.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    HStack(spacing: 8) {
                        Text(entry.formattedAmount)
                            .font(.caption)
                        
                        if let caffeine = entry.formattedCaffeineContent {
                            Text("•")
                            Text(caffeine)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.brown)
                        }
                        
                        Image(systemName: entry.temperature.icon)
                            .font(.caption)
                    }
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(entry.timestamp, style: .time)
                        .font(.caption)
                    
                    Text(entry.timestamp, style: .date)
                        .font(.caption2)
                }
                .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CaffeineProgressView: View {
    let current: Double
    let limit: Double
    
    private var progress: Double {
        min(1.0, current / limit)
    }
    
    private var progressColor: Color {
        switch current {
        case 0..<200:
            return .green
        case 200..<400:
            return .orange
        default:
            return .red
        }
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            HStack {
                Text("Daily Caffeine")
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(Int(current))mg / \(Int(limit))mg")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(progressColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [progressColor.opacity(0.8), progressColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * progress, height: 20)
                }
            }
            .frame(height: 20)
        }
    }
}

// Detail view for beverages
struct BeverageDetailView: View {
    let entry: FluidEntry
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Details") {
                    HStack {
                        Text("Type")
                        Spacer()
                        Text(entry.displayName)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        Text(entry.formattedAmount)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    
                    HStack {
                        Text("Temperature")
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: entry.temperature.icon)
                                .font(.caption)
                            Text(entry.temperature.rawValue)
                        }
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    
                    if let caffeine = entry.formattedCaffeineContent {
                        HStack {
                            Text("Caffeine")
                            Spacer()
                            Text(caffeine)
                                .foregroundColor(.brown)
                        }
                    }
                    
                    if entry.type.hydrationFactor != 1.0 {
                        HStack {
                            Text("Effective Hydration")
                            Spacer()
                            Text(entry.formattedEffectiveHydration)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }
                    
                    HStack {
                        Text("Time")
                        Spacer()
                        Text(entry.timestamp, format: .dateTime)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
                
                if let notes = entry.notes, !notes.isEmpty {
                    Section("Notes") {
                        Text(notes)
                            .font(.body)
                    }
                }
                
                if let meal = entry.meal {
                    Section("Linked Meal") {
                        HStack {
                            Image(systemName: meal.type.icon)
                                .foregroundStyle(DesignSystem.Gradients.primary)
                            
                            VStack(alignment: .leading) {
                                Text(meal.type.rawValue)
                                    .font(.subheadline)
                                
                                Text(meal.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Beverage Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HydrationProgressView: View {
    let current: Double
    let goal: Double
    
    private var progress: Double {
        min(1.0, current / goal)
    }
    
    private var progressColor: Color {
        switch progress {
        case 0..<0.5:
            return .red
        case 0.5..<0.8:
            return .orange
        default:
            return .green
        }
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            HStack {
                Text("Daily Goal Progress")
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(progressColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [progressColor.opacity(0.8), progressColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * progress, height: 20)
                }
            }
            .frame(height: 20)
            
            HStack {
                Text(formatAmount(current))
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                Spacer()
                
                Text("Goal: \(formatAmount(goal))")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount >= 1000 {
            return String(format: "%.1fL", amount / 1000)
        }
        return String(format: "%.0fml", amount)
    }
}

// MARK: - Preview

#Preview {
    BeveragesListView()
        .modelContainer(for: [FluidEntry.self, Meal.self], inMemory: true)
}