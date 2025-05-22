# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flare Food is a bright, data-driven iOS companion that helps people pinpoint the foods that trigger digestive, skin, or inflammatory flare-ups. By making meal and symptom logging friction-free and instantly insightful, Flare Food empowers users to take control of their health—one bite at a time.

### Target Audience
People with IBS, IBD, eczema, migraines, long-Covid, or anyone who suspects certain foods are affecting their well-being.

### Core Features

1. **Fast Meal Logging** (<30s)
   - Photo capture or recent foods selection
   - Thumb-friendly portion slider
   - Meal type tagging (breakfast, snack, etc.)

2. **Precise Symptom Tracking**
   - Symptom selection with severity slider
   - Notes and medication tracking
   - Minimal typing required

3. **Statistical Correlation Analysis**
   - Heat-map visualization
   - Identifies statistically significant food-symptom links
   - Insights available within 2 weeks of consistent logging

4. **Smart Notifications**
   - Optional meal-time reminders
   - Intelligent timing based on user patterns

5. **Data Export & Sharing**
   - Doctor-ready PDF reports
   - Raw data export capabilities

### Technical Requirements

- **Storage**: CoreData (offline-first architecture)
- **Sync**: iCloud integration
- **Health Integration**: HealthKit support (optional)
- **Security**: Face ID authentication
- **UI/UX**: Motivating design with streaks, confetti animations, warm color palette
- **Performance**: Fast logging experience (<30s average)
- **Future**: Photo recognition for meal logging (v2)

## Development Principles

### SOLID Principles
- **Single Responsibility**: Each class/struct should have one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Derived classes must be substitutable for base classes
- **Interface Segregation**: Many specific interfaces are better than one general interface
- **Dependency Inversion**: Depend on abstractions, not concretions

### Code Organization
- Create separate files for each component/feature
- Use folders to group related functionality:
  - Models/
  - Views/
  - ViewModels/
  - Services/
  - Utilities/
  - Extensions/

### Documentation Requirements
- Add comprehensive documentation comments for all public APIs
- Use Swift's documentation syntax (/// for single line, /** */ for multi-line)
- Include parameter descriptions, return values, and usage examples
- Document complex business logic and algorithms

### Testing Requirements
- Write unit tests for all business logic
- Aim for >80% code coverage
- Use Swift Testing framework with @Test macro
- Test file naming: [FeatureName]Tests.swift
- Include tests for:
  - Model validation
  - ViewModel logic
  - Service layer functionality
  - Statistical calculations
  - Data persistence

## Development Commands

### Building the Project
```bash
# Build for iOS Simulator
xcodebuild -project "Flare Food.xcodeproj" -scheme "Flare Food" -sdk iphonesimulator -configuration Debug build

# Build for iOS Device
xcodebuild -project "Flare Food.xcodeproj" -scheme "Flare Food" -sdk iphoneos -configuration Debug build
```

### Running Tests
```bash
# Run unit tests
xcodebuild test -project "Flare Food.xcodeproj" -scheme "Flare FoodTests" -destination 'platform=iOS Simulator,name=iPhone 15'

# Run UI tests
xcodebuild test -project "Flare Food.xcodeproj" -scheme "Flare FoodUITests" -destination 'platform=iOS Simulator,name=iPhone 15'

# Run tests with coverage
xcodebuild test -project "Flare Food.xcodeproj" -scheme "Flare Food" -destination 'platform=iOS Simulator,name=iPhone 15' -enableCodeCoverage YES
```

### Running the App
```bash
# Open in Xcode
open "Flare Food.xcodeproj"

# Run on iOS Simulator
xcodebuild -project "Flare Food.xcodeproj" -scheme "Flare Food" -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15' run
```

## Code Architecture

### Current Structure
1. **Flare_FoodApp.swift**: Main app entry point with SwiftData ModelContainer configuration
2. **ContentView.swift**: Basic list view (needs replacement with proper UI)
3. **Item.swift**: Placeholder model (needs replacement with proper data models)

### Required Data Models
- **Meal**: Photo, foods list, portions, meal type, timestamp
- **Food**: Name, category, common allergens/triggers
- **Symptom**: Type, severity (0-10), notes, medications, timestamp
- **Correlation**: Food-symptom statistical relationships

### Key Implementation Considerations
- **Performance**: Optimize for <30s meal logging
- **Offline-First**: CoreData with background sync to iCloud
- **Privacy**: Local data storage with optional cloud sync
- **Accessibility**: Large touch targets, VoiceOver support
- **Statistics Engine**: Implement correlation analysis for heat-map generation

### Testing Approach
The project uses Apple's Swift Testing framework with @Test macro syntax. Focus areas:
- Meal logging performance (<30s)
- Data persistence and sync
- Statistical correlation accuracy
- UI responsiveness and animations

## File Structure Guidelines

```
Flare Food/
├── Models/
│   ├── Meal.swift
│   ├── Food.swift
│   ├── Symptom.swift
│   └── Correlation.swift
├── Views/
│   ├── MealLogging/
│   ├── SymptomTracking/
│   ├── Analytics/
│   └── Settings/
├── ViewModels/
│   ├── MealLoggingViewModel.swift
│   ├── SymptomTrackingViewModel.swift
│   └── AnalyticsViewModel.swift
├── Services/
│   ├── DataService.swift
│   ├── StatisticsService.swift
│   ├── NotificationService.swift
│   └── ExportService.swift
├── Utilities/
│   └── Extensions/
└── Resources/
```