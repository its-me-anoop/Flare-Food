//
//  ReportGeneratorView.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import SwiftUI
import SwiftData

/// View for generating and sharing reports
struct ReportGeneratorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedDateRange = DateRange.lastMonth
    @State private var customStartDate = Date().addingTimeInterval(-30 * 24 * 60 * 60)
    @State private var customEndDate = Date()
    @State private var isGenerating = false
    @State private var showingShareSheet = false
    @State private var reportData: Data?
    @State private var showError = false
    @State private var errorMessage = ""
    
    enum DateRange: String, CaseIterable {
        case lastWeek = "Last Week"
        case lastMonth = "Last Month"
        case lastThreeMonths = "Last 3 Months"
        case lastSixMonths = "Last 6 Months"
        case lastYear = "Last Year"
        case custom = "Custom Range"
        
        var dateRange: (start: Date, end: Date) {
            let now = Date()
            let calendar = Calendar.current
            
            switch self {
            case .lastWeek:
                return (calendar.date(byAdding: .day, value: -7, to: now)!, now)
            case .lastMonth:
                return (calendar.date(byAdding: .month, value: -1, to: now)!, now)
            case .lastThreeMonths:
                return (calendar.date(byAdding: .month, value: -3, to: now)!, now)
            case .lastSixMonths:
                return (calendar.date(byAdding: .month, value: -6, to: now)!, now)
            case .lastYear:
                return (calendar.date(byAdding: .year, value: -1, to: now)!, now)
            case .custom:
                return (Date(), Date()) // Will be overridden
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Report Period") {
                    Picker("Date Range", selection: $selectedDateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    
                    if selectedDateRange == .custom {
                        DatePicker("Start Date", selection: $customStartDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $customEndDate, displayedComponents: .date)
                    }
                }
                
                Section("Report Contents") {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Meal Summary")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Symptom Analysis")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Hydration Report")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Food-Symptom Correlations")
                    }
                }
                
                Section {
                    Button(action: generateReport) {
                        if isGenerating {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                Text("Generating Report...")
                                    .padding(.leading, 8)
                            }
                        } else {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                Text("Generate PDF Report")
                            }
                        }
                    }
                    .disabled(isGenerating)
                    .foregroundColor(isGenerating ? .secondary : .white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isGenerating ? Color.gray : Color(DesignSystem.Colors.primaryGradientStart))
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Generate Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingShareSheet) {
                if let reportData = reportData {
                    ShareSheet(items: [reportData])
                }
            }
        }
    }
    
    private func generateReport() {
        isGenerating = true
        
        Task {
            do {
                let (startDate, endDate) = selectedDateRange == .custom ? 
                    (customStartDate, customEndDate) : selectedDateRange.dateRange
                
                // Fetch data
                let meals = try await fetchMeals(from: startDate, to: endDate)
                let symptoms = try await fetchSymptoms(from: startDate, to: endDate)
                let beverages = try await fetchBeverages(from: startDate, to: endDate)
                let correlations = try await fetchCorrelations()
                
                // Generate PDF
                let pdfData = PDFReportService.shared.generateReport(
                    from: startDate,
                    to: endDate,
                    meals: meals,
                    symptoms: symptoms,
                    beverages: beverages,
                    correlations: correlations
                )
                
                await MainActor.run {
                    isGenerating = false
                    
                    if let pdfData = pdfData {
                        self.reportData = pdfData
                        showingShareSheet = true
                    } else {
                        errorMessage = "Failed to generate report"
                        showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    errorMessage = "Error generating report: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    @MainActor
    private func fetchMeals(from startDate: Date, to endDate: Date) async throws -> [Meal] {
        let descriptor = FetchDescriptor<Meal>(
            predicate: #Predicate { meal in
                meal.timestamp >= startDate && meal.timestamp <= endDate
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    @MainActor
    private func fetchSymptoms(from startDate: Date, to endDate: Date) async throws -> [Symptom] {
        let descriptor = FetchDescriptor<Symptom>(
            predicate: #Predicate { symptom in
                symptom.timestamp >= startDate && symptom.timestamp <= endDate
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    @MainActor
    private func fetchBeverages(from startDate: Date, to endDate: Date) async throws -> [FluidEntry] {
        let descriptor = FetchDescriptor<FluidEntry>(
            predicate: #Predicate { beverage in
                beverage.timestamp >= startDate && beverage.timestamp <= endDate
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    @MainActor
    private func fetchCorrelations() async throws -> [Correlation] {
        let descriptor = FetchDescriptor<Correlation>(
            sortBy: [SortDescriptor(\.correlationCoefficient, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
}

#Preview {
    ReportGeneratorView()
        .modelContainer(for: [Meal.self, Symptom.self, FluidEntry.self, Correlation.self])
}