import Foundation
import AppKit

struct StorageMigration {
    private static let migrationKey = "didMigrateToSwiftData"
    private static let legacyKey = "clipboardHistory"

    static func migrateIfNeeded(into store: ClipboardStore) {
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }
        guard let data = UserDefaults.standard.data(forKey: legacyKey) else {
            UserDefaults.standard.set(true, forKey: migrationKey)
            return
        }
        guard let legacy = try? JSONDecoder().decode([LegacyClipboardItem].self, from: data) else {
            UserDefaults.standard.set(true, forKey: migrationKey)
            return
        }

        for old in legacy.reversed() {
            guard let item = convertLegacy(old) else { continue }
            store.insert(item)
        }

        UserDefaults.standard.removeObject(forKey: legacyKey)
        UserDefaults.standard.set(true, forKey: migrationKey)
    }

    private static func convertLegacy(_ old: LegacyClipboardItem) -> ClipboardItem? {
        let content: ClipboardContent
        switch old.type {
        case "text":
            content = .text(old.content)
        case "link":
            guard let url = URL(string: old.content) else { return nil }
            content = .link(url)
        case "file":
            content = .file(URL(fileURLWithPath: old.content))
        case "image":
            guard let data = Data(base64Encoded: old.content) else { return nil }
            content = .image(data)
        default:
            return nil
        }
        return ClipboardItem(
            content: content,
            timestamp: old.timestamp,
            sourceApp: old.sourceApp
        )
    }
}

private struct LegacyClipboardItem: Codable {
    let id: String
    let content: String
    let type: String
    let timestamp: Date
    let sourceApp: String?
}
