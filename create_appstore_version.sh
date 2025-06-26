#!/bin/bash

# Create App Store compatible version of ClipFlow

echo "Creating App Store compatible version..."

# Create new directory for App Store version
mkdir -p appstore_version/Sources

# Copy base files
cp -r Sources/* appstore_version/Sources/
cp Package.swift appstore_version/
cp Info.plist appstore_version/
cp generate_icon.swift appstore_version/

# Create sandboxed entitlements
cat > appstore_version/ClipFlow.entitlements << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.files.user-selected.read-only</key>
	<true/>
	<key>com.apple.security.network.client</key>
	<true/>
</dict>
</plist>
EOF

# Remove problematic code for App Store
echo "Removing App Store incompatible features..."

# Remove Carbon hotkey code
cat > appstore_version/Sources/HotkeyManager.swift << 'EOF'
import Foundation
import AppKit

class HotkeyManager: ObservableObject {
    private var onHotkeyPressed: (() -> Void)?
    
    init() {
        // App Store version: No global hotkeys allowed
        setupLocalHotkeys()
    }
    
    func setHotkeyAction(_ action: @escaping () -> Void) {
        onHotkeyPressed = action
    }
    
    private func setupLocalHotkeys() {
        // Use NSEvent.addLocalMonitorForEvents for when app is active
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command) && event.keyCode == 49 { // Cmd+Space
                self.onHotkeyPressed?()
                return nil // Consume the event
            }
            return event
        }
    }
}

extension NSApplication {
    func toggleWindow() {
        if let window = windows.first {
            if window.isVisible {
                window.orderOut(nil)
            } else {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}
EOF

# Simplify settings to remove AppleScript
cat > appstore_version/Sources/SettingsView.swift << 'EOF'
import SwiftUI

struct SettingsView: View {
    @AppStorage("maxClipboardItems") private var maxItems: Int = 100
    @AppStorage("showImagePreviews") private var showImagePreviews: Bool = true
    @AppStorage("clearHistoryOnQuit") private var clearHistoryOnQuit: Bool = false
    
    var body: some View {
        TabView {
            GeneralSettingsView(
                maxItems: $maxItems,
                clearHistoryOnQuit: $clearHistoryOnQuit
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }
            
            AppearanceSettingsView(
                showImagePreviews: $showImagePreviews
            )
            .tabItem {
                Label("Appearance", systemImage: "paintbrush")
            }
            
            AboutSettingsView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 350)
    }
}

struct GeneralSettingsView: View {
    @Binding var maxItems: Int
    @Binding var clearHistoryOnQuit: Bool
    
    var body: some View {
        Form {
            Section("Clipboard History") {
                HStack {
                    Text("Maximum items:")
                    Spacer()
                    TextField("", value: $maxItems, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
                
                Toggle("Clear history on quit", isOn: $clearHistoryOnQuit)
            }
            
            Section("Usage") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Click the menu bar icon to open ClipFlow")
                    Text("• Press Cmd+Space when ClipFlow window is active")
                    Text("• Click any item to copy it to clipboard")
                    Text("• Use search to find specific content")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct AppearanceSettingsView: View {
    @Binding var showImagePreviews: Bool
    
    var body: some View {
        Form {
            Section("Display") {
                Toggle("Show image previews", isOn: $showImagePreviews)
            }
            
            Section("Theme") {
                HStack {
                    Text("App theme:")
                    Spacer()
                    Text("System")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

struct AboutSettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("ClipFlow")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version 1.0")
                .foregroundColor(.secondary)
            
            Text("Effortless clipboard management with smart workflow")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack(spacing: 20) {
                Button("GitHub") {
                    if let url = URL(string: "https://github.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
                
                Button("Support") {
                    if let url = URL(string: "mailto:support@example.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
EOF

# Create App Store build script
cat > appstore_version/build_appstore.sh << 'EOF'
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
EOF

chmod +x appstore_version/build_appstore.sh

echo "✅ App Store version created in appstore_version/"
echo ""
echo "Key changes made:"
echo "• Enabled app sandbox"
echo "• Removed global hotkeys (Carbon framework)"
echo "• Removed AppleScript login item management"
echo "• Added local hotkey support (Cmd+Space when app is active)"
echo ""
echo "Next: Review appstore_version/ and submit via Xcode"