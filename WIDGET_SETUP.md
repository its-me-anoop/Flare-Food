# iOS Widget Setup Instructions

## Overview
The Flare Food iOS widgets have been created and are ready to be added to your Xcode project. The widgets display:
- **Small Widget**: Daily meal and symptom count
- **Medium Widget**: Recent meals with hydration stats
- **Large Widget**: Comprehensive daily summary

## Setup Steps in Xcode

### 1. Add Widget Extension Target
1. Open `Flare Food.xcodeproj` in Xcode
2. Select the project in the navigator
3. Click the "+" button at the bottom of the targets list
4. Choose "Widget Extension" from the iOS section
5. Name it "Flare Food Widget"
6. Language: Swift
7. Include Configuration Intent: NO (we're using App Intents)
8. Project: Flare Food
9. Embed in Application: Flare Food

### 2. Configure the Widget Target
1. Select the "Flare Food Widget" target
2. Under General tab:
   - Bundle Identifier: `co.uk.flutterly.Flare-Food.Widget`
   - Deployment Target: Match your main app (iOS 18.4)
3. Under Signing & Capabilities:
   - Add "App Groups" capability
   - Enable `group.co.uk.flutterly.flarefood`

### 3. Add Files to Widget Target
Add the following files to the widget target (check the target membership box):
- All files in `Flare Food Widget/` folder
- From main app, add these model files:
  - `Models/Meal.swift`
  - `Models/Food.swift`
  - `Models/FoodItem.swift` (if exists)
  - `Models/Symptom.swift`
  - `Models/FluidEntry.swift`
  - `Models/UserProfile.swift`
  - `Models/Correlation.swift`
  - `Utilities/ModelContainerConfig.swift`

### 4. Update Build Settings
1. Select the widget target
2. Go to Build Settings
3. Search for "App Groups"
4. Ensure the entitlements file path is set correctly

### 5. Build and Test
1. Select a simulator or device
2. Build the main app first
3. Run the widget extension
4. Add the widget from the home screen widget gallery

## Features

### Data Sharing
- Uses App Groups to share data between app and widget
- SwiftData container is shared via `ModelContainerConfig`
- Real-time updates every 30 minutes

### Widget Sizes
- **Small**: Quick glance at daily stats
- **Medium**: Recent meals and hydration
- **Large**: Full daily summary with meals and symptoms

### Styling
- Matches app's gradient design
- Supports dark mode
- Clean, modern interface

## Troubleshooting

### Widget Not Showing Data
1. Ensure App Groups is enabled on both targets
2. Check that the group identifier matches exactly
3. Build and run the main app first to create the shared database

### Build Errors
1. Make sure all required model files are added to widget target
2. Verify the widget's Info.plist is included
3. Check that entitlements files are properly configured

### Widget Not Appearing
1. Clean build folder (Cmd+Shift+K)
2. Delete app from device/simulator
3. Restart Xcode
4. Rebuild and reinstall

## Next Steps
1. Test widgets on different devices
2. Add widget to TestFlight builds
3. Consider adding interactive widgets with App Intents
4. Add widget screenshots for App Store