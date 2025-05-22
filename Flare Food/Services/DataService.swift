//
//  DataService.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import Foundation
import SwiftData
import SwiftUI

/// Protocol defining data service operations
protocol DataServiceProtocol {
    // Meal operations
    func saveMeal(_ meal: Meal) throws
    func fetchMeals(from startDate: Date, to endDate: Date) throws -> [Meal]
    func fetchRecentMeals(limit: Int) throws -> [Meal]
    func deleteMeal(_ meal: Meal) throws
    
    // Food operations
    func saveFood(_ food: Food) throws
    func fetchAllFoods() throws -> [Food]
    func fetchFavoriteFoods() throws -> [Food]
    func fetchRecentlyUsedFoods(limit: Int) throws -> [Food]
    func searchFoods(query: String) throws -> [Food]
    func incrementFoodUsage(_ food: Food) throws
    
    // Symptom operations
    func saveSymptom(_ symptom: Symptom) throws
    func fetchSymptoms(from startDate: Date, to endDate: Date) throws -> [Symptom]
    func fetchRecentSymptoms(limit: Int) throws -> [Symptom]
    func deleteSymptom(_ symptom: Symptom) throws
    
    // Correlation operations
    func saveCorrelation(_ correlation: Correlation) throws
    func fetchCorrelations(for food: Food) throws -> [Correlation]
    func fetchSignificantCorrelations() throws -> [Correlation]
    
    // User profile operations
    func fetchUserProfile() throws -> UserProfile
    func saveUserProfile(_ profile: UserProfile) throws
}

/// Main data service for managing app data
final class DataService: DataServiceProtocol {
    /// The model context for SwiftData operations
    private let modelContext: ModelContext
    
    /// Initializes the data service with a model context
    /// - Parameter modelContext: The SwiftData model context
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Meal Operations
    
    /// Saves a meal to the database
    /// - Parameter meal: The meal to save
    func saveMeal(_ meal: Meal) throws {
        modelContext.insert(meal)
        
        // Update food usage counts
        for foodItem in meal.foodItems {
            if let food = foodItem.food {
                try incrementFoodUsage(food)
            }
        }
        
        // Update user profile stats
        if let profile = try? fetchUserProfile() {
            profile.totalMealsLogged += 1
            profile.updateStreak(on: meal.timestamp)
        }
        
        try modelContext.save()
    }
    
