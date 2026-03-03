import SwiftUI

struct FilterBarView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(ClipboardFilter.allCases) { filter in
                    FilterChip(
                        filter: filter,
                        count: clipboardManager.count(for: filter),
                        isActive: clipboardManager.activeFilter == filter
                    ) {
                        clipboardManager.activeFilter = filter
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
}

private struct FilterChip: View {
    let filter: ClipboardFilter
    let count: Int
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: filter.icon)
                    .font(.system(size: 11, weight: .medium))
                Text(filter.label)
                    .font(.system(size: 12, weight: .medium))
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(
                            Capsule()
                                .fill(isActive ? Color.white.opacity(0.3) : Color.secondary.opacity(0.15))
                        )
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(isActive ? Color.accentColor : Color(NSColor.controlBackgroundColor))
            )
            .foregroundColor(isActive ? .white : .primary)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}
