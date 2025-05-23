//
//  BeverageLoggingSheet.swift
//  Flare Food
//
//  Created by Anoop Jose on 23/05/2025.
//

import SwiftUI
import SwiftData

/// Sheet view for logging beverage intake (fluid and caffeine)
struct BeverageLoggingSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<UserProfile> { $0.isActive }) private var activeProfiles: [UserProfile]
    
    @State private var selectedType: FluidEntry.FluidType = .water
    @State private var customTypeName = ""
    @State private var amount: Double = 250
    @State private var temperature: FluidEntry.FluidTemperature = .roomTemp
    @State private var caffeineContent: Double = 0
    @State private var isCustomCaffeine = false
    @State private var notes = ""
    @State private var selectedDate = Date()
    @State private var linkedMeal: Meal?
    
    @Query(sort: \Meal.timestamp, order: .reverse) private var allMeals: [Meal]
    
    private var activeProfile: UserProfile? {
        activeProfiles.first
    }
    
    private var recentMeals: [Meal] {
        guard let profileId = activeProfile?.id else { return [] }
        return allMeals.filter { $0.profileId == profileId }
    }
    
    private var currentMeal: Meal? {
        let fiveMinutesAgo = Date().addingTimeInterval(-5 * 60)
        return recentMeals.first { $0.timestamp >= fiveMinutesAgo }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    // Type Selection
                    typeSection
                    
                    // Amount Section
                    amountSection
                    
                    // Temperature Section
                    temperatureSection
                    
                    // Caffeine Section (if applicable)
                    if selectedType.isCaffeinated {
                        caffeineSection
                    }
                    
                    // Hydration Info
                    hydrationInfoSection
                    
                    // Date & Time
                    dateSection
                    
                    // Link to Meal
                    mealLinkSection
                    
                    // Notes
                    notesSection
                }
                .padding()
            }
            .navigationTitle("Log Beverage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBeverageEntry()
                    }
                    .fontWeight(.medium)
                    .disabled(selectedType == .other && customTypeName.isEmpty)
                }
            }
        }
        .onAppear {
            updateDefaults()
            linkedMeal = currentMeal
        }
    }
    
    // MARK: - Sections
    
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("Beverage Type")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: DesignSystem.Spacing.small) {
                ForEach(FluidEntry.FluidType.allCases, id: \.self) { type in
                    BeverageTypeButton(
                        type: type,
                        isSelected: selectedType == type,
                        action: {
                            selectedType = type
                            updateDefaults()
                        }
                    )
                }
            }
            
            if selectedType == .other {
                TextField("Custom beverage name", text: $customTypeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.top, DesignSystem.Spacing.xSmall)
            }
        }
    }
    
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                Text("Amount")
                    .font(.headline)
                
                Spacer()
                
                Text(formatAmount(amount))
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Gradients.accent)
            }
            
            Slider(value: $amount, in: 30...1000, step: 10)
                .tint(Color.blue)
            
            HStack {
                ForEach([125.0, 250.0, 350.0, 500.0], id: \.self) { preset in
                    Button(action: { amount = preset }) {
                        Text(formatAmount(preset))
                            .font(.caption)
                            .padding(.horizontal, DesignSystem.Spacing.small)
                            .padding(.vertical, DesignSystem.Spacing.xxSmall)
                            .background(amount == preset ? Color.blue : DesignSystem.Colors.cardBackground)
                            .foregroundColor(amount == preset ? .white : DesignSystem.Colors.primaryText)
                            .cornerRadius(DesignSystem.CornerRadius.small)
                    }
                }
            }
        }
    }
    
    private var temperatureSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("Temperature")
                .font(.headline)
            
            HStack(spacing: DesignSystem.Spacing.small) {
                ForEach(FluidEntry.FluidTemperature.allCases, id: \.self) { temp in
                    TemperatureButton(
                        temperature: temp,
                        isSelected: temperature == temp,
                        action: { temperature = temp }
                    )
                }
            }
        }
    }
    
    private var caffeineSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                Text("Caffeine Content")
                    .font(.headline)
                
                Spacer()
                
                Toggle("Custom", isOn: $isCustomCaffeine)
                    .labelsHidden()
                    .tint(.brown)
            }
            
            if isCustomCaffeine {
                HStack {
                    Text("\(Int(caffeineContent))mg")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(LinearGradient(
                            gradient: Gradient(colors: [Color.brown, Color.brown.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    Spacer()
                    
                    Stepper("", value: $caffeineContent, in: 0...500, step: 5)
                        .labelsHidden()
                }
            } else {
                Text("\(Int(caffeineContent))mg")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: [Color.brown, Color.brown.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
        }
    }
    
    private var hydrationInfoSection: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxSmall) {
                Text("Hydration Factor")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                Text(String(format: "%.0f%%", selectedType.hydrationFactor * 100))
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Gradients.accent)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xxSmall) {
                Text("Effective Hydration")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                Text(formatAmount(amount * selectedType.hydrationFactor))
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Gradients.accent)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("Date & Time")
                .font(.headline)
            
            DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .labelsHidden()
        }
    }
    
    private var mealLinkSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("Link to Meal")
                .font(.headline)
            
            if let meal = linkedMeal {
                HStack {
                    Image(systemName: meal.type.icon)
                        .foregroundStyle(DesignSystem.Gradients.primary)
                    
                    VStack(alignment: .leading) {
                        Text(meal.type.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(meal.timestamp, style: .time)
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    
                    Spacer()
                    
                    Button("Remove") {
                        linkedMeal = nil
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
                .padding(DesignSystem.Spacing.small)
                .background(DesignSystem.Colors.cardBackground)
                .cornerRadius(DesignSystem.CornerRadius.medium)
            } else {
                Text("No linked meal")
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("Notes (Optional)")
                .font(.headline)
            
            TextField("Add notes...", text: $notes, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateDefaults() {
        amount = selectedType.defaultServingSize
        if !isCustomCaffeine {
            caffeineContent = selectedType.typicalCaffeineContent ?? 0
        }
    }
    
    private func formatAmount(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.1fL", value / 1000)
        }
        return String(format: "%.0fml", value)
    }
    
    private func saveBeverageEntry() {
        do {
            guard let profile = activeProfile else {
                print("No active profile found")
                return
            }
            
            let entry = FluidEntry(
                profileId: profile.id,
                timestamp: selectedDate,
                type: selectedType,
                amount: amount,
                temperature: temperature,
                caffeineContent: selectedType.isCaffeinated ? caffeineContent : nil,
                notes: notes.isEmpty ? nil : notes,
                customTypeName: selectedType == .other ? customTypeName : nil,
                meal: linkedMeal
            )
            
            modelContext.insert(entry)
            try modelContext.save()
            
            // Sync to HealthKit if enabled
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isHealthKitEnabled) {
                Task {
                    await HealthKitService.shared.syncFluidEntry(entry)
                }
            }
            
            dismiss()
        } catch {
            print("Error saving beverage entry: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct BeverageTypeButton: View {
    let type: FluidEntry.FluidType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.xxSmall) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryText)
                
                Text(type.rawValue)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.secondaryText)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .padding(DesignSystem.Spacing.xSmall)
            .background(isSelected ? AnyShapeStyle(DesignSystem.Gradients.accent) : AnyShapeStyle(DesignSystem.Colors.cardBackground))
            .cornerRadius(DesignSystem.CornerRadius.medium)
        }
    }
}

struct TemperatureButton: View {
    let temperature: FluidEntry.FluidTemperature
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.xxSmall) {
                Image(systemName: temperature.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryText)
                
                Text(temperature.rawValue)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.small)
            .background(isSelected ? AnyShapeStyle(DesignSystem.Gradients.accent) : AnyShapeStyle(DesignSystem.Colors.cardBackground))
            .cornerRadius(DesignSystem.CornerRadius.medium)
        }
    }
}

// MARK: - Preview

#Preview {
    BeverageLoggingSheet()
        .modelContainer(for: [FluidEntry.self, Meal.self], inMemory: true)
}