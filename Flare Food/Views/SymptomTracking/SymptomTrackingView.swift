//
//  SymptomTrackingView.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import SwiftData

/// Main view for tracking symptoms
struct SymptomTrackingView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        SymptomTrackingContentView(modelContext: modelContext)
    }
}

/// Internal view that handles the view model
private struct SymptomTrackingContentView: View {
    let modelContext: ModelContext
    @StateObject private var viewModel: SymptomTrackingViewModel
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        let dataService = DataService(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: SymptomTrackingViewModel(dataService: dataService))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Recent Symptoms (Quick Log)
                    if !viewModel.recentSymptoms.isEmpty {
                        recentSymptomsSection
                    }
                    
                    // Symptom Category Selection
                    categorySelectionSection
                    
                    // Symptom Type Selection
                    symptomTypeSection
                    
                    // Severity Slider
                    severitySection
                    
                    // Duration Input
                    durationSection
                    
                    // Body Location (if applicable)
                    if !viewModel.suggestedBodyLocations.isEmpty {
                        bodyLocationSection
                    }
                    
                    // Medications
                    medicationsSection
                    
                    // Notes
                    notesSection
                    
                    // Save Button
                    saveButton
                }
                .padding()
            }
            .navigationTitle("Track Symptom")
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .overlay {
                if viewModel.showSuccessAnimation {
                    SuccessAnimationView()
                }
            }
        }
    }
    
    // MARK: - Sections
    
    /// Recent symptoms for quick logging
    private var recentSymptomsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Log Recent Symptom")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.recentSymptoms.prefix(5)) { symptom in
                        RecentSymptomChip(symptom: symptom) {
                            viewModel.quickLogFromRecent(symptom)
                        }
                    }
                }
            }
        }
    }
    
    /// Category selection section
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // All categories option
                    CategoryButton(
                        title: "All",
                        icon: "square.grid.2x2",
                        color: .gray,
                        isSelected: viewModel.selectedCategory == nil
                    ) {
                        viewModel.selectedCategory = nil
                    }
                    
                    ForEach(Symptom.SymptomCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            title: category.rawValue,
                            icon: category.icon,
                            color: category.color,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
        }
    }
    
    /// Symptom type selection section
    private var symptomTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Symptom Type")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                ForEach(viewModel.filteredSymptomTypes, id: \.self) { type in
                    SymptomTypeButton(
                        type: type,
                        isSelected: viewModel.selectedSymptomType == type
                    ) {
                        viewModel.selectedSymptomType = type
                    }
                }
            }
        }
    }
    
    /// Severity section with slider
    private var severitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Severity")
                    .font(.headline)
                Spacer()
                Text("\(Int(viewModel.severity))/10")
                    .font(.headline)
                    .foregroundColor(severityColor)
            }
            
            VStack(spacing: 8) {
                Slider(value: $viewModel.severity, in: 0...10, step: 1)
                    .tint(severityColor)
                
                HStack {
                    Text("Mild")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Severe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    /// Duration input section
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Duration")
                .font(.headline)
            
            HStack {
                TextField("Minutes", text: $viewModel.durationMinutes)
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                
                Text("minutes")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
    }
    
    /// Body location section
    private var bodyLocationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)
            
            // Suggested locations
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.suggestedBodyLocations, id: \.self) { location in
                        Button {
                            viewModel.bodyLocation = location
                        } label: {
                            Text(location)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(viewModel.bodyLocation == location ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(viewModel.bodyLocation == location ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
            }
            
            // Custom input
            TextField("Or specify location...", text: $viewModel.bodyLocation)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    /// Medications section
    private var medicationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Medications Taken")
                .font(.headline)
            
            // Common medications
            if !viewModel.commonMedications.isEmpty && viewModel.medications.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.commonMedications, id: \.self) { medication in
                            Button {
                                viewModel.medications.append(medication)
                            } label: {
                                Label(medication, systemImage: "plus.circle")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
            }
            
            // Added medications
            ForEach(viewModel.medications.indices, id: \.self) { index in
                HStack {
                    Text(viewModel.medications[index])
                    Spacer()
                    Button {
                        viewModel.removeMedication(at: index)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Add medication input
            HStack {
                TextField("Add medication...", text: $viewModel.newMedication)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        viewModel.addMedication()
                    }
                
                Button {
                    viewModel.addMedication()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                }
                .disabled(viewModel.newMedication.isEmpty)
            }
        }
    }
    
    /// Notes section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Notes", systemImage: "note.text")
                .font(.headline)
            
            TextField("Any additional notes?", text: $viewModel.notes, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
        }
    }
    
    /// Save button
    private var saveButton: some View {
        Button {
            Task {
                await viewModel.saveSymptom()
            }
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Save Symptom")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.pink)
            .foregroundColor(.white)
            .cornerRadius(12)
            .font(.headline)
        }
        .disabled(viewModel.isLoading)
    }
    
    // MARK: - Helper Properties
    
    /// Color based on severity
    private var severityColor: Color {
        switch viewModel.severity {
        case 0..<2.5: return .green
        case 2.5..<5.0: return .yellow
        case 5.0..<7.5: return .orange
        default: return .red
        }
    }
}

// MARK: - Supporting Views

/// Category selection button
struct CategoryButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption2)
            }
            .frame(width: 70, height: 60)
            .background(isSelected ? color : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(10)
        }
    }
}

/// Symptom type button
struct SymptomTypeButton: View {
    let type: Symptom.SymptomType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type.category.icon)
                    .foregroundColor(type.category.color)
                Text(type.rawValue)
                    .font(.caption)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? type.category.color.opacity(0.2) : Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? type.category.color : Color.clear, lineWidth: 2)
            )
            .cornerRadius(8)
        }
    }
}

/// Recent symptom chip for quick selection
struct RecentSymptomChip: View {
    let symptom: Symptom
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(symptom.type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                
                HStack(spacing: 4) {
                    Text("Severity: \(Int(symptom.severity))")
                        .font(.caption2)
                    Circle()
                        .fill(symptom.severityLevel.color)
                        .frame(width: 6, height: 6)
                }
                
                Text(symptom.timestamp, style: .relative)
                    .font(.caption2)
            }
            .padding()
            .background(symptom.type.category.color.opacity(0.1))
            .foregroundColor(.primary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(symptom.type.category.color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    SymptomTrackingView()
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