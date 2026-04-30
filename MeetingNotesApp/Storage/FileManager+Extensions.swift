import Foundation

extension FileManager {
    static func saveMeetingOutput(_ output: MeetingOutput, to folder: URL) throws -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: output.date)

        let filename = "\(output.title)_\(dateStr).md"
        let fileURL = folder.appendingPathComponent(filename)

        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        let markdown = generateMarkdown(from: output)
        try markdown.write(to: fileURL, atomically: true, encoding: .utf8)

        return fileURL
    }

    private static func generateMarkdown(from output: MeetingOutput) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateStr = dateFormatter.string(from: output.date)

        var md = "# \(output.title) — \(dateStr)\n\n"

        md += "## Executive Summary\n\(output.executiveSummary)\n\n"

        md += "## Key Topics\n"
        for topic in output.keyTopics {
            md += "- \(topic)\n"
        }
        md += "\n"

        md += "## Action Items\n"
        for item in output.actionItems {
            if let owner = item.owner {
                md += "- [ ] @\(owner): \(item.task)\n"
            } else {
                md += "- [ ] \(item.task)\n"
            }
        }
        md += "\n"

        md += "## Meeting Minutes\n"
        md += "**Attendees:** \(output.meetingMinutes.attendees.joined(separator: ", "))\n\n"
        md += "**Agenda:** \(output.meetingMinutes.agenda)\n\n"
        md += "**Decisions:**\n"
        for decision in output.meetingMinutes.decisions {
            md += "- \(decision)\n"
        }
        md += "\n**Next Steps:**\n"
        for step in output.meetingMinutes.nextSteps {
            md += "- \(step)\n"
        }
        md += "\n"

        md += "## Full Transcript\n\(output.fullTranscript)\n"

        return md
    }
}
