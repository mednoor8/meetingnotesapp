import SwiftUI
import AppKit

final class MeetingStatusViewModel: ObservableObject {
    @Published var state: MeetingState = .idle

    private let audioRecorder = AudioRecorder()
    private let settingsStore = SettingsStore()
    private var currentMeetingDate: Date?

    func startMeeting() {
        guard let outputFolder = settingsStore.outputFolder else {
            state = .error("Set output folder in Settings")
            return
        }

        currentMeetingDate = Date()
        do {
            try audioRecorder.startRecording(to: outputFolder)
            state = .recording
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func pauseMeeting() {
        audioRecorder.pause()
        state = .paused
    }

    func resumeMeeting() {
        audioRecorder.resume()
        state = .recording
    }

    func stopMeeting() {
        audioRecorder.stopRecording()
        processMeeting()
    }

    func reset() {
        state = .idle
        currentMeetingDate = nil
    }

    func openOutputFolder() {
        if let folder = settingsStore.outputFolder {
            NSWorkspace.shared.open(folder)
        }
    }

    func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        let settingsView = SettingsView(viewModel: self, settingsStore: settingsStore)
        let hostingView = NSHostingView(rootView: settingsView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Brief Settings"
        window.contentView = hostingView
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    private func processMeeting() {
        guard let date = currentMeetingDate,
              let outputFolder = settingsStore.outputFolder,
              let audioURL = audioRecorder.lastRecordingURL else {
            state = .error("Missing recording data")
            return
        }

        state = .transcribing(progress: 0)

        let transcriber = Transcriber()
        transcriber.transcribe(audioURL: audioURL, model: settingsStore.whisperModel) { [weak self] progress, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.state = .error(error.localizedDescription)
                    return
                }

                if let result = result {
                    self?.state = .summarizing
                    self?.summarize(transcript: result.fullText, date: date, outputFolder: outputFolder)
                } else {
                    self?.state = .transcribing(progress: progress)
                }
            }
        }
    }

    private func summarize(transcript: String, date: Date, outputFolder: URL) {
        let summarizer = LocalLLMSummarizer()
        let prompt = PromptBuilder.buildSummaryPrompt(transcript: transcript)

        summarizer.summarize(prompt: prompt) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let output = response.toMeetingOutput(
                        title: "Brief",
                        date: date,
                        fullTranscript: transcript
                    )
                    do {
                        let outputURL = try FileManager.saveMeetingOutput(output, to: outputFolder)
                        AudioCleanup.removeAudio(at: self?.audioRecorder.lastRecordingURL)
                        self?.state = .done
                        NSWorkspace.shared.open(outputURL)
                    } catch {
                        self?.state = .error("Failed to save: \(error.localizedDescription)")
                    }

                    self?.saveToObsidianBuildLog(date: date, transcript: transcript, output: output)

                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                }
            }
        }
    }

    private func saveToObsidianBuildLog(date: Date, transcript: String, output: MeetingOutput) {
        // Log meeting to Obsidian vault for tracking
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateStr = formatter.string(from: date)

        let logEntry = """
        \n## \(dateStr) — Meeting Recorded
        - **Duration:** \(output.fullTranscript.count) chars transcript
        - **Summary:** \(output.executiveSummary.prefix(200))
        - **Action Items:** \(output.actionItems.count)
        - **Topics:** \(output.keyTopics.joined(separator: ", "))
        """

        let vaultLogPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Claude/Claude Code/MeetingNotesApp/Projects/MeetingNotesApp/Build Log.md")

        if let data = logEntry.data(using: .utf8) {
            if let handle = try? FileHandle(forWritingTo: vaultLogPath) {
                handle.seekToEndOfFile()
                handle.write(data)
                handle.closeFile()
            }
        }
    }
}

struct SettingsView: View {
    @ObservedObject var viewModel: MeetingStatusViewModel
    @ObservedObject var settingsStore: SettingsStore
    @State private var folderPath: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.title2)
                .bold()

            HStack {
                Text("Output Folder:")
                TextField("Choose folder...", text: $folderPath)
                    .textFieldStyle(.roundedBorder)
                Button("Browse...") {
                    let panel = NSOpenPanel()
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false
                    panel.canCreateDirectories = true
                    if panel.runModal() == .OK {
                        if let url = panel.url {
                            folderPath = url.path
                            settingsStore.outputFolder = url
                        }
                    }
                }
            }

            Picker("Whisper Model:", selection: $settingsStore.whisperModel) {
                Text("Tiny").tag("tiny")
                Text("Base").tag("base")
                Text("Small").tag("small")
            }
            .pickerStyle(.segmented)

            HStack {
                Text("Status: \(viewModel.state.displayText)")
                Spacer()
                Button("Reset") {
                    viewModel.reset()
                }
            }

            Spacer()

            HStack {
                Spacer()
                Button("Close") {
                    NSApplication.shared.keyWindow?.close()
                }
            }
        }
        .padding()
        .frame(width: 380, height: 180)
        .onAppear {
            folderPath = settingsStore.outputFolder?.path ?? ""
        }
    }
}
