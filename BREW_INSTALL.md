# Installing ClipFlow with Homebrew

ClipFlow can be installed using Homebrew for a simple, clean installation process.

## Quick Install

```bash
# Add the ClipFlow tap
brew tap raslanismail87/clipboard https://github.com/raslanismail87/clipboard

# Install ClipFlow
brew install clipflow
```

## Manual Install Steps

If you prefer to install manually:

```bash
# 1. Add the custom tap
brew tap raslanismail87/clipboard https://github.com/raslanismail87/clipboard

# 2. Install ClipFlow
brew install clipflow

# 3. (Optional) Link to Applications folder
ln -sf "$(brew --prefix)/bin/ClipFlow.app" "/Applications/ClipFlow.app"
```

## First Launch

After installation:

1. **Launch ClipFlow**:
   ```bash
   open "$(brew --prefix)/bin/ClipFlow.app"
   ```

2. **Handle security dialog**:
   - Right-click the app → Select "Open"
   - Click "Open" in the security dialog

3. **Grant permissions**:
   - Allow accessibility permissions when prompted
   - This enables the auto-paste feature

## Updating

To update ClipFlow to the latest version:

```bash
brew update
brew upgrade clipflow
```

## Uninstalling

To remove ClipFlow:

```bash
brew uninstall clipflow
brew untap raslanismail87/clipboard
```

## Troubleshooting

### "clipflow" formula not found
Make sure you've added the tap first:
```bash
brew tap raslanismail87/clipboard https://github.com/raslanismail87/clipboard
```

### Permission denied errors
The app needs accessibility permissions:
1. Go to System Preferences → Security & Privacy → Privacy
2. Select "Accessibility" from the sidebar
3. Add ClipFlow and enable it

### App won't launch
For unsigned apps, you need to:
1. Right-click the app
2. Select "Open" from the context menu
3. Click "Open" in the security dialog

This bypasses Gatekeeper for trusted apps.

## Why Homebrew?

- **Clean installation**: No DMG mounting or manual dragging
- **Easy updates**: `brew upgrade clipflow`
- **Dependency management**: Automatically handles requirements
- **Uninstall tracking**: Complete removal with `brew uninstall`
- **Version management**: Switch between versions easily

## Support

For issues with the Homebrew installation:
- [GitHub Issues](https://github.com/raslanismail87/clipboard/issues)
- [ClipFlow Homepage](https://raslanismail87.github.io/clipboard/)