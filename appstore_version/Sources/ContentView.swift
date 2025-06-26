import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(clipboardManager.filteredItems) { item in
                        ClipboardItemView(item: item)
                            .onTapGesture {
                                clipboardManager.copyToClipboard(item)
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .frame(width: 400, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
    }
}