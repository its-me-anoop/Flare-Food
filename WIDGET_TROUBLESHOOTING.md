# Widget Troubleshooting Guide

## Common Issues and Solutions

### 1. Widget Extension Not Added to Project

**Steps to add Widget Extension in Xcode:**

1. Open `Flare Food.xcodeproj` in Xcode
2. Click on the project file in the navigator (the blue icon at the top)
3. Look at the bottom of the TARGETS list, click the "+" button
4. In the popup window:
   - Choose "iOS" platform
   - Search for "Widget Extension"
   - Select "Widget Extension" and click Next
5. Configure the widget:
   - Product Name: `Flare Food Widget`
   - Team: Your development team
   - Bundle Identifier: `co.uk.flutterly.Flare-Food.Widget`
   - Include Configuration Intent: **NO** (uncheck this)
   - Project: Flare Food
   - Embed in Application: Flare Food
6. Click Finish

### 2. Widget Files Not Recognized

After adding the extension, you need to:

1. **Delete the auto-generated files** that Xcode creates:
   - Select and delete all files inside the "Flare Food Widget" group that Xcode created
   - Choose "Move to Trash" when prompted

2. **Add the existing widget files**:
   - Right-click on "Flare Food Widget" group in Xcode
   - Choose "Add Files to 'Flare Food'"
   - Navigate to the "Flare Food Widget" folder on disk
   - Select all files and folders
   - Make sure "Flare Food Widget" is checked in target membership
   - Click Add

### 3. App Groups Not Configured

**For the Main App:**
1. Select the "Flare Food" target
2. Go to "Signing & Capabilities" tab
3. The App Groups capability should already be there
4. Make sure it shows `group.co.uk.flutterly.flarefood`

**For the Widget Extension:**
1. Select the "Flare Food Widget" target
2. Go to "Signing & Capabilities" tab
3. Click "+ Capability"
4. Add "App Groups"
5. Check the box for `group.co.uk.flutterly.flarefood`
6. If it's not there, click "+" and add it

### 4. Missing Model Files in Widget Target

The widget needs access to your data models:

1. In Xcode, select these files one by one:
   - `Models/Meal.swift`
   - `Models/Food.swift`
   - `Models/Symptom.swift`
   - `Models/FluidEntry.swift`
   - `Models/UserProfile.swift`
   - `Models/Correlation.swift`
   - `Utilities/ModelContainerConfig.swift`

2. For each file:
   - Look at the File Inspector (right panel)
   - Under "Target Membership"
   - Check the box for "Flare Food Widget"

### 5. Build Errors

If you see build errors:

**"No such module 'WidgetKit'"**
- Make sure you're building for iOS, not macOS
- Clean build folder: Cmd+Shift+K
- Close and reopen Xcode

**"Cannot find type 'Meal' in scope"**
- The model files aren't added to the widget target
- Follow step 4 above

**Provisioning/Signing errors**
- Select the widget target
- Go to Signing & Capabilities
- Make sure "Automatically manage signing" is checked
- Select your team

### 6. Widget Not Showing Up

After successful build:

1. **On Simulator:**
   - Long press on home screen
   - Tap "+" button in top left
   - Search for "Flare Food"
   - You should see your widgets

2. **If widgets don't appear:**
   - Delete the app from device/simulator
   - Clean build folder (Cmd+Shift+K)
   - Rebuild and install fresh
   - Restart the simulator/device

3. **Force widget refresh:**
   - Open the main app first
   - Log some data (meals/symptoms)
   - Wait a minute
   - Check widgets again

### 7. Widget Shows Placeholder Data

This means the widget is installed but can't access data:

1. **Check App Groups:**
   - Both targets must have the same App Group ID
   - The ID must match exactly: `group.co.uk.flutterly.flarefood`

2. **Check Data:**
   - Open the main app
   - Make sure you have logged some meals/symptoms
   - The widget only shows today's data

3. **Check ModelContainer:**
   - Ensure the main app is using `ModelContainerConfig.shared.container`
   - The app must write to the shared container

### 8. Step-by-Step Verification

Run through this checklist:

- [ ] Widget Extension target added to project
- [ ] All widget files added to the extension target
- [ ] App Groups enabled on both targets with same ID
- [ ] Model files added to widget target membership
- [ ] Entitlements files are correct
- [ ] Build succeeds without errors
- [ ] App installed on device/simulator
- [ ] Main app opened at least once
- [ ] Some data logged in main app
- [ ] Widget appears in widget gallery

### 9. Clean Install Process

If nothing works, try a clean install:

1. Delete app from device/simulator
2. In Xcode: Product → Clean Build Folder
3. Quit Xcode
4. Delete DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
5. Reopen Xcode
6. Build and run the main app first
7. Add some test data
8. Then try adding the widget

### 10. Console Debugging

To see widget logs:
1. Run the app on simulator
2. In Xcode: Window → Devices and Simulators
3. Select your simulator
4. Click "Open Console"
5. Filter by "Flare Food Widget"
6. Look for any error messages

## Still Having Issues?

If you're still having problems:

1. Check the widget's Info.plist is included
2. Verify the widget's entitlements file is included
3. Make sure iOS deployment target matches (18.4)
4. Try creating a simple test widget first to verify setup
5. Check Xcode console for specific error messages

The most common issue is forgetting to add the model files to the widget target membership. Double-check this first!