import SwiftUI

struct InlineEditView: View {
    let item: ClipboardItem
    @EnvironmentObject var clipboardManager: ClipboardManager
    @Binding var isPresented: Bool
    @State private var editText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.accentColor)
                Text("Edit clipboard item")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            TextEditor(text: $editText)
                .font(.system(size: 13))
                .frame(minHeight: 100, maxHeight: 200)
                .padding(6)
                .background(RoundedRectangle(cornerRadius: 8).fill(.regularMaterial))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor.opacity(0.3), lineWidth: 1))

            HStack(spacing: 8) {
                if item.editedContent != nil {
                    Button("Reset to Original") {
                        clipboardManager.updateEditedContent(nil, for: item)
                        isPresented = false
                    }
                    .foregroundColor(.red)
                    .buttonStyle(.plain)
                    .font(.system(size: 12))
                }
                Spacer()
                Button("Cancel") { isPresented = false }
                    .buttonStyle(.plain)
                    .font(.system(size: 13))
                Button("Save") {
                    let trimmed = editText.trimmingCharacters(in: .whitespacesAndNewlines)
                    clipboardManager.updateEditedContent(trimmed.isEmpty ? nil : trimmed, for: item)
                    isPresented = false
                }
                .buttonStyle(.plain)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.accentColor)
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
        .onAppear {
            editText = item.effectiveText ?? item.preview
        }
    }
}
