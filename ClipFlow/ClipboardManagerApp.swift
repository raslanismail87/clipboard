import SwiftUI

struct ClipboardManagerApp: App {
    @StateObject private var clipboardManager = ClipboardManager()
    @StateObject private var hotkeyManager = HotkeyManager()
    @StateObject private var menuBarManager = MenuBarManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(clipboardManager)
                .onAppear {
                    menuBarManager.setClipboardManager(clipboardManager)
                    clipboardManager.menuBarManager = menuBarManager
                    hotkeyManager.setHotkeyAction {
                        menuBarManager.showPopover()
                    }
                    
                    // Debug permissions on startup
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        clipboardManager.debugPermissionStatus()
                    }
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
        .defaultSize(width: 400, height: 600)
        
        Settings {
            SettingsView()
        }
    }
}