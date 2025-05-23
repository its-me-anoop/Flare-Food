//
//  ModelContainerConfig.swift
//  Flare Food
//
//  Created by Anoop Jose on 23/05/2025.
//

import SwiftData
import Foundation

/// Shared model container configuration for app and widget
@MainActor
class ModelContainerConfig {
    static let shared = ModelContainerConfig()
    
    static let appGroupIdentifier = "group.co.uk.flutterly.flarefood"
    
    lazy var container: ModelContainer = {
        let schema = Schema([
            Food.self,
            Meal.self,
            FoodItem.self,
            Symptom.self,
            Correlation.self,
            UserProfile.self,
            MealReminderTime.self,
            FluidEntry.self
        ])
        
        let modelConfiguration: ModelConfiguration
        
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier) {
            let storeURL = containerURL.appendingPathComponent("FlareFoodDatabase.sqlite")
            modelConfiguration = ModelConfiguration(
                schema: schema,
                url: storeURL,
                allowsSave: true
            )
        } else {
            // Fallback to default configuration if app groups not available
            modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    /// Shared UserDefaults for app group
    nonisolated static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }
    
    private init() {}
}