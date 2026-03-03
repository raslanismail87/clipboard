import Foundation
import AppKit

final class KeyboardNavigationState: ObservableObject {
    @Published var selectedIndex: Int? = nil
    var onClose: (() -> Void)?
    var onFocusSearch: (() -> Void)?

    func moveUp(count: Int) {
        guard count > 0 else { return }
        if let idx = selectedIndex {
            selectedIndex = max(0, idx - 1)
        } else {
            selectedIndex = 0
        }
    }

    func moveDown(count: Int) {
        guard count > 0 else { return }
        if let idx = selectedIndex {
            selectedIndex = min(count - 1, idx + 1)
        } else {
            selectedIndex = 0
        }
    }

    func reset() {
        selectedIndex = nil
    }
}
