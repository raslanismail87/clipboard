#!/bin/bash

# Build DMG for ClipFlow macOS app

APP_NAME="ClipFlow"

# Auto-increment version
VERSION_FILE=".version"
if [ ! -f "$VERSION_FILE" ]; then
    echo "1.1.0" > "$VERSION_FILE"
fi

# Read current version
CURRENT_VERSION=$(cat "$VERSION_FILE")

# Parse version components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Increment patch version
PATCH=$((PATCH + 1))

# Create new version
VERSION="${MAJOR}.${MINOR}.${PATCH}"

# Save new version
echo "$VERSION" > "$VERSION_FILE"

# Update DMG name
DMG_NAME="${APP_NAME}-${VERSION}"

echo "🔄 Auto-incrementing version: $CURRENT_VERSION → $VERSION"
BUILD_DIR="build"
DMG_DIR="dmg_build"
BACKGROUND_IMG="dmg_background.png"

echo "Building ${APP_NAME} DMG installer..."

# Clean previous DMG builds
rm -rf "$DMG_DIR"
rm -f "${APP_NAME}"-*.dmg
echo "🧹 Cleaned old DMG files"

# First build the app if it doesn't exist
if [ ! -d "$BUILD_DIR/$APP_NAME.app" ]; then
    echo "App not found, building first..."
    ./build_app.sh
    if [ $? -ne 0 ]; then
        echo "❌ App build failed"
        exit 1
    fi
fi

# Create DMG staging directory
mkdir -p "$DMG_DIR"

# Copy app to DMG directory
echo "Copying app bundle..."
cp -R "$BUILD_DIR/$APP_NAME.app" "$DMG_DIR/"

# Remove quarantine and extended attributes from app bundle
echo "Cleaning app bundle attributes..."
xattr -cr "$DMG_DIR/$APP_NAME.app" 2>/dev/null || true

# Ensure proper permissions
chmod -R 755 "$DMG_DIR/$APP_NAME.app"

# Create Applications symlink for easy installation
ln -s /Applications "$DMG_DIR/Applications"

# Create a simple background image programmatically
cat > create_bg.py << 'EOF'
from PIL import Image, ImageDraw, ImageFont
import os

# Create a 600x400 background image
width, height = 600, 400
img = Image.new('RGB', (width, height), color='#f8f9fa')
draw = ImageDraw.Draw(img)

# Add gradient effect
for y in range(height):
    color_ratio = y / height
    r = int(248 + (102 - 248) * color_ratio)
    g = int(249 + (126 - 249) * color_ratio)
    b = int(250 + (234 - 250) * color_ratio)
    draw.line([(0, y), (width, y)], fill=(r, g, b))

# Add text instructions
try:
    font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 24)
    small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 16)
except:
    font = ImageFont.load_default()
    small_font = ImageFont.load_default()

draw.text((width//2, height//2 - 40), "Drag ClipFlow to Applications", 
          fill='#2c3e50', font=font, anchor='mm')
draw.text((width//2, height//2 + 20), "to install", 
          fill='#6c757d', font=small_font, anchor='mm')

img.save('dmg_background.png')
print("Background image created")
EOF

# Create background image (fallback if Python/PIL not available)
if command -v python3 &> /dev/null && python3 -c "import PIL" 2>/dev/null; then
    python3 create_bg.py
    rm create_bg.py
else
    echo "Creating simple background..."
    # Create a simple solid color background as fallback
    sips -s format png --setProperty pixelsWide 600 --setProperty pixelsHigh 400 -s formatOptions high /System/Library/CoreServices/DefaultDesktop.heic --out dmg_background.png 2>/dev/null || {
        # Ultimate fallback - create empty background
        touch dmg_background.png
    }
fi

# Copy background to DMG directory if it exists
if [ -f "dmg_background.png" ]; then
    cp dmg_background.png "$DMG_DIR/.background.png"
fi

# Create DMG
echo "Creating DMG..."
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_DIR" -ov -format UDZO "${DMG_NAME}.dmg"

# Remove quarantine attribute to prevent Gatekeeper issues
echo "Removing quarantine attributes..."
xattr -rc "${DMG_NAME}.dmg" 2>/dev/null || true

# Verify DMG integrity
echo "Verifying DMG integrity..."
hdiutil verify "${DMG_NAME}.dmg"

# Apply Gatekeeper fix
echo "Applying Gatekeeper compatibility fixes..."
./fix_gatekeeper.sh >/dev/null 2>&1 && echo "✅ Gatekeeper fixes applied" || echo "⚠️  Gatekeeper fix failed (DMG should still work)"

if [ $? -eq 0 ]; then
    echo "✅ DMG created successfully: ${DMG_NAME}.dmg"
    echo "🎯 Version: $VERSION"
    
    # Get DMG size
    DMG_SIZE=$(ls -lh "${DMG_NAME}.dmg" | awk '{print $5}')
    echo "📦 DMG size: $DMG_SIZE"
    
    echo ""
    echo "🚀 DMG ready for distribution!"
    echo "📋 File: ${DMG_NAME}.dmg"
    echo "🔢 Version: $VERSION"
    echo "👥 Users can simply download and drag ClipFlow.app to Applications"
    echo ""
    echo "💡 Next steps:"
    echo "   - Test the DMG installation"
    echo "   - Update GitHub Pages with new version"
    echo "   - Commit and push the new version"
    
    # Clean up
    rm -rf "$DMG_DIR"
    rm -f dmg_background.png
    rm -f create_bg.py 2>/dev/null
else
    echo "❌ DMG creation failed"
    exit 1
fi