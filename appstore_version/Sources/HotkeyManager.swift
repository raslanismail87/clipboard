import Foundation
import AppKit

class HotkeyManager: ObservableObject {
    private var onHotkeyPressed: (() -> Void)?
    
    init() {
        // App Store version: No global hotkeys allowed
        setupLocalHotkeys()
    }
    
    func setHotkeyAction(_ action: @escaping () -> Void) {
        onHotkeyPressed = action
    }
    
    private func setupLocalHotkeys() {
        // Use NSEvent.addLocalMonitorForEvents for when app is active
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command) && event.keyCode == 49 { // Cmd+Space
                self.onHotkeyPressed?()
                return nil // Consume the event
            }
            return event
        }
    }
}

extension NSApplication {
    func toggleWindow() {
        if let window = windows.first {
            if window.isVisible {
                window.orderOut(nil)
            } else {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}
