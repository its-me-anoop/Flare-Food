//
//  FoodDatabaseSeeder.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import Foundation
import SwiftData

/// Seeds the database with common foods
struct FoodDatabaseSeeder {
    
    /// Seeds the database with initial food items if empty
    /// - Parameter dataService: The data service to use for saving
    static func seedIfNeeded(using dataService: DataServiceProtocol) async {
        do {
            let existingFoods = try dataService.fetchAllFoods()
            
            // Only seed if database is empty
            guard existingFoods.isEmpty else { return }
            
            // Create common foods
            let foods = createCommonFoods()
            
            // Save each food
            for food in foods {
                try dataService.saveFood(food)
            }
            
            print("Seeded database with \(foods.count) common foods")
            
        } catch {
            print("Failed to seed database: \(error)")
        }
    }
    
    /// Creates a list of common foods
    /// - Returns: Array of Food items
    private static func createCommonFoods() -> [Food] {
        var foods: [Food] = []
        
        // Dairy
        foods.append(contentsOf: [
            Food(name: "Milk", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Cheese", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Yogurt", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Butter", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy"]),
            Food(name: "Ice Cream", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"])
        ])
        
        // Grains
        foods.append(contentsOf: [
            Food(name: "Bread", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Rice", category: Food.Category.grains.rawValue, commonTriggers: []),
            Food(name: "Pasta", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Oats", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Quinoa", category: Food.Category.grains.rawValue, commonTriggers: [])
        ])
        
        // Proteins
        foods.append(contentsOf: [
            Food(name: "Chicken", category: Food.Category.proteins.rawValue, commonTriggers: []),
            Food(name: "Beef", category: Food.Category.proteins.rawValue, commonTriggers: []),
            Food(name: "Fish", category: Food.Category.proteins.rawValue, commonTriggers: []),
            Food(name: "Eggs", category: Food.Category.proteins.rawValue, commonTriggers: ["Eggs"]),
            Food(name: "Tofu", category: Food.Category.proteins.rawValue, commonTriggers: ["Soy"]),
            Food(name: "Beans", category: Food.Category.proteins.rawValue, commonTriggers: ["High FODMAP"])
        ])
        
        // Vegetables
        foods.append(contentsOf: [
            Food(name: "Broccoli", category: Food.Category.vegetables.rawValue, commonTriggers: ["High FODMAP"]),
            Food(name: "Carrots", category: Food.Category.vegetables.rawValue, commonTriggers: []),
            Food(name: "Tomatoes", category: Food.Category.vegetables.rawValue, commonTriggers: ["Nightshades", "Acidic"]),
            Food(name: "Spinach", category: Food.Category.vegetables.rawValue, commonTriggers: ["High Histamine"]),
            Food(name: "Onions", category: Food.Category.vegetables.rawValue, commonTriggers: ["High FODMAP"]),
            Food(name: "Garlic", category: Food.Category.vegetables.rawValue, commonTriggers: ["High FODMAP"]),
            Food(name: "Potatoes", category: Food.Category.vegetables.rawValue, commonTriggers: ["Nightshades"])
        ])
        
        // Fruits
        foods.append(contentsOf: [
            Food(name: "Apples", category: Food.Category.fruits.rawValue, commonTriggers: ["High FODMAP"]),
            Food(name: "Bananas", category: Food.Category.fruits.rawValue, commonTriggers: []),
            Food(name: "Oranges", category: Food.Category.fruits.rawValue, commonTriggers: ["Acidic"]),
            Food(name: "Strawberries", category: Food.Category.fruits.rawValue, commonTriggers: ["High Histamine"]),
            Food(name: "Grapes", category: Food.Category.fruits.rawValue, commonTriggers: []),
            Food(name: "Avocado", category: Food.Category.fruits.rawValue, commonTriggers: ["High Histamine"])
        ])
        
        // Fats & Oils
        foods.append(contentsOf: [
            Food(name: "Olive Oil", category: Food.Category.fats.rawValue, commonTriggers: []),
            Food(name: "Coconut Oil", category: Food.Category.fats.rawValue, commonTriggers: []),
            Food(name: "Nuts", category: Food.Category.fats.rawValue, commonTriggers: ["Nuts"]),
            Food(name: "Seeds", category: Food.Category.fats.rawValue, commonTriggers: [])
        ])
        
        // Beverages
        foods.append(contentsOf: [
            Food(name: "Coffee", category: Food.Category.beverages.rawValue, commonTriggers: ["Caffeine", "Acidic"]),
            Food(name: "Tea", category: Food.Category.beverages.rawValue, commonTriggers: ["Caffeine"]),
            Food(name: "Soda", category: Food.Category.beverages.rawValue, commonTriggers: ["Artificial Additives", "Caffeine"]),
            Food(name: "Juice", category: Food.Category.beverages.rawValue, commonTriggers: ["Acidic"]),
            Food(name: "Wine", category: Food.Category.beverages.rawValue, commonTriggers: ["Alcohol", "High Histamine"]),
            Food(name: "Beer", category: Food.Category.beverages.rawValue, commonTriggers: ["Alcohol", "Gluten"])
        ])
        
        // Sweets
        foods.append(contentsOf: [
            Food(name: "Chocolate", category: Food.Category.sweets.rawValue, commonTriggers: ["Caffeine"]),
            Food(name: "Candy", category: Food.Category.sweets.rawValue, commonTriggers: ["Artificial Additives"]),
            Food(name: "Cookies", category: Food.Category.sweets.rawValue, commonTriggers: ["Gluten", "Dairy"])
        ])
        
        // Spices
        foods.append(contentsOf: [
            Food(name: "Black Pepper", category: Food.Category.spices.rawValue, commonTriggers: ["Spicy"]),
            Food(name: "Chili Powder", category: Food.Category.spices.rawValue, commonTriggers: ["Spicy"]),
            Food(name: "Cinnamon", category: Food.Category.spices.rawValue, commonTriggers: []),
            Food(name: "Ginger", category: Food.Category.spices.rawValue, commonTriggers: [])
        ])
        
        return foods
    }
}