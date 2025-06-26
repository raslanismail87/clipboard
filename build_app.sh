#!/bin/bash

# Build script for ClipFlow macOS app

APP_NAME="ClipFlow"
BUNDLE_ID="com.clipflow.app"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Building ClipFlow..."

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Build the Swift executable
echo "Compiling Swift code..."
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

# Copy executable
cp ".build/release/ClipboardManager" "$MACOS_DIR/"

# Copy Info.plist
cp "Info.plist" "$CONTENTS_DIR/"

# Copy entitlements
cp "ClipboardManager.entitlements" "$CONTENTS_DIR/"

# Generate app icons
echo "Generating app icons..."
swift generate_icon.swift

# Create PkgInfo
echo "APPL????" > "$CONTENTS_DIR/PkgInfo"

echo "✅ App bundle created at: $APP_DIR"
echo ""
echo "To install and run:"
echo "1. Copy '$APP_NAME.app' to /Applications"
echo "2. Right-click and select 'Open' to bypass Gatekeeper"
echo "3. The app will appear in your menu bar"
echo "4. Use Cmd+Space to toggle the clipboard window"
echo ""
echo "Note: For distribution, you'll need to sign the app with:"
echo "codesign --deep --force --verify --verbose --sign 'Developer ID Application: Your Name' '$APP_NAME.app'"