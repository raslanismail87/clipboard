import Foundation
import AppKit

enum ContentDetector {
    private static let hexRegex = try! NSRegularExpression(
        pattern: "#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{3})\\b",
        options: []
    )
    private static let urlRegex = try! NSRegularExpression(
        pattern: "^https?://\\S+",
        options: .caseInsensitive
    )

    static func detectHexColor(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        guard let match = hexRegex.firstMatch(in: trimmed, range: range),
              match.range.length == trimmed.count else { return nil }
        return trimmed
    }

    static func isURL(_ string: String) -> Bool {
        let range = NSRange(string.startIndex..., in: string)
        return urlRegex.firstMatch(in: string, range: range) != nil
    }

    static func hexToRGB(_ hex: String) -> String? {
        guard let color = nsColor(from: hex) else { return nil }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return "rgb(\(Int(r*255)), \(Int(g*255)), \(Int(b*255)))"
    }

    static func hexToHSL(_ hex: String) -> String? {
        guard let color = nsColor(from: hex) else { return nil }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let max = Swift.max(r, g, b), min = Swift.min(r, g, b)
        let l = (max + min) / 2
        var h: CGFloat = 0, s: CGFloat = 0
        if max != min {
            let d = max - min
            s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
            switch max {
            case r: h = ((g - b) / d + (g < b ? 6 : 0)) / 6
            case g: h = ((b - r) / d + 2) / 6
            default: h = ((r - g) / d + 4) / 6
            }
        }
        return "hsl(\(Int(h*360)), \(Int(s*100))%, \(Int(l*100))%)"
    }

    static func nsColor(from hex: String) -> NSColor? {
        var raw = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        if raw.count == 3 {
            raw = raw.map { "\($0)\($0)" }.joined()
        }
        guard raw.count == 6, let value = UInt32(raw, radix: 16) else { return nil }
        return NSColor(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
