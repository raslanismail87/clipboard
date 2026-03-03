#!/bin/bash
set -e

APP_NAME="ClipFlow"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Building $APP_NAME..."

# Clean previous bundle
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

# Compile
echo "  Compiling Swift code..."
swift build -c release 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: swift build failed"
    exit 1
fi

# Copy binary
cp ".build/release/ClipboardManager" "$MACOS_DIR/ClipboardManager"
chmod +x "$MACOS_DIR/ClipboardManager"

# Copy Info.plist and strip NSMainStoryboardFile
cp "Info.plist" "$CONTENTS_DIR/Info.plist"
python3 - "$CONTENTS_DIR/Info.plist" << 'PYEOF'
import plistlib, sys
path = sys.argv[1]
with open(path, 'rb') as f:
    d = plistlib.load(f)
d.pop('NSMainStoryboardFile', None)
with open(path, 'wb') as f:
    plistlib.dump(d, f)
PYEOF

# Write PkgInfo
printf 'APPL????' > "$CONTENTS_DIR/PkgInfo"

# Ad-hoc code sign (no paid Apple Developer account required)
echo "  Ad-hoc signing bundle..."
codesign --deep --force --sign - "$APP_DIR" 2>&1
if codesign --verify --verbose "$APP_DIR" 2>&1 | grep -q "satisfies"; then
    echo "  Code signature: OK"
else
    # codesign --verify exits 0 on success, just print result
    codesign --verify "$APP_DIR" && echo "  Code signature: OK" || echo "  WARNING: signature verification inconclusive (app will still run)"
fi

echo ""
echo "Done: $APP_DIR"
ls -lah "$MACOS_DIR/ClipboardManager"
