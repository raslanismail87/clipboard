import Foundation
import AppKit
import Combine
import CoreGraphics
import ApplicationServices

class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []
    @Published var searchText: String = ""
    @Published var activeFilter: ClipboardFilter = .all

    private var pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = 0
    private var timer: Timer?
    var store: ClipboardStore?
    weak var menuBarManager: MenuBarManager?
    let exclusionManager = AppExclusionManager()

    private var hasShownPermissionAlert = false
    private var cachedPermissionStatus: Bool?
    private var lastPermissionCheck: Date = Date(timeIntervalSince1970: 0)
    private var expireTimer: Timer?

    @UserDefault("maxClipboardItems", defaultValue: 100) private var maxItems: Int
    @UserDefault("autoExpireDays", defaultValue: 0) private var autoExpireDays: Int

    init() {}

    func setup(store: ClipboardStore) {
        self.store = store
        loadPersistedItems()
        startMonitoring()
        scheduleExpireTimer()
        runExpiry()
        lastChangeCount = pasteboard.changeCount
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForClipboardChanges()
        }
    }

    private func scheduleExpireTimer() {
        expireTimer?.invalidate()
        expireTimer = Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { [weak self] _ in
            self?.runExpiry()
        }
    }

    private func runExpiry() {
        guard autoExpireDays > 0 else { return }
        let cutoff = Date().addingTimeInterval(-Double(autoExpireDays) * 86400)
        store?.deleteExpiredBefore(cutoff)
        items.removeAll { !$0.isPinned && $0.timestamp < cutoff }
    }

    private func checkForClipboardChanges() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        if let newItem = getClipboardContent() {
            DispatchQueue.main.async {
                if !self.items.contains(where: { self.areItemsEqual($0, newItem) }) {
                    self.items.insert(newItem, at: 0)
                    if self.items.count > self.maxItems {
                        let toRemove = self.items.suffix(from: self.maxItems)
                            .filter { !$0.isPinned }
                        for item in toRemove {
                            self.store?.delete(item)
                        }
                        self.items = Array(self.items.prefix(self.maxItems))
                    }
                    self.store?.insert(newItem)
                }
            }
        }
    }

    private func getClipboardContent() -> ClipboardItem? {
        let frontApp = NSWorkspace.shared.frontmostApplication
        let sourceApp = frontApp?.localizedName
        if let bundleID = frontApp?.bundleIdentifier,
           exclusionManager.isExcluded(bundleID: bundleID) { return nil }

        if let string = pasteboard.string(forType: .string) {
            if ContentDetector.isURL(string), let url = URL(string: string) {
                return ClipboardItem(content: .link(url), sourceApp: sourceApp)
            }
            if let hex = ContentDetector.detectHexColor(string) {
                return ClipboardItem(content: .color(hex: hex), sourceApp: sourceApp)
            }
            return ClipboardItem(content: .text(string), sourceApp: sourceApp)
        }

        if let image = pasteboard.readObjects(forClasses: [NSImage.self])?.first as? NSImage,
           let tiff = image.tiffRepresentation,
           let rep = NSBitmapImageRep(data: tiff),
           let png = rep.representation(using: .png, properties: [:]) {
            return ClipboardItem(content: .image(png), sourceApp: sourceApp)
        }

        if let fileURL = pasteboard.readObjects(forClasses: [NSURL.self])?.first as? URL {
            return ClipboardItem(content: .file(fileURL), sourceApp: sourceApp)
        }

        return nil
    }

    private func areItemsEqual(_ item1: ClipboardItem, _ item2: ClipboardItem) -> Bool {
        item1.content == item2.content
    }

    func copyToClipboard(_ item: ClipboardItem) {
        pasteboard.clearContents()
        let text = item.effectiveText
        switch item.content {
        case .text:
            pasteboard.setString(text ?? "", forType: .string)
        case .link(let url):
            pasteboard.setString(url.absoluteString, forType: .string)
        case .color(let hex):
            pasteboard.setString(hex, forType: .string)
        case .image(let data):
            if let image = NSImage(data: data) {
                pasteboard.writeObjects([image])
            }
        case .file(let url):
            pasteboard.writeObjects([url as NSURL])
        }
        lastChangeCount = pasteboard.changeCount
        incrementPasteCount(for: item)
    }

    func copyAsPlainText(_ item: ClipboardItem) {
        guard let text = item.effectiveText else { return }
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        lastChangeCount = pasteboard.changeCount
    }

    func copyAndPaste(_ item: ClipboardItem) {
        guard checkAccessibilityPermissions() else { return }
        copyToClipboard(item)
        menuBarManager?.hidePopover()
        NSApp.hide(nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.fallbackPaste()
        }
    }

    func pin(_ item: ClipboardItem) {
        updateItem(id: item.id) { $0.isPinned = true }
    }

    func unpin(_ item: ClipboardItem) {
        updateItem(id: item.id) { $0.isPinned = false }
    }

    func delete(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        store?.delete(item)
    }

    func updateEditedContent(_ text: String?, for item: ClipboardItem) {
        updateItem(id: item.id) { $0.editedContent = text }
    }

    private func incrementPasteCount(for item: ClipboardItem) {
        updateItem(id: item.id) {
            $0.pasteCount += 1
            $0.lastUsedAt = Date()
        }
    }

    private func updateItem(id: UUID, mutation: (inout ClipboardItem) -> Void) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        mutation(&items[idx])
        store?.update(items[idx])
    }

    var filteredItems: [ClipboardItem] {
        var result = items

        switch activeFilter {
        case .all: break
        case .text: result = result.filter { $0.type == .text }
        case .image: result = result.filter { $0.type == .image }
        case .link: result = result.filter { $0.type == .link }
        case .file: result = result.filter { $0.type == .file }
        case .color: result = result.filter { $0.type == .color }
        case .pinned: result = result.filter { $0.isPinned }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.preview.localizedCaseInsensitiveContains(searchText) }
        }

        return result.sorted {
            if $0.isPinned != $1.isPinned { return $0.isPinned }
            return $0.timestamp > $1.timestamp
        }
    }

    func count(for filter: ClipboardFilter) -> Int {
        switch filter {
        case .all: return items.count
        case .text: return items.filter { $0.type == .text }.count
        case .image: return items.filter { $0.type == .image }.count
        case .link: return items.filter { $0.type == .link }.count
        case .file: return items.filter { $0.type == .file }.count
        case .color: return items.filter { $0.type == .color }.count
        case .pinned: return items.filter { $0.isPinned }.count
        }
    }

    func clearHistory() {
        items.removeAll()
        store?.clear()
    }

    private func loadPersistedItems() {
        items = store?.fetchAll() ?? []
    }

    // MARK: - Accessibility

    private func checkAccessibilityPermissions() -> Bool {
        let now = Date()
        if let cached = cachedPermissionStatus,
           now.timeIntervalSince(lastPermissionCheck) < 30 {
            if !cached { requestAccessibilityPermissions() }
            return cached
        }
        let trusted = AXIsProcessTrusted()
        cachedPermissionStatus = trusted
        lastPermissionCheck = now
        if !trusted { requestAccessibilityPermissions() }
        return trusted
    }

    private func requestAccessibilityPermissions() {
        guard !hasShownPermissionAlert else { return }
        hasShownPermissionAlert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 300) { self.hasShownPermissionAlert = false }
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = "ClipFlow needs Accessibility permission to paste clipboard content automatically."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open Settings")
            alert.addButton(withTitle: "Cancel")
            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
        }
    }

    private func fallbackPaste() {
        let source = CGEventSource(stateID: .combinedSessionState)
        if let down = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true),
           let up = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false) {
            down.flags = .maskCommand
            up.flags = .maskCommand
            down.post(tap: .cghidEventTap)
            usleep(10000)
            up.post(tap: .cghidEventTap)
        }
    }
}

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
