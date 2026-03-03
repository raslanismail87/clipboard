import Foundation
import AppKit
import Carbon

class HotkeyManager: ObservableObject {
    private var monitor: Any?
    private var onHotkeyPressed: (() -> Void)?

    @Published var keyCode: UInt16 {
        didSet {
            UserDefaults.standard.set(Int(keyCode), forKey: "hotkeyKeyCode")
            reinstall()
        }
    }
    @Published var modifierFlags: NSEvent.ModifierFlags {
        didSet {
            UserDefaults.standard.set(modifierFlags.rawValue, forKey: "hotkeyModifierFlags")
            reinstall()
        }
    }

    init() {
        let savedKeyCode = UserDefaults.standard.integer(forKey: "hotkeyKeyCode")
        let savedMods = UserDefaults.standard.integer(forKey: "hotkeyModifierFlags")
        keyCode = savedKeyCode > 0 ? UInt16(savedKeyCode) : 49
        modifierFlags = savedMods > 0
            ? NSEvent.ModifierFlags(rawValue: UInt(savedMods))
            : [.option]
        setupMonitor()
    }

    deinit { teardown() }

    func setHotkeyAction(_ action: @escaping () -> Void) {
        onHotkeyPressed = action
    }

    var displayString: String {
        var parts: [String] = []
        if modifierFlags.contains(.control) { parts.append("^") }
        if modifierFlags.contains(.option)  { parts.append("⌥") }
        if modifierFlags.contains(.shift)   { parts.append("⇧") }
        if modifierFlags.contains(.command) { parts.append("⌘") }
        parts.append(keyCodeToString(keyCode))
        return parts.joined()
    }

    private func setupMonitor() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return }
            let relevantMods: NSEvent.ModifierFlags = [.command, .option, .control, .shift]
            if event.keyCode == self.keyCode &&
               event.modifierFlags.intersection(relevantMods) == self.modifierFlags.intersection(relevantMods) {
                DispatchQueue.main.async { self.onHotkeyPressed?() }
            }
        }
    }

    private func teardown() {
        if let monitor { NSEvent.removeMonitor(monitor) }
    }

    private func reinstall() {
        teardown()
        setupMonitor()
    }

    private func keyCodeToString(_ keyCode: UInt16) -> String {
        switch keyCode {
        case 49: return "Space"
        case 36: return "↩"
        case 51: return "⌫"
        case 53: return "⎋"
        default:
            if let chars = keyCodeToChars(keyCode) { return chars.uppercased() }
            return "[\(keyCode)]"
        }
    }

    private func keyCodeToChars(_ keyCode: UInt16) -> String? {
        let source = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        guard let layoutData = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else { return nil }
        let dataRef = unsafeBitCast(layoutData, to: CFData.self)
        let keyboardLayout = unsafeBitCast(CFDataGetBytePtr(dataRef), to: UnsafePointer<UCKeyboardLayout>.self)
        var deadKeyState: UInt32 = 0
        var chars = [UniChar](repeating: 0, count: 4)
        var length = 0
        UCKeyTranslate(keyboardLayout, keyCode, UInt16(kUCKeyActionDown), 0, UInt32(LMGetKbdType()), 0, &deadKeyState, 4, &length, &chars)
        return length > 0 ? String(utf16CodeUnits: Array(chars.prefix(length)), count: length) : nil
    }
}

extension NSApplication {
    func toggleWindow() {
        if let window = windows.first {
            if window.isVisible { window.orderOut(nil) }
            else { window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }
        }
    }
}
