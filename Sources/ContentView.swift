import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @EnvironmentObject var keyNav: KeyboardNavigationState
    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(searchFocused: $searchFocused)
            itemList
        }
        .frame(width: 420, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .background(KeyEventHandler { event in
            handleKeyEvent(event)
        })
        .onAppear { searchFocused = false }
    }

    private var itemList: some View {
        let items = clipboardManager.filteredItems
        return ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        ClipboardItemView(item: item, isSelected: keyNav.selectedIndex == index)
                            .id(item.id)
                            .overlay(
                                DoubleClickHandler(
                                    onSingleClick: {
                                        clipboardManager.copyToClipboard(item)
                                        keyNav.selectedIndex = index
                                    },
                                    onDoubleClick: {
                                        clipboardManager.copyAndPaste(item)
                                    }
                                )
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: clipboardManager.filteredItems.map { $0.id })
            }
            .onChange(of: keyNav.selectedIndex) { _, newIdx in
                if let idx = newIdx, idx < items.count {
                    withAnimation { proxy.scrollTo(items[idx].id, anchor: .center) }
                }
            }
        }
    }

    private func handleKeyEvent(_ event: NSEvent) {
        let items = clipboardManager.filteredItems
        switch event.keyCode {
        case 125: // Down
            keyNav.moveDown(count: items.count)
        case 126: // Up
            keyNav.moveUp(count: items.count)
        case 36, 76: // Return / numpad Enter
            if let idx = keyNav.selectedIndex, idx < items.count {
                if event.modifierFlags.contains(.command) {
                    clipboardManager.copyAndPaste(items[idx])
                } else {
                    clipboardManager.copyToClipboard(items[idx])
                }
            }
        case 51: // Delete
            if let idx = keyNav.selectedIndex, idx < items.count {
                clipboardManager.delete(items[idx])
                keyNav.selectedIndex = nil
            }
        case 53: // Escape
            keyNav.reset()
            keyNav.onClose?()
        default:
            // ⌘1-⌘9
            if event.modifierFlags.contains(.command),
               let num = Int(event.charactersIgnoringModifiers ?? ""),
               num >= 1, num <= 9 {
                let idx = num - 1
                if idx < items.count { clipboardManager.copyToClipboard(items[idx]) }
            }
            // ⌘F
            if event.modifierFlags.contains(.command),
               event.charactersIgnoringModifiers == "f" {
                searchFocused = true
            }
        }
    }
}

struct KeyEventHandler: NSViewRepresentable {
    let handler: (NSEvent) -> Void

    func makeNSView(context: Context) -> KeyCaptureView {
        let view = KeyCaptureView()
        view.handler = handler
        return view
    }

    func updateNSView(_ nsView: KeyCaptureView, context: Context) {
        nsView.handler = handler
    }
}

final class KeyCaptureView: NSView {
    var handler: ((NSEvent) -> Void)?
    private var localMonitor: Any?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handler?(event)
            return event
        }
    }

    override func removeFromSuperview() {
        if let m = localMonitor { NSEvent.removeMonitor(m) }
        super.removeFromSuperview()
    }
}

struct DoubleClickHandler: NSViewRepresentable {
    let onSingleClick: () -> Void
    let onDoubleClick: () -> Void

    func makeNSView(context: Context) -> ClickCaptureView {
        let view = ClickCaptureView()
        view.onSingleClick = onSingleClick
        view.onDoubleClick = onDoubleClick
        return view
    }

    func updateNSView(_ nsView: ClickCaptureView, context: Context) {
        nsView.onSingleClick = onSingleClick
        nsView.onDoubleClick = onDoubleClick
    }
}

final class ClickCaptureView: NSView {
    var onSingleClick: (() -> Void)?
    var onDoubleClick: (() -> Void)?
    private var localMonitor: Any?
    private var clickTimer: Timer?

    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil // Transparent to direct mouse events so buttons/context menus still work
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil, localMonitor == nil {
            localMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
                self?.handleClick(event)
                return event
            }
        } else if window == nil {
            clickTimer?.invalidate()
            if let m = localMonitor { NSEvent.removeMonitor(m); localMonitor = nil }
        }
    }

    override func removeFromSuperview() {
        clickTimer?.invalidate()
        if let m = localMonitor { NSEvent.removeMonitor(m); localMonitor = nil }
        super.removeFromSuperview()
    }

    private func handleClick(_ event: NSEvent) {
        guard self.window != nil else { return }
        let locationInView = self.convert(event.locationInWindow, from: nil)
        guard self.bounds.contains(locationInView) else { return }

        if event.clickCount == 2 {
            clickTimer?.invalidate()
            clickTimer = nil
            onDoubleClick?()
        } else if event.clickCount == 1 {
            clickTimer?.invalidate()
            clickTimer = Timer.scheduledTimer(withTimeInterval: NSEvent.doubleClickInterval, repeats: false) { [weak self] _ in
                self?.onSingleClick?()
            }
        }
    }
}
