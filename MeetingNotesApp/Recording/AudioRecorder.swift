import AVFoundation

final class AudioRecorder: NSObject {
    private var captureSession: AVCaptureSession?
    private var audioOutput: AVCaptureAudioDataOutput?
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private(set) var lastRecordingURL: URL?
    private var isPaused = false

    func startRecording(to folder: URL) throws {
        let session = AVCaptureSession()
        session.beginConfiguration()

        guard let microphone = AVCaptureDevice.default(for: .audio) else {
            throw RecorderError.noMicrophone
        }

        let input = try AVCaptureDeviceInput(device: microphone)
        guard session.canAddInput(input) else {
            throw RecorderError.cannotAddInput
        }
        session.addInput(input)

        let output = AVCaptureAudioDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "audio.recording"))
        guard session.canAddOutput(output) else {
            throw RecorderError.cannotAddOutput
        }
        session.addOutput(output)

        session.commitConfiguration()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let filename = "Brief_\(dateFormatter.string(from: Date())).m4a"
        let fileURL = folder.appendingPathComponent(filename)

        let writer = try AVAssetWriter(outputURL: fileURL, fileType: .m4a)
        let audioSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey: 64000
        ]
        let writerInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        writerInput.expectsMediaDataInRealTime = true
        guard writer.canAdd(writerInput) else {
            throw RecorderError.cannotAddWriterInput
        }
        writer.add(writerInput)

        self.captureSession = session
        self.audioOutput = output
        self.assetWriter = writer
        self.assetWriterInput = writerInput
        self.lastRecordingURL = fileURL
        self.isPaused = false

        session.startRunning()
    }

    func pause() {
        isPaused = true
    }

    func resume() {
        isPaused = false
    }

    func stopRecording() {
        captureSession?.stopRunning()
        assetWriterInput?.markAsFinished()
        assetWriter?.finishWriting { [weak self] in
            self?.captureSession = nil
            self?.assetWriter = nil
            self?.assetWriterInput = nil
        }
    }
}

extension AudioRecorder: AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !isPaused else { return }

        if assetWriter?.status == .unknown {
            assetWriter?.startWriting()
            assetWriter?.startSession(atSourceTime: sampleBuffer.presentationTimeStamp)
        }

        if assetWriter?.status == .writing, let input = assetWriterInput, input.isReadyForMoreMediaData {
            input.append(sampleBuffer)
        }
    }
}

enum RecorderError: LocalizedError {
    case noMicrophone
    case cannotAddInput
    case cannotAddOutput
    case cannotAddWriterInput

    var errorDescription: String? {
        switch self {
        case .noMicrophone: return "No microphone found"
        case .cannotAddInput: return "Cannot connect microphone"
        case .cannotAddOutput: return "Cannot configure audio capture"
        case .cannotAddWriterInput: return "Cannot create audio file"
        }
    }
}
