# NoteWidget

A tiny always-on-top sticky note widget for macOS. Jot things down while watching a video, browsing, or working in any other app — the widget stays visible above everything, including full-screen apps.

## Features

- **Always-on-top floating widget** with a quick text input and save button
- Stays visible **even over full-screen apps** (e.g. a full-screen video)
- Global keyboard shortcut (**⌃⌥N**) to show/hide the widget from anywhere
- **Tags** with custom colors — create, delete, and filter notes by tag
- A **note list** window, newest first, with tag filtering
- **Images**: drag an image straight into the input box; click any thumbnail to view it full size
- Click a note in the list to edit or delete it
- Pink accent theme, rounded system font, minimal UI

## Requirements

- macOS 14+
- Xcode (for building)

## Build & Run

This is a plain Swift Package (no `.xcodeproj`), so it can be opened directly in Xcode or built from the command line:

```bash
swift build
```

To run it as a proper macOS app (recommended over `swift run`, for correct window/focus behavior):

```bash
swift build
cp .build/arm64-apple-macosx/debug/NoteWidget NoteWidget.app/Contents/MacOS/NoteWidget
open NoteWidget.app
```

## Tech Stack

SwiftUI + AppKit (custom `NSPanel` for the floating/full-screen behavior) + SwiftData (local storage) + [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) for the global hotkey.

## Project Docs

Detailed requirements, technical design, and the day-by-day build log live in [`docs/`](docs) and [`dev-log/`](dev-log) (in Chinese).
