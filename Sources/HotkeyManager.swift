import Foundation
import AppKit
import Carbon

class HotkeyManager: ObservableObject {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var onHotkeyPressed: (() -> Void)?
    
    init() {
        setupGlobalHotkey()
    }
    
    deinit {
        cleanupHotkey()
    }
    
    func setHotkeyAction(_ action: @escaping () -> Void) {
        onHotkeyPressed = action
    }
    
    private func setupGlobalHotkey() {
        let hotKeyID = EventHotKeyID(signature: OSType(0x68747279), id: 1)
        let keyCode = UInt32(kVK_Space)
        let modifiers = UInt32(cmdKey)
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            guard let userData = userData else { return OSStatus(eventNotHandledErr) }
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.onHotkeyPressed?()
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)
        
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }
    
    private func cleanupHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
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