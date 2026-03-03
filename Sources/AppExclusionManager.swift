import Foundation
import AppKit

final class AppExclusionManager: ObservableObject {
    private static let defaultsKey = "excludedBundleIDs"
    @Published private(set) var excludedBundleIDs: Set<String> = []

    init() {
        load()
    }

    func isExcluded(bundleID: String) -> Bool {
        excludedBundleIDs.contains(bundleID)
    }

    func add(bundleID: String) {
        excludedBundleIDs.insert(bundleID)
        save()
    }

    func remove(bundleID: String) {
        excludedBundleIDs.remove(bundleID)
        save()
    }

    var runningApps: [NSRunningApplication] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && $0.bundleIdentifier != nil }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
    }

    private func load() {
        let arr = UserDefaults.standard.stringArray(forKey: Self.defaultsKey) ?? []
        excludedBundleIDs = Set(arr)
    }

    private func save() {
        UserDefaults.standard.set(Array(excludedBundleIDs), forKey: Self.defaultsKey)
    }
}
