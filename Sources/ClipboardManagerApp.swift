import SwiftUI

struct ClipboardManagerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(delegate.hotkeyManager)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let clipboardManager = ClipboardManager()
    let hotkeyManager = HotkeyManager()
    let menuBarManager = MenuBarManager()
    let keyNav = KeyboardNavigationState()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let store = ClipboardStore()
        StorageMigration.migrateIfNeeded(into: store)
        clipboardManager.setup(store: store)

        menuBarManager.configure(
            clipboardManager: clipboardManager,
            keyNav: keyNav,
            hotkeyManager: hotkeyManager
        )
        hotkeyManager.setHotkeyAction { [weak self] in
            self?.menuBarManager.showPopover()
        }

        NSApp.setActivationPolicy(.accessory)
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if UserDefaults.standard.bool(forKey: "clearHistoryOnQuit") {
            clipboardManager.clearHistory()
        }
        return .terminateNow
    }
}
