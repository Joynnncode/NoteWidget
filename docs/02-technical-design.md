# Technical Design

Corresponding requirements: [01-requirements.md](01-requirements.md).

## Tech stack

- **Swift + SwiftUI**: UI
- **AppKit (NSPanel)**: keeps the floating window on top and visible over full screen (SwiftUI's native window APIs aren't enough on their own, so this needs manual control)
- **SwiftData**: local data storage (Apple's official solution for macOS 14+, no extra database software needed)
- **KeyboardShortcuts** (third-party open-source library, pulled in via Swift Package Manager): global keyboard shortcut

## Project structure

The project uses **Swift Package Manager** (`Package.swift`) instead of a hand-written `.xcodeproj`. Reason: `.xcodeproj` is a complex internal format that's easy to get subtly wrong by hand, which can make Xcode fail to open it; `Package.swift` is a simple text file that can be generated accurately and reliably, and **can be opened, run, and debugged directly in Xcode** (Xcode natively supports Swift Package projects, working exactly like a `.xcodeproj`). It would also be easy to convert to a formal `.xcodeproj` later if ever needed.

```
Package.swift                  — project config (dependencies, targets)
NoteWidget.app/                — .app wrapper used for everyday testing (see "Dev environment notes" below)
Sources/NoteWidget/
  NoteWidgetApp.swift          — app entry point (just an empty Settings Scene; actual windows are managed manually by AppDelegate)
  AppDelegate.swift            — manages the floating widget window + list window + global shortcut, exposes the AppDelegate.shared singleton
  AppModelContainer.swift      — shared SwiftData ModelContainer
  FloatingPanel.swift          — `FloatingPanel` (a non-activating NSPanel subclass) + `ClickThroughHostingView` (an NSHostingView subclass that responds to the very first click)
  Models/
    Note.swift                 — note data model (text, timestamp, tag, later an image)
    Tag.swift                  — tag data model (name + custom colorHex)
  Views/
    FloatingWidgetView.swift   — floating widget UI: tag picker menu + image/text input area + open-list button + hide button + save button
    NoteListView.swift         — main window: tag filter bar + reverse-chronological note list (card style) + per-note delete
    NoteEditView.swift         — edit window shown after tapping a note, can view/remove the image
    ThumbnailImageView.swift   — thumbnail component, tap to view the full-size image
    TagFilterBar.swift         — tag filter bar (each tag uses its own custom color)
    TagManagementView.swift    — tag management sheet: add/delete tags, change tag color
  ColorHex.swift               — small helper for converting between Color and hex strings (used to store/read tag colors)
  NSImagePNG.swift             — small helper for converting NSImage to PNG Data (used to store images)
  GlobalHotKey.swift           — defines the global shortcut name (`.toggleWidget`, default ⌃⌥N)
  Theme.swift                  — shared `Color.brandPink` brand color constant
```

Theme colors/icons aren't stored in `Assets.xcassets` — managing a resource catalog in a plain SPM executable is fiddly, so colors are defined directly as code constants in `Theme.swift` instead, with the same effect and more reliability. The app icon hasn't been made yet either; this doesn't affect functionality for now.

## Key technical points

### 1. Floating on top + visible in full screen (done)

Both the floating widget and the list window are now `FloatingPanel` (an `NSPanel` subclass):

- Both `styleMask`s include `.nonactivatingPanel` (the floating widget is additionally borderless + `.resizable`; the list window keeps `.titled/.closable/.miniaturizable/.resizable` — the two don't conflict, so a window can be both "doesn't steal focus" and "has a title bar/close button/resizable" at once).
- `isFloatingPanel = true`, `level = .floating`.
- `collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]` (the list window doesn't need `.ignoresCycle`) — `.fullScreenAuxiliary` is the key setting that lets the window appear above another app's full-screen view.
- `FloatingPanel` overrides `canBecomeKey` (returns `true`, so the titleless floating widget can still receive keyboard input) and `canBecomeMain` (returns `false`, so it doesn't take over the main-window role).
- The floating widget's content uses `ClickThroughHostingView` (an `NSHostingView` subclass overriding `acceptsFirstMouse` to return `true`) instead of `NSHostingController`, so a "doesn't steal focus" panel responds to the very first click instead of needing a first click to activate and a second click to actually trigger a button. The list window still uses `NSHostingController` since it needs `.sheet` (the note edit popup) to work correctly.
- **Both windows are created once, up front, at app launch** (the floating widget shown immediately, the list window created then immediately hidden with `orderOut`) rather than created on first click — testing showed that if a new window is created only after another app is already in full screen, the system won't place it into that full-screen space.
- **Don't call `NSApp.activate(ignoringOtherApps:)` when showing/hiding windows** (use it only once, at app launch) — otherwise it will kick the system out of full screen back to the regular desktop during video playback. Routine show/hide should only use `makeKeyAndOrderFront(nil)` / `orderOut(nil)`.
- This part took a long time to get right; see the stage 1 and stage 4 notes in [04-execution-plan.md](04-execution-plan.md) for the full list of gotchas.

### 2. How key components call each other

**Don't use `NSApp.delegate as? AppDelegate` to get the AppDelegate instance** — testing showed `NSApp.delegate` reads as `nil` in this setup (root cause not fully confirmed; suspected to be related to using only a `Settings` Scene with no `WindowGroup`), which made button taps look like they "did nothing." Correct approach: `AppDelegate` exposes `static var shared: AppDelegate!`, assigned in `applicationDidFinishLaunching`; SwiftUI views consistently call `AppDelegate.shared.xxx()`.

### 3. Text input field

**Don't use `TextEditor`** — testing showed it has a text-clipping rendering bug on this particular system/toolchain combination. **Don't use `TextField(axis: .vertical)` either** — it selects all the entered text instead of inserting a newline when Enter is pressed. Use the hand-rolled `MultilineTextField` (in `Sources/NoteWidget/Views/MultilineTextField.swift`, wrapping a plain `NSTextView`) for all multi-line input instead — see the Enter-key bugfix note in [04-execution-plan.md](04-execution-plan.md).

### 4. Global keyboard shortcut (done)

Uses the `KeyboardShortcuts` open-source library (`Sources/NoteWidget/GlobalHotKey.swift` defines the shortcut name `.toggleWidget`), bound by default to **⌃⌥N** (chosen to avoid conflicts with common Safari/system/app shortcuts). `AppDelegate.toggleWidget()` handles showing/hiding the floating widget. To let the user customize the shortcut later, a `KeyboardShortcuts.Recorder` could be added to a settings screen, with no changes needed to the underlying logic.
- Known limitation: this shortcut correctly shows/hides the widget while it exists as a normal window, but if a video enters true system-level full screen (its own Space), the widget itself won't follow it there yet — that's what stage 4 addresses, unrelated to the shortcut itself.

### 5. Data model (SwiftData)

- `Note`: `id`, `text`, `createdAt` (written automatically on creation, not editable), `tag` (relationship to Tag, can be nil), `imageData: Data?` (optional field storing the image's PNG data)
- `Tag`: `id`, `name` (e.g. "French Learning", "General"), `colorHex` (user-customized color, stored as a hex string, converted via `ColorHex.swift`)
- On first launch the app seeds two default tags, "French Learning" (pink) and "General" (gray); the user can change colors or add/remove tags under "Manage Tags". Early versions seeded these with Chinese names; `AppDelegate.renameLegacyChineseTagsIfNeeded()` performs a one-time rename migration.
- **Important**: when adding a new field to a SwiftData model, give it a default value directly at the property declaration (`var colorHex: String = "#FF6B9D"`), not only in the `init` parameter — otherwise automatic migration of existing data will fail and crash the app on launch (see the stage 2 notes in [04-execution-plan.md](04-execution-plan.md)). `imageData` is an optional (`Data?`), so it migrates safely without needing a default.
- Image storage: PNG binary data is stored directly in SwiftData (`imageData: Data?`) rather than saving a file to disk and storing a path — note images are usually small, so this is simpler, and the data stays managed together with the note by SwiftData (deleting a note automatically leaves no orphaned image file).

### 6. List sorting & filtering

- The main window uses `@Query(sort: \Note.createdAt, order: .reverse)` for automatic newest-first ordering (done).
- The tag filter bar at the top (`TagFilterBar`) highlights the selected tag with its own custom color, with "All" fixed to pink; tapping a tag shows only that tag's notes, and tapping "All" restores the full list (done).
- Tag management (`TagManagementView`, a sheet): each tag row has a `ColorPicker` to change its color directly, and a delete button on the right; the bottom has a text field + color picker + "Add" button for creating new tags. Deleting a tag automatically leaves notes that used it "untagged" (SwiftData's default `.nullify` delete rule for the relationship).

### 7. Image support (done)

- The floating widget's image+text input area is a single rounded container (not two separate boxes); dragging an image in uses `.onDrop(of: [.image], ...)`, read via `NSItemProvider.loadObject(ofClass: NSImage.self)`, converted to PNG `Data` and stored in `attachedImageData`.
- Both the list and edit window use `ThumbnailImageView` to show thumbnails, tapping one opens a `.sheet` with the full-size image.
- A "paste from clipboard" button was attempted at one point; no matter what was tried (different icon, layout safeguards) it just wouldn't respond to clicks. The root cause was never found, so it was dropped in favor of drag-and-drop only (which turned out to be sufficient).

### 8. Visual design (done)

See [03-design-spec.md](03-design-spec.md) for details. The theme color uses the `Color.brandPink` constant in `Theme.swift` (rather than Assets.xcassets' AccentColor), the font is uniformly `.system(.body, design: .rounded)`, and the note list uses a `ScrollView + LazyVStack` card style (`cornerRadius(12)` + light shadow) instead of a plain `List`.

### 9. Interface language (done)

All app UI text (buttons, menus, window titles, placeholders) is in English, hardcoded directly in the code — no multi-language `Localizable.strings` system, since this is a single-user personal project and doesn't need language switching; hardcoding English strings is simpler. The project docs (`docs/`, `dev-log/`) are also in English now, matching the rest of the repo.

## Environment requirements

- macOS 14 or later (the user is currently on macOS 26.5.1/26.6, Apple Silicon, which is well above the minimum)
- Full Xcode installation (already installed: Xcode 26.6, with command-line tools pointed at the full install)

## Dev environment notes

- For everyday testing, prefer packaging as a `.app` and launching with `open`, rather than `swift run` directly: after `swift build`, copy `.build/arm64-apple-macosx/debug/NoteWidget` to `NoteWidget.app/Contents/MacOS/NoteWidget`, then `open NoteWidget.app`. `NoteWidget.app/Contents/Info.plist` is already set up and doesn't need to be rebuilt each time.
- Before re-running after a code change, always run `pkill -9 -f NoteWidget` to make sure no old process is still around (`ps aux | grep -i notewidget`) — otherwise having both an old and new window running at once makes test feedback confusing and hard to debug.
