//
//  ContentView.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftUI
import SwiftData

/// Main content view with tab navigation
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = Tab.home
    
    var body: some View {
        #if os(iOS)
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    DesignSystem.Colors.background,
                    DesignSystem.Colors.background.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(Tab.home)
                
                MealsListView()
                    .tabItem {
                        Label("Meals", systemImage: "fork.knife")
                    }
                    .tag(Tab.meals)
                
                SymptomTrackingView()
                    .tabItem {
                        Label("Symptoms", systemImage: "heart.text.square.fill")
                    }
                    .tag(Tab.symptoms)
                
                AnalyticsView()
                    .tabItem {
                        Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(Tab.analytics)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(Tab.settings)
            }
            .tint(DesignSystem.Colors.primaryGradientStart)
        }
        #else
        // macOS sidebar navigation
        NavigationSplitView {
            List(Tab.allCases, id: \.self, selection: $selectedTab) { tab in
                Label(tab.title, systemImage: tab.icon)
                    .tag(tab)
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } detail: {
            switch selectedTab {
            case .home:
                HomeView()
            case .meals:
                MealsListView()
            case .symptoms:
                SymptomTrackingView()
            case .analytics:
                AnalyticsView()
            case .settings:
                SettingsView()
            }
        }
        #endif
    }
}

/// Tab enumeration for navigation
enum Tab: String, CaseIterable {
    case home
    case meals
    case symptoms
    case analytics
    case settings
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .meals: return "Meals"
        case .symptoms: return "Symptoms"
        case .analytics: return "Analytics"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .meals: return "fork.knife"
        case .symptoms: return "heart.text.square.fill"
        case .analytics: return "chart.line.uptrend.xyaxis"
        case .settings: return "gear"
        }
    }
}

// MARK: - Placeholder Views (to be implemented)

// HomeView is now defined in Views/Home/HomeView.swift
// MealLoggingView is now defined in Views/MealLogging/MealLoggingView.swift
// SymptomTrackingView is now defined in Views/SymptomTracking/SymptomTrackingView.swift
// AnalyticsView is now defined in Views/Analytics/AnalyticsView.swift
// SettingsView is now defined in Views/Settings/SettingsView.swift

#Preview {
    ContentView()
        .modelContainer(for: [
            Food.self,
            Meal.self,
            FoodItem.self,
            Symptom.self,
            Correlation.self,
            UserProfile.self,
            MealReminderTime.self
        ], inMemory: true)
}
