import Foundation
import WhisperKit

final class Transcriber {
    private var whisperKit: WhisperKit?

    func transcribe(
        audioURL: URL,
        model: String,
        progressHandler: @escaping (Double, TranscriptionResult?, Error?) -> Void
    ) {
        Task {
            do {
                let result = try await runWhisperKit(audioURL: audioURL, model: model) { progress in
                    Task { @MainActor in
                        progressHandler(progress, nil, nil)
                    }
                }
                await MainActor.run {
                    progressHandler(1.0, result, nil)
                }
            } catch {
                await MainActor.run {
                    progressHandler(0, nil, error)
                }
            }
        }
    }

    private func runWhisperKit(
        audioURL: URL,
        model: String,
        onProgress: @escaping (Double) -> Void
    ) async throws -> TranscriptionResult {
        let whisper = try await WhisperKit(model: model)
        self.whisperKit = whisper

        let results = try await whisper.transcribe(
            audioPath: audioURL.path
        ) { progress in
            let pct = min(1.0, Double(progress.tokens.count) / 1000.0)
            onProgress(pct)
            return true
        }

        let fullText = results.map(\.text).joined(separator: " ")
        let segments = results.enumerated().flatMap { index, result in
            result.segments.map { seg in
                TranscriptionResult.Segment(
                    text: seg.text,
                    startTime: TimeInterval(seg.start),
                    endTime: TimeInterval(seg.end)
                )
            }
        }
        let duration = segments.last?.endTime ?? 0

        return TranscriptionResult(
            fullText: fullText,
            segments: segments,
            duration: duration,
            modelUsed: model
        )
    }
}
