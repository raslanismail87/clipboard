import SwiftUI
import AppKit

struct HotkeyRecorderView: NSViewRepresentable {
    @Binding var keyCode: UInt16
    @Binding var modifierFlags: NSEvent.ModifierFlags

    func makeNSView(context: Context) -> HotkeyTextField {
        let field = HotkeyTextField()
        field.delegate = context.coordinator
        field.onHotkeyRecorded = { kc, mf in
            keyCode = kc
            modifierFlags = mf
        }
        field.update(keyCode: keyCode, modifierFlags: modifierFlags)
        return field
    }

    func updateNSView(_ nsView: HotkeyTextField, context: Context) {
        nsView.update(keyCode: keyCode, modifierFlags: modifierFlags)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
    class Coordinator: NSObject, NSTextFieldDelegate {}
}

final class HotkeyTextField: NSTextField {
    var onHotkeyRecorded: ((UInt16, NSEvent.ModifierFlags) -> Void)?
    private var isRecording = false

    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        isEditable = false
        isSelectable = false
        isBezeled = true
        bezelStyle = .roundedBezel
        alignment = .center
        font = .systemFont(ofSize: 13)
        toolTip = "Click to record a new shortcut"
    }

    func update(keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags) {
        guard !isRecording else { return }
        stringValue = formatHotkey(keyCode: keyCode, modifierFlags: modifierFlags)
    }

    override func mouseDown(with event: NSEvent) {
        isRecording = true
        stringValue = "Type a shortcut..."
        becomeFirstResponder()
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording else { super.keyDown(with: event); return }
        let mods = event.modifierFlags.intersection([.command, .option, .control, .shift])
        guard !mods.isEmpty else { return }
        let kc = event.keyCode
        isRecording = false
        onHotkeyRecorded?(kc, mods)
        stringValue = formatHotkey(keyCode: kc, modifierFlags: mods)
    }

    override func flagsChanged(with event: NSEvent) {
        guard isRecording else { super.flagsChanged(with: event); return }
        let mods = event.modifierFlags.intersection([.command, .option, .control, .shift])
        var preview = ""
        if mods.contains(.control) { preview += "^" }
        if mods.contains(.option)  { preview += "⌥" }
        if mods.contains(.shift)   { preview += "⇧" }
        if mods.contains(.command) { preview += "⌘" }
        stringValue = preview.isEmpty ? "Type a shortcut..." : "\(preview)..."
    }

    private func formatHotkey(keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags) -> String {
        var parts = ""
        if modifierFlags.contains(.control) { parts += "^" }
        if modifierFlags.contains(.option)  { parts += "⌥" }
        if modifierFlags.contains(.shift)   { parts += "⇧" }
        if modifierFlags.contains(.command) { parts += "⌘" }
        switch keyCode {
        case 49: parts += "Space"
        case 36: parts += "↩"
        case 48: parts += "⇥"
        default: parts += "[\(keyCode)]"
        }
        return parts
    }
}
