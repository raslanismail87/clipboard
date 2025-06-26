import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    
    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 12) {
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                SearchBar(text: $clipboardManager.searchText)
            }
            
            FilterTabsView()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
        )
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            TextField("Search clipboard...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 14))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

struct FilterTabsView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(ClipboardManager.FilterType.allCases, id: \.rawValue) { filter in
                FilterTab(
                    title: filter.rawValue,
                    isSelected: clipboardManager.selectedFilter == filter
                ) {
                    clipboardManager.selectedFilter = filter
                }
            }
            
            Spacer()
        }
    }
}

struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if title == "All" {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isSelected ? .white : .secondary)
                }
                
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? 
                          LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ) : 
                          LinearGradient(
                            colors: [Color.clear, Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.0 : 0.98)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}