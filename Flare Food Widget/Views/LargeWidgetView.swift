//
//  LargeWidgetView.swift
//  Flare Food Widget
//
//  Created by Anoop Jose on 23/05/2025.
//

import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let entry: SimpleEntry
    
    private var recentMeals: [Meal] {
        entry.meals.sorted { $0.timestamp > $1.timestamp }
    }
    
    private var recentSymptoms: [Symptom] {
        entry.symptoms.sorted { $0.timestamp > $1.timestamp }
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
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text("Flare Food")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Stats row
                HStack(spacing: 20) {
                    StatCard(icon: "fork.knife", label: "Meals", value: "\(entry.totalMeals)")
                    StatCard(icon: "heart.text.square", label: "Symptoms", value: "\(entry.totalSymptoms)")
                    StatCard(icon: "drop.fill", label: "Hydration", value: "\(Int(entry.totalFluid)) ml", iconColor: .blue)
                }
                
                // Recent Meals Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Meals")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if recentMeals.isEmpty {
                        HStack {
                            Text("No meals logged today")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    } else {
                        ForEach(recentMeals.prefix(3)) { meal in
                            MealRow(meal: meal)
                        }
                    }
                }
                
                // Recent Symptoms Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Symptoms")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if recentSymptoms.isEmpty {
                        HStack {
                            Text("No symptoms logged today")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    } else {
                        ForEach(recentSymptoms.prefix(2)) { symptom in
                            SymptomRow(symptom: symptom)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    var iconColor: Color = .secondary
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title3)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.3))
        .cornerRadius(8)
    }
}

struct MealRow: View {
    let meal: Meal
    
    var body: some View {
        HStack {
            Circle()
                .fill(mealTypeColor(meal.mealType))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(meal.foods.compactMap { $0.food?.name }.joined(separator: ", "))
                    .font(.caption)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(meal.mealType.rawValue)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
    
    private func mealTypeColor(_ type: Meal.MealType) -> Color {
        switch type {
        case .breakfast: return .orange
        case .lunch: return .green
        case .dinner: return .blue
        case .snack: return .purple
        }
    }
}

struct SymptomRow: View {
    let symptom: Symptom
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(severityColor(symptom.severity))
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(symptom.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(symptom.name)
                    .font(.caption)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(symptom.severity.rawValue)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func severityColor(_ severity: Symptom.Severity) -> Color {
        switch severity {
        case .mild: return .green
        case .moderate: return .orange
        case .severe: return .red
        }
    }
}

#Preview(as: .systemLarge) {
    FlareFoodWidget()
} timeline: {
    SimpleEntry(date: .now, meals: [], symptoms: [], beverages: [], totalMeals: 3, totalSymptoms: 1, totalFluid: 1500)
}