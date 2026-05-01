---
project: MeetingNotesApp
status: active
started: 2026-04-30
---

# Meeting Notes App — Dashboard

## Current State
- **Phase:** MVP (Phase 1)
- **Status:** Menu bar icon visible, full pipeline coded, ready for E2E test

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
- [x] Transcribr — real WhisperKit 0.18.0 integration (async/await)
- [x] LocalLLMSummarizer — NLP-based extraction (regex + keyword, free)
- [x] PromptBuilder + JSON models
- [x] Storage layer (FileManager extensions, SettingsStore, AudioCleanup)
- [x] SPM integration — WhisperKit 0.18.0 + MLX Swift 0.31.3 via Package.swift
- [x] BUILD SUCCEEDED (swift build) — all 14 files + WhisperKit + MLX compile
- [x] Menu bar icon visible — NSStatusBar + NSPopover (proven AppKit approach)
- [x] App bundle properly structured (PkgInfo, codesign)
- [x] Single GitHub repo at https://github.com/mednoor8/meetingnotesapp

## Next Actions
- [ ] End-to-end test with real meeting recording
- [ ] Test Start/Stop/Pause menu interactions
- [ ] Wire up full flow: Record → Transcribe → Summarize → Save as .md
- [ ] Future: upgrade summarizer to MLX LLM when mlx-lm bindings mature

## Phases
- [x] Phase 1 — MVP (menu bar, record, transcribe, summarize, save .md) — **IN PROGRESS**
- [ ] Phase 2 — Screen capture, system audio, pause/resume
- [ ] Phase 3 — Live transcription, calendar, search
