import Foundation

enum TextTransform: String, CaseIterable, Identifiable {
    case uppercase = "Uppercase"
    case lowercase = "Lowercase"
    case titleCase = "Title Case"
    case trimWhitespace = "Trim Whitespace"
    case collapseSpaces = "Collapse Spaces"
    case removeLineBreaks = "Remove Line Breaks"
    case base64Encode = "Base64 Encode"
    case base64Decode = "Base64 Decode"
    case urlEncode = "URL Encode"
    case urlDecode = "URL Decode"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .uppercase: return "textformat.characters"
        case .lowercase: return "textformat.characters"
        case .titleCase: return "textformat"
        case .trimWhitespace: return "text.badge.minus"
        case .collapseSpaces: return "arrow.compress.horizontal"
        case .removeLineBreaks: return "text.line.first.and.arrowtriangle.forward"
        case .base64Encode: return "lock.doc"
        case .base64Decode: return "lock.open.doc"
        case .urlEncode: return "link.badge.plus"
        case .urlDecode: return "link.badge.minus"
        }
    }

    func apply(to text: String) -> String? {
        switch self {
        case .uppercase:
            return text.uppercased()
        case .lowercase:
            return text.lowercased()
        case .titleCase:
            return text.capitalized
        case .trimWhitespace:
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        case .collapseSpaces:
            return text.components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }
                .joined(separator: " ")
        case .removeLineBreaks:
            return text.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
        case .base64Encode:
            return Data(text.utf8).base64EncodedString()
        case .base64Decode:
            guard let data = Data(base64Encoded: text),
                  let decoded = String(data: data, encoding: .utf8) else { return nil }
            return decoded
        case .urlEncode:
            return text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        case .urlDecode:
            return text.removingPercentEncoding
        }
    }
}

enum TextTransformService {
    static func wordCount(_ text: String) -> Int {
        text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }.count
    }

    static func charCount(_ text: String) -> Int {
        text.count
    }
}
