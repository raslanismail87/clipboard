import SwiftUI
import AppKit

struct ClipboardItemView: View {
    let item: ClipboardItem
    let isSelected: Bool
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var isHovered = false
    @State private var isEditing = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            mainCard
            if isHovered { actionButtons }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: .black.opacity(isHovered ? 0.15 : 0.05),
                radius: isHovered ? 6 : 3, x: 0, y: isHovered ? 3 : 1)
        .scaleEffect(isHovered ? 1.005 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
        .onHover { isHovered = $0 }
        .contextMenu { contextMenuItems }
        .sheet(isPresented: $isEditing) {
            InlineEditView(item: item, isPresented: $isEditing)
                .environmentObject(clipboardManager)
        }
    }

    private var borderColor: Color {
        if isSelected { return .accentColor }
        if isHovered { return Color.accentColor.opacity(0.3) }
        return Color.clear
    }

    private var mainCard: some View {
        HStack(alignment: .top, spacing: 14) {
            AppIconView(appName: item.sourceApp)
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    ContentPreview(item: item)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        TimeStampView(date: item.timestamp)
                        if item.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.accentColor)
                        }
                        if item.editedContent != nil {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                if let sourceApp = item.sourceApp {
                    Text(sourceApp)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isSelected ? Color.accentColor.opacity(0.08) : Color(NSColor.windowBackgroundColor).opacity(0.01))
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        )
    }

    private var actionButtons: some View {
        HStack(spacing: 4) {
            Button { clipboardManager.pin(item) } label: {
                Image(systemName: item.isPinned ? "pin.slash.fill" : "pin.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(item.isPinned ? .accentColor : .secondary)
            }
            .buttonStyle(ActionButtonStyle())
            .help(item.isPinned ? "Unpin" : "Pin")

            Button { clipboardManager.delete(item) } label: {
                Image(systemName: "trash.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.red.opacity(0.8))
            }
            .buttonStyle(ActionButtonStyle())
            .help("Delete")
        }
        .padding(8)
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }

    @ViewBuilder
    private var contextMenuItems: some View {
        Button("Copy") { clipboardManager.copyToClipboard(item) }
        Button("Copy as Plain Text") { clipboardManager.copyAsPlainText(item) }
        Button("Paste") { clipboardManager.copyAndPaste(item) }
        Divider()
        Button("Edit") { isEditing = true }
        if item.isPinned {
            Button("Unpin") { clipboardManager.unpin(item) }
        } else {
            Button("Pin") { clipboardManager.pin(item) }
        }
        if item.editedContent != nil {
            Button("Reset to Original") { clipboardManager.updateEditedContent(nil, for: item) }
        }
        Divider()
        if case .color(let hex) = item.content {
            Menu("Copy Color As") {
                Button("Hex (\(hex))") { copyString(hex) }
                if let rgb = ContentDetector.hexToRGB(hex) {
                    Button("RGB (\(rgb))") { copyString(rgb) }
                }
                if let hsl = ContentDetector.hexToHSL(hex) {
                    Button("HSL (\(hsl))") { copyString(hsl) }
                }
            }
            Divider()
        }
        if let text = item.effectiveText, !text.isEmpty {
            Menu("Text Transforms") {
                let words = TextTransformService.wordCount(text)
                let chars = TextTransformService.charCount(text)
                Text("\(words) words, \(chars) chars").foregroundColor(.secondary)
                Divider()
                ForEach(TextTransform.allCases) { transform in
                    Button(transform.rawValue) {
                        applyTransform(transform, to: text)
                    }
                }
            }
        }
        Divider()
        Button("Delete", role: .destructive) { clipboardManager.delete(item) }
    }

    private func copyString(_ string: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
    }

    private func applyTransform(_ transform: TextTransform, to text: String) {
        guard let result = transform.apply(to: text) else { return }
        let newItem = ClipboardItem(content: .text(result), sourceApp: "ClipFlow")
        clipboardManager.items.insert(newItem, at: 0)
        clipboardManager.store?.insert(newItem)
        copyString(result)
    }
}

struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(5)
            .background(Circle().fill(.regularMaterial).opacity(configuration.isPressed ? 0.7 : 1))
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
    }
}

struct AppIconView: View {
    let appName: String?

    var body: some View {
        Group {
            if let name = appName, let icon = getAppIcon(for: name) {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
            } else {
                RoundedRectangle(cornerRadius: 7)
                    .fill(LinearGradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.3)],
                                        startPoint: .top, endPoint: .bottom))
                    .frame(width: 28, height: 28)
                    .overlay(Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
    }

    private func getAppIcon(for appName: String) -> NSImage? {
        NSWorkspace.shared.runningApplications
            .first { $0.localizedName == appName }?.icon
    }
}

struct ContentPreview: View {
    let item: ClipboardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 6) {
                if case .color(let hex) = item.content {
                    ColorSwatch(hex: hex)
                } else {
                    TypeIcon(type: item.type)
                }
                Text(item.preview)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            if case .image(let data) = item.content, let image = NSImage(data: data) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 200, maxHeight: 100)
                    .cornerRadius(8)
                    .padding(.top, 4)
            }
        }
    }
}

struct ColorSwatch: View {
    let hex: String
    var body: some View {
        if let color = ContentDetector.nsColor(from: hex) {
            Circle()
                .fill(Color(nsColor: color))
                .frame(width: 18, height: 18)
                .overlay(Circle().stroke(Color.primary.opacity(0.15), lineWidth: 1))
        }
    }
}

struct TypeIcon: View {
    let type: ClipboardItemType
    var body: some View {
        Group {
            switch type {
            case .text:
                Image(systemName: "textformat")
                    .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
            case .image:
                Image(systemName: "photo")
                    .foregroundStyle(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
            case .link:
                Image(systemName: "link")
                    .foregroundStyle(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
            case .file:
                Image(systemName: "doc")
                    .foregroundStyle(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
            case .color:
                Image(systemName: "paintpalette")
                    .foregroundStyle(LinearGradient(colors: [.red, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        }
        .font(.system(size: 12, weight: .medium))
    }
}

struct TimeStampView: View {
    let date: Date
    var body: some View {
        Text(formatTime(date))
            .font(.caption)
            .foregroundColor(.secondary)
    }

    private func formatTime(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: date)
        } else if cal.isDateInYesterday(date) {
            return "Yesterday"
        }
        let f = DateFormatter(); f.dateFormat = "MMM d"; return f.string(from: date)
    }
}
