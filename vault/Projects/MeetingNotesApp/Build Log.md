---
project: MeetingNotesApp
type: log
---

# Build Log

## 2026-04-30 — Setup

- Created project folder at `/Users/mednoor/Desktop/MeetingNotesApp/`
- Wrote PLANNING.md with architecture, tech stack, state machine, data flow
- Created Obsidian vault at `/Users/mednoor/Claude/Claude Code/MeetingNotesApp/`
- Initialized git repo in vault
- Tech stack decisions:
  - macOS 14+ (MenuBarExtra, no AppKit bridging)
  - SwiftUI native macOS app
  - AVCaptureSession for mic → M4A via AVAssetWriter
  - WhisperKit for on-device transcription (base model, chunked 30s)
  - MLX + Llama 3.2 3B for free on-device summarization
  - ScreenCaptureKit for screen capture (Phase 2)
- Rule saved: every new project gets its own Obsidian vault linked with GitHub

## 2026-04-30 — Xcode Project & First Build

- Created all 14 Swift source files across 7 groups (App, MenuBar, Models, Recording, Transcription, Processing, Storage)
- Generated Xcode project (pbxproj + xcscheme) via Python script
- Fixed 3 build issues:
  1. Parse error — literal `\t` `\n` in pbxproj output (Python f-string escape issue)
  2. Missing main group `path = MeetingNotesApp` — files resolved to project root
  3. Duplicate fileRef IDs — Python list comprehension scoping bug, all files pointed to same ID
- **BUILD SUCCEEDED** at 23:48 — targets macOS 14.0, Swift 5.0

### Files created
| File | Group | Status |
|---|---|---|
| `MeetingNotesApp.swift` | App | @main, MenuBarExtra compiles |
| `Info.plist` | App | Mic permission configured |
| `MeetingStatusViewModel.swift` | MenuBar | Full pipeline orchestration |
| `MeetingState.swift` | Models | State machine enum |
| `TranscriptionResult.swift` | Models | Codable segment model |
| `MeetingOutput.swift` | Models | Final markdown output model |
| `LLMPromptResponse.swift` | Models | LLM JSON response → MeetingOutput mapper |
| `AudioRecorder.swift` | Recording | AVCaptureSession → M4A |
| `Transcriber.swift` | Transcription | WhisperKit stub |
| `LocalLLMSummarizer.swift` | Processing | MLX stub |
| `PromptBuilder.swift` | Processing | Prompt templates |
| `FileManager+Extensions.swift` | Storage | Markdown generation + save |
| `SettingsStore.swift` | Storage | UserDefaults wrapper |
| `AudioCleanup.swift` | Storage | Post-processing cleanup |

## Next
- [ ] Integrate WhisperKit via SPM (real transcription)
- [ ] Integrate MLX Swift via SPM (real summarization)
- [ ] End-to-end test with a real meeting recording
