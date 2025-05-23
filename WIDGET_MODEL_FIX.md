# Fix Widget Model Errors

The widget is not finding the model types (Meal, Symptom, FluidEntry). You need to add these files to the widget target in Xcode:

## Steps to Fix:

1. **In Xcode, select these files one by one:**
   - `Flare Food/Models/Meal.swift`
   - `Flare Food/Models/Food.swift`
   - `Flare Food/Models/Symptom.swift`
   - `Flare Food/Models/FluidEntry.swift`
   - `Flare Food/Models/UserProfile.swift`
   - `Flare Food/Models/Correlation.swift`
   - `Flare Food/Utilities/ModelContainerConfig.swift`

2. **For each file:**
   - Select the file in the navigator
   - Open the File Inspector (right panel)
   - Look for "Target Membership"
   - Check the box next to "Flare Food WidgetExtension"

3. **Important: Also add these supporting files:**
   - Any file that defines `FoodItem` (if it exists separately)
   - Any file that defines `MealReminderTime` (if it exists separately)

## If FoodItem is inside Meal.swift:

The error might be because `FoodItem` is defined in the same file as `Meal`. Make sure the entire `Meal.swift` file is added to the widget target.

## Quick Check:

After adding all files, you should see in the File Inspector:
- ✓ Flare Food
- ✓ Flare Food WidgetExtension

Both should be checked for all model files.

## Clean and Build:

After adding all files:
1. Clean build folder: `Cmd + Shift + K`
2. Build the widget scheme

This should resolve all "Cannot find type in scope" errors.