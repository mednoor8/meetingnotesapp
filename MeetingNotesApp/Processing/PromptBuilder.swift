import Foundation

enum PromptBuilder {
    static func buildSummaryPrompt(transcript: String) -> String {
        """
        ### System
        You are a meeting summarizer. Output ONLY valid JSON in this exact schema. No other text.

        ### Schema
        {
          "executiveSummary": "2-3 sentence summary",
          "keyTopics": ["topic 1", "topic 2"],
          "actionItems": [{"task": "description", "owner": "name or null"}],
          "meetingMinutes": {
            "attendees": ["inferred names"],
            "agenda": "inferred agenda",
            "decisions": ["decision 1"],
            "nextSteps": ["step 1"]
          }
        }

        ### Transcript
        \(transcript)

        ### JSON Output
        """
    }
}
