import Foundation
import AppKit

struct ClipboardItem: Identifiable, Equatable {
    let id: UUID
    var content: ClipboardContent
    let timestamp: Date
    let sourceApp: String?
    var isPinned: Bool
    var editedContent: String?
    var pasteCount: Int
    var lastUsedAt: Date?

    init(
        id: UUID = UUID(),
        content: ClipboardContent,
        timestamp: Date = Date(),
        sourceApp: String? = nil,
        isPinned: Bool = false,
        editedContent: String? = nil,
        pasteCount: Int = 0,
        lastUsedAt: Date? = nil
    ) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
        self.sourceApp = sourceApp
        self.isPinned = isPinned
        self.editedContent = editedContent
        self.pasteCount = pasteCount
        self.lastUsedAt = lastUsedAt
    }

    var type: ClipboardItemType { content.itemType }

    var effectiveText: String? {
        if let edited = editedContent { return edited }
        switch content {
        case .text(let s): return s
        case .link(let u): return u.absoluteString
        case .color(let hex): return hex
        default: return nil
        }
    }

    var preview: String {
        if let edited = editedContent { return String(edited.prefix(200)) }
        switch content {
        case .text(let s): return String(s.prefix(200))
        case .link(let u): return u.absoluteString
        case .image: return "Image"
        case .file(let u): return u.lastPathComponent
        case .color(let hex): return hex
        }
    }

    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.id == rhs.id
    }
}
