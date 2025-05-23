//
//  TestWidget.swift
//  Flare Food Widget
//
//  Test widget to verify setup
//

import WidgetKit
import SwiftUI

// Simple test widget that doesn't require any data models
struct TestWidget: Widget {
    let kind: String = "TestWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TestProvider()) { entry in
            TestWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Test Widget")
        .description("A test widget to verify setup.")
        .supportedFamilies([.systemSmall])
    }
}

struct TestProvider: TimelineProvider {
    func placeholder(in context: Context) -> TestEntry {
        TestEntry(date: Date(), message: "Placeholder")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TestEntry) -> ()) {
        let entry = TestEntry(date: Date(), message: "Snapshot")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = TestEntry(date: Date(), message: "Hello from Widget!")
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct TestEntry: TimelineEntry {
    let date: Date
    let message: String
}

struct TestWidgetView: View {
    var entry: TestEntry
    
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.green)
            Text(entry.message)
                .font(.caption)
        }
        .padding()
    }
}