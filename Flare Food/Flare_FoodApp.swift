//
//  Flare_FoodApp.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import SwiftData

@main
struct Flare_FoodApp: App {
    /// Shared model container for SwiftData
    var sharedModelContainer: ModelContainer = {
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

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // If migration fails, try to delete the store and start fresh
            print("Migration failed, attempting to delete store and start fresh: \(error)")
            
            // Delete the existing store
            let storeURL = modelConfiguration.url
            try? FileManager.default.removeItem(at: storeURL)
            
            // Also delete related files
            let walURL = storeURL.appendingPathExtension("wal")
            let shmURL = storeURL.appendingPathExtension("shm")
            try? FileManager.default.removeItem(at: walURL)
            try? FileManager.default.removeItem(at: shmURL)
            
            // Try creating the container again
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer even after deleting store: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Seed database on first launch
                    await seedDatabaseIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .commands {
            // Add macOS-specific menu commands here
        }
        #endif
    }
    
    /// Seeds the database with initial data if needed
    @MainActor
    private func seedDatabaseIfNeeded() async {
        let context = sharedModelContainer.mainContext
        let dataService = DataService(modelContext: context)
        
        // Ensure we have an active profile
        await ensureActiveProfile(context: context)
        
        // Seed food database
        await FoodDatabaseSeeder.seedIfNeeded(using: dataService)
    }
    
    /// Ensures there's an active user profile
    @MainActor
    private func ensureActiveProfile(context: ModelContext) async {
        do {
            let profilesDescriptor = FetchDescriptor<UserProfile>(
                predicate: #Predicate { $0.isActive }
            )
            let activeProfiles = try context.fetch(profilesDescriptor)
            
            if activeProfiles.isEmpty {
                // Create a default profile
                let defaultProfile = UserProfile()
                defaultProfile.name = "Default Profile"
                defaultProfile.isActive = true
                context.insert(defaultProfile)
                try context.save()
            }
        } catch {
            print("Error ensuring active profile: \(error)")
        }
    }
}
