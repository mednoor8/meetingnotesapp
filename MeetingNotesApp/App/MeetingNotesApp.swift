import SwiftUI

@main
struct MeetingNotesApp: App {
    @StateObject private var viewModel = MeetingStatusViewModel()

    var body: some Scene {
        MenuBarExtra("Brief", systemImage: iconName) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.state.displayText)
                    .font(.headline)
                    .padding(.horizontal, 8)

                Divider()

                if viewModel.state.canStart {
                    Button("Start Meeting") {
                        viewModel.startMeeting()
                    }
                    .keyboardShortcut("s", modifiers: [.command, .shift])
                }

                if viewModel.state.canStop {
                    Button("Stop Meeting") {
                        viewModel.stopMeeting()
                    }
                    .keyboardShortcut("e", modifiers: [.command, .shift])
                }

                if viewModel.state.canPause {
                    Button("Pause") {
                        viewModel.pauseMeeting()
                    }
                }

                if viewModel.state.canResume {
                    Button("Resume") {
                        viewModel.resumeMeeting()
                    }
                }

                if case .done = viewModel.state {
                    Button("Open Output Folder") {
                        viewModel.openOutputFolder()
                    }
                }

                if case .error = viewModel.state {
                    Button("Reset") {
                        viewModel.reset()
                    }
                }

                Divider()

                Button("Settings...") {
                    viewModel.openSettings()
                }
                .keyboardShortcut(",", modifiers: [.command])

                Divider()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: [.command])
            }
            .padding(.vertical, 8)
            .frame(minWidth: 200)
        }
        .menuBarExtraStyle(.window)
    }

    private var iconName: String {
        switch viewModel.state {
        case .recording:
            return "record.circle.fill"
        case .paused:
            return "pause.circle.fill"
        case .transcribing, .summarizing:
            return "arrow.triangle.2.circlepath"
        case .done:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.circle.fill"
        case .idle:
            return "circle"
        }
    }
}
