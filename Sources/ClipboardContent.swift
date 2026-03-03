import Foundation
import AppKit

enum ClipboardContent: Equatable {
    case text(String)
    case link(URL)
    case image(Data)
    case file(URL)
    case color(hex: String)

    var previewText: String {
        switch self {
        case .text(let s): return s
        case .link(let u): return u.absoluteString
        case .image: return "Image"
        case .file(let u): return u.lastPathComponent
        case .color(let hex): return hex
        }
    }

    var itemType: ClipboardItemType {
        switch self {
        case .text: return .text
        case .link: return .link
        case .image: return .image
        case .file: return .file
        case .color: return .color
        }
    }

    static func == (lhs: ClipboardContent, rhs: ClipboardContent) -> Bool {
        switch (lhs, rhs) {
        case (.text(let a), .text(let b)): return a == b
        case (.link(let a), .link(let b)): return a == b
        case (.image(let a), .image(let b)): return a == b
        case (.file(let a), .file(let b)): return a == b
        case (.color(let a), .color(let b)): return a == b
        default: return false
        }
    }
}

enum ClipboardItemType: String, Codable {
    case text
    case link
    case image
    case file
    case color
}

enum ClipboardFilter: String, CaseIterable, Identifiable {
    case all, text, image, link, file, color, pinned

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "All"
        case .text: return "Text"
        case .image: return "Images"
        case .link: return "Links"
        case .file: return "Files"
        case .color: return "Colors"
        case .pinned: return "Pinned"
        }
    }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .text: return "text.alignleft"
        case .image: return "photo"
        case .link: return "link"
        case .file: return "doc"
        case .color: return "paintpalette"
        case .pinned: return "pin.fill"
        }
    }
}
