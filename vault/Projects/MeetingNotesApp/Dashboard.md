---
project: MeetingNotesApp
status: active
started: 2026-04-30
---

# Meeting Notes App — Dashboard

## Current State
- **Phase:** MVP (Phase 1)
- **Status:** Scaffolded & compiling

## Quick Links
- [[Planning]] — Full architecture & tech stack
- [[Build Log]] — Step-by-step progress
- [[Decisions]] — Key decisions made

## Completed
- [x] Create project folder + planning doc
- [x] Create Obsidian vault + git init
- [x] Create Xcode project with SwiftUI, target macOS 14
- [x] Configure Info.plist (mic permission)
- [x] Implement MeetingState enum + MeetingStatusViewModel
- [x] Implement AudioRecorder (AVCaptureSession → M4A)
- [x] Scaffold Transcriber (WhisperKit stub)
- [x] Scaffold LocalLLMSummarizer (MLX stub)
- [x] Build PromptBuilder + JSON models
- [x] Storage layer (FileManager extensions, SettingsStore, AudioCleanup)
- [x] **BUILD SUCCEEDED** — all 14 source files compile

## Next Actions
- [ ] Integrate WhisperKit via SPM for real transcription
- [ ] Integrate MLX Swift via SPM for real summarization
- [ ] End-to-end test with real meeting recording
- [ ] Wire up full flow: Record → Transcribe → Summarize → Save as .md
- [ ] Add cleanup step (delete raw audio after success)

## Phases
- [ ] Phase 1 — MVP (menu bar, record, transcribe, summarize, save .md)
- [ ] Phase 2 — Screen capture, system audio, pause/resume
- [ ] Phase 3 — Live transcription, calendar, search
