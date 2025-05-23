//
//  FlareFoodWidget.swift
//  Flare Food Widget
//
//  Created by Anoop Jose on 23/05/2025.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    @MainActor
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), meals: [], symptoms: [], beverages: [], totalMeals: 0, totalSymptoms: 0, totalFluid: 0)
    }
    
    @MainActor
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = getEntry(for: Date())
        completion(entry)
    }
    
    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let entry = getEntry(for: currentDate)
        
        // Update every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    @MainActor
    private func getEntry(for date: Date) -> SimpleEntry {
        let container = ModelContainerConfig.shared.container
        let context = container.mainContext
        
        // Get today's data
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Fetch today's meals
        let mealPredicate = #Predicate<Meal> { meal in
            meal.timestamp >= startOfDay && meal.timestamp < endOfDay
        }
        let meals = (try? context.fetch(FetchDescriptor(predicate: mealPredicate))) ?? []
        
        // Fetch today's symptoms
        let symptomPredicate = #Predicate<Symptom> { symptom in
            symptom.timestamp >= startOfDay && symptom.timestamp < endOfDay
        }
        let symptoms = (try? context.fetch(FetchDescriptor(predicate: symptomPredicate))) ?? []
        
        // Fetch today's beverages
        let beveragePredicate = #Predicate<FluidEntry> { beverage in
            beverage.timestamp >= startOfDay && beverage.timestamp < endOfDay
        }
        let beverages = (try? context.fetch(FetchDescriptor(predicate: beveragePredicate))) ?? []
        
        // Calculate total fluid intake
        let totalFluid = beverages.reduce(0) { $0 + $1.amount }
        
        return SimpleEntry(
            date: date,
            meals: Array(meals.prefix(5)),
            symptoms: Array(symptoms.prefix(5)),
            beverages: beverages,
            totalMeals: meals.count,
            totalSymptoms: symptoms.count,
            totalFluid: totalFluid
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let meals: [Meal]
    let symptoms: [Symptom]
    let beverages: [FluidEntry]
    let totalMeals: Int
    let totalSymptoms: Int
    let totalFluid: Double
}

struct FlareFoodWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct FlareFoodWidget: Widget {
    let kind: String = "FlareFoodWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FlareFoodWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Flare Food")
        .description("Track your daily meals, symptoms, and hydration.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    FlareFoodWidget()
} timeline: {
    SimpleEntry(date: .now, meals: [], symptoms: [], beverages: [], totalMeals: 3, totalSymptoms: 1, totalFluid: 1500)
}

#Preview(as: .systemMedium) {
    FlareFoodWidget()
} timeline: {
    SimpleEntry(date: .now, meals: [], symptoms: [], beverages: [], totalMeals: 3, totalSymptoms: 1, totalFluid: 1500)
}

#Preview(as: .systemLarge) {
    FlareFoodWidget()
} timeline: {
    SimpleEntry(date: .now, meals: [], symptoms: [], beverages: [], totalMeals: 3, totalSymptoms: 1, totalFluid: 1500)
}