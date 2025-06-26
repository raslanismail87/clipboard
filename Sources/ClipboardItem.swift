import Foundation
import AppKit

enum ClipboardItemType {
    case text
    case image
    case link
    case file
}

struct ClipboardItem: Identifiable, Equatable {
    let id: UUID
    let content: Any
    let type: ClipboardItemType
    let timestamp: Date
    let sourceApp: String?
    
    init(content: Any, type: ClipboardItemType, timestamp: Date, sourceApp: String?) {
        self.id = UUID()
        self.content = content
        self.type = type
        self.timestamp = timestamp
        self.sourceApp = sourceApp
    }
    
    init(id: UUID, content: Any, type: ClipboardItemType, timestamp: Date, sourceApp: String?) {
        self.id = id
        self.content = content
        self.type = type
        self.timestamp = timestamp
        self.sourceApp = sourceApp
    }
    
    var preview: String {
        switch type {
        case .text:
            if let text = content as? String {
                return String(text.prefix(100))
            }
        case .link:
            if let url = content as? URL {
                return url.absoluteString
            }
        case .image:
            return "Image"
        case .file:
            if let url = content as? URL {
                return url.lastPathComponent
            }
        }
        return "Unknown content"
    }
    
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        return lhs.id == rhs.id
    }
}