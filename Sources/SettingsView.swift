import SwiftUI

struct SettingsView: View {
    @AppStorage("maxClipboardItems") private var maxItems: Int = 100
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    @AppStorage("showImagePreviews") private var showImagePreviews: Bool = true
    @AppStorage("clearHistoryOnQuit") private var clearHistoryOnQuit: Bool = false
    
    var body: some View {
        TabView {
            GeneralSettingsView(
                maxItems: $maxItems,
                launchAtLogin: $launchAtLogin,
                clearHistoryOnQuit: $clearHistoryOnQuit
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }
            
            AppearanceSettingsView(
                showImagePreviews: $showImagePreviews
            )
            .tabItem {
                Label("Appearance", systemImage: "paintbrush")
            }
            
            AboutSettingsView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 350)
    }
}

struct GeneralSettingsView: View {
    @Binding var maxItems: Int
    @Binding var launchAtLogin: Bool
    @Binding var clearHistoryOnQuit: Bool
    
    var body: some View {
        Form {
            Section("Clipboard History") {
                HStack {
                    Text("Maximum items:")
                    Spacer()
                    TextField("", value: $maxItems, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
                
                Toggle("Clear history on quit", isOn: $clearHistoryOnQuit)
            }
            
            Section("Startup") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        setLaunchAtLogin(enabled: newValue)
                    }
            }
            
            Section("Hotkeys") {
                HStack {
                    Text("Show clipboard:")
                    Spacer()
                    Text("⌘ + Space")
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Section {
                Button("Quit ClipFlow") {
                    NSApplication.shared.terminate(nil)
                }
                .foregroundColor(.red)
            }
        }
        .padding()
    }
    
    private func setLaunchAtLogin(enabled: Bool) {
        let _ = Bundle.main.bundleIdentifier ?? "com.clipflow.app"
        
        if enabled {
            let script = """
                tell application "System Events"
                    make login item at end with properties {path:"\(Bundle.main.bundlePath)", hidden:false}
                end tell
                """
            
            if let scriptObject = NSAppleScript(source: script) {
                scriptObject.executeAndReturnError(nil)
            }
        } else {
            let script = """
                tell application "System Events"
                    delete login item "\(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "ClipFlow")"
                end tell
                """
            
            if let scriptObject = NSAppleScript(source: script) {
                scriptObject.executeAndReturnError(nil)
            }
        }
    }
}

struct AppearanceSettingsView: View {
    @Binding var showImagePreviews: Bool
    
    var body: some View {
        Form {
            Section("Display") {
                Toggle("Show image previews", isOn: $showImagePreviews)
            }
            
            Section("Theme") {
                HStack {
                    Text("App theme:")
                    Spacer()
                    Text("System")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

struct AboutSettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("ClipFlow")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version 1.0")
                .foregroundColor(.secondary)
            
            Text("Effortless clipboard management with smart workflow")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack(spacing: 20) {
                Button("GitHub") {
                    if let url = URL(string: "https://github.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
                
                Button("Support") {
                    if let url = URL(string: "mailto:support@example.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}