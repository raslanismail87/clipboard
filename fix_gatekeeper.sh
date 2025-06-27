#!/bin/bash

# Fix Gatekeeper issues for ClipFlow DMG

echo "🔧 ClipFlow Gatekeeper Fix"
echo "This script helps resolve 'app is damaged' errors on macOS"
echo ""

# Find the latest DMG
DMG_FILE=$(ls -t ClipFlow-*.dmg 2>/dev/null | head -1)

if [ -z "$DMG_FILE" ]; then
    echo "❌ No ClipFlow DMG file found"
    echo "Please run ./build_dmg.sh first"
    exit 1
fi

echo "🎯 Working with: $DMG_FILE"
echo ""

# Method 1: Remove quarantine attributes completely
echo "📋 Method 1: Removing quarantine attributes..."
xattr -d com.apple.quarantine "$DMG_FILE" 2>/dev/null && echo "✅ Quarantine removed from DMG" || echo "ℹ️  No quarantine found on DMG"

# Method 2: Create a new DMG with no quarantine
echo ""
echo "📋 Method 2: Creating clean DMG..."

# Extract version from filename
VERSION=$(echo "$DMG_FILE" | sed 's/ClipFlow-\(.*\)\.dmg/\1/')
CLEAN_DMG="ClipFlow-${VERSION}-clean.dmg"

# Mount original DMG
MOUNT_POINT=$(mktemp -d)
echo "Mounting original DMG..."
if hdiutil attach "$DMG_FILE" -mountpoint "$MOUNT_POINT" -nobrowse -quiet; then
    
    # Copy app and clean it
    TEMP_DIR=$(mktemp -d)
    echo "Cleaning app bundle..."
    cp -R "$MOUNT_POINT/ClipFlow.app" "$TEMP_DIR/"
    cp -R "$MOUNT_POINT/Applications" "$TEMP_DIR/" 2>/dev/null || ln -s /Applications "$TEMP_DIR/Applications"
    
    # Remove all extended attributes recursively
    xattr -cr "$TEMP_DIR/ClipFlow.app" 2>/dev/null || true
    find "$TEMP_DIR/ClipFlow.app" -exec xattr -c {} \; 2>/dev/null || true
    
    # Ensure proper permissions
    chmod -R 755 "$TEMP_DIR/ClipFlow.app"
    
    # Unmount original
    hdiutil detach "$MOUNT_POINT" -quiet
    rmdir "$MOUNT_POINT"
    
    # Create new clean DMG
    echo "Creating clean DMG..."
    hdiutil create -volname "ClipFlow" -srcfolder "$TEMP_DIR" -ov -format UDZO "$CLEAN_DMG"
    
    # Remove quarantine from new DMG
    xattr -c "$CLEAN_DMG" 2>/dev/null || true
    
    # Clean up
    rm -rf "$TEMP_DIR"
    
    if [ -f "$CLEAN_DMG" ]; then
        echo "✅ Clean DMG created: $CLEAN_DMG"
        
        # Replace original with clean version
        mv "$CLEAN_DMG" "$DMG_FILE"
        echo "✅ Original DMG replaced with clean version"
        
        # Verify the new DMG
        echo ""
        echo "🧪 Verifying clean DMG..."
        if hdiutil verify "$DMG_FILE" >/dev/null 2>&1; then
            echo "✅ DMG verification: PASSED"
        else
            echo "❌ DMG verification: FAILED"
        fi
        
    else
        echo "❌ Failed to create clean DMG"
        exit 1
    fi
    
else
    echo "❌ Failed to mount original DMG"
    rmdir "$MOUNT_POINT"
    exit 1
fi

echo ""
echo "🎉 Gatekeeper fix completed!"
echo ""
echo "📱 Installation instructions for users:"
echo "1. Download the DMG file"
echo "2. If you get 'damaged' error, try these steps:"
echo "   • Right-click the DMG → Open"
echo "   • Or run: xattr -c ClipFlow-*.dmg"
echo "3. Drag ClipFlow to Applications"
echo "4. Right-click ClipFlow in Applications → Open"
echo "5. Click 'Open' in the security dialog"
echo ""
echo "🔒 This is normal for unsigned apps. ClipFlow is safe to use."