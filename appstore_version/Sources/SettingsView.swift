import SwiftUI

struct SettingsView: View {
    @AppStorage("maxClipboardItems") private var maxItems: Int = 100
    @AppStorage("showImagePreviews") private var showImagePreviews: Bool = true
    @AppStorage("clearHistoryOnQuit") private var clearHistoryOnQuit: Bool = false
    
    var body: some View {
        TabView {
            GeneralSettingsView(
                maxItems: $maxItems,
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
            
            Section("Usage") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Click the menu bar icon to open ClipFlow")
                    Text("• Press Cmd+Space when ClipFlow window is active")
                    Text("• Click any item to copy it to clipboard")
                    Text("• Use search to find specific content")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
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
