import Foundation

struct MeetingOutput: Codable {
    let title: String
    let date: Date
    let executiveSummary: String
    let keyTopics: [String]
    let actionItems: [ActionItem]
    let meetingMinutes: MeetingMinutes
    let fullTranscript: String

    struct ActionItem: Codable, Identifiable {
        let id: UUID
        let task: String
        let owner: String?
    }

    struct MeetingMinutes: Codable {
        let attendees: [String]
        let agenda: String
        let decisions: [String]
        let nextSteps: [String]
    }
}
