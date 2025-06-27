# ClipFlow Double-Click Paste Debugging Guide

## Problem Summary
The user reports that double-click paste functionality is not working despite having granted accessibility permissions.

## Changes Made

### 1. Fixed Build Configuration Issue
- **Problem**: The Xcode project was using files from `ClipFlow/` directory, but the working implementation was in `Sources/` directory
- **Solution**: Updated all files in `ClipFlow/` directory to match the `Sources/` implementation

### 2. Added Comprehensive Logging
Added detailed logging throughout the paste execution chain:

- 🔥 `copyAndPaste` method entry
- ✅/❌ Accessibility permission status
- 📋 Clipboard copy operation
- 📱 Popover hiding
- ⏰ Paste automation timing
- 📜 AppleScript execution
- 🔧 CGEvent fallback attempts
- ⌨️ Key event posting
- 🖱️ Double-click gesture detection
- 🔍 Permission status checks

### 3. Enhanced Permission Handling
- Added caching for permission checks
- Added debug function for permission status
- Enhanced error reporting for AppleScript failures
- Added CGEvent fallback with proper timestamps

## Testing Instructions

### 1. Install the Updated App
```bash
# Build the app
./build_app.sh

# Copy to Applications (if not already done)
cp -r build/ClipFlow.app /Applications/

# Launch the app
open /Applications/ClipFlow.app
```

### 2. Monitor Debug Logs
In Terminal, run the debug monitoring script:
```bash
./debug_logs.sh
```

### 3. Test Double-Click Functionality
1. Open the ClipFlow app (Cmd+Space if hotkey is set)
2. Double-click on any clipboard item
3. Check the debug output in the monitoring terminal

### 4. Expected Debug Output Flow
For successful double-click paste:
```
🖱️ Double-click detected on item: [item preview]
🔥 copyAndPaste called with item: [item preview]
🔍 Current accessibility permission status: true
🔍 CGEvent permissions status: true
✅ Accessibility permissions granted
📋 Item copied to clipboard
📱 Popover hidden
⏰ Executing paste automation after delay
📜 Executing frontmost AppleScript
✅ Paste executed successfully via frontmost AppleScript
```

## Troubleshooting

### If Double-Click Not Detected
- Look for: `🖱️ Double-click detected on item:`
- **Issue**: UI gesture recognition problem
- **Solution**: Check SwiftUI gesture conflicts

### If Accessibility Permissions Denied
- Look for: `❌ Accessibility permissions not granted`
- **Solution**: Re-grant accessibility permissions in System Preferences

### If AppleScript Fails
- Look for: `❌ Frontmost AppleScript error:` followed by error details
- **Common errors**:
  - `-1743`: AppleScript execution timeout
  - `-1708`: Process not found
- **Solution**: App will try generic AppleScript then CGEvent fallback

### If CGEvent Fallback Fails
- Look for: `❌ CGEvent permissions not available`
- **Issue**: System security restrictions
- **Solution**: May need to add CGEvent-specific entitlements

## Automation Methods Used

### 1. Primary: Frontmost Process AppleScript
```applescript
tell application "System Events"
    tell process 1 where frontmost is true
        keystroke "v" using command down
    end tell
end tell
```

### 2. Fallback: Generic AppleScript
```applescript
tell application "System Events"
    keystroke "v" using command down
end tell
```

### 3. Final Fallback: CGEvent
Direct keyboard event injection using Core Graphics Event framework.

## Additional Debugging

### Console App Method
1. Open Console.app
2. Filter for "ClipFlow" in the search bar
3. Look for the emoji-prefixed debug messages

### Manual Permission Check
The app includes a debug function that checks permissions on startup:
- Wait 1 second after app launch
- Check console for permission status messages

## Files Modified
- `/ClipFlow/ClipboardManager.swift`: Added `copyAndPaste` method and permission handling
- `/ClipFlow/ContentView.swift`: Added double-click gesture with logging
- `/ClipFlow/ClipboardManagerApp.swift`: Added permission debug check on startup
- `debug_logs.sh`: Log monitoring script
- `DEBUGGING_GUIDE.md`: This guide

## Next Steps
1. Run the debug monitoring script
2. Test double-click functionality
3. Analyze the debug output to identify where the process fails
4. Report specific error messages for further troubleshooting