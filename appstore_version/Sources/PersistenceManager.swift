import Foundation
import AppKit

class PersistenceManager {
    private let userDefaults = UserDefaults.standard
    private let clipboardHistoryKey = "clipboardHistory"
    
    func saveClipboardItems(_ items: [ClipboardItem]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let persistableItems = items.map { item in
            PersistableClipboardItem(
                id: item.id.uuidString,
                content: serializeContent(item.content, type: item.type),
                type: item.type.rawValue,
                timestamp: item.timestamp,
                sourceApp: item.sourceApp
            )
        }
        
        if let encoded = try? encoder.encode(persistableItems) {
            userDefaults.set(encoded, forKey: clipboardHistoryKey)
        }
    }
    
    func loadClipboardItems() -> [ClipboardItem] {
        guard let data = userDefaults.data(forKey: clipboardHistoryKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let persistableItems = try? decoder.decode([PersistableClipboardItem].self, from: data) else {
            return []
        }
        
        return persistableItems.compactMap { persistableItem in
            guard let id = UUID(uuidString: persistableItem.id),
                  let type = ClipboardItemType(rawValue: persistableItem.type),
                  let content = deserializeContent(persistableItem.content, type: type) else {
                return nil
            }
            
            return ClipboardItem(
                id: id,
                content: content,
                type: type,
                timestamp: persistableItem.timestamp,
                sourceApp: persistableItem.sourceApp
            )
        }
    }
    
    private func serializeContent(_ content: Any, type: ClipboardItemType) -> String {
        switch type {
        case .text:
            return content as? String ?? ""
        case .link:
            if let url = content as? URL {
                return url.absoluteString
            }
            return ""
        case .image:
            if let image = content as? NSImage,
               let tiffData = image.tiffRepresentation,
               let bitmapImage = NSBitmapImageRep(data: tiffData),
               let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                return pngData.base64EncodedString()
            }
            return ""
        case .file:
            if let url = content as? URL {
                return url.path
            }
            return ""
        }
    }
    
    private func deserializeContent(_ contentString: String, type: ClipboardItemType) -> Any? {
        switch type {
        case .text:
            return contentString
        case .link:
            return URL(string: contentString)
        case .image:
            guard let data = Data(base64Encoded: contentString) else { return nil }
            return NSImage(data: data)
        case .file:
            return URL(fileURLWithPath: contentString)
        }
    }
}

struct PersistableClipboardItem: Codable {
    let id: String
    let content: String
    let type: String
    let timestamp: Date
    let sourceApp: String?
}

extension ClipboardItemType: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: String) {
        switch rawValue {
        case "text": self = .text
        case "image": self = .image
        case "link": self = .link
        case "file": self = .file
        default: return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .text: return "text"
        case .image: return "image"
        case .link: return "link"
        case .file: return "file"
        }
    }
}