import Foundation
import AppKit
import Combine

class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []
    @Published var searchText: String = ""
    @Published var selectedFilter: FilterType = .all
    
    private var pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = 0
    private var timer: Timer?
    private let persistenceManager = PersistenceManager()
    
    enum FilterType: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case text = "Text"
        case image = "Image"
        case link = "Link"
    }
    
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
    
    var filteredItems: [ClipboardItem] {
        var filtered = items
        
        switch selectedFilter {
        case .all:
            break
        case .today:
            let today = Calendar.current.startOfDay(for: Date())
            filtered = filtered.filter { $0.timestamp >= today }
        case .text:
            filtered = filtered.filter { $0.type == .text }
        case .image:
            filtered = filtered.filter { $0.type == .image }
        case .link:
            filtered = filtered.filter { $0.type == .link }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { item in
                item.preview.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    private func loadPersistedItems() {
        items = persistenceManager.loadClipboardItems()
    }
    
    private func saveItems() {
        persistenceManager.saveClipboardItems(items)
    }
}