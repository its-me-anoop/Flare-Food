//
//  MealLoggingViewModel.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import Foundation
import SwiftUI
import PhotosUI
import SwiftData

/// View model for meal logging functionality
@MainActor
final class MealLoggingViewModel: ObservableObject {
    /// The data service for database operations
    let dataService: DataServiceProtocol
    
    /// Selected meal type
    @Published var selectedMealType: Meal.MealType = .breakfast
    
    /// Selected foods for the meal
    @Published var selectedFoodItems: [FoodItemSelection] = []
    
    /// Photo item selection
    @Published var selectedPhotoItem: PhotosPickerItem?
    
    /// Photo data
    @Published var photoData: Data?
    
    /// Notes for the meal
    @Published var notes: String = ""
    
    /// Location of the meal
    @Published var location: String = ""
    
    /// Search query for foods
    @Published var foodSearchQuery: String = ""
    
    /// Search results
    @Published var searchResults: [Food] = []
    
    /// Recently used foods
    @Published var recentFoods: [Food] = []
    
    /// Favorite foods
    @Published var favoriteFoods: [Food] = []
    
    /// Loading state
    @Published var isLoading: Bool = false
    
    /// Error message
    @Published var errorMessage: String?
    
    /// Show success animation
    @Published var showSuccessAnimation: Bool = false
    
    /// Initializes the view model
    /// - Parameter dataService: The data service for database operations
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        Task {
            await loadInitialData()
        }
    }
    
    /// Loads initial data (recent and favorite foods)
    func loadInitialData() async {
        isLoading = true
        do {
            recentFoods = try dataService.fetchRecentlyUsedFoods(limit: 10)
            favoriteFoods = try dataService.fetchFavoriteFoods()
        } catch {
            errorMessage = "Failed to load foods: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    /// Searches for foods based on the query
    func searchFoods() async {
        guard !foodSearchQuery.isEmpty else {
            searchResults = []
            return
        }
        
        do {
            searchResults = try dataService.searchFoods(query: foodSearchQuery)
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }
    }
    
    /// Adds a food to the selected items
    /// - Parameter food: The food to add
    func addFood(_ food: Food) {
        let selection = FoodItemSelection(food: food)
        selectedFoodItems.append(selection)
        foodSearchQuery = ""
        searchResults = []
    }
    
    /// Removes a food item at the specified index
    /// - Parameter index: The index to remove
    func removeFoodItem(at index: Int) {
        guard index < selectedFoodItems.count else { return }
        selectedFoodItems.remove(at: index)
    }
    
    /// Updates the portion size for a food item
    /// - Parameters:
    ///   - index: The index of the food item
    ///   - portion: The new portion size
    func updatePortion(at index: Int, to portion: Double) {
        guard index < selectedFoodItems.count else { return }
        selectedFoodItems[index].portionSize = portion
    }
    
    /// Loads photo from the selected item
    func loadPhoto() async {
        guard let selectedPhotoItem else { return }
        
        do {
            if let data = try await selectedPhotoItem.loadTransferable(type: Data.self) {
                photoData = data
            }
        } catch {
            errorMessage = "Failed to load photo: \(error.localizedDescription)"
        }
    }
    
    /// Saves the meal
    func saveMeal() async {
        guard !selectedFoodItems.isEmpty else {
            errorMessage = "Please add at least one food item"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Create food items
            let foodItems = selectedFoodItems.map { selection in
                FoodItem(
                    food: selection.food,
                    portionSize: selection.portionSize,
                    quantity: selection.quantity
                )
            }
            
            // Create meal
            let meal = Meal(
                mealType: selectedMealType,
                foodItems: foodItems,
                photoData: photoData,
                notes: notes.isEmpty ? nil : notes,
                location: location.isEmpty ? nil : location
            )
            
            // Save to database
            try dataService.saveMeal(meal)
            
            // Show success animation
            showSuccessAnimation = true
            
            // Reset form after a delay
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            resetForm()
            
        } catch {
            errorMessage = "Failed to save meal: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Resets the form to initial state
    func resetForm() {
        selectedMealType = determineMealType()
        selectedFoodItems = []
        selectedPhotoItem = nil
        photoData = nil
        notes = ""
        location = ""
        foodSearchQuery = ""
        searchResults = []
        showSuccessAnimation = false
        
        Task {
            await loadInitialData()
        }
    }
    
    /// Determines the meal type based on current time
    /// - Returns: The suggested meal type
    private func determineMealType() -> Meal.MealType {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<11:
            return .breakfast
        case 11..<15:
            return .lunch
        case 15..<17:
            return .snack
        case 17..<22:
            return .dinner
        default:
            return .snack
        }
    }
}

/// Represents a food item selection with editable portion
struct FoodItemSelection: Identifiable {
    let id = UUID()
    let food: Food
    var portionSize: Double = 1.0
    var quantity: String?
}