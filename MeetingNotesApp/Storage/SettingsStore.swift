import Foundation
import Combine

final class SettingsStore: ObservableObject {
    @Published var outputFolder: URL? {
        didSet {
            if let url = outputFolder {
                UserDefaults.standard.set(url.path, forKey: "outputFolder")
            }
        }
    }

    @Published var whisperModel: String {
        didSet {
            UserDefaults.standard.set(whisperModel, forKey: "whisperModel")
        }
    }

    init() {
        if let path = UserDefaults.standard.string(forKey: "outputFolder") {
            self.outputFolder = URL(fileURLWithPath: path)
        } else {
            self.outputFolder = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Documents/Brief")
        }
        self.whisperModel = UserDefaults.standard.string(forKey: "whisperModel") ?? "base"
    }
}
