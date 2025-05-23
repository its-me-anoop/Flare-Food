//
//  DataMigrationManager.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import Foundation
import SwiftData

/// Manages data migration between different schema versions
class DataMigrationManager {
    
    /// Creates a model container with proper migration handling
    static func createModelContainer() throws -> ModelContainer {
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
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        // Create container with migration options
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
    
    /// Migrates existing data to include profileId fields
    @MainActor
    static func migrateExistingData(context: ModelContext) async throws {
        // Check if migration is needed by looking for data without profileId
        let mealsDescriptor = FetchDescriptor<Meal>()
        let meals = try context.fetch(mealsDescriptor)
        
        let symptomsDescriptor = FetchDescriptor<Symptom>()
        let symptoms = try context.fetch(symptomsDescriptor)
        
        let fluidsDescriptor = FetchDescriptor<FluidEntry>()
        let fluids = try context.fetch(fluidsDescriptor)
        
        // Check if we have any data that needs migration
        let needsMigration = !meals.isEmpty || !symptoms.isEmpty || !fluids.isEmpty
        
        if needsMigration {
            // Ensure we have an active profile
            let profilesDescriptor = FetchDescriptor<UserProfile>(
                predicate: #Predicate { $0.isActive }
            )
            let activeProfiles = try context.fetch(profilesDescriptor)
            
            let defaultProfile: UserProfile
            if let existingProfile = activeProfiles.first {
                defaultProfile = existingProfile
            } else {
                // Create a default profile for existing data
                defaultProfile = UserProfile()
                defaultProfile.name = "Default Profile"
                defaultProfile.isActive = true
                context.insert(defaultProfile)
            }
            
            // Update existing data with the default profile ID
            for meal in meals {
                // Only update if profileId is not already set (assuming UUID() creates a new one each time)
                // This is a simple check - in real migration you'd check if it's a default/empty UUID
                if meal.profileId == UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
                    meal.profileId = defaultProfile.id
                }
            }
            
            for symptom in symptoms {
                if symptom.profileId == UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
                    symptom.profileId = defaultProfile.id
                }
            }
            
            for fluid in fluids {
                if fluid.profileId == UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
                    fluid.profileId = defaultProfile.id
                }
            }
            
            try context.save()
        }
    }
}