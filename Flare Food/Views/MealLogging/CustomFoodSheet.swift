//
//  CustomFoodSheet.swift
//  Flare Food
//
//  Created by Anoop Jose on 23/05/2025.
//

import SwiftUI
import SwiftData

/// Sheet for creating custom food items
struct CustomFoodSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var foodName = ""
    @State private var selectedCategory: Food.Category = .other
    @State private var selectedTriggers: Set<Food.CommonTrigger> = []
    @State private var notes = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var onFoodCreated: ((Food) -> Void)?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    // Food Name
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                        Label("Food Name", systemImage: "fork.knife")
                            .font(.headline)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        TextField("Enter food name", text: $foodName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                    }
                    
                    // Category Selection
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                        Label("Category", systemImage: "square.grid.2x2")
                            .font(.headline)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(Food.Category.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .glassBackground()
                    }
                    
                    // Common Triggers
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                        Label("Common Triggers", systemImage: "exclamationmark.triangle")
                            .font(.headline)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        Text("Select all that may apply")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: DesignSystem.Spacing.small) {
                            ForEach(Food.CommonTrigger.allCases, id: \.self) { trigger in
                                TriggerChip(
                                    trigger: trigger,
                                    isSelected: selectedTriggers.contains(trigger)
                                ) {
                                    if selectedTriggers.contains(trigger) {
                                        selectedTriggers.remove(trigger)
                                    } else {
                                        selectedTriggers.insert(trigger)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Notes
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                        Label("Notes (Optional)", systemImage: "note.text")
                            .font(.headline)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                            .padding(8)
                            .glassBackground()
                            .cornerRadius(DesignSystem.CornerRadius.small)
                    }
                    
                    // Info Card
                    HStack(spacing: DesignSystem.Spacing.small) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(DesignSystem.Gradients.accent)
                        
                        Text("Custom foods will be saved for future use and appear in your food list with a special badge.")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    .padding()
                    .glassBackground()
                }
                .padding()
            }
            .navigationTitle("Add Custom Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveFood()
                    }
                    .fontWeight(.semibold)
                    .disabled(foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    /// Save the custom food
    private func saveFood() {
        let trimmedName = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            alertMessage = "Please enter a food name"
            showingAlert = true
            return
        }
        
        // Create the custom food
        let food = Food(
            name: trimmedName,
            category: selectedCategory.rawValue,
            commonTriggers: selectedTriggers.map { $0.rawValue },
            isCustom: true,
            notes: notes.isEmpty ? nil : notes
        )
        
        // Save to database
        modelContext.insert(food)
        
        do {
            try modelContext.save()
            onFoodCreated?(food)
            dismiss()
        } catch {
            alertMessage = "Failed to save food: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

/// Trigger selection chip
struct TriggerChip: View {
    let trigger: Food.CommonTrigger
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xxSmall) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                }
                Text(trigger.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ?
                AnyShapeStyle(DesignSystem.Gradients.primary) :
                AnyShapeStyle(Color.gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryText)
            .cornerRadius(DesignSystem.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .stroke(
                        isSelected ? Color.clear : Color.gray.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    CustomFoodSheet()
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