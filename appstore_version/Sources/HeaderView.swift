import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "doc.on.clipboard")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                SearchBar(text: $clipboardManager.searchText)
                
                Button(action: {}) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            FilterTabsView()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Type to Search...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(8)
    }
}

struct FilterTabsView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ClipboardManager.FilterType.allCases, id: \.rawValue) { filter in
                FilterTab(
                    title: filter.rawValue,
                    isSelected: clipboardManager.selectedFilter == filter
                ) {
                    clipboardManager.selectedFilter = filter
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if title == "All" {
                    Image(systemName: "doc.on.clipboard")
                        .font(.caption)
                } else if title == "Today" {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .medium : .regular))
            }
            .foregroundColor(isSelected ? .primary : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}