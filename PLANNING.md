# Meeting Notes App — Project Plan

## Name Suggestions

| Name | Why it works |
|---|---|
| **Recap** | Short, memorable, means "summary" |
| **Scribe** | Classic — it writes down what was said |
| **Takeaway** | Focuses on action items and outcomes |
| **Minute** | Clever double-meaning (time + meeting minutes) |
| **Notesmith** | You craft notes from raw material |
| **Brief** | Clean, one word, means summary |
| **Memoire** | French for "memory" — elegant |
| **Session** | Neutral, professional |

**Recommendation:** `Brief` or `Recap` — short, easy to type, clear meaning.

---

## Tech Stack

| Layer | Choice | Reason |
|---|---|---|
| Language | Swift (native macOS) | Best system API access (mic, screen, menu bar) |
| Minimum macOS | macOS 14 (Sonoma) | `MenuBarExtra` works without AppKit bridging; SwiftUI is mature enough |
| UI | SwiftUI | Modern, less boilerplate than AppKit |
| Audio capture | `AVCaptureSession` + `AVCaptureAudioDataOutput` | Built-in, no dependencies |
| Audio format | M4A (AAC) via `AVAssetWriter` | Compressed — ~1MB/min vs 10MB/min for WAV |
| Screen capture | **ScreenCaptureKit** (not CGDisplayStream) | CGDisplayStream is deprecated; ScreenCaptureKit is the modern Apple API |
| Transcription | **WhisperKit** (on-device) | Free, private, works offline |
| Summarization | **MLX + local LLM** (on-device) | Completely free, private, no API costs. Runs a small model like Llama 3.2 3B or Mistral 7B on Apple Silicon. |
| Model runtime | MLX Swift (Apple's official bindings) | Native Swift integration, optimized for Apple Silicon |
| Local storage | SQLite + Markdown files | Simple, portable |

### Why free on-device summarization instead of Claude API?

- **Zero cost** — no API bill, no tokens to track
- **Fully private** — transcripts never leave the device
- **Works offline** — no internet needed
- **Apple Silicon is fast enough** — a 3B parameter model can summarize a 1-hour transcript in ~10-30 seconds on an M1+

Trade-off: A local 3B model won't match Claude's quality for nuanced summarization. The structured output prompt needs to be tighter and more explicit to get reliable JSON.

---

## Architecture

```
┌─────────────────────┐
│   Menu Bar App      │  ← Lives in menu bar, not dock
│   (MenuBarExtra)    │  ← Red dot when recording, spinner when processing
└──────┬──────────────┘
       │
┌──────▼──────────────┐
│  State Machine      │  ← idle → recording → paused → transcribing → summarizing → done
│  (MeetingState)     │  ← Drives UI, enables/disables actions
└──────┬──────────────┘
       │
┌──────▼──────────────┐
│  Audio Recorder     │  ← AVCaptureSession → M4A file
│  Screen Recorder    │  ← ScreenCaptureKit → PNG every N sec (Phase 2)
└──────┬──────────────┘
       │
┌──────▼──────────────┐
│  Transcriber        │  ← WhisperKit: M4A → text
│                     │  ← Chunked transcription (30s segments) for progress
│                     │  ← Timestamps per segment
└──────┬──────────────┘
       │
┌──────▼──────────────┐
│  AI Processor       │  ← MLX + local LLM: text → summary/actions/minutes
│                     │  ← Structured JSON output via constrained decoding
└──────┬──────────────┘
       │
┌──────▼──────────────┐
│  Storage / Export   │  ← Saves to user-chosen folder
│                     │  ← Markdown + JSON output
│                     │  ← Cleanup: delete raw audio after successful processing
└─────────────────────┘
```

---

## Data Flow

```
Start Meeting → Menu bar icon turns red
              → Microphone starts recording (M4A/AAC)
              → Timer starts (screenshot every 30s, Phase 2)

Pause         → Pause recording (optional, resumes to same file)
              → Menu bar icon turns yellow

End Meeting   → Stop recording
              → Stop screenshots
              → Save compressed audio + screenshots
              → Menu bar icon shows spinner

Processing    → Transcribe audio in chunks (WhisperKit)
              → Show progress: "Transcribing 60%..."
              → Load local LLM model (lazy, or keep warm)
              → Send transcript to local LLM with structured prompt
              → Parse JSON output

Output        → Delete raw audio file (keep transcript JSON)
              → Generate .md file with:
                  # Brief - 2026-04-30
                  ## Summary
                  ...
                  ## Action Items
                  - [ ] ...
                  ## Meeting Minutes
                  ...
                  ## Transcript
                  ...
              → Save screenshots as gallery
              → Open file / show in-app preview
              → Menu bar icon returns to normal
```

---

## Meeting State Machine

```
                 ┌─────────┐
                 │  idle   │ ←────────────┐
                 └────┬────┘              │
                      │ Start             │ Done / Reset
                 ┌────▼────┐         ┌────┴────┐
                 │recording│         │  done   │
                 └────┬────┘         └────▲────┘
                      │ Pause             │
                 ┌────▼────┐              │
                 │ paused  │──Resume──────┘
                 └────┬────┘         (if stopped)
                      │ Stop
                 ┌────▼──────────┐
                 │ transcribing  │
                 └────┬──────────┘
                      │ Done
                 ┌────▼──────────┐
                 │ summarizing   │
                 └───────────────┘
```

States map directly to which menu items are enabled and what the menu bar icon shows.

---

## MVP Scope (Phase 1 — ~1 week)

### Core features
- [ ] Menu bar app with `MenuBarExtra` (macOS 14+)
- [ ] Recording state machine (idle → recording → paused → transcribing → summarizing → done)
- [ ] Menu bar icon states: normal, recording (red dot), processing (spinner)
- [ ] Microphone audio capture → compressed M4A file via `AVAssetWriter`
- [ ] Microphone permission request (`NSMicrophoneUsageDescription` in Info.plist)
- [ ] On-device transcription via WhisperKit (`base` or `small` model, chunked 30s segments)
- [ ] Transcription progress feedback
- [ ] On-device summarization via MLX + local LLM (Llama 3.2 3B or Mistral 7B)
- [ ] Structured JSON output from LLM (summary, action items, key topics, minutes)
- [ ] Output as formatted .md file
- [ ] Auto-cleanup: delete raw audio after successful transcription
- [ ] Minimal settings (output folder)

### What's NOT in MVP
- Screen capture (Phase 2)
- System audio loopback (Phase 2)
- Pause/resume recording (Phase 2)
- Live transcription during call (Phase 3)
- Calendar integration (Phase 3)
- Search across past meetings (Phase 3+)
- In-app meeting history browser (Phase 2)

---

## File Structure Plan

```
MeetingNotesApp/
├── MeetingNotesApp.xcodeproj
├── MeetingNotesApp/
│   ├── App/
│   │   ├── MeetingNotesApp.swift           ← @main entry point
│   │   └── Info.plist                       ← Permissions & entitlements
│   ├── MenuBar/
│   │   ├── MenuBarManager.swift             ← Menu bar controller (MenuBarExtra)
│   │   ├── MeetingStatusViewModel.swift     ← State management + MeetingState enum
│   │   └── MenuBarIcon.swift                ← Icon states (normal/recording/processing)
│   ├── Models/
│   │   ├── MeetingState.swift               ← State machine enum
│   │   ├── TranscriptionResult.swift        ← Transcript model
│   │   ├── MeetingOutput.swift              ← Final output model (Codable)
│   │   └── LLMPromptResponse.swift          ← Structured JSON response from local LLM
│   ├── Recording/
│   │   ├── AudioRecorder.swift              ← Mic capture via AVCaptureSession
│   │   └── AudioRecorderDelegate.swift      ← AVCaptureFileOutputRecordingDelegate
│   ├── Transcription/
│   │   ├── Transcriber.swift                ← WhisperKit wrapper (chunked)
│   │   └── TranscriptionProgress.swift      ← Progress tracker for UI
│   ├── Processing/
│   │   ├── LocalLLMSummarizer.swift         ← MLX model loader + inference
│   │   └── PromptBuilder.swift              ← Builds structured prompts for the local LLM
│   ├── Storage/
│   │   ├── FileManager+Extensions.swift     ← Save utilities
│   │   ├── SettingsStore.swift              ← UserDefaults wrapper
│   │   └── AudioCleanup.swift               ← Deletes raw audio post-transcription
│   └── Resources/
│       └── Info.plist                        ← NSMicrophoneUsageDescription, etc.
├── PLANNING.md
└── README.md
```

---

## Local LLM Prompt Template

The prompt must be tighter for a local 3B model than it would be for Claude. Use constrained output by defining a JSON schema the model must follow:

```
### System
You are a meeting summarizer. Output ONLY valid JSON in this exact schema. No other text.

### Schema
{
  "executiveSummary": "2-3 sentence summary",
  "keyTopics": ["topic 1", "topic 2"],
  "actionItems": [{"task": "description", "owner": "name or null"}],
  "meetingMinutes": {
    "attendees": ["inferred names"],
    "agenda": "inferred agenda",
    "decisions": ["decision 1"],
    "nextSteps": ["step 1"]
  }
}

### Transcript
[transcript text here]

### JSON Output
```

**Model recommendations:**
- **Llama 3.2 3B Instruct** — Best quality for instruction-following at this size (~2 GB download)
- **Mistral 7B Instruct v0.3** — Slightly better reasoning but larger download (~4 GB)
- Download model on first launch, cache it locally
- Keep the model warm in memory if the user runs back-to-back meetings
- Quantize to 4-bit to reduce memory usage on 8GB machines

---

## Permissions Checklist

| Permission | Purpose | Info.plist Key | When to Request |
|---|---|---|---|
| Microphone | Audio recording | `NSMicrophoneUsageDescription` | First time user clicks "Start Meeting" |
| Screen capture (Phase 2) | Periodic screenshots | `com.apple.developer.screen-capture` entitlement | Phase 2 |

---

## Next Steps

1. [x] Create project folder + planning doc
2. [ ] Create Xcode project with SwiftUI, target macOS 14
3. [ ] Configure Info.plist (mic permission, background audio mode)
4. [ ] Set up `MenuBarExtra` with icon states
5. [ ] Implement `MeetingState` enum + `MeetingStatusViewModel`
6. [ ] Implement AudioRecorder (AVCaptureSession → M4A via AVAssetWriter)
7. [ ] Integrate WhisperKit for chunked transcription (base model)
8. [ ] Integrate MLX Swift + local LLM for summarization (Llama 3.2 3B)
9. [ ] Build PromptBuilder + JSON parsing
10. [ ] Wire up full flow: Record → Transcribe → Summarize → Save as .md
11. [ ] Add cleanup step (delete raw audio after success)
12. [ ] Test with real meetings
13. [ ] Phase 2: screen capture (ScreenCaptureKit), system audio, pause/resume
14. [ ] Phase 3: live transcription, calendar integration, search

---

## Known Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Local LLM output isn't valid JSON | Use constrained grammar / JSON mode in the inference engine; fall back to regex extraction |
| WhisperKit is slow on older Macs | Use `base` model; offer `tiny` as a setting for older hardware |
| Local LLM is slow on 8GB RAM | Use the 3B model, not 7B; quantize to 4-bit |
| Long meeting transcript exceeds LLM context | Chunk the transcript and summarize in sliding windows, then merge |
| Mac sleeps during recording | Use `beginActivity` with `NSBackgroundActivity` to prevent App Nap |
| First launch downloads 2-4GB model | Show download progress bar in menu; cache model permanently afterward |
