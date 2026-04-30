import Foundation

enum AudioCleanup {
    static func removeAudio(at url: URL?) {
        guard let url = url else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
