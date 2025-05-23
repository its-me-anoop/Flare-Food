# Xcode Widget Setup - Step by Step

## Step 1: Add Widget Extension Target

1. **Open your project in Xcode**
   - Open `Flare Food.xcodeproj`

2. **Add new target**
   - Click on the project name (blue icon) in the navigator
   - Look at the TARGETS list
   - Click the **"+"** button at the bottom

3. **Select Widget Extension**
   - In the template chooser:
     - Platform: **iOS**
     - Search for: **"Widget"**
     - Select: **"Widget Extension"**
     - Click: **Next**

4. **Configure the widget**
   ```
   Product Name: Flare Food Widget
   Team: [Your Team]
   Organization Identifier: co.uk.flutterly
   Bundle Identifier: co.uk.flutterly.Flare-Food.Widget
   Include Configuration Intent: ☐ (UNCHECKED)
   Include Live Activity: ☐ (UNCHECKED)
   Project: Flare Food
   Embed in Application: Flare Food
   ```
   - Click **Finish**

## Step 2: Replace Auto-Generated Files

1. **Delete Xcode's generated files**
   - In the project navigator, find the new "Flare Food Widget" group
   - Select all files inside it
   - Press Delete key
   - Choose "Move to Trash"

2. **Add our widget files**
   - Right-click on "Flare Food Widget" group
   - Choose "Add Files to 'Flare Food'..."
   - Navigate to your project folder → "Flare Food Widget" folder
   - Select ALL files and folders inside
   - Options:
     - ✓ Copy items if needed (if not already in project)
     - ✓ Create groups
     - ✓ Flare Food Widget (target membership)
   - Click **Add**

## Step 3: Configure App Groups

### For Main App:
1. Select **"Flare Food"** target
2. Go to **"Signing & Capabilities"** tab
3. You should see "App Groups" capability
4. Make sure it shows: `group.co.uk.flutterly.flarefood`

### For Widget:
1. Select **"Flare Food Widget"** target
2. Go to **"Signing & Capabilities"** tab
3. Click **"+ Capability"**
4. Search and add **"App Groups"**
5. Click the **"+"** under App Groups
6. Add: `group.co.uk.flutterly.flarefood`
7. Make sure it's checked ✓

## Step 4: Add Model Files to Widget Target

You need to add these files to the widget target:

1. **Select each file below in Xcode:**
   - `Flare Food/Models/Meal.swift`
   - `Flare Food/Models/Food.swift`
   - `Flare Food/Models/Symptom.swift`
   - `Flare Food/Models/FluidEntry.swift`
   - `Flare Food/Models/UserProfile.swift`
   - `Flare Food/Models/Correlation.swift`
   - `Flare Food/Utilities/ModelContainerConfig.swift`

2. **For each file:**
   - Select the file
   - Open File Inspector (right panel)
   - Under "Target Membership"
   - Check ✓ **"Flare Food Widget"**

## Step 5: Fix Build Settings

1. Select **"Flare Food Widget"** target
2. Go to **"Build Settings"** tab
3. Search for: **"iOS Deployment Target"**
4. Set to: **18.4** (or match your main app)

## Step 6: Build and Test

1. **Clean and Build**
   - Press `Cmd + Shift + K` (Clean)
   - Press `Cmd + B` (Build)

2. **Run the main app first**
   - Select "Flare Food" scheme
   - Run on simulator
   - Add some test data (meals, symptoms)

3. **Test the widget**
   - Stop the app
   - Long press on home screen
   - Tap "+" button
   - Search "Flare Food"
   - You should see:
     - Test Widget (green checkmark)
     - Flare Food widgets (3 sizes)

## Troubleshooting Quick Checks

If widgets don't appear:

**Check 1: Build Succeeded?**
- Look for any red errors in Xcode
- Check the Issue Navigator (⌘5)

**Check 2: Correct Bundle ID?**
- Widget target → General → Bundle Identifier
- Should be: `co.uk.flutterly.Flare-Food.Widget`

**Check 3: Deployment Target?**
- Both targets should have same iOS deployment target

**Check 4: Entitlements?**
- Check both entitlement files exist
- Both should have the same App Group

**Check 5: Clean Install?**
```bash
# In Terminal:
rm -rf ~/Library/Developer/Xcode/DerivedData
```
- Delete app from simulator
- Rebuild everything

## Expected Result

After successful setup:
1. Main app runs normally
2. In widget gallery, you see:
   - "Test Widget" with green checkmark
   - "Flare Food" with 3 size options
3. Widgets show real data after using the app

## If Only Test Widget Works

If you see the Test Widget but not the main widgets:
- The model files aren't properly linked
- Re-check Step 4 carefully
- Make sure ModelContainerConfig.swift is added to widget target

## Need More Help?

1. Check Xcode console for specific errors
2. Look at the WIDGET_TROUBLESHOOTING.md file
3. Try building just the widget scheme directly