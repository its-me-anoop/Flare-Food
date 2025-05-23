//
//  PDFReportService.swift
//  Flare Food
//
//  Created by Assistant on 23/05/2025.
//

import Foundation
import PDFKit
import SwiftUI
import SwiftData

/// Service for generating PDF reports
class PDFReportService {
    static let shared = PDFReportService()
    
    private init() {}
    
    /// Generate a PDF report for a date range
    func generateReport(
        from startDate: Date,
        to endDate: Date,
        meals: [Meal],
        symptoms: [Symptom],
        beverages: [FluidEntry],
        correlations: [Correlation]
    ) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Flare Food",
            kCGPDFContextTitle: "Flare Food Health Report",
            kCGPDFContextSubject: "Personal Health Tracking Report"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0 // 8.5 inches in points
        let pageHeight = 11.0 * 72.0 // 11 inches in points
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            // Page 1: Cover and Summary
            context.beginPage()
            drawCoverPage(in: context, rect: pageRect, startDate: startDate, endDate: endDate)
            
            // Page 2: Meal Summary
            context.beginPage()
            drawMealSummary(in: context, rect: pageRect, meals: meals)
            
            // Page 3: Symptom Analysis
            context.beginPage()
            drawSymptomAnalysis(in: context, rect: pageRect, symptoms: symptoms)
            
            // Page 4: Hydration Report
            context.beginPage()
            drawHydrationReport(in: context, rect: pageRect, beverages: beverages)
            
            // Page 5: Correlations
            if !correlations.isEmpty {
                context.beginPage()
                drawCorrelations(in: context, rect: pageRect, correlations: correlations)
            }
        }
        
        return data
    }
    
    // MARK: - Page Drawing Methods
    
    private func drawCoverPage(in context: UIGraphicsPDFRendererContext, rect: CGRect, startDate: Date, endDate: Date) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 36, weight: .bold),
            .foregroundColor: UIColor(DesignSystem.Colors.primaryText)
        ]
        
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor(DesignSystem.Colors.secondaryText)
        ]
        
        // Title
        let title = "Flare Food Health Report"
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(
            x: (rect.width - titleSize.width) / 2,
            y: 100,
            width: titleSize.width,
            height: titleSize.height
        )
        title.draw(in: titleRect, withAttributes: titleAttributes)
        
        // Date range
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateRange = "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
        let dateSize = dateRange.size(withAttributes: subtitleAttributes)
        let dateRect = CGRect(
            x: (rect.width - dateSize.width) / 2,
            y: titleRect.maxY + 20,
            width: dateSize.width,
            height: dateSize.height
        )
        dateRange.draw(in: dateRect, withAttributes: subtitleAttributes)
        
        // Logo placeholder
        let logoRect = CGRect(x: (rect.width - 100) / 2, y: rect.midY - 50, width: 100, height: 100)
        context.cgContext.setFillColor(UIColor(DesignSystem.Colors.primaryGradientStart).cgColor)
        context.cgContext.fillEllipse(in: logoRect)
        
        // Footer
        let footer = "Generated on \(dateFormatter.string(from: Date()))"
        let footerSize = footer.size(withAttributes: subtitleAttributes)
        let footerRect = CGRect(
            x: (rect.width - footerSize.width) / 2,
            y: rect.height - 100,
            width: footerSize.width,
            height: footerSize.height
        )
        footer.draw(in: footerRect, withAttributes: subtitleAttributes)
    }
    
    private func drawMealSummary(in context: UIGraphicsPDFRendererContext, rect: CGRect, meals: [Meal]) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor(DesignSystem.Colors.primaryText)
        ]
        
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor(DesignSystem.Colors.primaryText)
        ]
        
        var yPosition: CGFloat = 50
        
        // Title
        "Meal Summary".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
        yPosition += 40
        
        // Stats
        let mealTypes = Dictionary(grouping: meals, by: { $0.type })
        let statsText = """
        Total Meals: \(meals.count)
        Breakfast: \(mealTypes[.breakfast]?.count ?? 0)
        Lunch: \(mealTypes[.lunch]?.count ?? 0)
        Dinner: \(mealTypes[.dinner]?.count ?? 0)
        Snacks: \(mealTypes[.snack]?.count ?? 0)
        """
        
        statsText.draw(
            in: CGRect(x: 50, y: yPosition, width: rect.width - 100, height: 200),
            withAttributes: bodyAttributes
        )
        
        yPosition += 150
        
        // Recent meals list
        "Recent Meals:".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
        yPosition += 30
        
        for meal in meals.prefix(10) {
            let mealText = "\(meal.type.rawValue) - \(DateFormatter.localizedString(from: meal.timestamp, dateStyle: .short, timeStyle: .short))"
            mealText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: bodyAttributes)
            yPosition += 20
        }
    }
    
    private func drawSymptomAnalysis(in context: UIGraphicsPDFRendererContext, rect: CGRect, symptoms: [Symptom]) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor(DesignSystem.Colors.primaryText)
        ]
        
        var yPosition: CGFloat = 50
        
        // Title
        "Symptom Analysis".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
        yPosition += 40
        
        // Group symptoms by type
        let groupedSymptoms = Dictionary(grouping: symptoms, by: { $0.type })
        
        for (type, typeSymptoms) in groupedSymptoms {
            let avgSeverity = typeSymptoms.reduce(0) { $0 + $1.severity } / Double(typeSymptoms.count)
            let text = "\(type.rawValue): \(typeSymptoms.count) occurrences, avg severity: \(String(format: "%.1f", avgSeverity))/10"
            text.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor(DesignSystem.Colors.primaryText)
            ])
            yPosition += 25
        }
    }
    
    private func drawHydrationReport(in context: UIGraphicsPDFRendererContext, rect: CGRect, beverages: [FluidEntry]) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor(DesignSystem.Colors.primaryText)
        ]
        
        var yPosition: CGFloat = 50
        
        // Title
        "Hydration Report".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
        yPosition += 40
        
        // Calculate totals
        let totalFluid = beverages.reduce(0) { $0 + $1.amount }
        let totalCaffeine = beverages.reduce(0) { $0 + ($1.caffeineContent ?? 0) }
        let avgDaily = totalFluid / max(1, Double(Set(beverages.map { Calendar.current.startOfDay(for: $0.timestamp) }).count))
        
        let stats = """
        Total Fluid Intake: \(String(format: "%.1f", totalFluid / 1000)) L
        Average Daily Intake: \(String(format: "%.1f", avgDaily / 1000)) L
        Total Caffeine: \(String(format: "%.0f", totalCaffeine)) mg
        """
        
        stats.draw(
            in: CGRect(x: 50, y: yPosition, width: rect.width - 100, height: 100),
            withAttributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor(DesignSystem.Colors.primaryText)
            ]
        )
    }
    
    private func drawCorrelations(in context: UIGraphicsPDFRendererContext, rect: CGRect, correlations: [Correlation]) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor(DesignSystem.Colors.primaryText)
        ]
        
        var yPosition: CGFloat = 50
        
        // Title
        "Food-Symptom Correlations".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
        yPosition += 40
        
        // List correlations
        for correlation in correlations.prefix(15) {
            let foodName = correlation.food?.name ?? "Unknown"
            let text = "\(foodName) → \(correlation.symptomType): \(String(format: "%.0f%%", abs(correlation.correlationCoefficient) * 100)) correlation"
            text.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                NSAttributedString.Key.foregroundColor: UIColor(DesignSystem.Colors.primaryText)
            ])
            yPosition += 20
        }
    }
}