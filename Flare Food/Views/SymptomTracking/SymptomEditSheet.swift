//
//  SymptomEditSheet.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import SwiftData

/// Sheet for editing an existing symptom
struct SymptomEditSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let symptom: Symptom
    
    @State private var selectedSymptomType: Symptom.SymptomType
    @State private var selectedTimestamp: Date
    @State private var severity: Double
    @State private var notes: String
    @State private var medications: [String]
    @State private var newMedication: String = ""
    @State private var durationMinutes: String
    @State private var bodyLocation: String
    
    init(symptom: Symptom) {
        self.symptom = symptom
        self._selectedSymptomType = State(initialValue: symptom.type)
        self._selectedTimestamp = State(initialValue: symptom.timestamp)
        self._severity = State(initialValue: symptom.severity)
        self._notes = State(initialValue: symptom.notes ?? "")
        self._medications = State(initialValue: symptom.medications)
        self._durationMinutes = State(initialValue: symptom.durationMinutes != nil ? "\(symptom.durationMinutes!)" : "")
        self._bodyLocation = State(initialValue: symptom.bodyLocation ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    // Symptom type
                    symptomTypeSection
                    
                    // Date and time
                    dateTimeSection
                    
                    // Severity
                    severitySection
                    
                    // Duration
                    durationSection
                    
                    // Medications
                    medicationsSection
                    
                    // Body location
                    bodyLocationSection
                    
                    // Notes
                    notesSection
                }
                .padding()
            }
            .navigationTitle("Edit Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSymptom()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Sections
    
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
                                selectedSymptomType = type
                            }) {
                                Label(type.rawValue, systemImage: type.icon)
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: selectedSymptomType.icon)
                        .foregroundStyle(DesignSystem.Gradients.secondary)
                    Text(selectedSymptomType.rawValue)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .padding()
                .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
            }
        }
    }
    
    /// Date and time selection
    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Date & Time", systemImage: "calendar.clock")
                .font(.headline)
                .foregroundStyle(DesignSystem.Gradients.accent)
            
            DatePicker(
                "",
                selection: $selectedTimestamp,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .padding()
            .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
        }
    }
    
    /// Severity slider
    private var severitySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                Label("Severity", systemImage: "gauge")
                    .font(.headline)
                    .foregroundStyle(severityGradient)
                
                Spacer()
                
                Text("\(Int(severity))/10")
                    .font(.headline)
                    .foregroundStyle(severityGradient)
            }
            
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Slider(value: $severity, in: 0...10, step: 1)
                    .tint(severityColor)
                
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
        }
    }
    
    /// Duration input
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Duration (optional)", systemImage: "clock")
                .font(.headline)
                .foregroundStyle(DesignSystem.Gradients.accent)
            
            HStack {
                TextField("Duration", text: $durationMinutes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                Text("minutes")
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
    }
    
    /// Medications section
    private var medicationsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Medications", systemImage: "pills")
                .font(.headline)
                .foregroundStyle(DesignSystem.Gradients.primary)
            
            // Current medications
            if !medications.isEmpty {
                ForEach(medications, id: \.self) { medication in
                    HStack {
                        Text(medication)
                            .font(.subheadline)
                        Spacer()
                        Button(action: {
                            medications.removeAll { $0 == medication }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.small)
                    .padding(.vertical, DesignSystem.Spacing.xSmall)
                    .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
                }
            }
            
            // Add medication
            HStack {
                TextField("Add medication", text: $newMedication)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: addMedication) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(DesignSystem.Gradients.primary)
                }
                .disabled(newMedication.isEmpty)
            }
        }
    }
    
    /// Body location input
    private var bodyLocationSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Body Location (optional)", systemImage: "figure.stand")
                .font(.headline)
                .foregroundStyle(DesignSystem.Gradients.accent)
            
            TextField("Body location", text: $bodyLocation)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    /// Notes section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Notes (optional)", systemImage: "note.text")
                .font(.headline)
                .foregroundStyle(DesignSystem.Gradients.accent)
            
            TextField("Additional notes", text: $notes, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(2...4)
        }
    }
    
    // MARK: - Helper Properties
    
    private var severityGradient: LinearGradient {
        switch severityLevel {
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
    
    private var severityColor: Color {
        switch severityLevel {
        case .mild:
            return .green
        case .moderate:
            return .yellow
        case .severe:
            return .orange
        case .verySevere:
            return .red
        }
    }
    
    private var severityLevel: Symptom.SeverityLevel {
        switch severity {
        case 0..<2.5: return .mild
        case 2.5..<5.0: return .moderate
        case 5.0..<7.5: return .severe
        default: return .verySevere
        }
    }
    
    // MARK: - Methods
    
    /// Add a new medication
    private func addMedication() {
        let trimmed = newMedication.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        medications.append(trimmed)
        newMedication = ""
    }
    
    /// Save the edited symptom
    private func saveSymptom() {
        // Update symptom properties
        symptom.symptomType = selectedSymptomType.rawValue
        symptom.timestamp = selectedTimestamp
        symptom.severity = severity
        symptom.notes = notes.isEmpty ? nil : notes
        symptom.medications = medications
        symptom.durationMinutes = Int(durationMinutes)
        symptom.bodyLocation = bodyLocation.isEmpty ? nil : bodyLocation
        
        // Save context is automatic with SwiftData
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(for: Symptom.self)
    let symptom = Symptom(type: .headache, severity: 5.0)
    container.mainContext.insert(symptom)
    
    return SymptomEditSheet(symptom: symptom)
        .modelContainer(container)
}