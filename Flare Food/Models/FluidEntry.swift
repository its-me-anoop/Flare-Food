//
//  FluidEntry.swift
//  Flare Food
//
//  Created by Anoop Jose on 23/05/2025.
//

import Foundation
import SwiftData

/// Model for tracking fluid/water intake with optional caffeine content
@Model
final class FluidEntry {
    var id: UUID
    var profileId: UUID
    var timestamp: Date
    var type: FluidType
    var amount: Double // in ml
    var temperature: FluidTemperature
    var caffeineContent: Double? // in mg (optional for caffeinated beverages)
    var notes: String?
    var customTypeName: String?
    
    @Relationship(deleteRule: .nullify)
    var meal: Meal?
    
    /// Types of fluids
    enum FluidType: String, CaseIterable, Codable {
        case water = "Water"
        case sparklingWater = "Sparkling Water"
        case coffee = "Coffee"
        case espresso = "Espresso"
        case latte = "Latte"
        case cappuccino = "Cappuccino"
        case tea = "Tea"
        case greenTea = "Green Tea"
        case blackTea = "Black Tea"
        case herbalTea = "Herbal Tea"
        case juice = "Juice"
        case milk = "Milk"
        case smoothie = "Smoothie"
        case energyDrink = "Energy Drink"
        case soda = "Soda"
        case coconutWater = "Coconut Water"
        case sportsDrink = "Sports Drink"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .water:
                return "drop.fill"
            case .sparklingWater:
                return "bubbles.and.sparkles.fill"
            case .coffee, .espresso, .latte, .cappuccino:
                return "cup.and.saucer.fill"
            case .tea, .greenTea, .blackTea, .herbalTea:
                return "leaf.fill"
            case .juice:
                return "cup.and.saucer"
            case .milk:
                return "mug.fill"
            case .smoothie:
                return "takeoutbag.and.cup.and.straw.fill"
            case .energyDrink:
                return "bolt.fill"
            case .soda:
                return "bubbles.and.sparkles.fill"
            case .coconutWater:
                return "tree.fill"
            case .sportsDrink:
                return "figure.run"
            case .other:
                return "ellipsis.circle.fill"
            }
        }
        
        /// Whether this fluid type typically contains caffeine
        var isCaffeinated: Bool {
            switch self {
            case .coffee, .espresso, .latte, .cappuccino, .tea, .greenTea, .blackTea, .energyDrink, .soda:
                return true
            default:
                return false
            }
        }
        
        /// Default serving size in ml
        var defaultServingSize: Double {
            switch self {
            case .water, .sparklingWater:
                return 250
            case .espresso:
                return 30
            case .coffee:
                return 240
            case .latte, .cappuccino:
                return 360
            case .tea, .greenTea, .blackTea, .herbalTea:
                return 240
            case .juice, .milk:
                return 200
            case .smoothie:
                return 350
            case .energyDrink:
                return 250
            case .soda:
                return 355
            case .coconutWater:
                return 330
            case .sportsDrink:
                return 500
            case .other:
                return 250
            }
        }
        
        /// Typical caffeine content per serving in mg
        var typicalCaffeineContent: Double? {
            switch self {
            case .espresso:
                return 64
            case .coffee:
                return 95
            case .latte, .cappuccino:
                return 154
            case .tea:
                return 47
            case .greenTea:
                return 28
            case .blackTea:
                return 47
            case .energyDrink:
                return 80
            case .soda:
                return 34
            default:
                return nil
            }
        }
        
        /// Hydration factor (1.0 = same as water)
        var hydrationFactor: Double {
            switch self {
            case .water, .sparklingWater:
                return 1.0
            case .coffee, .espresso, .latte, .cappuccino:
                return 0.85 // Caffeine has mild diuretic effect
            case .tea, .greenTea, .blackTea:
                return 0.9
            case .herbalTea:
                return 0.95
            case .coconutWater:
                return 0.95
            case .milk:
                return 0.9
            case .juice:
                return 0.85
            case .smoothie:
                return 0.8
            case .energyDrink:
                return 0.8
            case .soda:
                return 0.85
            case .sportsDrink:
                return 1.1
            case .other:
                return 0.9
            }
        }
    }
    
    /// Temperature of the fluid
    enum FluidTemperature: String, CaseIterable, Codable {
        case cold = "Cold"
        case roomTemp = "Room Temperature"
        case warm = "Warm"
        case hot = "Hot"
        
        var icon: String {
            switch self {
            case .cold:
                return "snowflake"
            case .roomTemp:
                return "thermometer.medium"
            case .warm:
                return "thermometer.high"
            case .hot:
                return "flame.fill"
            }
        }
    }
    
    init(
        profileId: UUID,
        timestamp: Date = Date(),
        type: FluidType,
        amount: Double,
        temperature: FluidTemperature = .roomTemp,
        caffeineContent: Double? = nil,
        notes: String? = nil,
        customTypeName: String? = nil,
        meal: Meal? = nil
    ) {
        self.id = UUID()
        self.profileId = profileId
        self.timestamp = timestamp
        self.type = type
        self.amount = amount
        self.temperature = temperature
        self.caffeineContent = caffeineContent ?? type.typicalCaffeineContent
        self.notes = notes
        self.customTypeName = customTypeName
        self.meal = meal
    }
    
    /// Display name for the fluid type
    var displayName: String {
        if type == .other, let customName = customTypeName {
            return customName
        }
        return type.rawValue
    }
    
    /// Formatted amount display
    var formattedAmount: String {
        if amount >= 1000 {
            return String(format: "%.1fL", amount / 1000)
        }
        return String(format: "%.0fml", amount)
    }
    
    /// Effective hydration amount (adjusted by hydration factor)
    var effectiveHydration: Double {
        amount * type.hydrationFactor
    }
    
    /// Formatted effective hydration display
    var formattedEffectiveHydration: String {
        if effectiveHydration >= 1000 {
            return String(format: "%.1fL", effectiveHydration / 1000)
        }
        return String(format: "%.0fml", effectiveHydration)
    }
    
    /// Formatted caffeine content display
    var formattedCaffeineContent: String? {
        guard let caffeine = caffeineContent else { return nil }
        return String(format: "%.0fmg", caffeine)
    }
}