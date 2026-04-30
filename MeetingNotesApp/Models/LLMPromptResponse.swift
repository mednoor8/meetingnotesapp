import Foundation

struct LLMPromptResponse: Codable {
    let executiveSummary: String
    let keyTopics: [String]
    let actionItems: [ActionItem]
    let meetingMinutes: MeetingMinutes

    struct ActionItem: Codable {
        let task: String
        let owner: String?
    }

    struct MeetingMinutes: Codable {
        let attendees: [String]
        let agenda: String
        let decisions: [String]
        let nextSteps: [String]
    }

    func toMeetingOutput(title: String, date: Date, fullTranscript: String) -> MeetingOutput {
        MeetingOutput(
            title: title,
            date: date,
            executiveSummary: executiveSummary,
            keyTopics: keyTopics,
            actionItems: actionItems.map {
                MeetingOutput.ActionItem(id: UUID(), task: $0.task, owner: $0.owner)
            },
            meetingMinutes: MeetingOutput.MeetingMinutes(
                attendees: meetingMinutes.attendees,
                agenda: meetingMinutes.agenda,
                decisions: meetingMinutes.decisions,
                nextSteps: meetingMinutes.nextSteps
            ),
            fullTranscript: fullTranscript
        )
    }
}
