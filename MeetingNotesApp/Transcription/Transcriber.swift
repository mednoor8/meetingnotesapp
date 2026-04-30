import Foundation

final class Transcriber {
    func transcribe(
        audioURL: URL,
        model: String,
        progressHandler: @escaping (Double, TranscriptionResult?, Error?) -> Void
    ) {
        // WhisperKit transcription happens on a background queue.
        // Chunked into 30s segments for progress reporting.
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try self.runWhisperKit(audioURL: audioURL, model: model) { progress in
                    DispatchQueue.main.async {
                        progressHandler(progress, nil, nil)
                    }
                }
                DispatchQueue.main.async {
                    progressHandler(1.0, result, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    progressHandler(0, nil, error)
                }
            }
        }
    }

    private func runWhisperKit(audioURL: URL, model: String, onProgress: @escaping (Double) -> Void) throws -> TranscriptionResult {
        // TODO: Integrate WhisperKit Swift package
        // let whisperKit = try WhisperKit(model: model)
        // let result = try whisperKit.transcribe(audioURL: audioURL) { progress in
        //     onProgress(progress)
        // }
        // return TranscriptionResult(fullText: result.text, segments: result.segments.map { ... })

        // Stub implementation for now
        onProgress(0.5)
        Thread.sleep(forTimeInterval: 1)
        onProgress(0.8)
        Thread.sleep(forTimeInterval: 0.5)

        return TranscriptionResult(
            fullText: "[Transcription stub — WhisperKit integration pending]",
            segments: [],
            duration: 0,
            modelUsed: model
        )
    }
}
