import Foundation

final class LocalLLMSummarizer {
    func summarize(prompt: String, completion: @escaping (Result<LLMPromptResponse, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let response = self.extractStructuredOutput(from: prompt)
            DispatchQueue.main.async {
                completion(.success(response))
            }
        }
    }

    private func extractStructuredOutput(from prompt: String) -> LLMPromptResponse {
        let transcript = extractTranscript(from: prompt)

        return LLMPromptResponse(
            executiveSummary: summarizeText(transcript),
            keyTopics: extractKeyTopics(from: transcript),
            actionItems: extractActionItems(from: transcript),
            meetingMinutes: LLMPromptResponse.MeetingMinutes(
                attendees: extractAttendees(from: transcript),
                agenda: extractAgenda(from: transcript),
                decisions: extractDecisions(from: transcript),
                nextSteps: extractNextSteps(from: transcript)
            )
        )
    }

    // MARK: - Transcript extraction from prompt

    private func extractTranscript(from prompt: String) -> String {
        guard let range = prompt.range(of: "### Transcript\n") else {
            return prompt
        }
        var text = String(prompt[range.upperBound...])
        if let endRange = text.range(of: "\n### JSON Output") {
            text = String(text[..<endRange.lowerBound])
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - NLP extraction

    private func summarizeText(_ text: String) -> String {
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 20 }

        guard !sentences.isEmpty else { return "No summary available." }

        let important = sentences.filter { sentence in
            let lower = sentence.lowercased()
            return lower.contains("decision") || lower.contains("action") ||
                   lower.contains("agree") || lower.contains("next step") ||
                   lower.contains("key") || lower.contains("important") ||
                   lower.contains("summar") || lower.contains("conclusion")
        }

        let chosen = important.isEmpty ? sentences : important
        let summarySentences = Array(chosen.prefix(3))
        return summarySentences.joined(separator: ". ") + "."
    }

    private func extractKeyTopics(from text: String) -> [String] {
        let ignoreWords: Set<String> = ["the", "a", "an", "is", "are", "was", "were",
            "be", "been", "being", "have", "has", "had", "do", "does", "did",
            "will", "would", "could", "should", "may", "might", "can", "shall",
            "to", "of", "in", "for", "on", "with", "at", "by", "from", "as",
            "into", "through", "during", "before", "after", "above", "below",
            "between", "and", "but", "or", "nor", "not", "so", "yet", "both",
            "either", "neither", "each", "every", "all", "any", "few", "more",
            "most", "other", "some", "such", "only", "own", "same", "than",
            "too", "very", "just", "now", "then", "also", "if", "it", "its",
            "here", "there", "when", "where", "why", "how", "which", "who",
            "whom", "this", "that", "these", "those", "say", "said", "get",
            "got", "make", "made", "go", "went", "come", "came", "know",
            "knew", "take", "took", "see", "saw", "think", "thought",
            "want", "look", "use", "used", "like", "yeah", "um", "uh"]

        let words = text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 3 && !ignoreWords.contains($0) }

        let frequencies = Dictionary(grouping: words, by: { $0 })
            .mapValues { $0.count }
            .filter { $0.value >= 2 }
            .sorted { $0.value > $1.value }
            .prefix(8)
            .map { $0.key.capitalized }

        return Array(frequencies)
    }

    private func extractActionItems(from text: String) -> [LLMPromptResponse.ActionItem] {
        let patterns: [(String, Bool)] = [
            ("need to", false),
            ("should", false),
            ("will", false),
            ("going to", false),
            ("action item", true),
            ("todo", true),
            ("assign", false),
            ("follow up", true),
            ("i'll", false),
            ("let me", false),
        ]

        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 15 }

        var items: [LLMPromptResponse.ActionItem] = []
        var seen = Set<String>()

        for sentence in sentences {
            let lower = sentence.lowercased()
            for (pattern, isExact) in patterns {
                if isExact ? lower.contains(pattern) : lower.range(of: "\\b\(pattern)\\b", options: .regularExpression) != nil {
                    let task = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
                    let key = task.lowercased()
                    if !seen.contains(key) {
                        seen.insert(key)
                        let owner = extractOwner(from: sentence)
                        items.append(LLMPromptResponse.ActionItem(task: task, owner: owner))
                    }
                    break
                }
            }
        }

        return Array(items.prefix(10))
    }

    private func extractOwner(from text: String) -> String? {
        let atPattern = try? NSRegularExpression(pattern: "@(\\w+)", options: [])
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        if let match = atPattern?.firstMatch(in: text, options: [], range: range) {
            if let nameRange = Range(match.range(at: 1), in: text) {
                return String(text[nameRange])
            }
        }

        let assignPatterns = ["assigned to (\\w+)", "(\\w+) will", "(\\w+) is going to"]
        for pattern in assignPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    if let nameRange = Range(match.range(at: 1), in: text) {
                        let name = String(text[nameRange]).lowercased()
                        let stopWords = ["will", "should", "need", "going", "have", "the"]
                        if !stopWords.contains(name) {
                            return String(text[nameRange])
                        }
                    }
                }
            }
        }
        return nil
    }

    private func extractAttendees(from text: String) -> [String] {
        let patterns = [
            try? NSRegularExpression(pattern: "@(\\w+)", options: []),
            try? NSRegularExpression(pattern: "(\\w+) (?:joined|is here|attending|on the call|here|present)", options: [.caseInsensitive]),
        ]

        var names = Set<String>()
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        for pattern in patterns {
            guard let pattern else { continue }
            let matches = pattern.matches(in: text, options: [], range: range)
            for match in matches {
                if let nameRange = Range(match.range(at: 1), in: text) {
                    let name = String(text[nameRange])
                    if name.count > 1 && !["the", "and", "for", "with"].contains(name.lowercased()) {
                        names.insert(name.capitalized)
                    }
                }
            }
        }
        return Array(names).sorted()
    }

    private func extractAgenda(from text: String) -> String {
        let agendaPatterns = ["agenda", "today we", "we're going to", "purpose of", "goal is"]
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        for sentence in sentences {
            let lower = sentence.lowercased()
            for pattern in agendaPatterns {
                if lower.contains(pattern) {
                    return sentence
                }
            }
        }
        return "General discussion"
    }

    private func extractDecisions(from text: String) -> [String] {
        let decisionPatterns = ["decided", "decision", "agreed", "agreement",
            "we'll go with", "let's", "conclusion"]
        return text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { sentence in
                let lower = sentence.lowercased()
                return decisionPatterns.contains { lower.contains($0) } && sentence.count > 15
            }
            .prefix(5)
            .map { $0 }
    }

    private func extractNextSteps(from text: String) -> [String] {
        let nextPatterns = ["next step", "next up", "follow up", "by tomorrow",
            "by next", "deadline", "due", "upcoming"]
        return text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { sentence in
                let lower = sentence.lowercased()
                return nextPatterns.contains { lower.contains($0) } && sentence.count > 15
            }
            .prefix(5)
            .map { $0 }
    }
}
