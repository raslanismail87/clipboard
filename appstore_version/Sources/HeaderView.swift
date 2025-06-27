import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    
    var body: some View {
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

