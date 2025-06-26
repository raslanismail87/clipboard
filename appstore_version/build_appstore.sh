#!/bin/bash

APP_NAME="ClipFlow"
BUILD_DIR="build_appstore"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Building ClipFlow for App Store..."

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Build with sandbox entitlements
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

# Copy executable
cp ".build/release/ClipboardManager" "$MACOS_DIR/"

# Copy Info.plist
cp "Info.plist" "$CONTENTS_DIR/"

# Copy sandboxed entitlements
cp "ClipFlow.entitlements" "$CONTENTS_DIR/"

# Generate app icons
swift generate_icon.swift

# Create PkgInfo
echo "APPL????" > "$CONTENTS_DIR/PkgInfo"

echo "✅ App Store version created at: $APP_DIR"
echo ""
echo "Next steps:"
echo "1. Open this project in Xcode"
echo "2. Configure signing with your Developer ID"
echo "3. Archive and upload to App Store Connect"
