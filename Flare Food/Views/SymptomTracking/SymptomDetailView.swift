//
//  SymptomDetailView.swift
//  Flare Food
//
//  Created by Anoop Jose on 23/05/2025.
//

import SwiftUI
import SwiftData

/// Detailed view of a symptom
struct SymptomDetailView: View {
    let symptom: Symptom
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var meals: [Meal]
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    /// Meals logged around the symptom time
    private var nearbyMeals: [Meal] {
        let timeWindow = TimeInterval(4 * 60 * 60) // 4 hours
        let startTime = symptom.timestamp.addingTimeInterval(-timeWindow)
        
        return meals.filter { meal in
            meal.timestamp >= startTime && meal.timestamp <= symptom.timestamp
        }
        .sorted { $0.timestamp > $1.timestamp }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                    // Header card
                    headerCard
                    
                    // Severity section
                    severitySection
                    
                    // Duration section
                    if let duration = symptom.durationMinutes {
                        durationSection(duration: duration)
                    }
                    
                    // Potential triggers section
                    if !nearbyMeals.isEmpty {
                        potentialTriggersSection
                    }
                    
                    // Notes section
                    if let notes = symptom.notes, !notes.isEmpty {
                        notesSection(notes: notes)
                    }
                    
                    // Metadata section
                    metadataSection
                }
                .padding()
            }
            .navigationTitle("Symptom Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                SymptomEditSheet(symptom: symptom)
            }
            .alert("Delete Symptom", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteSymptom()
                }
            } message: {
                Text("Are you sure you want to delete this symptom? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerCard: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            // Icon and category
            VStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: symptom.type.icon)
                    .font(.system(size: 60))
                    .foregroundStyle(severityGradient)
                    .frame(width: 100, height: 100)
                    .glassBackground(cornerRadius: DesignSystem.CornerRadius.large)
                
                Text(symptom.type.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Label(symptom.type.category.rawValue, systemImage: symptom.type.category.icon)
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            
            // Time info
            VStack(spacing: DesignSystem.Spacing.xxSmall) {
                Text(symptom.timestamp, style: .date)
                    .font(.headline)
                Text(symptom.timestamp, style: .time)
                    .font(.subheadline)
                Text(relativeTime)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.large)
        .glassBackground()
    }
    
    private var severitySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Severity", systemImage: "gauge")
                .font(.headline)
                .foregroundStyle(severityGradient)
            
            HStack(spacing: DesignSystem.Spacing.medium) {
                // Severity gauge
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                    
                    Circle()
                        .trim(from: 0, to: symptom.severity / 10)
                        .stroke(severityGradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: symptom.severity)
                    
                    VStack(spacing: 4) {
                        Text("\(Int(symptom.severity))")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(severityGradient)
                        
                        Text("out of 10")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
                .frame(width: 120, height: 120)
                
                // Severity level
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                    Text(symptom.severityLevel.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(severityGradient)
                    
                    Text(severityDescription)
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(DesignSystem.Spacing.medium)
            .glassBackground()
        }
    }
    
    private func durationSection(duration: Int) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Duration", systemImage: "clock")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            HStack {
                Image(systemName: "clock.fill")
                    .font(.title2)
                    .foregroundStyle(DesignSystem.Gradients.accent)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(duration) minutes")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(durationDescription(duration))
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
            }
            .padding(DesignSystem.Spacing.medium)
            .glassBackground()
        }
    }
    
    private var potentialTriggersSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Potential Food Triggers", systemImage: "exclamationmark.triangle")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Text("Meals consumed in the 4 hours before this symptom:")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            ForEach(nearbyMeals) { meal in
                NavigationLink(destination: MealDetailView(meal: meal)) {
                    HStack {
                        Image(systemName: meal.type.icon)
                            .font(.title3)
                            .foregroundStyle(DesignSystem.Gradients.primary)
                            .frame(width: 40, height: 40)
                            .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(meal.type.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("•")
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                                
                                Text(timeBeforeSymptom(meal: meal))
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                            
                            if !meal.foodItems.isEmpty {
                                Text(meal.foodItems.prefix(3).compactMap { $0.food?.name }.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    .padding(DesignSystem.Spacing.small)
                    .glassBackground()
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func notesSection(notes: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Notes", systemImage: "note.text")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Text(notes)
                .font(.body)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .padding(DesignSystem.Spacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassBackground()
        }
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Information", systemImage: "info.circle")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                metadataRow(label: "Recorded", value: symptom.timestamp.formatted(date: .complete, time: .standard))
                metadataRow(label: "Category", value: symptom.type.category.rawValue)
                metadataRow(label: "Type", value: symptom.type.rawValue)
            }
            .padding(DesignSystem.Spacing.medium)
            .glassBackground()
        }
    }
    
    private func metadataRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.primaryText)
        }
    }
    
    // MARK: - Helper Properties
    
    private var severityGradient: LinearGradient {
        switch symptom.severityLevel {
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
    
    private var severityDescription: String {
        switch symptom.severityLevel {
        case .mild:
            return "Minor discomfort that doesn't significantly impact daily activities"
        case .moderate:
            return "Noticeable discomfort that may affect some activities"
        case .severe:
            return "Significant discomfort that interferes with daily activities"
        case .verySevere:
            return "Extreme discomfort requiring immediate attention or rest"
        }
    }
    
    private var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: symptom.timestamp, relativeTo: Date())
    }
    
    private func durationDescription(_ minutes: Int) -> String {
        switch minutes {
        case 0..<15:
            return "Brief episode"
        case 15..<30:
            return "Short duration"
        case 30..<60:
            return "Moderate duration"
        case 60..<120:
            return "Extended duration"
        default:
            return "Long duration"
        }
    }
    
    private func timeBeforeSymptom(meal: Meal) -> String {
        let interval = symptom.timestamp.timeIntervalSince(meal.timestamp)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m before"
        } else {
            return "\(minutes)m before"
        }
    }
    
    /// Delete the symptom
    private func deleteSymptom() {
        modelContext.delete(symptom)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    SymptomDetailView(symptom: Symptom(
        type: .bloating,
        timestamp: Date(),
        severity: 7,
        notes: "Felt bloated after lunch, possibly from the dairy products",
        durationMinutes: 45
    ))
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