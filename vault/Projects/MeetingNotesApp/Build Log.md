---
project: MeetingNotesApp
type: log
---

# Build Log

## 2026-04-30 — Setup & Scaffolding
- Created project folder, PLANNING.md, Obsidian vault
- Created all 14 Swift source files across 7 groups
- Xcode project generated — BUILD SUCCEEDED (no SPM)
- All repos consolidated into single GitHub repo

## 2026-05-01 — SPM Integration
- **WhisperKit 0.18.0** — integrated via Package.swift, real transcription code
- **MLX Swift 0.31.3** — integrated (core), LLM summarization pending ecosystem
- **Package.swift** — primary build system (replaces manual pbxproj SPM editing)
- **LocalLLMSummarizer** — NLP-based extraction (regex + keyword), no API costs
- **BUILD SUCCEEDED** via `swift build` — all packages compile and link

### SPM Issues & Fixes
1. pbxproj SPM: packages resolved but not linked (indentation bug in packageProductDependencies)
2. Switched to Package.swift (`swift build`) — SPM resolves all dependencies correctly
3. WhisperKit API: returns `[TranscriptionResult]` (array), segments use `start`/`end`
4. MLXLLM not available as SPM product — summarizer uses NLP extraction for now

### What compiles
- WhisperKit transcription (real): audio → text with segmented progress
- NLP summarization (real): action items, topics, decisions, attendees, agenda, next steps
- Audio recording: AVCaptureSession → M4A via AVAssetWriter
- Markdown generation + save + audio cleanup
- Menu bar app with full state machine

## 2026-05-01 01:31 — Menu Bar Icon Fix
- **MenuBarExtra silent failure** — SwiftUI `MenuBarExtra` compiled and ran but no icon appeared
- **Root cause:** Swift 6.3 on macOS 15 — MenuBarExtra silently didn't render (no errors logged)
- **Fix:** Switched to `NSStatusBar` + `NSPopover` (proven AppKit approach)
  - `NSApplicationDelegate` sets `setActivationPolicy(.accessory)` in `applicationDidFinishLaunching`
  - `NSStatusBar.system.statusItem(withLength:)` creates menu bar item
  - Icon set via `NSImage(systemSymbolName:)` on the button
  - `NSPopover` with `NSHostingController` for the SwiftUI menu content
  - Timer polls state changes to update icon image
- **App bundle:** Added PkgInfo, CFBundlePackageType, CFBundleSignature, ad-hoc signing
- **ICON VISIBLE** — circle icon appears in menu bar
- **bundle.sh** script saved at `.build/bundle.sh` for reproducible builds

## Next
- [ ] End-to-end test with real meeting recording
- [ ] Test Start/Stop/Pause menu interactions
- [ ] Future: upgrade summarizer to MLX LLM
