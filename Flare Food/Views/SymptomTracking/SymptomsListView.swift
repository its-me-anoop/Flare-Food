//
//  SymptomsListView.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import SwiftData

/// View displaying a list of all tracked symptoms
struct SymptomsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Symptom.timestamp, order: .reverse) private var symptoms: [Symptom]
    
    @State private var searchText = ""
    @State private var selectedCategory: Symptom.SymptomCategory?
    @State private var showingSymptomTracker = false
    @State private var selectedSymptom: Symptom?
    @State private var symptomToEdit: Symptom?
    @State private var showingDeleteAlert = false
    @State private var symptomToDelete: Symptom?
    
    /// Filtered symptoms based on search and category
    private var filteredSymptoms: [Symptom] {
        symptoms.filter { symptom in
            let matchesSearch = searchText.isEmpty || 
                symptom.type.rawValue.localizedCaseInsensitiveContains(searchText) ||
                (symptom.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchesCategory = selectedCategory == nil || symptom.type.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
    }
    
    /// Groups filtered symptoms by date
    private var groupedSymptoms: [(key: String, value: [Symptom])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let grouped = Dictionary(grouping: filteredSymptoms) { symptom in
            let symptomDate = calendar.startOfDay(for: symptom.timestamp)
            
            if symptomDate == today {
                return "Today"
            } else if symptomDate == yesterday {
                return "Yesterday"
            } else {
                return symptom.timestamp.formatted(date: .abbreviated, time: .omitted)
            }
        }
        
        // Sort groups by date (Today first, then Yesterday, then by date)
        return grouped.sorted { first, second in
            if first.key == "Today" { return true }
            if second.key == "Today" { return false }
            if first.key == "Yesterday" { return true }
            if second.key == "Yesterday" { return false }
            
            // For other dates, sort by actual date
            if let firstSymptom = first.value.first,
               let secondSymptom = second.value.first {
                return firstSymptom.timestamp > secondSymptom.timestamp
            }
            return false
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.clear,
                        DesignSystem.Colors.secondaryGradientStart.opacity(0.1),
                        DesignSystem.Colors.secondaryGradientEnd.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                if symptoms.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 0) {
                        // Category filter
                        categoryFilterView
                            .padding(.horizontal)
                            .padding(.vertical, DesignSystem.Spacing.small)
                        
                        // Symptoms list
                        if filteredSymptoms.isEmpty {
                            Spacer()
                            noResultsView
                            Spacer()
                        } else {
                            List {
                                ForEach(groupedSymptoms, id: \.key) { dateGroup in
                                    Section {
                                        ForEach(dateGroup.value) { symptom in
                                            SymptomRowView(symptom: symptom) {
                                                selectedSymptom = symptom
                                            }
                                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                Button(role: .destructive) {
                                                    symptomToDelete = symptom
                                                    showingDeleteAlert = true
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                                
                                                Button {
                                                    symptomToEdit = symptom
                                                } label: {
                                                    Label("Edit", systemImage: "pencil")
                                                }
                                                .tint(.purple)
                                            }
                                        }
                                    } header: {
                                        Text(dateGroup.key)
                                            .font(.headline)
                                            .foregroundColor(DesignSystem.Colors.secondaryText)
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingSymptomTracker = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(DesignSystem.Gradients.secondary)
                                .clipShape(Circle())
                                .shadow(color: DesignSystem.Colors.secondaryGradientEnd.opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                        .padding(.trailing, DesignSystem.Spacing.large)
                        .padding(.bottom, DesignSystem.Spacing.large)
                    }
                }
            }
            .navigationTitle("Symptoms")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search symptoms")
            .sheet(isPresented: $showingSymptomTracker) {
                SymptomTrackingSheet()
            }
            .sheet(item: $selectedSymptom) { symptom in
                SymptomDetailView(symptom: symptom)
            }
            .sheet(item: $symptomToEdit) { symptom in
                SymptomEditSheet(symptom: symptom)
            }
            .alert("Delete Symptom", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    symptomToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let symptom = symptomToDelete {
                        deleteSymptom(symptom)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this symptom? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Delete a symptom
    private func deleteSymptom(_ symptom: Symptom) {
        modelContext.delete(symptom)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete symptom: \(error)")
        }
        symptomToDelete = nil
    }
    
    // MARK: - Supporting Views
    
    /// Category filter chips
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.small) {
                // All categories chip
                FilterChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                // Category chips
                ForEach(Symptom.SymptomCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
        }
    }
    
    /// Empty state when no symptoms
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 80))
                .foregroundStyle(DesignSystem.Gradients.secondary)
            
            VStack(spacing: DesignSystem.Spacing.small) {
                Text("No Symptoms Tracked")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Start tracking your symptoms to identify patterns")
                    .font(.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            GradientButton(
                title: "Track First Symptom",
                icon: "plus.circle.fill",
                gradient: DesignSystem.Gradients.secondary,
                action: {
                    showingSymptomTracker = true
                }
            )
        }
        .padding()
    }
    
    /// No results view for filtered search
    private var noResultsView: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            Text("No symptoms found")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            if !searchText.isEmpty {
                Text("Try adjusting your search or filters")
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
    }
}

/// Individual symptom row
struct SymptomRowView: View {
    let symptom: Symptom
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            // Header
            HStack {
                // Symptom icon
                Image(systemName: symptom.type.icon)
                    .font(.title2)
                    .foregroundStyle(severityGradient)
                    .frame(width: 44, height: 44)
                    .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
                
                // Symptom info
                VStack(alignment: .leading, spacing: 4) {
                    Text(symptom.type.rawValue)
                        .font(.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    HStack(spacing: DesignSystem.Spacing.xSmall) {
                        // Severity
                        Label("\(Int(symptom.severity))/10", systemImage: "gauge")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                        
                        // Severity indicator
                        Circle()
                            .fill(severityGradient)
                            .frame(width: 8, height: 8)
                        
                        // Category
                        Text("• \(symptom.type.category.rawValue)")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
                
                Spacer()
                
                // Time
                Text(symptom.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            
            // Duration if available
            if let duration = symptom.durationMinutes {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("Duration: \(duration) minutes")
                        .font(.caption)
                }
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .padding(.leading, 44 + DesignSystem.Spacing.small)
            }
            
            // Notes if available
            if let notes = symptom.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .lineLimit(2)
                    .padding(.leading, 44 + DesignSystem.Spacing.small)
            }
            
            }
            .padding()
            .glassBackground()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
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
}

// MARK: - Preview

#Preview {
    SymptomsListView()
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
