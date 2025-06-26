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
                    hotkeyManager.setHotkeyAction {
                        menuBarManager.showPopover()
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