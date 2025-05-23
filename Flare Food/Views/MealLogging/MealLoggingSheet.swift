//
//  MealLoggingSheet.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import PhotosUI
import SwiftData

/// Bottom sheet for logging meals
struct MealLoggingSheet: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentDetent: PresentationDetent = .medium
    
    var body: some View {
        MealLoggingSheetContent(modelContext: modelContext)
            .presentationDetents([.medium, .large], selection: $currentDetent)
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(DesignSystem.CornerRadius.large)
    }
}

/// Internal content view that handles the view model
private struct MealLoggingSheetContent: View {
    let modelContext: ModelContext
    @StateObject private var viewModel: MealLoggingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingCustomFoodSheet = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        let dataService = DataService(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: MealLoggingViewModel(dataService: dataService))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    // Quick meal type selection
                    quickMealTypeSection
                    
                    // Date and time selection
                    dateTimeSection
                    
                    // Recent foods for quick add
                    if !viewModel.recentFoods.isEmpty {
                        recentFoodsSection
                    }
                    
                    // Search and add foods
                    foodSearchSection
                    
                    // Selected foods with portions
                    if !viewModel.selectedFoodItems.isEmpty {
                        selectedFoodsSection
                    }
                    
                    // Optional fields (expandable)
                    optionalFieldsSection
                }
                .padding()
            }
            .navigationTitle("Log Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.saveMeal()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(viewModel.selectedFoodItems.isEmpty || viewModel.isLoading)
                }
            }
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
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                dismiss()
                            }
                        }
                }
            }
            .sheet(isPresented: $showingCustomFoodSheet) {
                CustomFoodSheet { newFood in
                    // Add the newly created food to the selection
                    viewModel.addFood(newFood)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    /// Date and time selection
    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Date & Time")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .padding(.horizontal, DesignSystem.Spacing.xxxSmall)
            
            DatePicker(
                "",
                selection: $viewModel.selectedTimestamp,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
        }
    }
    
    /// Quick meal type selection
    private var quickMealTypeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Meal Type")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .padding(.horizontal, DesignSystem.Spacing.xxxSmall)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.xSmall) {
                    ForEach(Meal.MealType.allCases, id: \.self) { type in
                        CompactMealTypeButton(
                            type: type,
                            isSelected: viewModel.selectedMealType == type
                        ) {
                            viewModel.selectedMealType = type
                        }
                    }
                }
            }
        }
    }
    
    /// Recent foods section
    private var recentFoodsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            HStack {
                Text("Recent Foods")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                Spacer()
                
                Button {
                    showingCustomFoodSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption)
                        Text("Custom")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(DesignSystem.Colors.primaryGradientStart)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xxxSmall)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.xxSmall) {
                    ForEach(viewModel.recentFoods.prefix(10)) { food in
                        QuickAddFoodChip(food: food) {
                            viewModel.addFood(food)
                        }
                    }
                }
            }
        }
    }
    
    /// Food search section
    private var foodSearchSection: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search or add food...", text: $viewModel.foodSearchQuery)
                    .textFieldStyle(.plain)
                    .onChange(of: viewModel.foodSearchQuery) { _, _ in
                        Task {
                            await viewModel.searchFoods()
                        }
                    }
                
                if !viewModel.foodSearchQuery.isEmpty {
                    Button {
                        viewModel.foodSearchQuery = ""
                        viewModel.searchResults = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
            
            // Search results
            if !viewModel.searchResults.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxSmall) {
                    ForEach(viewModel.searchResults.prefix(5)) { food in
                        CompactFoodRow(food: food) {
                            viewModel.addFood(food)
                        }
                    }
                }
            } else if !viewModel.foodSearchQuery.isEmpty {
                // Add custom food option when no results found
                Button {
                    showingCustomFoodSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(DesignSystem.Gradients.primary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Add \"\(viewModel.foodSearchQuery)\" as custom food")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Create a new food item")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    .padding()
                    .glassBackground()
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    /// Selected foods section
    private var selectedFoodsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Selected Foods")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .padding(.horizontal, DesignSystem.Spacing.xxxSmall)
            
            ForEach(viewModel.selectedFoodItems.indices, id: \.self) { index in
                CompactSelectedFoodRow(
                    selection: viewModel.selectedFoodItems[index],
                    onPortionChange: { portion in
                        viewModel.updatePortion(at: index, to: portion)
                    },
                    onRemove: {
                        viewModel.removeFoodItem(at: index)
                    }
                )
            }
        }
    }
    
    /// Optional fields section (collapsible)
    private var optionalFieldsSection: some View {
        DisclosureGroup("Add Details (Optional)") {
            VStack(spacing: DesignSystem.Spacing.medium) {
                // Photo
                PhotosPicker(
                    selection: $viewModel.selectedPhotoItem,
                    matching: .images
                ) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .foregroundStyle(DesignSystem.Gradients.primary)
                        Text(viewModel.photoData != nil ? "Change Photo" : "Add Photo")
                        Spacer()
                        if viewModel.photoData != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
                }
                .onChange(of: viewModel.selectedPhotoItem) { _, _ in
                    Task {
                        await viewModel.loadPhoto()
                    }
                }
                
                // Notes
                TextField("Notes", text: $viewModel.notes, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(2...4)
                
                // Location
                TextField("Location", text: $viewModel.location)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.top, DesignSystem.Spacing.xSmall)
        }
        .tint(DesignSystem.Colors.primaryGradientStart)
    }
}

