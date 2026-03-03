import SwiftUI

struct SettingsView: View {
    @AppStorage("maxClipboardItems") private var maxItems: Int = 100
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    @AppStorage("showImagePreviews") private var showImagePreviews: Bool = true
    @AppStorage("clearHistoryOnQuit") private var clearHistoryOnQuit: Bool = false
    @AppStorage("autoExpireDays") private var autoExpireDays: Int = 0

    var body: some View {
        TabView {
            GeneralSettingsView(
                maxItems: $maxItems,
                launchAtLogin: $launchAtLogin,
                clearHistoryOnQuit: $clearHistoryOnQuit,
                autoExpireDays: $autoExpireDays
            )
            .tabItem { Label("General", systemImage: "gear") }

            AppearanceSettingsView(showImagePreviews: $showImagePreviews)
                .tabItem { Label("Appearance", systemImage: "paintbrush") }

            ShortcutsSettingsView()
                .tabItem { Label("Shortcuts", systemImage: "keyboard") }

            PrivacySettingsView()
                .tabItem { Label("Privacy", systemImage: "lock.shield") }

            AboutSettingsView()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 480, height: 400)
    }
}

struct GeneralSettingsView: View {
    @Binding var maxItems: Int
    @Binding var launchAtLogin: Bool
    @Binding var clearHistoryOnQuit: Bool
    @Binding var autoExpireDays: Int

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
                Picker("Auto-expire items:", selection: $autoExpireDays) {
                    Text("Never").tag(0)
                    Text("After 1 day").tag(1)
                    Text("After 7 days").tag(7)
                    Text("After 14 days").tag(14)
                    Text("After 30 days").tag(30)
                    Text("After 90 days").tag(90)
                }
                Toggle("Clear history on quit", isOn: $clearHistoryOnQuit)
            }

            Section("Startup") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in setLaunchAtLogin(enabled: newValue) }
            }

            Section {
                Button("Quit ClipFlow") { NSApplication.shared.terminate(nil) }
                    .foregroundColor(.red)
            }
        }
        .padding()
    }

    private func setLaunchAtLogin(enabled: Bool) {
        let name = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "ClipFlow"
        let script = enabled
            ? "tell application \"System Events\" to make login item at end with properties {path:\"\(Bundle.main.bundlePath)\", hidden:false}"
            : "tell application \"System Events\" to delete login item \"\(name)\""
        NSAppleScript(source: script)?.executeAndReturnError(nil)
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
                    Text("System").foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

struct ShortcutsSettingsView: View {
    @EnvironmentObject var hotkeyManager: HotkeyManager

    var body: some View {
        Form {
            Section("Global Shortcut") {
                HStack {
                    Text("Open ClipFlow:")
                    Spacer()
                    HotkeyRecorderView(keyCode: $hotkeyManager.keyCode, modifierFlags: $hotkeyManager.modifierFlags)
                        .frame(width: 140, height: 28)
                }
            }

            Section("Keyboard Navigation") {
                shortcutRow("Move up / down", keys: "↑ / ↓")
                shortcutRow("Copy selected item", keys: "↵")
                shortcutRow("Copy & paste", keys: "⌘↵")
                shortcutRow("Delete selected", keys: "⌫")
                shortcutRow("Toggle pin", keys: "Space")
                shortcutRow("Focus search", keys: "⌘F")
                shortcutRow("Instant copy 1–9", keys: "⌘1–⌘9")
                shortcutRow("Close", keys: "⎋")
            }
        }
        .padding()
    }

    private func shortcutRow(_ label: String, keys: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(keys)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.secondary.opacity(0.15))
                .cornerRadius(5)
        }
    }
}

struct PrivacySettingsView: View {
    @StateObject private var exclusionManager = AppExclusionManager()
    @State private var selectedBundleID: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Excluded Applications")
                .font(.headline)

            Text("ClipFlow will not capture clipboard content from these apps.")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(alignment: .top, spacing: 12) {
                List(selection: $selectedBundleID) {
                    ForEach(Array(exclusionManager.excludedBundleIDs).sorted(), id: \.self) { id in
                        HStack {
                            Image(systemName: "app.badge.checkmark")
                                .foregroundColor(.secondary)
                            Text(id)
                                .font(.system(size: 12, design: .monospaced))
                        }
                        .tag(id)
                    }
                }
                .frame(minHeight: 150)
                .border(Color(NSColor.separatorColor))

                VStack(spacing: 8) {
                    Menu("Add App") {
                        ForEach(exclusionManager.runningApps, id: \.bundleIdentifier) { app in
                            if let bid = app.bundleIdentifier, !exclusionManager.isExcluded(bundleID: bid) {
                                Button("\(app.localizedName ?? bid)") {
                                    exclusionManager.add(bundleID: bid)
                                }
                            }
                        }
                    }
                    .menuStyle(.borderedButton)

                    Button("Remove") {
                        if let id = selectedBundleID {
                            exclusionManager.remove(bundleID: id)
                            selectedBundleID = nil
                        }
                    }
                    .disabled(selectedBundleID == nil)
                }
            }
        }
        .padding()
    }
}

struct AboutSettingsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 56))
                .foregroundColor(.accentColor)
            Text("ClipFlow")
                .font(.title)
                .fontWeight(.bold)
            Text("Version 1.1")
                .foregroundColor(.secondary)
            Text("Effortless clipboard management for macOS")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
