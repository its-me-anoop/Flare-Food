//
//  FoodTests.swift
//  Flare FoodTests
//
//  Created by Anoop Jose on 22/05/2025.
//

import Testing
import SwiftData
@testable import Flare_Food

/// Tests for the Food model
struct FoodTests {
    
    @Test("Food initialization with default values")
    func testFoodInitializationDefaults() async throws {
        // Given
        let name = "Apple"
        let category = "Fruits"
        
        // When
        let food = Food(name: name, category: category)
        
        // Then
        #expect(food.name == name)
        #expect(food.category == category)
        #expect(food.commonTriggers.isEmpty)
        #expect(food.usageCount == 0)
        #expect(food.isFavorite == false)
        #expect(food.notes == nil)
        #expect(food.dateAdded.timeIntervalSinceNow < 1) // Recently created
    }
    
    @Test("Food initialization with all parameters")
    func testFoodInitializationWithAllParameters() async throws {
        // Given
        let name = "Milk"
        let category = "Dairy"
        let triggers = ["Dairy", "Lactose"]
        let notes = "Whole milk"
        
        // When
        let food = Food(
            name: name,
            category: category,
            commonTriggers: triggers,
            notes: notes
        )
        
        // Then
        #expect(food.name == name)
        #expect(food.category == category)
        #expect(food.commonTriggers == triggers)
        #expect(food.notes == notes)
    }
    
    @Test("Food category enum has all expected cases")
    func testFoodCategoryEnum() async throws {
        // Given/When
        let categories = Food.Category.allCases
        
        // Then
        #expect(categories.count == 10)
        #expect(categories.contains(.dairy))
        #expect(categories.contains(.grains))
        #expect(categories.contains(.proteins))
        #expect(categories.contains(.vegetables))
        #expect(categories.contains(.fruits))
        #expect(categories.contains(.fats))
        #expect(categories.contains(.sweets))
        #expect(categories.contains(.beverages))
        #expect(categories.contains(.spices))
        #expect(categories.contains(.other))
    }
    
    @Test("Common trigger enum has all expected cases")
    func testCommonTriggerEnum() async throws {
        // Given/When
        let triggers = Food.CommonTrigger.allCases
        
        // Then
        #expect(triggers.count == 14)
        #expect(triggers.contains(.gluten))
        #expect(triggers.contains(.dairy))
        #expect(triggers.contains(.fodmap))
        #expect(triggers.contains(.histamine))
    }
    
    @Test("Food usage count increment")
    func testFoodUsageIncrement() async throws {
        // Given
        let food = Food(name: "Test Food", category: "Other")
        let initialCount = food.usageCount
        
        // When
        food.usageCount += 1
        
        // Then
        #expect(food.usageCount == initialCount + 1)
    }
    
    @Test("Food favorite toggle")
    func testFoodFavoriteToggle() async throws {
        // Given
        let food = Food(name: "Test Food", category: "Other")
        #expect(food.isFavorite == false)
        
        // When
        food.isFavorite = true
        
        // Then
        #expect(food.isFavorite == true)
    }
}