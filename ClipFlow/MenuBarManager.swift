import SwiftUI
import AppKit

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var clipboardManager: ClipboardManager?
    
    init() {
        setupMenuBar()
    }
    
    func setClipboardManager(_ manager: ClipboardManager) {
        self.clipboardManager = manager
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "ClipFlow")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        setupPopover()
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 600)
        popover?.behavior = .transient
        popover?.animates = true
    }
    
    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        
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
}