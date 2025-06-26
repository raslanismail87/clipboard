import SwiftUI
import AppKit

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var clipboardManager: ClipboardManager?
    private var rightClickMenu: NSMenu?
    @AppStorage("clearHistoryOnQuit") private var clearHistoryOnQuit: Bool = false
    
    init() {
        setupMenuBar()
        setupRightClickMenu()
    }
    
    func setClipboardManager(_ manager: ClipboardManager) {
        self.clipboardManager = manager
        manager.menuBarManager = self
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "ClipFlow")
            button.action = #selector(togglePopover)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        setupPopover()
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 420, height: 600)
        popover?.behavior = .transient
        popover?.animates = true
    }
    
    private func setupRightClickMenu() {
        rightClickMenu = NSMenu()
        rightClickMenu?.addItem(NSMenuItem(title: "Show ClipFlow", action: #selector(showClipFlow), keyEquivalent: ""))
        rightClickMenu?.addItem(NSMenuItem.separator())
        
        // Clear history option
        let clearItem = NSMenuItem(title: "Clear History", action: #selector(clearHistory), keyEquivalent: "")
        clearItem.target = self
        rightClickMenu?.addItem(clearItem)
        
        rightClickMenu?.addItem(NSMenuItem.separator())
        rightClickMenu?.addItem(NSMenuItem(title: "Quit ClipFlow", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        
        let event = NSApp.currentEvent
        
        if event?.type == .rightMouseUp {
            // Show menu on right-click
            if let menu = rightClickMenu {
                statusItem?.menu = menu
                button.performClick(nil)
                statusItem?.menu = nil
            }
        } else {
            // Show popover on left-click
            if let popover = popover {
                if popover.isShown {
                    popover.performClose(nil)
                } else {
                    if let clipboardManager = clipboardManager {
                        let contentView = ContentView().environmentObject(clipboardManager)
                        popover.contentViewController = NSHostingController(rootView: contentView)
                    }
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                }
            }
        }
    }
    
    @objc private func showClipFlow() {
        showPopover()
    }
    
    @objc private func clearHistory() {
        clipboardManager?.clearHistory()
    }
    
    func showPopover() {
        guard let button = statusItem?.button else { return }
        
        if let popover = popover, !popover.isShown {
            if let clipboardManager = clipboardManager {
                let contentView = ContentView().environmentObject(clipboardManager)
                popover.contentViewController = NSHostingController(rootView: contentView)
            }
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    func hidePopover() {
        popover?.performClose(nil)
    }
}