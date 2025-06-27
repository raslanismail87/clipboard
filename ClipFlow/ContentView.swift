import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(clipboardManager.filteredItems) { item in
                        ClipboardItemView(item: item)
                            // High priority double-click to ensure paste takes precedence
                            .highPriorityGesture(
                                TapGesture(count: 2).onEnded {
                                    print("🖱️ Double-click detected on item: \(item.preview)")
                                    clipboardManager.copyAndPaste(item)
                                }
                            )
                            .onTapGesture {
                                clipboardManager.copyToClipboard(item)
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(NSColor.windowBackgroundColor),
                        Color(NSColor.windowBackgroundColor).opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(width: 420, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}