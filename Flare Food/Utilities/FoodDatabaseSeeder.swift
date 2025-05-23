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
            Food(name: "Whole Milk", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Skim Milk", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Almond Milk", category: Food.Category.dairy.rawValue, commonTriggers: ["Nuts"]),
            Food(name: "Soy Milk", category: Food.Category.dairy.rawValue, commonTriggers: ["Soy"]),
            Food(name: "Oat Milk", category: Food.Category.dairy.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Cheese", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Cheddar Cheese", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Mozzarella Cheese", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Parmesan Cheese", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose", "High Histamine"]),
            Food(name: "Blue Cheese", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose", "High Histamine"]),
            Food(name: "Yogurt", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Greek Yogurt", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Kefir", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Butter", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy"]),
            Food(name: "Cream", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Sour Cream", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Cream Cheese", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Cottage Cheese", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"]),
            Food(name: "Ice Cream", category: Food.Category.dairy.rawValue, commonTriggers: ["Dairy", "Lactose"])
        ])
        
        // Grains
        foods.append(contentsOf: [
            Food(name: "Bread", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "White Bread", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Whole Wheat Bread", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Sourdough Bread", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Rice", category: Food.Category.grains.rawValue, commonTriggers: []),
            Food(name: "White Rice", category: Food.Category.grains.rawValue, commonTriggers: []),
            Food(name: "Brown Rice", category: Food.Category.grains.rawValue, commonTriggers: []),
            Food(name: "Wild Rice", category: Food.Category.grains.rawValue, commonTriggers: []),
            Food(name: "Pasta", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Spaghetti", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Penne", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Rice Noodles", category: Food.Category.grains.rawValue, commonTriggers: []),
            Food(name: "Oats", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Rolled Oats", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Steel Cut Oats", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Quinoa", category: Food.Category.grains.rawValue, commonTriggers: []),
            Food(name: "Barley", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Couscous", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Bulgur", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Cereal", category: Food.Category.grains.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Corn", category: Food.Category.grains.rawValue, commonTriggers: [])
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
            Food(name: "Cauliflower", category: Food.Category.vegetables.rawValue, commonTriggers: ["High FODMAP"]),
            Food(name: "Brussels Sprouts", category: Food.Category.vegetables.rawValue, commonTriggers: ["High FODMAP"]),
            Food(name: "Carrots", category: Food.Category.vegetables.rawValue, commonTriggers: []),
            Food(name: "Tomatoes", category: Food.Category.vegetables.rawValue, commonTriggers: ["Nightshades", "Acidic"]),
            Food(name: "Cherry Tomatoes", category: Food.Category.vegetables.rawValue, commonTriggers: ["Nightshades", "Acidic"]),
            Food(name: "Spinach", category: Food.Category.vegetables.rawValue, commonTriggers: ["High Histamine"]),
            Food(name: "Kale", category: Food.Category.vegetables.rawValue, commonTriggers: []),
            Food(name: "Lettuce", category: Food.Category.vegetables.rawValue, commonTriggers: []),
            Food(name: "Arugula", category: Food.Category.vegetables.rawValue, commonTriggers: []),
            Food(name: "Onions", category: Food.Category.vegetables.rawValue, commonTriggers: ["High FODMAP"]),
            Food(name: "Red Onions", category: Food.Category.vegetables.rawValue, commonTriggers: ["High FODMAP"]),
            Food(name: "Green Onions", category: Food.Category.vegetables.rawValue, commonTriggers: []),
            Food(name: "Garlic", category: Food.Category.vegetables.rawValue, commonTriggers: ["High FODMAP"]),
            Food(name: "Potatoes", category: Food.Category.vegetables.rawValue, commonTriggers: ["Nightshades"]),
            Food(name: "Sweet Potatoes", category: Food.Category.vegetables.rawValue, commonTriggers: []),
            Food(name: "Bell Peppers", category: Food.Category.vegetables.rawValue, commonTriggers: ["Nightshades"]),
            Food(name: "Eggplant", category: Food.Category.vegetables.rawValue, commonTriggers: ["Nightshades", "High Histamine"]),
            Food(name: "Zucchini", category: Food.Category.vegetables.rawValue, commonTriggers: []),
            Food(name: "Cucumber", category: Food.Category.vegetables.rawValue, commonTriggers: []),
            Food(name: "Celery", category: Food.Category.vegetables.rawValue, commonTriggers: []),
            Food(name: "Asparagus", category: Food.Category.vegetables.rawValue, commonTriggers: ["High FODMAP"]),
            Food(name: "Green Beans", category: Food.Category.vegetables.rawValue, commonTriggers: []),
            Food(name: "Peas", category: Food.Category.vegetables.rawValue, commonTriggers: ["High FODMAP"]),
            Food(name: "Corn", category: Food.Category.vegetables.rawValue, commonTriggers: []),
            Food(name: "Mushrooms", category: Food.Category.vegetables.rawValue, commonTriggers: ["High FODMAP"])
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
            Food(name: "Cayenne Pepper", category: Food.Category.spices.rawValue, commonTriggers: ["Spicy"]),
            Food(name: "Paprika", category: Food.Category.spices.rawValue, commonTriggers: []),
            Food(name: "Cinnamon", category: Food.Category.spices.rawValue, commonTriggers: []),
            Food(name: "Ginger", category: Food.Category.spices.rawValue, commonTriggers: []),
            Food(name: "Turmeric", category: Food.Category.spices.rawValue, commonTriggers: []),
            Food(name: "Cumin", category: Food.Category.spices.rawValue, commonTriggers: []),
            Food(name: "Coriander", category: Food.Category.spices.rawValue, commonTriggers: []),
            Food(name: "Salt", category: Food.Category.spices.rawValue, commonTriggers: []),
            Food(name: "Mustard", category: Food.Category.spices.rawValue, commonTriggers: []),
            Food(name: "Vanilla", category: Food.Category.spices.rawValue, commonTriggers: [])
        ])
        
        // Composite Foods - Other category
        foods.append(contentsOf: [
            // Pizza varieties
            Food(name: "Pizza", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Dairy", "Nightshades"]),
            Food(name: "Cheese Pizza", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Dairy", "Nightshades"]),
            Food(name: "Pepperoni Pizza", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Dairy", "Nightshades", "Spicy"]),
            Food(name: "Vegetable Pizza", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Dairy", "Nightshades", "High FODMAP"]),
            
            // Burgers and Sandwiches
            Food(name: "Hamburger", category: Food.Category.other.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "Cheeseburger", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Dairy"]),
            Food(name: "Sandwich", category: Food.Category.other.rawValue, commonTriggers: ["Gluten"]),
            Food(name: "BLT Sandwich", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Nightshades"]),
            Food(name: "Grilled Cheese", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Dairy"]),
            
            // Asian Dishes
            Food(name: "Sushi", category: Food.Category.other.rawValue, commonTriggers: ["Soy", "High Histamine"]),
            Food(name: "Ramen", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Soy", "High FODMAP"]),
            Food(name: "Pad Thai", category: Food.Category.other.rawValue, commonTriggers: ["Nuts", "Soy", "Eggs"]),
            Food(name: "Fried Rice", category: Food.Category.other.rawValue, commonTriggers: ["Soy", "Eggs"]),
            Food(name: "Spring Rolls", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Soy"]),
            
            // Indian Dishes
            Food(name: "Curry", category: Food.Category.other.rawValue, commonTriggers: ["Spicy", "High FODMAP", "Nightshades"]),
            Food(name: "Chicken Curry", category: Food.Category.other.rawValue, commonTriggers: ["Spicy", "High FODMAP", "Nightshades"]),
            Food(name: "Vegetable Curry", category: Food.Category.other.rawValue, commonTriggers: ["Spicy", "High FODMAP", "Nightshades"]),
            Food(name: "Dal", category: Food.Category.other.rawValue, commonTriggers: ["High FODMAP", "Spicy"]),
            Food(name: "Biryani", category: Food.Category.other.rawValue, commonTriggers: ["Spicy", "High FODMAP"]),
            Food(name: "Naan Bread", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Dairy"]),
            
            // Italian Dishes
            Food(name: "Lasagna", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Dairy", "Nightshades"]),
            Food(name: "Spaghetti Bolognese", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Nightshades"]),
            Food(name: "Risotto", category: Food.Category.other.rawValue, commonTriggers: ["Dairy", "High FODMAP"]),
            Food(name: "Carbonara", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Dairy", "Eggs"]),
            
            // Mexican Dishes
            Food(name: "Tacos", category: Food.Category.other.rawValue, commonTriggers: ["Spicy", "Nightshades"]),
            Food(name: "Burrito", category: Food.Category.other.rawValue, commonTriggers: ["High FODMAP", "Spicy", "Dairy"]),
            Food(name: "Quesadilla", category: Food.Category.other.rawValue, commonTriggers: ["Dairy", "Gluten"]),
            Food(name: "Nachos", category: Food.Category.other.rawValue, commonTriggers: ["Dairy", "Nightshades", "Spicy"]),
            
            // Breakfast Items
            Food(name: "Pancakes", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Dairy", "Eggs"]),
            Food(name: "Waffles", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Dairy", "Eggs"]),
            Food(name: "French Toast", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "Dairy", "Eggs"]),
            Food(name: "Omelet", category: Food.Category.other.rawValue, commonTriggers: ["Eggs", "Dairy"]),
            Food(name: "Smoothie", category: Food.Category.other.rawValue, commonTriggers: ["Dairy", "High FODMAP"]),
            
            // Salads
            Food(name: "Caesar Salad", category: Food.Category.other.rawValue, commonTriggers: ["Dairy", "Eggs", "Gluten"]),
            Food(name: "Greek Salad", category: Food.Category.other.rawValue, commonTriggers: ["Dairy", "Nightshades"]),
            Food(name: "Cobb Salad", category: Food.Category.other.rawValue, commonTriggers: ["Eggs", "Dairy"]),
            
            // Soups
            Food(name: "Tomato Soup", category: Food.Category.other.rawValue, commonTriggers: ["Nightshades", "Acidic", "Dairy"]),
            Food(name: "Chicken Noodle Soup", category: Food.Category.other.rawValue, commonTriggers: ["Gluten", "High FODMAP"]),
            Food(name: "Minestrone Soup", category: Food.Category.other.rawValue, commonTriggers: ["Nightshades", "High FODMAP", "Gluten"])
        ])
        
        return foods
    }
}