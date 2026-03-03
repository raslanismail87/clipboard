import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    var searchFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.accentColor)
                SearchBar(text: $clipboardManager.searchText, focused: searchFocused)
                itemCountLabel
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 8)

            FilterBarView()
                .padding(.bottom, 4)

            Divider()
        }
        .background(Rectangle().fill(.ultraThinMaterial))
    }

    @ViewBuilder
    private var itemCountLabel: some View {
        let total = clipboardManager.items.count
        let filtered = clipboardManager.filteredItems.count
        let label = clipboardManager.searchText.isEmpty && clipboardManager.activeFilter == .all
            ? "\(total)"
            : "\(filtered)/\(total)"
        Text(label)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.secondary)
            .monospacedDigit()
    }
}

struct SearchBar: View {
    @Binding var text: String
    var focused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            TextField("Search clipboard...", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .focused(focused)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 13))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(.regularMaterial))
        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
            .stroke(focused.wrappedValue ? Color.accentColor.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1))
        .animation(.easeInOut(duration: 0.15), value: focused.wrappedValue)
    }
}
