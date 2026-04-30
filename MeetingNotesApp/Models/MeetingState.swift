import Foundation

enum MeetingState: Equatable {
    case idle
    case recording
    case paused
    case transcribing(progress: Double)
    case summarizing
    case done
    case error(String)

    var canStart: Bool {
        switch self {
        case .idle, .done, .error: return true
        default: return false
        }
    }

    var canStop: Bool {
        switch self {
        case .recording, .paused: return true
        default: return false
        }
    }

    var canPause: Bool {
        switch self {
        case .recording: return true
        default: return false
        }
    }

    var canResume: Bool {
        switch self {
        case .paused: return true
        default: return false
        }
    }

    var isProcessing: Bool {
        switch self {
        case .transcribing, .summarizing: return true
        default: return false
        }
    }

    var displayText: String {
        switch self {
        case .idle: return "Ready"
        case .recording: return "Recording..."
        case .paused: return "Paused"
        case .transcribing(let p): return "Transcribing \(Int(p * 100))%"
        case .summarizing: return "Summarizing..."
        case .done: return "Done"
        case .error(let msg): return "Error: \(msg)"
        }
    }
}
