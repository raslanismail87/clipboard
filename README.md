# ClipFlow

<div align="center">
  <img src="https://via.placeholder.com/120x120/667eea/ffffff?text=📋" alt="ClipFlow Logo" width="120" height="120">
  
  **A powerful, lightweight clipboard manager for macOS**
  
  [![Download](https://img.shields.io/badge/Download-v1.1.0-blue?style=for-the-badge)](https://github.com/raslanismail87/clipboard/raw/master/ClipFlow-1.1.0.dmg)
  [![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
  [![macOS](https://img.shields.io/badge/macOS-11.0+-orange?style=for-the-badge)](https://www.apple.com/macos/)
  
  [Download](https://raslanismail87.github.io/clipboard/) • [Features](#features) • [Installation](#installation) • [Usage](#usage)
</div>

## Overview

ClipFlow is a native macOS clipboard manager that keeps track of everything you copy, making it instantly accessible whenever you need it. Built with SwiftUI, it offers a clean, modern interface that feels right at home on your Mac.

## Features

### ⚡ **Lightning Fast**
- Instant access with `Cmd+Space` hotkey
- Native performance with SwiftUI
- Minimal memory footprint

### 🔒 **Privacy First**
- All data stays on your Mac
- No cloud sync or data collection
- Complete offline operation

### 🎨 **Native Design**
- Beautiful macOS-native interface
- Follows Apple's design guidelines
- Seamless integration with system appearance

### 📱 **Menu Bar Integration**
- Lives quietly in your menu bar
- Quick access without cluttering your workspace
- Smart popover interface

### 💾 **Persistent History**
- Clipboard history survives app restarts
- Automatic data persistence
- Configurable history limits

### ⌨️ **Keyboard Shortcuts**
- Fully controllable with keyboard
- Power user friendly
- Customizable hotkeys

### 🖱️ **Smart Interactions**
- Single click to copy
- Double-click to copy and paste automatically
- Search through clipboard history

## Installation

### Download from GitHub Pages
1. Visit [ClipFlow Download Page](https://raslanismail87.github.io/clipboard/)
2. Click "Download ClipFlow v1.1.0.dmg"
3. Open the downloaded DMG file
4. Drag ClipFlow to your Applications folder

### Build from Source
```bash
git clone https://github.com/raslanismail87/clipboard.git
cd clipboard
open ClipFlow.xcodeproj
```

## Usage

### Getting Started
1. Launch ClipFlow from Applications
2. Grant accessibility permissions when prompted
3. The app will appear in your menu bar
4. Start copying text, images, or files - they'll automatically appear in ClipFlow

### Keyboard Shortcuts
- `Cmd+Space` - Show/hide ClipFlow popover
- `Enter` - Copy selected item to clipboard
- `Double-click` - Copy and paste item automatically
- `Esc` - Close popover

### Search
Type in the search bar to filter your clipboard history. ClipFlow searches through all your copied content to help you find what you need quickly.

## System Requirements

- macOS 11.0 (Big Sur) or later
- Accessibility permissions (for auto-paste feature)

## Permissions

ClipFlow requires the following permissions:

### Accessibility Access
- **Purpose**: Enables the double-click to paste feature
- **Scope**: Only used for sending keyboard shortcuts (Cmd+V)
- **Privacy**: No data is collected or transmitted

To grant permissions:
1. Go to System Preferences > Security & Privacy > Privacy
2. Select "Accessibility" from the sidebar
3. Click the lock to make changes
4. Add ClipFlow to the list and check the box

## Architecture

ClipFlow is built with modern Swift technologies:

- **SwiftUI** - Native user interface
- **Combine** - Reactive programming
- **AppKit** - macOS system integration
- **Core Graphics** - Advanced clipboard handling

## Project Structure

```
ClipFlow/
├── ClipFlow/                 # Main app target
│   ├── ClipboardManager.swift
│   ├── ContentView.swift
│   ├── HeaderView.swift
│   └── ClipboardManagerApp.swift
├── Sources/                  # Shared source code
├── appstore_version/         # App Store variant
└── index.html               # GitHub Pages website
```

## Development

### Prerequisites
- Xcode 13.0 or later
- Swift 5.5 or later
- macOS 11.0 or later

### Building
1. Clone the repository
2. Open `ClipFlow.xcodeproj` in Xcode
3. Build and run (`Cmd+R`)

### Creating Release DMG
```bash
# Auto-increment version and build DMG
./build_dmg.sh

# Manual version management
./version.sh show              # Show current version
./version.sh set 2.0.0         # Set specific version
./version.sh major             # Increment major version
./version.sh minor             # Increment minor version
./version.sh patch             # Increment patch version
```

The build system automatically increments the patch version (e.g., 1.1.0 → 1.1.1) each time you run `build_dmg.sh`. Use the `version.sh` script for manual version control.

### Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Version History

### v1.1.0 (Latest)
- **UI Simplification**: Removed filter tabs for cleaner interface
- **Improved UX**: Streamlined design with just search and settings
- **Better Performance**: Optimized filtering logic
- **Enhanced Accessibility**: Improved double-click paste functionality

### v1.0.0
- Initial release
- Basic clipboard management
- Menu bar integration
- Search functionality
- Filter tabs (Today, Text, Image, Link)

## Troubleshooting

### App doesn't paste automatically
1. Ensure accessibility permissions are granted
2. Try restarting ClipFlow
3. Check System Preferences > Security & Privacy > Accessibility

### Clipboard history not persisting
1. Check app permissions
2. Ensure ClipFlow has write access to user directory
3. Try clearing and rebuilding history

### Performance issues
1. Clear old clipboard history
2. Restart the application
3. Check available disk space

## Support

- **Issues**: [GitHub Issues](https://github.com/raslanismail87/clipboard/issues)
- **Website**: [ClipFlow Homepage](https://raslanismail87.github.io/clipboard/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with ❤️ for the macOS community
- Inspired by the need for a simple, privacy-focused clipboard manager
- Thanks to all contributors and users

---

<div align="center">
  <strong>Made with ❤️ for macOS</strong>
  <br>
  <a href="https://raslanismail87.github.io/clipboard/">Download ClipFlow</a>
</div>