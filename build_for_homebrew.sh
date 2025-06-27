#!/bin/bash

# Homebrew-compatible build script for ClipFlow macOS app
# This avoids Swift Package Manager sandbox issues in Homebrew

APP_NAME="ClipFlow"
BUNDLE_ID="com.clipflow.app"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Building ClipFlow for Homebrew..."

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Compile Swift code directly without Package Manager
echo "Compiling Swift code with swiftc..."

# Find all Swift source files
SWIFT_FILES=""
for dir in "ClipFlow" "Sources"; do
    if [ -d "$dir" ]; then
        SWIFT_FILES="$SWIFT_FILES $(find "$dir" -name "*.swift" | tr '\n' ' ')"
    fi
done

# Trim whitespace
SWIFT_FILES=$(echo $SWIFT_FILES | xargs)

if [ -z "$SWIFT_FILES" ]; then
    echo "❌ No Swift source files found in ClipFlow/ or Sources/ directories"
    exit 1
fi

echo "Found Swift files: $SWIFT_FILES"

# Compile with swiftc directly
swiftc -o "$MACOS_DIR/ClipboardManager" \
    -module-name ClipboardManager \
    -target arm64-apple-macosx11.0 \
    -O \
    -import-objc-header ClipFlow/ClipFlow-Bridging-Header.h 2>/dev/null || \
swiftc -o "$MACOS_DIR/ClipboardManager" \
    -module-name ClipboardManager \
    -target arm64-apple-macosx11.0 \
    -O \
    $SWIFT_FILES

if [ $? -ne 0 ]; then
    echo "❌ Swift compilation failed"
    exit 1
fi

echo "✅ Swift compilation successful"

# Make executable
chmod +x "$MACOS_DIR/ClipboardManager"

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>ClipboardManager</string>
    <key>CFBundleIdentifier</key>
    <string>com.clipflow.app</string>
    <key>CFBundleName</key>
    <string>ClipFlow</string>
    <key>CFBundleDisplayName</key>
    <string>ClipFlow</string>
    <key>CFBundleVersion</key>
    <string>1.1.3</string>
    <key>CFBundleShortVersionString</key>
    <string>1.1.3</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
EOF

# Create entitlements file
cat > "$CONTENTS_DIR/ClipboardManager.entitlements" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
</dict>
</plist>
EOF

# Create simple app icon (if none exists)
mkdir -p "$RESOURCES_DIR/AppIcon.appiconset"

# Create a basic icon set description
cat > "$RESOURCES_DIR/AppIcon.appiconset/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "icon_16x16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_16x16@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_32x32@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128x128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_128x128@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_256x256@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_512x512@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create simple placeholder icons (using system iconutil if available)
if command -v sips >/dev/null 2>&1; then
    echo "Creating app icons..."
    # Create a simple colored square as placeholder
    for size in 16 32 128 256 512; do
        sips -s format png --setProperty pixelsWide $size --setProperty pixelsHigh $size \
             -s formatOptions high \
             /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns \
             --out "$RESOURCES_DIR/AppIcon.appiconset/icon_${size}x${size}.png" 2>/dev/null || touch "$RESOURCES_DIR/AppIcon.appiconset/icon_${size}x${size}.png"
        
        # Create @2x versions
        double_size=$((size * 2))
        sips -s format png --setProperty pixelsWide $double_size --setProperty pixelsHigh $double_size \
             -s formatOptions high \
             /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns \
             --out "$RESOURCES_DIR/AppIcon.appiconset/icon_${size}x${size}@2x.png" 2>/dev/null || touch "$RESOURCES_DIR/AppIcon.appiconset/icon_${size}x${size}@2x.png"
    done
else
    echo "Creating placeholder icons..."
    # Create empty placeholder files
    for size in 16 32 128 256 512; do
        touch "$RESOURCES_DIR/AppIcon.appiconset/icon_${size}x${size}.png"
        touch "$RESOURCES_DIR/AppIcon.appiconset/icon_${size}x${size}@2x.png"
    done
fi

# Create PkgInfo
echo "APPL????" > "$CONTENTS_DIR/PkgInfo"

echo "✅ App bundle created at: $APP_DIR"
echo "📦 Bundle structure:"
ls -la "$APP_DIR"
ls -la "$CONTENTS_DIR"
ls -la "$MACOS_DIR"

echo ""
echo "🎉 ClipFlow build completed successfully!"
echo "📍 App location: $APP_DIR"