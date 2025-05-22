//
//  ModelContext+Extensions.swift
//  Flare Food
//
//  Created by Anoop Jose on 22/05/2025.
//

import SwiftData
import SwiftUI

extension View {
    /// Helper to create a data service with the current model context
    func dataService(from modelContext: ModelContext) -> DataService {
        DataService(modelContext: modelContext)
    }
}