import Foundation
import AppKit

protocol ClipboardStoreProtocol {
    func fetchAll() -> [ClipboardItem]
    func insert(_ item: ClipboardItem)
    func update(_ item: ClipboardItem)
    func delete(_ item: ClipboardItem)
    func deleteExpiredBefore(_ date: Date)
    func clear()
}

final class ClipboardStore: ClipboardStoreProtocol {
    static let appSupportDirectory: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("com.clipflow.app", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    static let blobsDirectory: URL = {
        let dir = appSupportDirectory.appendingPathComponent("blobs", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private var historyFile: URL {
        Self.appSupportDirectory.appendingPathComponent("history.json")
    }

    func fetchAll() -> [ClipboardItem] {
        guard let data = try? Data(contentsOf: historyFile) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let records = (try? decoder.decode([StoredRecord].self, from: data)) ?? []
        return records.compactMap { toItem($0) }
    }

    func insert(_ item: ClipboardItem) {
        var records = loadRecords()
        records.insert(toRecord(item), at: 0)
        saveRecords(records)
    }

    func update(_ item: ClipboardItem) {
        var records = loadRecords()
        guard let idx = records.firstIndex(where: { $0.id == item.id.uuidString }) else { return }
        let isoFormatter = ISO8601DateFormatter()
        records[idx].isPinned = item.isPinned
        records[idx].editedContent = item.editedContent
        records[idx].pasteCount = item.pasteCount
        records[idx].lastUsedAt = item.lastUsedAt.map { isoFormatter.string(from: $0) }
        saveRecords(records)
    }

    func delete(_ item: ClipboardItem) {
        var records = loadRecords()
        if let idx = records.firstIndex(where: { $0.id == item.id.uuidString }) {
            let r = records[idx]
            if let blob = r.blobFileName {
                try? FileManager.default.removeItem(at: Self.blobsDirectory.appendingPathComponent(blob))
            }
            records.remove(at: idx)
        }
        saveRecords(records)
    }

    func deleteExpiredBefore(_ date: Date) {
        let isoFormatter = ISO8601DateFormatter()
        var records = loadRecords()
        records = records.filter { r in
            if r.isPinned { return true }
            guard let ts = isoFormatter.date(from: r.timestamp) else { return true }
            let keep = ts >= date
            if !keep, let blob = r.blobFileName {
                try? FileManager.default.removeItem(at: Self.blobsDirectory.appendingPathComponent(blob))
            }
            return keep
        }
        saveRecords(records)
    }

    func clear() {
        let records = loadRecords()
        for r in records {
            if let blob = r.blobFileName {
                try? FileManager.default.removeItem(at: Self.blobsDirectory.appendingPathComponent(blob))
            }
        }
        try? FileManager.default.removeItem(at: historyFile)
    }

    private func loadRecords() -> [StoredRecord] {
        guard let data = try? Data(contentsOf: historyFile) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([StoredRecord].self, from: data)) ?? []
    }

    private func saveRecords(_ records: [StoredRecord]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(records) {
            try? data.write(to: historyFile, options: .atomic)
        }
    }

    private func toRecord(_ item: ClipboardItem) -> StoredRecord {
        var textPayload: String?
        var blobFileName: String?

        switch item.content {
        case .text(let s): textPayload = s
        case .link(let u): textPayload = u.absoluteString
        case .color(let hex): textPayload = hex
        case .file(let u): textPayload = u.path
        case .image(let data):
            let fileName = "\(item.id.uuidString).png"
            let url = Self.blobsDirectory.appendingPathComponent(fileName)
            try? data.write(to: url, options: .atomic)
            blobFileName = fileName
        }

        let isoFormatter = ISO8601DateFormatter()
        return StoredRecord(
            id: item.id.uuidString,
            contentType: item.type.rawValue,
            textPayload: textPayload,
            blobFileName: blobFileName,
            timestamp: isoFormatter.string(from: item.timestamp),
            sourceApp: item.sourceApp,
            isPinned: item.isPinned,
            editedContent: item.editedContent,
            pasteCount: item.pasteCount,
            lastUsedAt: item.lastUsedAt.map { isoFormatter.string(from: $0) }
        )
    }

    private func toItem(_ record: StoredRecord) -> ClipboardItem? {
        guard let type = ClipboardItemType(rawValue: record.contentType) else { return nil }
        guard let id = UUID(uuidString: record.id) else { return nil }
        let isoFormatter = ISO8601DateFormatter()
        guard let timestamp = isoFormatter.date(from: record.timestamp) else { return nil }

        let content: ClipboardContent
        switch type {
        case .text:
            content = .text(record.textPayload ?? "")
        case .link:
            guard let raw = record.textPayload, let url = URL(string: raw) else { return nil }
            content = .link(url)
        case .color:
            content = .color(hex: record.textPayload ?? "")
        case .file:
            guard let path = record.textPayload else { return nil }
            content = .file(URL(fileURLWithPath: path))
        case .image:
            guard let fileName = record.blobFileName else { return nil }
            let url = Self.blobsDirectory.appendingPathComponent(fileName)
            guard let data = try? Data(contentsOf: url) else { return nil }
            content = .image(data)
        }

        return ClipboardItem(
            id: id,
            content: content,
            timestamp: timestamp,
            sourceApp: record.sourceApp,
            isPinned: record.isPinned,
            editedContent: record.editedContent,
            pasteCount: record.pasteCount,
            lastUsedAt: record.lastUsedAt.flatMap { isoFormatter.date(from: $0) }
        )
    }
}

private struct StoredRecord: Codable {
    var id: String
    var contentType: String
    var textPayload: String?
    var blobFileName: String?
    var timestamp: String
    var sourceApp: String?
    var isPinned: Bool
    var editedContent: String?
    var pasteCount: Int
    var lastUsedAt: String?
}
