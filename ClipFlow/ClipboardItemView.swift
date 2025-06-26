import SwiftUI
import AppKit

struct ClipboardItemView: View {
    let item: ClipboardItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AppIconView(appName: item.sourceApp)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    ContentPreview(item: item)
                    Spacer()
                    TimeStampView(date: item.timestamp)
                }
                
                if let sourceApp = item.sourceApp {
                    Text(sourceApp)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
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
                    .frame(width: 24, height: 24)
                    .cornerRadius(4)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "doc.on.clipboard")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    )
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
                    .foregroundColor(.blue)
            case .image:
                Image(systemName: "photo")
                    .foregroundColor(.green)
            case .link:
                Image(systemName: "link")
                    .foregroundColor(.purple)
            case .file:
                Image(systemName: "doc")
                    .foregroundColor(.orange)
            }
        }
        .font(.caption)
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