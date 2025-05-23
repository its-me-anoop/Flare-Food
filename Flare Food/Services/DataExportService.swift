//
//  DataExportService.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import Foundation
import SwiftData

/// Service for exporting app data in various formats
class DataExportService {
    static let shared = DataExportService()
    
    private init() {}
    
    enum ExportFormat: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"
        
        var fileExtension: String {
            switch self {
            case .csv: return "csv"
            case .json: return "json"
            }
        }
    }
    
    // MARK: - Export All Data
    
    func exportAllData(
        meals: [Meal],
        symptoms: [Symptom],
        beverages: [FluidEntry],
        format: ExportFormat
    ) -> Data? {
        switch format {
        case .csv:
            return exportToCSV(meals: meals, symptoms: symptoms, beverages: beverages)
        case .json:
            return exportToJSON(meals: meals, symptoms: symptoms, beverages: beverages)
        }
    }
    
    // MARK: - CSV Export
    
    private func exportToCSV(meals: [Meal], symptoms: [Symptom], beverages: [FluidEntry]) -> Data? {
        var csvString = ""
        
        // Meals CSV
        csvString += "MEALS\n"
        csvString += "Date,Time,Type,Foods,Notes\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        for meal in meals {
            let foods = meal.foodItems.compactMap { $0.food?.name }.joined(separator: "; ")
            csvString += "\(dateFormatter.string(from: meal.timestamp)),"
            csvString += "\(timeFormatter.string(from: meal.timestamp)),"
            csvString += "\(meal.type.rawValue),"
            csvString += "\"\(foods)\","
            csvString += "\"\(meal.notes?.replacingOccurrences(of: "\"", with: "\"\"") ?? "")\"\n"
        }
        
        csvString += "\n\n"
        
        // Symptoms CSV
        csvString += "SYMPTOMS\n"
        csvString += "Date,Time,Type,Severity,Duration,Notes\n"
        
        for symptom in symptoms {
            csvString += "\(dateFormatter.string(from: symptom.timestamp)),"
            csvString += "\(timeFormatter.string(from: symptom.timestamp)),"
            csvString += "\(symptom.type.rawValue),"
            csvString += "\(symptom.severity),"
            csvString += "\(symptom.durationMinutes ?? 0),"
            csvString += "\"\(symptom.notes?.replacingOccurrences(of: "\"", with: "\"\"") ?? "")\"\n"
        }
        
        csvString += "\n\n"
        
        // Beverages CSV
        csvString += "BEVERAGES\n"
        csvString += "Date,Time,Type,Amount(ml),Caffeine(mg),Temperature,Notes\n"
        
        for beverage in beverages {
            csvString += "\(dateFormatter.string(from: beverage.timestamp)),"
            csvString += "\(timeFormatter.string(from: beverage.timestamp)),"
            csvString += "\(beverage.type.rawValue),"
            csvString += "\(beverage.amount),"
            csvString += "\(beverage.caffeineContent ?? 0),"
            csvString += "\(beverage.temperature.rawValue),"
            csvString += "\"\(beverage.notes?.replacingOccurrences(of: "\"", with: "\"\"") ?? "")\"\n"
        }
        
        return csvString.data(using: .utf8)
    }
    
    // MARK: - JSON Export
    
    private func exportToJSON(meals: [Meal], symptoms: [Symptom], beverages: [FluidEntry]) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let exportData = ExportData(
            exportDate: Date(),
            meals: meals.map { MealExport(from: $0) },
            symptoms: symptoms.map { SymptomExport(from: $0) },
            beverages: beverages.map { BeverageExport(from: $0) }
        )
        
        return try? encoder.encode(exportData)
    }
}

// MARK: - Export Models

struct ExportData: Codable {
    let exportDate: Date
    let meals: [MealExport]
    let symptoms: [SymptomExport]
    let beverages: [BeverageExport]
}

struct MealExport: Codable {
    let timestamp: Date
    let type: String
    let foods: [String]
    let notes: String?
    
    init(from meal: Meal) {
        self.timestamp = meal.timestamp
        self.type = meal.type.rawValue
        self.foods = meal.foodItems.compactMap { $0.food?.name }
        self.notes = meal.notes
    }
}

struct SymptomExport: Codable {
    let timestamp: Date
    let type: String
    let severity: Double
    let duration: Int?
    let notes: String?
    
    init(from symptom: Symptom) {
        self.timestamp = symptom.timestamp
        self.type = symptom.type.rawValue
        self.severity = symptom.severity
        self.duration = symptom.durationMinutes
        self.notes = symptom.notes
    }
}

struct BeverageExport: Codable {
    let timestamp: Date
    let type: String
    let amount: Double
    let caffeineContent: Double?
    let temperature: String?
    let notes: String?
    
    init(from beverage: FluidEntry) {
        self.timestamp = beverage.timestamp
        self.type = beverage.type.rawValue
        self.amount = beverage.amount
        self.caffeineContent = beverage.caffeineContent
        self.temperature = beverage.temperature.rawValue
        self.notes = beverage.notes
    }
}