// MARK: - Compact Supporting Views

/// Compact meal type button for bottom sheet
struct CompactMealTypeButton: View {
    let type: Meal.MealType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xxxSmall) {
                Image(systemName: type.icon)
                    .font(.caption)
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xxSmall)
            .background(
                isSelected ?
                DesignSystem.Gradients.primary :
                LinearGradient(colors: [Color.gray.opacity(0.2)], startPoint: .top, endPoint: .bottom)
            )
            .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryText)
            .cornerRadius(DesignSystem.CornerRadius.small)
        }
    }
}

/// Quick add food chip
struct QuickAddFoodChip: View {
    let food: Food
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xxxSmall) {
                Text(food.name)
                    .font(.caption)
                
                if food.isCustom {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.yellow)
                }
                
                Image(systemName: "plus.circle")
                    .font(.caption2)
            }
            .padding(.horizontal, DesignSystem.Spacing.xSmall)
            .padding(.vertical, DesignSystem.Spacing.xxxSmall)
            .background(DesignSystem.Colors.primaryGradientStart.opacity(0.1))
            .foregroundColor(DesignSystem.Colors.primaryGradientStart)
            .cornerRadius(DesignSystem.CornerRadius.small)
        }
    }
}

/// Compact food row for search results
struct CompactFoodRow: View {
    let food: Food
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(food.name)
                            .font(.subheadline)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        if food.isCustom {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                        }
                    }
                    Text(food.category)
                        .font(.caption2)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(DesignSystem.Gradients.primary)
            }
            .padding(.vertical, DesignSystem.Spacing.xxSmall)
            .padding(.horizontal, DesignSystem.Spacing.xSmall)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Compact selected food row
struct CompactSelectedFoodRow: View {
    let selection: FoodItemSelection
    let onPortionChange: (Double) -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            // Food name
            Text(selection.food.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Spacer()
            
            // Portion control
            HStack(spacing: DesignSystem.Spacing.xxxSmall) {
                Button {
                    let newPortion = max(0.1, selection.portionSize - 0.25)
                    onPortionChange(newPortion)
                } label: {
                    Image(systemName: "minus.circle")
                        .foregroundStyle(DesignSystem.Gradients.primary)
                }
                
                Text("\(Int(selection.portionSize * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .frame(minWidth: 40)
                
                Button {
                    let newPortion = min(2.0, selection.portionSize + 0.25)
                    onPortionChange(newPortion)
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(DesignSystem.Gradients.primary)
                }
            }
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red.opacity(0.8))
                    .font(.caption)
            }
        }
        .padding()
        .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
    }
}

// MARK: - Preview

#Preview {
    Text("Tap to show sheet")
        .sheet(isPresented: .constant(true)) {
            MealLoggingSheet()
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
}