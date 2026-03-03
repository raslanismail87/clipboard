#!/bin/bash
set -e

APP_NAME="ClipFlow"
BUILD_DIR="build"
STAGING_DIR="dmg_staging"

# Read version from Info.plist
VERSION=$(python3 -c "
import plistlib
with open('Info.plist','rb') as f:
    d = plistlib.load(f)
print(d.get('CFBundleShortVersionString','1.0'))
")
DMG_NAME="${APP_NAME}-${VERSION}"

echo "Building $DMG_NAME.dmg  (version $VERSION)"
echo ""

# ── 1. Build the .app ─────────────────────────────────────────────────────────
echo "Step 1/4  Building app bundle..."
bash "$(dirname "$0")/build_app.sh"
echo ""

# ── 2. Create staging directory ───────────────────────────────────────────────
echo "Step 2/4  Preparing DMG staging area..."
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

cp -R "$BUILD_DIR/$APP_NAME.app" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

# Strip any quarantine attributes from the copy
xattr -cr "$STAGING_DIR/$APP_NAME.app" 2>/dev/null || true

# ── 3. Create DMG ─────────────────────────────────────────────────────────────
echo "Step 3/4  Creating DMG..."
rm -f "${DMG_NAME}.dmg"

hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    "${DMG_NAME}.dmg"

# Strip quarantine from the DMG file itself
xattr -cr "${DMG_NAME}.dmg" 2>/dev/null || true

# ── 4. Verify ─────────────────────────────────────────────────────────────────
echo "Step 4/4  Verifying DMG..."
hdiutil verify "${DMG_NAME}.dmg"

# Quick mount/unmount test
MOUNT_POINT=$(hdiutil attach "${DMG_NAME}.dmg" -nobrowse -noverify | awk 'END{print $NF}')
if [ -d "$MOUNT_POINT/$APP_NAME.app" ] && [ -L "$MOUNT_POINT/Applications" ]; then
    echo "  Mount test: OK (app and Applications symlink present)"
else
    echo "  WARNING: mount test inconclusive"
fi
hdiutil detach "$MOUNT_POINT" -quiet

# Checksum
SHASUM=$(shasum -a 256 "${DMG_NAME}.dmg" | awk '{print $1}')
DMG_SIZE=$(ls -lh "${DMG_NAME}.dmg" | awk '{print $5}')

# Cleanup staging
rm -rf "$STAGING_DIR"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "────────────────────────────────────────────"
echo "  File    : ${DMG_NAME}.dmg"
echo "  Size    : $DMG_SIZE"
echo "  SHA-256 : $SHASUM"
echo "────────────────────────────────────────────"
echo ""
echo "Send ${DMG_NAME}.dmg to colleagues."
echo ""
echo "Installation instructions for recipients"
echo "(one-time, because the app is not notarized):"
echo ""
echo "  1. Open ${DMG_NAME}.dmg"
echo "  2. Drag ClipFlow into the Applications folder"
echo "  3. Eject the DMG"
echo "  4. In Applications, RIGHT-CLICK ClipFlow → Open"
echo "  5. Click 'Open' in the Gatekeeper dialog"
echo "  6. ClipFlow will appear in the menu bar (top-right)"
echo "  7. Press Option+Space to open the clipboard history"
echo ""
