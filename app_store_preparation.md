# ClipFlow - App Store Deployment Guide

## Prerequisites
1. Apple Developer Account ($99/year)
2. Xcode with latest version
3. Valid Developer Certificate
4. App Store Connect access

## Required Changes for App Store

### 1. Sandbox Compatibility
The app needs to be sandboxed for App Store submission:

```xml
<!-- ClipboardManager.entitlements -->
<key>com.apple.security.app-sandbox</key>
<true/>
```

### 2. Remove Restricted Features
- Global hotkeys (Carbon framework) - Not allowed in sandbox
- AppleScript for login items - Restricted
- Direct clipboard monitoring - May need entitlements

### 3. Privacy Descriptions Required
Add to Info.plist:
```xml
<key>NSAppleEventsUsageDescription</key>
<string>ClipFlow needs AppleScript access to manage startup preferences.</string>
```

### 4. App Store Metadata Needed
- App description (4000 characters max)
- Keywords (100 characters max) 
- Screenshots (multiple sizes required)
- App icon (1024x1024px)
- Privacy policy URL
- Support URL

## Step-by-Step Submission Process

### Phase 1: Prepare App
1. Update entitlements for sandbox
2. Remove Carbon/global hotkey code
3. Test thoroughly in sandbox mode
4. Create App Store screenshots
5. Prepare marketing materials

### Phase 2: App Store Connect
1. Create new app entry
2. Upload app metadata
3. Set pricing (free/paid)
4. Configure app information
5. Upload screenshots

### Phase 3: Code Signing & Upload
1. Create distribution certificate
2. Create App Store provisioning profile
3. Archive app in Xcode
4. Upload via Xcode or Transporter
5. Submit for review

### Phase 4: Review Process
- Initial review: 24-48 hours
- Full review: 1-7 days
- Address any rejection feedback
- Resubmit if necessary

## Alternative: Direct Distribution
Instead of App Store, consider:
- Notarized DMG distribution
- GitHub releases
- Personal website distribution
- Third-party app stores (Setapp, etc.)

## Files Needed for Submission
- App binary (sandboxed version)
- 1024x1024 app icon
- Screenshots (various sizes)
- App description & keywords
- Privacy policy
- Support documentation