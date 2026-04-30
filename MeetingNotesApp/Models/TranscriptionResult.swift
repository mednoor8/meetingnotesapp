import Foundation

struct TranscriptionResult: Codable {
    struct Segment: Codable {
        let text: String
        let startTime: TimeInterval
        let endTime: TimeInterval
    }

    let fullText: String
    let segments: [Segment]
    let duration: TimeInterval
    let modelUsed: String
}
