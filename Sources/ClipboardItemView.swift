import SwiftUI
import AppKit

struct ClipboardItemView: View {
    let item: ClipboardItem
    @State private var isHovered = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            AppIconView(appName: item.sourceApp)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    ContentPreview(item: item)
                    Spacer()
                    TimeStampView(date: item.timestamp)
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
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    isHovered ? Color.accentColor.opacity(0.4) : Color.clear,
                    lineWidth: 1
                )
        )
        .shadow(
            color: .black.opacity(isHovered ? 0.15 : 0.05),
            radius: isHovered ? 6 : 3,
            x: 0,
            y: isHovered ? 3 : 1
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct AppIconView: View {
    let appName: String?
    
    var body: some View {
        Group {
            if let appName = appName,
               let appIcon = getAppIcon(for: appName) {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
            } else {
                RoundedRectangle(cornerRadius: 7)
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
    }
    
    private func getAppIcon(for appName: String) -> NSImage? {
        let apps = NSWorkspace.shared.runningApplications
        if let app = apps.first(where: { $0.localizedName == appName }) {
            return app.icon
        }
        return nil
    }
}

struct ContentPreview: View {
    let item: ClipboardItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                TypeIcon(type: item.type)
                
                Text(item.preview)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            if item.type == .image {
                ImagePreview(item: item)
            }
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
                    .foregroundStyle(
                        LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            case .image:
                Image(systemName: "photo")
                    .foregroundStyle(
                        LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            case .link:
                Image(systemName: "link")
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            case .file:
                Image(systemName: "doc")
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
        }
        .font(.system(size: 12, weight: .medium))
    }
}

struct ImagePreview: View {
    let item: ClipboardItem
    
    var body: some View {
        if let image = item.content as? NSImage {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 200, maxHeight: 100)
                .cornerRadius(8)
        }
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
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
        }
        
        return formatter.string(from: date)
    }
}