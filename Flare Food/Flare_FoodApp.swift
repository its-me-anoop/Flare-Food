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
            MealReminderTime.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
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
        do {
            let context = sharedModelContainer.mainContext
            let dataService = DataService(modelContext: context)
            await FoodDatabaseSeeder.seedIfNeeded(using: dataService)
        } catch {
            print("Failed to seed database: \(error)")
        }
    }
}
