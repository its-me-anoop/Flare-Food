//
//  MealEditSheet.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

/// Sheet for editing an existing meal
struct MealEditSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let meal: Meal
    
    @State private var selectedMealType: Meal.MealType
    @State private var selectedTimestamp: Date
    @State private var selectedFoodItems: [FoodItem]
    @State private var notes: String
    @State private var location: String
    @State private var photoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    init(meal: Meal) {
        self.meal = meal
        self._selectedMealType = State(initialValue: meal.type)
        self._selectedTimestamp = State(initialValue: meal.timestamp)
        self._selectedFoodItems = State(initialValue: meal.foodItems)
        self._notes = State(initialValue: meal.notes ?? "")
        self._location = State(initialValue: meal.location ?? "")
        self._photoData = State(initialValue: meal.photoData)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    // Meal type selection
                    mealTypeSection
                    
                    // Date and time selection
                    dateTimeSection
                    
                    // Food items (read-only for now)
                    foodItemsSection
                    
                    // Optional fields
                    optionalFieldsSection
                }
                .padding()
            }
            .navigationTitle("Edit Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMeal()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    /// Meal type selection
    private var mealTypeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Meal Type", systemImage: "fork.knife")
                .font(.headline)
                .foregroundStyle(DesignSystem.Gradients.primary)
            
            Picker("Meal Type", selection: $selectedMealType) {
                ForEach(Meal.MealType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
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
    
    /// Food items display
    private var foodItemsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("Food Items", systemImage: "list.bullet")
                .font(.headline)
                .foregroundStyle(DesignSystem.Gradients.secondary)
            
            ForEach(selectedFoodItems) { foodItem in
                HStack {
                    VStack(alignment: .leading) {
                        Text(foodItem.food?.name ?? "Unknown Food")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack {
                            if let quantity = foodItem.quantity {
                                Text("\(quantity) × \(foodItem.portionSize, specifier: "%.1f")")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            } else {
                                Text("Portion: \(foodItem.portionSize, specifier: "%.1f")")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
            }
            
            Text("Note: Food items cannot be edited. Delete and create a new meal to change foods.")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .italic()
        }
    }
    
    /// Optional fields section
    private var optionalFieldsSection: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            // Photo picker
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images
            ) {
                HStack {
                    Image(systemName: "camera.fill")
                        .foregroundStyle(DesignSystem.Gradients.primary)
                    Text(photoData != nil ? "Change Photo" : "Add Photo")
                    Spacer()
                    if photoData != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
            }
            .onChange(of: selectedPhotoItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        photoData = data
                    }
                }
            }
            
            // Notes
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                Label("Notes", systemImage: "note.text")
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                TextField("Notes", text: $notes, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(2...4)
            }
            
            // Location
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                Label("Location", systemImage: "location")
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                TextField("Location", text: $location)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
    
    // MARK: - Methods
    
    /// Save the edited meal
    private func saveMeal() {
        // Update meal properties
        meal.mealType = selectedMealType.rawValue
        meal.timestamp = selectedTimestamp
        meal.notes = notes.isEmpty ? nil : notes
        meal.location = location.isEmpty ? nil : location
        meal.photoData = photoData
        
        // Save context is automatic with SwiftData
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(for: Meal.self, Food.self, FoodItem.self)
    let profileId = UUID()
    let meal = Meal(profileId: profileId, mealType: .lunch)
    container.mainContext.insert(meal)
    
    return MealEditSheet(meal: meal)
        .modelContainer(container)
}