---
project: MeetingNotesApp
type: decisions
---

# Key Decisions

## 2026-04-30

### Free, on-device summarization (no paid APIs)
- Replaced Claude API with MLX + local LLM (Llama 3.2 3B)
- Trade-off: lower quality summarization, but zero cost and fully private
- Mitigation: tighter prompt templates, constrained JSON output, 4-bit quantization for 8GB machines

### M4A/AAC instead of WAV
- ~1MB/min vs 10MB/min — critical for 1hr+ meetings
- AVAssetWriter for compressed recording

### macOS 14 minimum
- Enables MenuBarExtra (pure SwiftUI, no AppKit bridging)
- Drops support for Intel Macs without Apple Silicon

### ScreenCaptureKit over CGDisplayStream
- CGDisplayStream is deprecated
- ScreenCaptureKit is the modern Apple API (macOS 12.3+)

### Dedicated Obsidian vault per project
- Every project gets its own vault at `/Users/mednoor/Claude/Claude Code/<ProjectName>/`
- Linked with GitHub for version control
- Keeps project knowledge isolated and portable
