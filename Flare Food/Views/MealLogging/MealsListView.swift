//
//  MealsListView.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import SwiftData

/// View displaying a list of all logged meals
struct MealsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Meal.timestamp, order: .reverse) private var meals: [Meal]
    
    @State private var showingMealLogger = false
    @State private var selectedMeal: Meal?
    @State private var searchText = ""
    @State private var selectedMealType: Meal.MealType?
    @State private var mealToEdit: Meal?
    @State private var showingDeleteAlert = false
    @State private var mealToDelete: Meal?
    
    /// Filtered meals based on search and meal type
    private var filteredMeals: [Meal] {
        meals.filter { meal in
            let matchesSearch = searchText.isEmpty || 
                meal.foodItems.contains { foodItem in
                    foodItem.food?.name.localizedCaseInsensitiveContains(searchText) ?? false
                }
            
            let matchesMealType = selectedMealType == nil || meal.type == selectedMealType
            
            return matchesSearch && matchesMealType
        }
    }
    
    /// Grouped meals by date
    private var groupedMeals: [(date: Date, meals: [Meal])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredMeals) { meal in
            calendar.startOfDay(for: meal.timestamp)
        }
        
        return grouped.map { (date: $0.key, meals: $0.value) }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if meals.isEmpty {
                    emptyStateView
                } else {
                    mealsList
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton(
                            icon: "plus",
                            gradient: DesignSystem.Gradients.primary
                        ) {
                            showingMealLogger = true
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Meals")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search foods")
            .sheet(isPresented: $showingMealLogger) {
                MealLoggingSheet()
            }
            .sheet(item: $selectedMeal) { meal in
                MealDetailView(meal: meal)
            }
            .sheet(item: $mealToEdit) { meal in
                MealEditSheet(meal: meal)
            }
            .alert("Delete Meal", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    mealToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let meal = mealToDelete {
                        deleteMeal(meal)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this meal? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Views
    
    /// Empty state view
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 80))
                .foregroundStyle(DesignSystem.Gradients.primary)
            
            Text("No Meals Logged Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start tracking your meals to discover food patterns")
                .font(.body)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                showingMealLogger = true
            } label: {
                Label("Log Your First Meal", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(GradientButtonStyle())
        }
        .padding()
    }
    
    /// Meals list view
    private var mealsList: some View {
        VStack(spacing: 0) {
            // Meal type filter
            mealTypeFilter
                .padding(.vertical, DesignSystem.Spacing.small)
            
            // Grouped meals in List
            List {
                ForEach(groupedMeals, id: \.date) { group in
                    Section {
                        ForEach(group.meals) { meal in
                            MealRowView(meal: meal) {
                                selectedMeal = meal
                            }
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    mealToDelete = meal
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    mealToEdit = meal
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                        }
                    } header: {
                        Text(dateHeader(for: group.date))
                            .font(.headline)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
    
    /// Meal type filter
    private var mealTypeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xSmall) {
                // All meals option
                FilterChip(
                    title: "All",
                    isSelected: selectedMealType == nil
                ) {
                    selectedMealType = nil
                }
                
                // Meal type filters
                ForEach(Meal.MealType.allCases, id: \.self) { type in
                    FilterChip(
                        title: type.rawValue,
                        icon: type.icon,
                        isSelected: selectedMealType == type
                    ) {
                        selectedMealType = type
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Format date for section header
    private func dateHeader(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    /// Delete a meal
    private func deleteMeal(_ meal: Meal) {
        modelContext.delete(meal)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete meal: \(error)")
        }
        mealToDelete = nil
    }
}

// MARK: - Supporting Views

/// Individual meal row
struct MealRowView: View {
    let meal: Meal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.small) {
                // Meal type icon
                Image(systemName: meal.type.icon)
                    .font(.title2)
                    .foregroundStyle(DesignSystem.Gradients.primary)
                    .frame(width: 50, height: 50)
                    .glassBackground(cornerRadius: DesignSystem.CornerRadius.small)
                
                // Meal info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(meal.type.rawValue)
                            .font(.headline)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        Spacer()
                        
                        Text(meal.timestamp, style: .time)
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    
                    if !meal.foodItems.isEmpty {
                        Text(meal.foodItems.compactMap { $0.food?.name }.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .lineLimit(2)
                    }
                    
                    if meal.photoData != nil {
                        Label("Photo", systemImage: "camera.fill")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.primaryGradientStart)
                    }
                }
                
                Spacer()
                
                // Chevron
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

/// Filter chip for meal types
struct FilterChip: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xxxSmall) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, DesignSystem.Spacing.xSmall)
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

// MARK: - Meal Detail View

/// Detailed view of a meal
struct MealDetailView: View {
    let meal: Meal
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                    // Photo if available
                    if let photoData = meal.photoData {
                        #if os(iOS)
                        if let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(DesignSystem.CornerRadius.medium)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                        #elseif os(macOS)
                        if let nsImage = NSImage(data: photoData) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(DesignSystem.CornerRadius.medium)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                        #endif
                    }
                    
                    // Meal info
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        // Type and time
                        HStack {
                            Label(meal.type.rawValue, systemImage: meal.type.icon)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(DesignSystem.Gradients.primary)
                            
                            Spacer()
                            
                            Text(meal.timestamp, style: .relative)
                                .font(.subheadline)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                        .padding()
                        .glassBackground()
                        
                        // Foods
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                            Text("Foods")
                                .font(.headline)
                            
                            ForEach(meal.foodItems) { foodItem in
                                HStack {
                                    Text(foodItem.food?.name ?? "Unknown")
                                        .font(.body)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(foodItem.portionSize * 100))% portion")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                }
                                .padding()
                                .glassBackground()
                            }
                        }
                        
                        // Notes
                        if let notes = meal.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxSmall) {
                                Text("Notes")
                                    .font(.headline)
                                
                                Text(notes)
                                    .font(.body)
                                    .padding()
                                    .glassBackground()
                            }
                        }
                        
                        // Location
                        if let location = meal.location, !location.isEmpty {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(DesignSystem.Gradients.accent)
                                Text(location)
                                    .font(.body)
                            }
                            .padding()
                            .glassBackground()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Meal Details")
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
                MealEditSheet(meal: meal)
            }
            .alert("Delete Meal", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteMeal()
                }
            } message: {
                Text("Are you sure you want to delete this meal? This action cannot be undone.")
            }
        }
    }
    
    /// Delete the meal
    private func deleteMeal() {
        modelContext.delete(meal)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete meal: \(error)")
        }
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    MealsListView()
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