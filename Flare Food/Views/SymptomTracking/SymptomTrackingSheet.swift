//
//  SymptomTrackingSheet.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import SwiftData

/// Bottom sheet for tracking symptoms
struct SymptomTrackingSheet: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentDetent: PresentationDetent = .medium
    
    var body: some View {
        SymptomTrackingSheetContent(modelContext: modelContext)
            .presentationDetents([.medium, .large], selection: $currentDetent)
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(DesignSystem.CornerRadius.large)
    }
}

/// Internal content view that handles the view model
private struct SymptomTrackingSheetContent: View {
    let modelContext: ModelContext
    @StateObject private var viewModel: SymptomTrackingViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        let dataService = DataService(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: SymptomTrackingViewModel(dataService: dataService))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.background,
                        DesignSystem.Colors.secondaryGradientStart.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.large) {
                        // Quick selection header
                        quickSelectionHeader
                        
                        // Main form
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            // Symptom Type Selection
                            symptomTypeSection
                            
                            // Severity Slider
                            severitySection
                            
                            // Duration
                            durationSection
                            
                            // Potential Triggers
                            triggersSection
                            
                            // Notes
                            notesSection
                            
                            // Action Buttons
                            actionButtons
                        }
                        .padding(.horizontal)
                        .padding(.bottom, DesignSystem.Spacing.large)
                    }
                }
            }
            .navigationTitle("Track Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }
    
    // MARK: - Supporting Views
    
    /// Quick selection for common symptoms
    private var quickSelectionHeader: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("Quick Select")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.small) {
                    // Common symptoms
                    ForEach([
                        ("Bloating", Symptom.SymptomType.bloating),
                        ("Stomach Pain", Symptom.SymptomType.stomachPain),
                        ("Headache", Symptom.SymptomType.headache),
                        ("Fatigue", Symptom.SymptomType.fatigue),
                        ("Nausea", Symptom.SymptomType.nausea)
                    ], id: \.0) { name, type in
                        Button(action: {
                            viewModel.selectedType = type
                        }) {
                            HStack(spacing: DesignSystem.Spacing.xxSmall) {
                                Image(systemName: type.category.icon)
                                Text(name)
                            }
                            .font(.subheadline)
                            .fontWeight(viewModel.selectedType == type ? .semibold : .regular)
                            .padding(.horizontal, DesignSystem.Spacing.small)
                            .padding(.vertical, DesignSystem.Spacing.xSmall)
                            .background(
                                viewModel.selectedType == type
                                    ? AnyView(DesignSystem.Gradients.secondary)
                                    : AnyView(Color.gray.opacity(0.2))
                            )
                            .foregroundColor(viewModel.selectedType == type ? .white : DesignSystem.Colors.primaryText)
                            .cornerRadius(DesignSystem.CornerRadius.small)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    /// Symptom type selection
    private var symptomTypeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Symptom Type", systemImage: "heart.text.square")
                .font(.headline)
                .foregroundStyle(DesignSystem.Gradients.secondary)
            
            Menu {
                ForEach(Symptom.SymptomCategory.allCases, id: \.self) { category in
                    Section(category.rawValue) {
                        ForEach(Symptom.SymptomType.allCases.filter { $0.category == category }, id: \.self) { type in
                            Button(action: {
                                viewModel.selectedType = type
                            }) {
                                Label(type.rawValue, systemImage: category.icon)
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    if let selectedType = viewModel.selectedType {
                        Image(systemName: selectedType.category.icon)
                            .foregroundStyle(DesignSystem.Gradients.secondary)
                        Text(selectedType.rawValue)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    } else {
                        Text("Select symptom type")
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .padding()
                .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
            }
        }
    }
    
    /// Severity slider section
    private var severitySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                Label("Severity", systemImage: "gauge")
                    .font(.headline)
                    .foregroundStyle(severityGradient)
                
                Spacer()
                
                Text("\(Int(viewModel.severity))/10")
                    .font(.headline)
                    .foregroundStyle(severityGradient)
            }
            
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Slider(value: $viewModel.severity, in: 0...10, step: 1) { _ in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                .tint(Color(severityGradient.stops.first?.color ?? .red))
                
                HStack {
                    Text("Mild")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    Spacer()
                    Text("Severe")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            .padding()
            .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
            
            // Severity description
            Text(severityDescription)
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .italic()
        }
    }
    
    /// Duration input
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Duration (optional)", systemImage: "clock")
                .font(.headline)
                .foregroundStyle(DesignSystem.Gradients.accent)
            
            HStack {
                TextField("Duration", value: $viewModel.duration, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                Text("minutes")
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
    }
    
    /// Potential triggers
    private var triggersSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Potential Triggers", systemImage: "exclamationmark.triangle")
                .font(.headline)
                .foregroundStyle(DesignSystem.Gradients.primary)
            
            // Recent meals as potential triggers
            if !viewModel.recentMeals.isEmpty {
                Text("Recent meals (tap to select)")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.small) {
                        ForEach(viewModel.recentMeals) { meal in
                            TriggerChip(
                                title: meal.type.rawValue,
                                subtitle: meal.timestamp.formatted(date: .omitted, time: .shortened),
                                isSelected: viewModel.selectedMealTriggers.contains(meal.id),
                                action: {
                                    if viewModel.selectedMealTriggers.contains(meal.id) {
                                        viewModel.selectedMealTriggers.remove(meal.id)
                                    } else {
                                        viewModel.selectedMealTriggers.insert(meal.id)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            
            // Custom triggers
            TextField("Other triggers (comma separated)", text: $viewModel.customTriggers)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    /// Notes section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Notes (optional)", systemImage: "note.text")
                .font(.headline)
                .foregroundStyle(DesignSystem.Gradients.accent)
            
            TextField("Additional notes", text: $viewModel.notes, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(2...4)
        }
    }
    
    /// Action buttons
    private var actionButtons: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            // Cancel button
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .glassBackground(cornerRadius: DesignSystem.CornerRadius.medium)
            }
            
            // Save button
            GradientButton(
                title: "Save Symptom",
                icon: "checkmark.circle.fill",
                gradient: DesignSystem.Gradients.secondary,
                action: {
                    Task {
                        await viewModel.saveSymptom()
                        dismiss()
                    }
                },
                isDisabled: viewModel.selectedType == nil
            )
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Helper Properties
    
    private var severityGradient: LinearGradient {
        switch viewModel.severityLevel {
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
        switch viewModel.severityLevel {
        case .mild:
            return "Mild discomfort, easily manageable"
        case .moderate:
            return "Noticeable discomfort, some impact on activities"
        case .severe:
            return "Significant discomfort, interferes with daily activities"
        case .verySevere:
            return "Intense discomfort, severely limits activities"
        }
    }
}

/// Trigger selection chip
private struct TriggerChip: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : DesignSystem.Colors.secondaryText)
            }
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(
                isSelected
                    ? AnyView(DesignSystem.Gradients.primary)
                    : AnyView(Color.gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryText)
            .cornerRadius(DesignSystem.CornerRadius.small)
        }
    }
}

// MARK: - Preview

#Preview {
    SymptomTrackingSheet()
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