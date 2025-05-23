//
//  Meal.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import Foundation
import SwiftData
import SwiftUI

/// Represents a meal entry in the user's food log
@Model
final class Meal {
    /// Unique identifier for the meal
    var id: UUID
    
    /// Profile ID this meal belongs to
    var profileId: UUID
    
    /// Timestamp when the meal was consumed
    var timestamp: Date
    
    /// Type of meal (breakfast, lunch, dinner, snack)
    var mealType: String
    
    /// Foods included in this meal with their portions
    var foodItems: [FoodItem]
    
    /// Optional photo data for the meal
    @Attribute(.externalStorage)
    var photoData: Data?
    
    /// Optional notes about the meal
    var notes: String?
    
    /// Location where the meal was consumed (home, restaurant, etc.)
    var location: String?
    
    /// Initializes a new Meal entry
    /// - Parameters:
    ///   - profileId: The profile ID this meal belongs to
    ///   - mealType: The type of meal
    ///   - timestamp: When the meal was consumed
    ///   - foodItems: Array of food items with portions
    ///   - photoData: Optional photo data
    ///   - notes: Optional notes
    ///   - location: Optional location
    init(
        profileId: UUID,
        mealType: MealType,
        timestamp: Date = Date(),
        foodItems: [FoodItem] = [],
        photoData: Data? = nil,
        notes: String? = nil,
        location: String? = nil
    ) {
        self.id = UUID()
        self.profileId = profileId
        self.timestamp = timestamp
        self.mealType = mealType.rawValue
        self.foodItems = foodItems
        self.photoData = photoData
        self.notes = notes
        self.location = location
    }
}

/// Represents a food item within a meal with portion information
@Model
final class FoodItem {
    /// Unique identifier
    var id: UUID
    
    /// Reference to the food
    var food: Food?
    
    /// Portion size (0.0 to 1.0, where 1.0 is a full serving)
    var portionSize: Double
    
    /// Optional specific quantity (e.g., "2 slices", "1 cup")
    var quantity: String?
    
    /// Initializes a new FoodItem
    /// - Parameters:
    ///   - food: The food reference
    ///   - portionSize: The portion size (0.0 to 1.0)
    ///   - quantity: Optional specific quantity description
    init(food: Food, portionSize: Double = 1.0, quantity: String? = nil) {
        self.id = UUID()
        self.food = food
        self.portionSize = max(0.0, min(1.0, portionSize))
        self.quantity = quantity
    }
}

// MARK: - Meal Types
extension Meal {
    /// Types of meals
    enum MealType: String, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
        case other = "Other"
        
        /// Icon for each meal type
        var icon: String {
            switch self {
            case .breakfast: return "sun.max.fill"
            case .lunch: return "sun.min.fill"
            case .dinner: return "moon.fill"
            case .snack: return "leaf.fill"
            case .other: return "fork.knife"
            }
        }
        
        /// Color associated with each meal type
        var color: Color {
            switch self {
            case .breakfast: return .orange
            case .lunch: return .blue
            case .dinner: return .purple
            case .snack: return .green
            case .other: return .gray
            }
        }
    }
    
    /// Computed property to get MealType enum from stored string
    var type: MealType {
        MealType(rawValue: mealType) ?? .other
    }
}