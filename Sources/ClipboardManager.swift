import Foundation
import AppKit
import Combine
import CoreGraphics
import ApplicationServices

class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []
    @Published var searchText: String = ""
    
    private var pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = 0
    private var timer: Timer?
    private let persistenceManager = PersistenceManager()
    weak var menuBarManager: MenuBarManager?
    private var hasShownPermissionAlert = false
    private var cachedPermissionStatus: Bool?
    private var lastPermissionCheck: Date = Date(timeIntervalSince1970: 0)
    
    
    init() {
        loadPersistedItems()
        startMonitoring()
        loadInitialContent()
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkForClipboardChanges()
        }
    }
    
    private func loadInitialContent() {
        lastChangeCount = pasteboard.changeCount
        if let content = getClipboardContent() {
            items.insert(content, at: 0)
        }
    }
    
    private func checkForClipboardChanges() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        
        lastChangeCount = pasteboard.changeCount
        
        if let newItem = getClipboardContent() {
            DispatchQueue.main.async {
                if !self.items.contains(where: { self.areItemsEqual($0, newItem) }) {
                    self.items.insert(newItem, at: 0)
                    
                    if self.items.count > 100 {
                        self.items = Array(self.items.prefix(100))
                    }
                    
                    self.saveItems()
                }
            }
        }
    }
    
    private func getClipboardContent() -> ClipboardItem? {
        let sourceApp = NSWorkspace.shared.frontmostApplication?.localizedName
        
        if let string = pasteboard.string(forType: .string) {
            if isURL(string) {
                if let url = URL(string: string) {
                    return ClipboardItem(
                        content: url,
                        type: .link,
                        timestamp: Date(),
                        sourceApp: sourceApp
                    )
                }
            }
            return ClipboardItem(
                content: string,
                type: .text,
                timestamp: Date(),
                sourceApp: sourceApp
            )
        }
        
        if let image = pasteboard.readObjects(forClasses: [NSImage.self])?.first as? NSImage {
            return ClipboardItem(
                content: image,
                type: .image,
                timestamp: Date(),
                sourceApp: sourceApp
            )
        }
        
        if let fileURL = pasteboard.readObjects(forClasses: [NSURL.self])?.first as? URL {
            return ClipboardItem(
                content: fileURL,
                type: .file,
                timestamp: Date(),
                sourceApp: sourceApp
            )
        }
        
        return nil
    }
    
    private func isURL(_ string: String) -> Bool {
        let urlRegex = try! NSRegularExpression(pattern: "^https?://.*", options: .caseInsensitive)
        return urlRegex.firstMatch(in: string, range: NSRange(location: 0, length: string.count)) != nil
    }
    
    private func areItemsEqual(_ item1: ClipboardItem, _ item2: ClipboardItem) -> Bool {
        switch (item1.type, item2.type) {
        case (.text, .text), (.link, .link):
            return String(describing: item1.content) == String(describing: item2.content)
        default:
            return false
        }
    }
    
    func copyToClipboard(_ item: ClipboardItem) {
        pasteboard.clearContents()
        
        switch item.type {
        case .text:
            if let text = item.content as? String {
                pasteboard.setString(text, forType: .string)
            }
        case .link:
            if let url = item.content as? URL {
                pasteboard.setString(url.absoluteString, forType: .string)
            }
        case .image:
            if let image = item.content as? NSImage {
                pasteboard.writeObjects([image])
            }
        case .file:
            if let url = item.content as? URL {
                pasteboard.writeObjects([url as NSURL])
            }
        }
        
        lastChangeCount = pasteboard.changeCount
    }
    
    func copyAndPaste(_ item: ClipboardItem) {
        print("🔄 copyAndPaste called for item: \(item.preview)")
        
        // Check for accessibility permissions first
        guard checkAccessibilityPermissions() else {
            print("❌ Accessibility permissions not granted")
            return
        }
        
        print("✅ Accessibility permissions confirmed")
        
        // First copy to clipboard
        copyToClipboard(item)
        print("📋 Item copied to clipboard")
        
        // Hide the popover immediately
        menuBarManager?.hidePopover()
        print("🚫 Popover hidden")
        
        // Use AppleScript for more reliable automation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            print("⏰ Starting paste automation after delay")
            // Try direct AppleScript to frontmost app first
            let frontmostScript = """
                tell application "System Events"
                    tell process 1 where frontmost is true
                        keystroke "v" using command down
                    end tell
                end tell
            """
            
            if let scriptObject = NSAppleScript(source: frontmostScript) {
                var error: NSDictionary?
                scriptObject.executeAndReturnError(&error)
                
                if let error = error {
                    print("❌ Frontmost AppleScript error: \(error)")
                    // Try generic System Events approach
                    self.tryGenericAppleScript()
                } else {
                    print("✅ Paste executed successfully via frontmost AppleScript")
                }
            } else {
                print("❌ Failed to create frontmost AppleScript")
                // Fallback to CGEvent if AppleScript creation fails
                self.fallbackPaste()
            }
        }
    }
    
    private func fallbackPaste() {
        print("🔄 Attempting CGEvent fallback paste")
        guard checkCGEventPermissions() else {
            print("❌ CGEvent permissions not available")
            return
        }
        print("✅ CGEvent permissions confirmed")
        
        let source = CGEventSource(stateID: .combinedSessionState)
        
        if let vKeyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true),
           let vKeyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false) {
            
            // Set timestamps for Sequoia compatibility
            let timestamp = mach_absolute_time()
            vKeyDown.timestamp = timestamp
            vKeyUp.timestamp = timestamp + 1000000 // 1ms later
            
            vKeyDown.flags = .maskCommand
            vKeyUp.flags = .maskCommand
            
            vKeyDown.post(tap: .cghidEventTap)
            usleep(10000) // 10ms delay between events
            vKeyUp.post(tap: .cghidEventTap)
            print("✅ CGEvent Cmd+V sent successfully")
        }
    }
    
    var filteredItems: [ClipboardItem] {
        var filtered = items
        
        if !searchText.isEmpty {
            filtered = filtered.filter { item in
                item.preview.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    func clearHistory() {
        items.removeAll()
        persistenceManager.clearAllItems()
    }
    
    private func loadPersistedItems() {
        items = persistenceManager.loadClipboardItems()
    }
    
    private func saveItems() {
        persistenceManager.saveClipboardItems(items)
    }
    
    // MARK: - Permission Management
    
    private func checkAccessibilityPermissions() -> Bool {
        let now = Date()
        
        // Use cached result if check was recent (within 30 seconds)
        if let cached = cachedPermissionStatus,
           now.timeIntervalSince(lastPermissionCheck) < 30 {
            if !cached {
                requestAccessibilityPermissions()
            }
            return cached
        }
        
        // Perform fresh permission check
        let isTrusted = AXIsProcessTrusted()
        cachedPermissionStatus = isTrusted
        lastPermissionCheck = now
        
        if !isTrusted {
            requestAccessibilityPermissions()
        }
        
        return isTrusted
    }
    
    private func checkCGEventPermissions() -> Bool {
        let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
            callback: { _, _, event, _ in return Unmanaged.passRetained(event) },
            userInfo: nil
        )
        
        return eventTap != nil
    }
    
    private func requestAccessibilityPermissions() {
        guard !hasShownPermissionAlert else { return }
        
        hasShownPermissionAlert = true
        
        // Reset the flag after 5 minutes to allow showing again if needed
        DispatchQueue.main.asyncAfter(deadline: .now() + 300) {
            self.hasShownPermissionAlert = false
        }
        
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = "ClipFlow needs Accessibility permission to paste clipboard content automatically. Click 'Open Settings' to grant permission."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open Settings")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            
            if response == .alertFirstButtonReturn {
                self.openAccessibilitySettings()
            }
        }
    }
    
    private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    private func tryGenericAppleScript() {
        print("🔄 Trying generic AppleScript")
        let genericScript = """
            tell application "System Events"
                keystroke "v" using command down
            end tell
        """
        
        if let scriptObject = NSAppleScript(source: genericScript) {
            var error: NSDictionary?
            scriptObject.executeAndReturnError(&error)
            
            if let error = error {
                print("❌ Generic AppleScript error: \(error)")
                // Final fallback to CGEvent
                self.fallbackPaste()
            } else {
                print("✅ Paste executed successfully via generic AppleScript")
            }
        } else {
            print("❌ Failed to create generic AppleScript")
            // Final fallback to CGEvent
            self.fallbackPaste()
        }
    }
}