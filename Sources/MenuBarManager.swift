import SwiftUI
import AppKit

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var hostingController: NSHostingController<AnyView>?
    private var clipboardManager: ClipboardManager?
    private var keyNav: KeyboardNavigationState?
    private var hotkeyManager: HotkeyManager?
    private var rightClickMenu: NSMenu?
    @AppStorage("clearHistoryOnQuit") private var clearHistoryOnQuit: Bool = false

    init() {
        setupMenuBar()
    }

    func configure(clipboardManager: ClipboardManager, keyNav: KeyboardNavigationState, hotkeyManager: HotkeyManager) {
        self.clipboardManager = clipboardManager
        self.keyNav = keyNav
        self.hotkeyManager = hotkeyManager
        clipboardManager.menuBarManager = self
        keyNav.onClose = { [weak self] in self?.hidePopover() }
        buildHostingController()
        setupRightClickMenu()
    }

    private func buildHostingController() {
        guard let cm = clipboardManager, let kn = keyNav, let hm = hotkeyManager else { return }
        let root = AnyView(
            ContentView()
                .environmentObject(cm)
                .environmentObject(kn)
                .environmentObject(hm)
        )
        if hostingController == nil {
            hostingController = NSHostingController(rootView: root)
        } else {
            hostingController?.rootView = root
        }
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "ClipFlow")
            button.action = #selector(handleButtonClick)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 420, height: 600)
        popover?.behavior = .transient
        popover?.animates = true
    }

    private func setupRightClickMenu() {
        rightClickMenu = NSMenu()

        let showItem = NSMenuItem(title: "Show ClipFlow", action: #selector(showClipFlow), keyEquivalent: "")
        showItem.target = self
        rightClickMenu?.addItem(showItem)

        rightClickMenu?.addItem(.separator())
        buildPinnedSubmenu()
        rightClickMenu?.addItem(.separator())

        let countItem = NSMenuItem(title: historyCountTitle, action: nil, keyEquivalent: "")
        countItem.isEnabled = false
        countItem.tag = 100
        rightClickMenu?.addItem(countItem)

        let clearItem = NSMenuItem(title: "Clear History", action: #selector(clearHistory), keyEquivalent: "")
        clearItem.target = self
        rightClickMenu?.addItem(clearItem)

        rightClickMenu?.addItem(.separator())
        rightClickMenu?.addItem(NSMenuItem(title: "Quit ClipFlow", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }

    private func buildPinnedSubmenu() {
        guard let cm = clipboardManager else { return }
        let pinned = cm.items.filter { $0.isPinned }.prefix(5)
        guard !pinned.isEmpty else { return }

        let pinnedMenu = NSMenu(title: "Pinned Items")
        for item in pinned {
            let mi = NSMenuItem(title: String(item.preview.prefix(40)), action: #selector(copyPinnedItem(_:)), keyEquivalent: "")
            mi.target = self
            mi.representedObject = item.id.uuidString
            pinnedMenu.addItem(mi)
        }
        let pinnedItem = NSMenuItem(title: "Pinned Items", action: nil, keyEquivalent: "")
        pinnedItem.submenu = pinnedMenu
        rightClickMenu?.addItem(pinnedItem)
    }

    private var historyCountTitle: String {
        let count = clipboardManager?.items.count ?? 0
        return "History (\(count) item\(count == 1 ? "" : "s"))"
    }

    @objc private func handleButtonClick() {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            if let menu = rightClickMenu {
                if let countItem = menu.item(withTag: 100) {
                    countItem.title = historyCountTitle
                }
                statusItem?.menu = menu
                statusItem?.button?.performClick(nil)
                statusItem?.menu = nil
            }
        } else {
            togglePopover()
        }
    }

    private func togglePopover() {
        guard let button = statusItem?.button, let popover else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            openPopover(button: button)
        }
    }

    func showPopover() {
        guard let button = statusItem?.button, let popover, !popover.isShown else { return }
        openPopover(button: button)
    }

    func hidePopover() {
        popover?.performClose(nil)
    }

    private func openPopover(button: NSStatusBarButton) {
        guard let popover, let hc = hostingController else { return }
        popover.contentViewController = hc
        keyNav?.reset()
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        DispatchQueue.main.async {
            popover.contentViewController?.view.window?.makeFirstResponder(nil)
        }
    }

    @objc private func showClipFlow() { showPopover() }

    @objc private func clearHistory() { clipboardManager?.clearHistory() }

    @objc private func copyPinnedItem(_ sender: NSMenuItem) {
        guard let idString = sender.representedObject as? String,
              let id = UUID(uuidString: idString),
              let item = clipboardManager?.items.first(where: { $0.id == id }) else { return }
        clipboardManager?.copyToClipboard(item)
    }
}
