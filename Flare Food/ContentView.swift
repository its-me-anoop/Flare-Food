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
                
                SymptomsListView()
                    .tabItem {
                        Label("Symptoms", systemImage: "heart.text.square.fill")
                    }
                    .tag(Tab.symptoms)
                
                BeveragesListView()
                    .tabItem {
                        Label("Beverages", systemImage: "drop.fill")
                    }
                    .tag(Tab.beverages)
                
                AnalyticsView()
                    .tabItem {
                        Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(Tab.analytics)
        }
        .tint(DesignSystem.Colors.primaryGradientStart)
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
                SymptomsListView()
            case .beverages:
                BeveragesListView()
            case .analytics:
                AnalyticsView()
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
    case beverages
    case analytics
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .meals: return "Meals"
        case .symptoms: return "Symptoms"
        case .beverages: return "Beverages"
        case .analytics: return "Analytics"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .meals: return "fork.knife"
        case .symptoms: return "heart.text.square.fill"
        case .beverages: return "drop.fill"
        case .analytics: return "chart.line.uptrend.xyaxis"
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
            MealReminderTime.self,
            FluidEntry.self
        ], inMemory: true)
}