    /// Fetches meals within a date range
    /// - Parameters:
    ///   - startDate: Start date of the range
    ///   - endDate: End date of the range
    /// - Returns: Array of meals within the date range
    func fetchMeals(from startDate: Date, to endDate: Date) throws -> [Meal] {
        let descriptor = FetchDescriptor<Meal>(
            predicate: #Predicate { meal in
                meal.timestamp >= startDate && meal.timestamp <= endDate
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetches the most recent meals
    /// - Parameter limit: Maximum number of meals to fetch
    /// - Returns: Array of recent meals
    func fetchRecentMeals(limit: Int) throws -> [Meal] {
        var descriptor = FetchDescriptor<Meal>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }
    
    /// Deletes a meal from the database
    /// - Parameter meal: The meal to delete
    func deleteMeal(_ meal: Meal) throws {
        modelContext.delete(meal)
        try modelContext.save()
    }
    
    // MARK: - Food Operations
    
    /// Saves a food item to the database
    /// - Parameter food: The food to save
    func saveFood(_ food: Food) throws {
        modelContext.insert(food)
        try modelContext.save()
    }
    
    /// Fetches all food items
    /// - Returns: Array of all foods
    func fetchAllFoods() throws -> [Food] {
        let descriptor = FetchDescriptor<Food>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetches favorite food items
    /// - Returns: Array of favorite foods
    func fetchFavoriteFoods() throws -> [Food] {
        let descriptor = FetchDescriptor<Food>(
            predicate: #Predicate { food in
                food.isFavorite == true
            },
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetches recently used foods
    /// - Parameter limit: Maximum number of foods to fetch
    /// - Returns: Array of recently used foods
    func fetchRecentlyUsedFoods(limit: Int) throws -> [Food] {
        var descriptor = FetchDescriptor<Food>(
            predicate: #Predicate { food in
                food.usageCount > 0
            },
            sortBy: [SortDescriptor(\.usageCount, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }
    
    /// Searches for foods by name
    /// - Parameter query: Search query
    /// - Returns: Array of matching foods
    func searchFoods(query: String) throws -> [Food] {
        let lowercaseQuery = query.lowercased()
        let descriptor = FetchDescriptor<Food>(
            predicate: #Predicate { food in
                food.name.localizedStandardContains(lowercaseQuery)
            },
            sortBy: [SortDescriptor(\.usageCount, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Increments the usage count for a food
    /// - Parameter food: The food to update
    func incrementFoodUsage(_ food: Food) throws {
        food.usageCount += 1
        try modelContext.save()
    }
    
    // MARK: - Symptom Operations
    
    /// Saves a symptom to the database
    /// - Parameter symptom: The symptom to save
    func saveSymptom(_ symptom: Symptom) throws {
        modelContext.insert(symptom)
        
        // Update user profile stats
        if let profile = try? fetchUserProfile() {
            profile.totalSymptomsLogged += 1
            profile.updateStreak(on: symptom.timestamp)
        }
        
        try modelContext.save()
    }
    
    /// Fetches symptoms within a date range
    /// - Parameters:
    ///   - startDate: Start date of the range
    ///   - endDate: End date of the range
    /// - Returns: Array of symptoms within the date range
    func fetchSymptoms(from startDate: Date, to endDate: Date) throws -> [Symptom] {
        let descriptor = FetchDescriptor<Symptom>(
            predicate: #Predicate { symptom in
                symptom.timestamp >= startDate && symptom.timestamp <= endDate
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetches the most recent symptoms
    /// - Parameter limit: Maximum number of symptoms to fetch
    /// - Returns: Array of recent symptoms
    func fetchRecentSymptoms(limit: Int) throws -> [Symptom] {
        var descriptor = FetchDescriptor<Symptom>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }
    
    /// Deletes a symptom from the database
    /// - Parameter symptom: The symptom to delete
    func deleteSymptom(_ symptom: Symptom) throws {
        modelContext.delete(symptom)
        try modelContext.save()
    }
    
    // MARK: - Correlation Operations
    
    /// Saves a correlation to the database
    /// - Parameter correlation: The correlation to save
    func saveCorrelation(_ correlation: Correlation) throws {
        modelContext.insert(correlation)
        try modelContext.save()
    }
    
    /// Fetches correlations for a specific food
    /// - Parameter food: The food to fetch correlations for
    /// - Returns: Array of correlations for the food
    func fetchCorrelations(for food: Food) throws -> [Correlation] {
        let foodId = food.id
        let descriptor = FetchDescriptor<Correlation>(
            predicate: #Predicate { correlation in
                correlation.food?.id == foodId
            },
            sortBy: [SortDescriptor(\.correlationCoefficient, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetches all statistically significant correlations
    /// - Returns: Array of significant correlations
    func fetchSignificantCorrelations() throws -> [Correlation] {
        let descriptor = FetchDescriptor<Correlation>(
            predicate: #Predicate { correlation in
                correlation.pValue < 0.05
            },
            sortBy: [SortDescriptor(\.correlationCoefficient, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - User Profile Operations
    
    /// Fetches the user profile, creating one if it doesn't exist
    /// - Returns: The user profile
    func fetchUserProfile() throws -> UserProfile {
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(descriptor)
        
        if let profile = profiles.first {
            return profile
        } else {
            // Create default profile if none exists
            let newProfile = UserProfile()
            modelContext.insert(newProfile)
            try modelContext.save()
            return newProfile
        }
    }
    
    /// Saves the user profile
    /// - Parameter profile: The profile to save
    func saveUserProfile(_ profile: UserProfile) throws {
        try modelContext.save()
    }
}