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
    @StateObject private var authService = BiometricAuthService.shared
    @State private var showSplash = true
    @State private var showOnboarding = false
    @State private var isAppReady = false
    
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
            ZStack {
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                } else if showOnboarding {
                    OnboardingContainerView(isOnboardingComplete: Binding(
                        get: { !showOnboarding },
                        set: { showOnboarding = !$0 }
                    ))
                        .transition(.move(edge: .trailing))
                } else if authService.isBiometricEnabled && !authService.isAuthenticated {
                    BiometricLockView()
                        .transition(.opacity)
                } else if isAppReady {
                    ContentView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .animation(.easeInOut(duration: 0.5), value: showOnboarding)
            .animation(.easeInOut(duration: 0.3), value: authService.isAuthenticated)
            .task {
                // Seed database on first launch
                await seedDatabaseIfNeeded()
                
                // Handle app launch flow
                await handleAppLaunch()
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
    
    /// Handle app launch flow
    @MainActor
    private func handleAppLaunch() async {
        // Show splash screen for a minimum duration
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Check if onboarding is complete
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
        
        withAnimation {
            showSplash = false
            
            if !hasCompletedOnboarding {
                showOnboarding = true
            } else {
                // If biometric is enabled, the lock screen will show automatically
                // Otherwise, show the main app
                if !authService.isBiometricEnabled {
                    isAppReady = true
                }
            }
        }
        
        // If biometric is enabled and onboarding is complete, wait for authentication
        if hasCompletedOnboarding && authService.isBiometricEnabled {
            // Monitor authentication state
            while !authService.isAuthenticated {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
            
            withAnimation {
                isAppReady = true
            }
        }
        
        // Monitor onboarding completion
        if showOnboarding {
            while showOnboarding {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
            
            withAnimation {
                isAppReady = true
            }
        }
    }
}
