//
//  SmallWidgetView.swift
//  Flare Food Widget
//
//  Created by Anoop Jose on 23/05/2025.
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: SimpleEntry
    
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
            
            VStack(spacing: 12) {
                // Header
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                    Text("Today")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                Spacer()
                
                // Stats
                VStack(spacing: 8) {
                    StatRow(icon: "fork.knife", label: "Meals", value: entry.totalMeals)
                    StatRow(icon: "heart.text.square", label: "Symptoms", value: entry.totalSymptoms)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: Int
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text("\(value)")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

#Preview(as: .systemSmall) {
    FlareFoodWidget()
} timeline: {
    SimpleEntry(date: .now, meals: [], symptoms: [], beverages: [], totalMeals: 3, totalSymptoms: 1, totalFluid: 1500)
}