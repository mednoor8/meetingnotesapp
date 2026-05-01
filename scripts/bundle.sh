#!/bin/bash
set -e
APP_DIR="$(dirname "$0")/Brief.app"
BUILD_BIN="$(dirname "$0")/debug/MeetingNotesApp"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$BUILD_BIN" "$APP_DIR/Contents/MacOS/Brief"
chmod +x "$APP_DIR/Contents/MacOS/Brief"

echo -n "APPL????" > "$APP_DIR/Contents/PkgInfo"

cat > "$APP_DIR/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Brief</string>
    <key>CFBundleIdentifier</key>
    <string>com.brief.app</string>
    <key>CFBundleName</key>
    <string>Brief</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSMicrophoneUsageDescription</key>
    <string>Brief needs microphone access to record your meetings for transcription.</string>
</dict>
</plist>
PLIST

# Ad-hoc code sign (required for menu bar apps on modern macOS)
codesign --sign - --force --deep "$APP_DIR" 2>&1

echo "Brief.app bundle created and signed at $APP_DIR"
