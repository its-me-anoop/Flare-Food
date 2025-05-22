//
//  MealTests.swift
//  Flare FoodTests
//
//  Created by Anoop Jose on 22/05/2025.
//

import Testing
import SwiftData
@testable import Flare_Food

/// Tests for the Meal model
struct MealTests {
    
    @Test("Meal initialization with default values")
    func testMealInitializationDefaults() async throws {
        // Given
        let mealType = Meal.MealType.breakfast
        
        // When
        let meal = Meal(mealType: mealType)
        
        // Then
        #expect(meal.mealType == mealType.rawValue)
        #expect(meal.foodItems.isEmpty)
        #expect(meal.photoData == nil)
        #expect(meal.notes == nil)
        #expect(meal.location == nil)
        #expect(meal.timestamp.timeIntervalSinceNow < 1) // Recently created
    }
    
    @Test("Meal initialization with all parameters")
    func testMealInitializationWithAllParameters() async throws {
        // Given
        let mealType = Meal.MealType.lunch
        let food = Food(name: "Salad", category: "Vegetables")
        let foodItem = FoodItem(food: food, portionSize: 0.75)
        let photoData = Data([0x1, 0x2, 0x3])
        let notes = "Light lunch"
        let location = "Office"
        
        // When
        let meal = Meal(
            mealType: mealType,
            foodItems: [foodItem],
            photoData: photoData,
            notes: notes,
            location: location
        )
        
        // Then
        #expect(meal.mealType == mealType.rawValue)
        #expect(meal.foodItems.count == 1)
        #expect(meal.photoData == photoData)
        #expect(meal.notes == notes)
        #expect(meal.location == location)
    }
    
    @Test("MealType enum properties")
    func testMealTypeEnumProperties() async throws {
        // Test icons
        #expect(Meal.MealType.breakfast.icon == "sun.max.fill")
        #expect(Meal.MealType.lunch.icon == "sun.min.fill")
        #expect(Meal.MealType.dinner.icon == "moon.fill")
        #expect(Meal.MealType.snack.icon == "leaf.fill")
        #expect(Meal.MealType.other.icon == "fork.knife")
        
        // Test that all cases are covered
        let allCases = Meal.MealType.allCases
        #expect(allCases.count == 5)
    }
    
    @Test("Meal type computed property")
    func testMealTypeComputedProperty() async throws {
        // Given
        let meal = Meal(mealType: .dinner)
        
        // When/Then
        #expect(meal.type == .dinner)
        
        // Test invalid meal type
        meal.mealType = "InvalidType"
        #expect(meal.type == .other)
    }
    
    @Test("FoodItem initialization")
    func testFoodItemInitialization() async throws {
        // Given
        let food = Food(name: "Rice", category: "Grains")
        let portionSize = 0.5
        let quantity = "1 cup"
        
        // When
        let foodItem = FoodItem(
            food: food,
            portionSize: portionSize,
            quantity: quantity
        )
        
        // Then
        #expect(foodItem.food?.name == food.name)
        #expect(foodItem.portionSize == portionSize)
        #expect(foodItem.quantity == quantity)
    }
    
    @Test("FoodItem portion size bounds")
    func testFoodItemPortionSizeBounds() async throws {
        // Given
        let food = Food(name: "Test", category: "Other")
        
        // Test upper bound
        let foodItem1 = FoodItem(food: food, portionSize: 1.5)
        #expect(foodItem1.portionSize == 1.0)
        
        // Test lower bound
        let foodItem2 = FoodItem(food: food, portionSize: -0.5)
        #expect(foodItem2.portionSize == 0.0)
        
        // Test valid range
        let foodItem3 = FoodItem(food: food, portionSize: 0.75)
        #expect(foodItem3.portionSize == 0.75)
    }
}