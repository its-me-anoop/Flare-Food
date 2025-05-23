//
//  Food.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import Foundation
import SwiftData

/// Represents a food item that can be tracked in meals
@Model
final class Food {
    /// Unique identifier for the food item
    var id: UUID
    
    /// Name of the food item
    var name: String
    
    /// Category of the food (e.g., "Dairy", "Grains", "Fruits", etc.)
    var category: String
    
    /// Common allergens or triggers associated with this food
    var commonTriggers: [String]
    
    /// Date when this food was first added to the database
    var dateAdded: Date
    
    /// Number of times this food has been logged
    var usageCount: Int
    
    /// Whether this food is marked as a favorite for quick access
    var isFavorite: Bool
    
    /// Whether this is a custom user-created food
    var isCustom: Bool
    
    /// Optional notes about this food
    var notes: String?
    
    /// Initializes a new Food item
    /// - Parameters:
    ///   - name: The name of the food
    ///   - category: The category of the food
    ///   - commonTriggers: Array of common triggers (defaults to empty)
    ///   - notes: Optional notes about the food
    init(
        name: String,
        category: String,
        commonTriggers: [String] = [],
        isCustom: Bool = false,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.commonTriggers = commonTriggers
        self.dateAdded = Date()
        self.usageCount = 0
        self.isFavorite = false
        self.isCustom = isCustom
        self.notes = notes
    }
}

// MARK: - Food Categories
extension Food {
    /// Common food categories for organization
    enum Category: String, CaseIterable {
        case dairy = "Dairy"
        case grains = "Grains"
        case proteins = "Proteins"
        case vegetables = "Vegetables"
        case fruits = "Fruits"
        case fats = "Fats & Oils"
        case sweets = "Sweets & Desserts"
        case beverages = "Beverages"
        case spices = "Spices & Seasonings"
        case other = "Other"
    }
    
    /// Common food triggers/allergens
    enum CommonTrigger: String, CaseIterable {
        case gluten = "Gluten"
        case dairy = "Dairy"
        case soy = "Soy"
        case eggs = "Eggs"
        case nuts = "Nuts"
        case shellfish = "Shellfish"
        case nightshades = "Nightshades"
        case fodmap = "High FODMAP"
        case histamine = "High Histamine"
        case caffeine = "Caffeine"
        case alcohol = "Alcohol"
        case spicy = "Spicy"
        case acidic = "Acidic"
        case artificial = "Artificial Additives"
    }
}