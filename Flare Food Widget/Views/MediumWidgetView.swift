//
//  MediumWidgetView.swift
//  Flare Food Widget
//
//  Created by Anoop Jose on 23/05/2025.
//

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: SimpleEntry
    
    private var recentMeals: [Meal] {
        entry.meals.sorted { $0.timestamp > $1.timestamp }.prefix(3).map { $0 }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.89, blue: 0.96),
                    Color(red: 0.91, green: 0.94, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 16) {
                // Left side - Stats
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text("Today")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.secondary)
                            Text("\(entry.totalMeals) meals")
                                .font(.caption)
                        }
                        
                        HStack {
                            Image(systemName: "heart.text.square")
                                .foregroundColor(.secondary)
                            Text("\(entry.totalSymptoms) symptoms")
                                .font(.caption)
                        }
                        
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            Text("\(Int(entry.totalFluid)) ml")
                                .font(.caption)
                        }
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // Right side - Recent meals
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Meals")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if recentMeals.isEmpty {
                        Text("No meals today")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(recentMeals.prefix(3)) { meal in
                            HStack {
                                Circle()
                                    .fill(mealTypeColor(Meal.MealType(rawValue: meal.mealType) ?? .other))
                                    .frame(width: 6, height: 6)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(meal.timestamp, style: .time)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    if let firstFood = meal.foodItems.first {
                                        Text(firstFood.food?.name ?? "Unknown")
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
    
    private func mealTypeColor(_ type: Meal.MealType) -> Color {
        switch type {
        case .breakfast: return .orange
        case .lunch: return .green
        case .dinner: return .blue
        case .snack: return .purple
        case .other: return .gray
        }
    }
}

#Preview(as: .systemMedium) {
    FlareFoodWidget()
} timeline: {
    SimpleEntry(date: Date.now, meals: [], symptoms: [], beverages: [], totalMeals: 3, totalSymptoms: 1, totalFluid: 1500)
}