#!/bin/bash

# DMG Verification Script for ClipFlow

if [ -z "$1" ]; then
    echo "Usage: $0 <dmg-file>"
    echo "Example: $0 ClipFlow-1.1.1.dmg"
    exit 1
fi

DMG_FILE="$1"

if [ ! -f "$DMG_FILE" ]; then
    echo "❌ DMG file not found: $DMG_FILE"
    exit 1
fi

echo "🔍 Verifying DMG: $DMG_FILE"
echo ""

# Check file size
FILE_SIZE=$(ls -lh "$DMG_FILE" | awk '{print $5}')
echo "📦 File size: $FILE_SIZE"

# Check file type
FILE_TYPE=$(file "$DMG_FILE")
echo "📄 File type: $FILE_TYPE"

# Verify DMG integrity
echo ""
echo "🧪 Testing DMG integrity..."
if hdiutil verify "$DMG_FILE"; then
    echo "✅ DMG integrity: GOOD"
else
    echo "❌ DMG integrity: FAILED"
    exit 1
fi

# Try mounting DMG
echo ""
echo "🔌 Testing DMG mount..."
MOUNT_POINT=$(mktemp -d)
if hdiutil attach "$DMG_FILE" -mountpoint "$MOUNT_POINT" -nobrowse -quiet; then
    echo "✅ DMG mount: SUCCESS"
    
    # Check app bundle
    if [ -d "$MOUNT_POINT/ClipFlow.app" ]; then
        echo "✅ App bundle: FOUND"
        
        # Check app signature
        echo "🔐 Checking app signature..."
        codesign -vv "$MOUNT_POINT/ClipFlow.app" 2>&1 || echo "⚠️  App is not signed (expected for local builds)"
        
        # Check app info
        APP_VERSION=$(defaults read "$MOUNT_POINT/ClipFlow.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
        echo "📋 App version: $APP_VERSION"
        
    else
        echo "❌ App bundle: NOT FOUND"
    fi
    
    # Unmount
    hdiutil detach "$MOUNT_POINT" -quiet
    rmdir "$MOUNT_POINT"
    
else
    echo "❌ DMG mount: FAILED"
    rmdir "$MOUNT_POINT"
    exit 1
fi

echo ""
echo "✅ DMG verification completed successfully!"
echo ""
echo "💡 To install:"
echo "   1. Double-click the DMG file"
echo "   2. Drag ClipFlow to Applications folder"
echo "   3. Right-click ClipFlow in Applications and select 'Open'"
echo "   4. Click 'Open' in the security dialog"