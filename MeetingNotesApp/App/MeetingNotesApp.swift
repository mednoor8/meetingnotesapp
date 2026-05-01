import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let viewModel = MeetingStatusViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusIcon()

        popover = NSPopover()
        popover.contentSize = NSSize(width: 220, height: 260)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MenuBarContentView(viewModel: viewModel, closePopover: { [weak self] in
                self?.popover.performClose(nil)
            })
        )

        if let button = statusItem.button {
            button.action = #selector(togglePopover)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Observe state changes to update icon
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateStatusIcon()
        }
    }

    private func updateStatusIcon() {
        if let button = statusItem.button {
            let image = NSImage(
                systemSymbolName: iconName,
                accessibilityDescription: iconName
            )
            button.image = image
            button.title = ""
        }
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

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

struct MenuBarContentView: View {
    @ObservedObject var viewModel: MeetingStatusViewModel
    let closePopover: () -> Void

    var body: some View {
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
                Button("Pause") { viewModel.pauseMeeting() }
            }

            if viewModel.state.canResume {
                Button("Resume") { viewModel.resumeMeeting() }
            }

            if case .done = viewModel.state {
                Button("Open Output Folder") {
                    viewModel.openOutputFolder()
                }
            }

            if case .error = viewModel.state {
                Button("Reset") { viewModel.reset() }
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
}

@main
struct MeetingNotesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
