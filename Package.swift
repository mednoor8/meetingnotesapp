// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MeetingNotesApp",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/argmaxinc/WhisperKit.git", from: "0.18.0"),
        .package(url: "https://github.com/ml-explore/mlx-swift.git", from: "0.31.0"),
    ],
    targets: [
        .executableTarget(
            name: "MeetingNotesApp",
            dependencies: [
                .product(name: "WhisperKit", package: "WhisperKit"),
                .product(name: "MLX", package: "mlx-swift"),
            ],
            path: "MeetingNotesApp",
            sources: [
                "App/MeetingNotesApp.swift",
                "MenuBar/MeetingStatusViewModel.swift",
                "Models/MeetingState.swift",
                "Models/TranscriptionResult.swift",
                "Models/MeetingOutput.swift",
                "Models/LLMPromptResponse.swift",
                "Recording/AudioRecorder.swift",
                "Transcription/Transcriber.swift",
                "Processing/LocalLLMSummarizer.swift",
                "Processing/PromptBuilder.swift",
                "Storage/FileManager+Extensions.swift",
                "Storage/SettingsStore.swift",
                "Storage/AudioCleanup.swift",
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        )
    ]
)
