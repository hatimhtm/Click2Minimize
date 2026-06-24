import Foundation

struct VersionUtils {
    static func isNewerVersion(_ newVersion: String, currentVersion: String) -> Bool {
        let newVersionComponents = newVersion.split(separator: ".").map { Int($0) ?? 0 }
        let currentVersionComponents = currentVersion.split(separator: ".").map { Int($0) ?? 0 }

        for (new, current) in zip(newVersionComponents, currentVersionComponents) {
            if new > current {
                return true
            } else if new < current {
                return false
            }
        }
        return newVersionComponents.count > currentVersionComponents.count
    }
}
