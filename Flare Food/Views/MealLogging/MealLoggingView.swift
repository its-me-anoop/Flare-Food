//
//  MealLoggingView.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import PhotosUI
import SwiftData

/// Main view for logging meals
struct MealLoggingView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        MealLoggingContentView(modelContext: modelContext)
    }
}

/// Internal view that handles the view model
private struct MealLoggingContentView: View {
    let modelContext: ModelContext
    @StateObject private var viewModel: MealLoggingViewModel
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        let dataService = DataService(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: MealLoggingViewModel(dataService: dataService))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                    VStack(spacing: DesignSystem.Spacing.large) {
                        // Meal Type Selection
                        mealTypeSection
                        
                        // Photo Section
                        photoSection
                        
                        // Food Selection
                        foodSelectionSection
                        
                        // Selected Foods List
                        if !viewModel.selectedFoodItems.isEmpty {
                            selectedFoodsSection
                        }
                        
                        // Additional Info
                        additionalInfoSection
                        
                        // Save Button
                        saveButton
                    }
                    .padding()
                }
            .navigationTitle("Log Meal")
            .navigationBarTitleDisplayMode(.large)
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
    
    /// Meal type selection section
    private var mealTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meal Type")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Meal.MealType.allCases, id: \.self) { type in
                        MealTypeButton(
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
    
    /// Photo section
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meal Photo")
                .font(.headline)
            
            PhotosPicker(
                selection: $viewModel.selectedPhotoItem,
                matching: .images
            ) {
                if let photoData = viewModel.photoData {
                    #if os(iOS)
                    if let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    #elseif os(macOS)
                    if let nsImage = NSImage(data: photoData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    #endif
                } else {
                    VStack(spacing: DesignSystem.Spacing.small) {
                        Image(systemName: "camera.fill")
                            .font(.largeTitle)
                            .foregroundStyle(DesignSystem.Gradients.primary)
                        Text("Add Photo")
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .fontWeight(.medium)
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .glassBackground()
                }
            }
            .onChange(of: viewModel.selectedPhotoItem) { _, _ in
                Task {
                    await viewModel.loadPhoto()
                }
            }
        }
    }
    
    /// Food selection section
    private var foodSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Foods")
                .font(.headline)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search foods...", text: $viewModel.foodSearchQuery)
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
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Quick Access Foods
            if viewModel.foodSearchQuery.isEmpty {
                if !viewModel.recentFoods.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Foods")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.recentFoods) { food in
                                    FoodChip(food: food) {
                                        viewModel.addFood(food)
                                    }
                                }
                            }
                        }
                    }
                }
                
                if !viewModel.favoriteFoods.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Favorites")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.favoriteFoods) { food in
                                    FoodChip(food: food) {
                                        viewModel.addFood(food)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Search Results
            if !viewModel.searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.searchResults) { food in
                        Button {
                            viewModel.addFood(food)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(food.name)
                                        .foregroundColor(.primary)
                                    Text(food.category)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.orange)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
    }
    
    /// Selected foods section
    private var selectedFoodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected Foods")
                .font(.headline)
            
            ForEach(viewModel.selectedFoodItems.indices, id: \.self) { index in
                SelectedFoodRow(
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
    
    /// Additional info section
    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Information")
                .font(.headline)
            
            VStack(spacing: 16) {
                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Label("Notes", systemImage: "note.text")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Any notes about this meal?", text: $viewModel.notes, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                // Location
                VStack(alignment: .leading, spacing: 8) {
                    Label("Location", systemImage: "location")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Where did you eat?", text: $viewModel.location)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
    }
    
    /// Save button
    private var saveButton: some View {
        Button {
            Task {
                await viewModel.saveMeal()
            }
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Save Meal")
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(GradientButtonStyle(
            gradient: viewModel.selectedFoodItems.isEmpty ? 
                LinearGradient(colors: [Color.gray], startPoint: .top, endPoint: .bottom) : 
                DesignSystem.Gradients.primary
        ))
        .disabled(viewModel.selectedFoodItems.isEmpty || viewModel.isLoading)
    }
}

// MARK: - Supporting Views

/// Meal type selection button
struct MealTypeButton: View {
    let type: Meal.MealType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.xxSmall) {
                Image(systemName: type.icon)
                    .font(.title2)
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(width: 80, height: 80)
            .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryText)
            .background(
                isSelected ? 
                DesignSystem.Gradients.primary : 
                LinearGradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.6)], startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .shadow(color: isSelected ? type.color.opacity(0.3) : .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

/// Food chip for quick selection
struct FoodChip: View {
    let food: Food
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(food.name)
                    .font(.caption)
                Image(systemName: "plus.circle.fill")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.2))
            .foregroundColor(.orange)
            .cornerRadius(20)
        }
    }
}

/// Selected food row with portion control
struct SelectedFoodRow: View {
    let selection: FoodItemSelection
    let onPortionChange: (Double) -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            HStack {
                VStack(alignment: .leading) {
                    Text(selection.food.name)
                        .font(.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    Text(selection.food.category)
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DesignSystem.Gradients.secondary)
                        .font(.title3)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Portion Size")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    Spacer()
                    Text("\(Int(selection.portionSize * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(DesignSystem.Gradients.primary)
                }
                
                Slider(value: .init(
                    get: { selection.portionSize },
                    set: onPortionChange
                ), in: 0.1...2.0)
                .tint(DesignSystem.Colors.primaryGradientStart)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .glassBackground()
    }
}

/// Success animation overlay
struct SuccessAnimationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .blur(radius: 3)
            
            VStack(spacing: DesignSystem.Spacing.medium) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Gradients.success)
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)
                        .offset(y: -10)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(DesignSystem.Gradients.success)
                        .rotationEffect(.degrees(rotation))
                }
                
                GradientText("Meal Saved!", gradient: DesignSystem.Gradients.success, font: .title.bold())
                
                Text("Great job tracking your meal!")
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .padding(DesignSystem.Spacing.xLarge)
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.9))
            .cornerRadius(DesignSystem.CornerRadius.large)
            .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 10)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                rotation = 360
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0.0
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MealLoggingView()
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