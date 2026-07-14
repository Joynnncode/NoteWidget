# Execution Plan (staged, one small step at a time)

Principle: after each step, actually run and verify it before moving to the next one — don't stack up too many changes at once. After finishing a step, record what was done that day and what's left in [dev-log/](../dev-log/).

Progress is marked with `[ ]` / `[x]` and updated as work proceeds.

---

## Stage 0: Environment setup ✅ Done

- [x] Confirm the Mac's system version (macOS 26.5.1, Apple Silicon)
- [x] Confirm Xcode is fully installed from the App Store (Xcode 26.6)
- [x] Open Xcode once, accept the license agreement, wait for additional components to finish installing
- [x] Confirm the command-line tools point at the full Xcode install (`xcode-select -p` → `/Applications/Xcode.app/Contents/Developer`)

---

## Stage 1: Basic version — can take notes, can save ✅ Done

What actually got done (a bit more than originally planned, since the list + edit view got built in passing while debugging the floating-window issues):
- [x] Set up the project skeleton with Swift Package Manager (`Package.swift` + `Sources/NoteWidget/`)
- [x] Build the `Note` / `Tag` data models (SwiftData)
- [x] Floating note widget (`FloatingWidgetView`, a normal titled window + `.floating` level for now, full-screen support not yet done — see stage 4): input box + save button + open-list button
- [x] Note list main window (`NoteListView`): shown newest-first, tapping a note opens the editor (`NoteEditView`)
- [x] **Verified**: typing text and tapping save, the list showing newest-first, editing and saving a note, and notes still being there after quitting and reopening — all confirmed working

### Gotchas (important, keep in mind for future work)
This stage took a long time to debug; recorded here to avoid repeating the same mistakes:

1. **`TextEditor` has a text-clipping rendering bug on this particular machine's system/toolchain combination** (only the bottom half of the text shows). Fix: use `TextField("...", text:, axis: .vertical).textFieldStyle(.plain).lineLimit(n...m)` instead of `TextEditor` — similar visual result, no clipping. (Update, 2026-07-14: this `TextField` approach turned out to have its own Enter-key bug — see the bugfix note further down. Neither built-in option should be used anymore; use `MultilineTextField` instead.)
2. **`NSApp.delegate` reads as `nil`**, even though `@NSApplicationDelegateAdaptor` is initialized normally. Don't rely on `NSApp.delegate as? AppDelegate` to get the AppDelegate instance — use our own `AppDelegate.shared` (a static property assigned in `applicationDidFinishLaunching`) instead.
3. **When multiple windows use `NSWindow.level` to float on top, the levels must be consistent** — otherwise a window with a higher level will keep blocking a new window with a lower level, even though the new window actually opened fine (this shows up as "I clicked it and nothing happened"). The floating widget and list window are both set to `.floating`.
4. **When debugging, always confirm with `ps aux | grep NoteWidget` that only one process is running** before having someone test it. Before re-running after a code change via `swift run` or the raw binary, always kill the old process first (`pkill -9 -f NoteWidget`) — otherwise having both an old and new window around at once produces contradictory feedback that's hard to debug.
5. For everyday testing, prefer **packaging as a `.app` and launching with `open`** (rather than running `swift run` / the bare executable directly) — behavior is closer to real-world usage. To package: after `swift build`, copy `.build/arm64-apple-macosx/debug/NoteWidget` to `NoteWidget.app/Contents/MacOS/NoteWidget` (`Info.plist` is already in place under `NoteWidget.app/Contents/`), then just `open NoteWidget.app`.

---

## Stage 2: Note list + tag filtering ✅ Done

- [x] Build the `NoteListView` main window, showing all notes newest-first (finished early, during stage 1)
- [x] Tapping a note opens the editor (finished early, during stage 1)
- [x] Build the tag filter bar `TagFilterBar` (with default "French Learning" and "General" tags, colored per each tag's custom color)
- [x] Add a tag picker (`Menu`) to the floating widget, so a tag can be chosen when saving a note
- [x] Tag management (more than originally planned, requested by the user): `TagManagementView` supports adding/deleting tags and customizing each tag's color (`Tag.colorHex` + `ColorPicker`)
- [x] Changed the input box to auto-grow as the floating widget is resized (the previous fixed line-count limit didn't take effect on window resize — now fixed)
- [x] **Verified**: saving notes with different tags, the list ordering + filtering both work correctly; adding/deleting tags and changing colors all work; the input box grows along with the resized window

### Gotchas (additional)
- **When adding a new field to a SwiftData model, give it a default value directly at the property declaration** (e.g. `var colorHex: String = "#FF6B9D"`) — don't only give a default in the `init` parameter. Otherwise, automatic migration of old data will fail because a required field has "no value," crashing the app on launch with `Fatal error: could not create local database`. Since this was only test data at the time, the local database was simply deleted and recreated (`~/Library/Application Support/default.store*`), but this needs to be avoided once there's real data — think about whether a field needs a default before adding it.

### Extra feature (requested by the user, not in the original plan)
- [x] Added a delete (trash icon) button to each note in the list

---

## Stage 3: Global keyboard shortcut to show/hide ✅ Done

- [x] Add the `KeyboardShortcuts` dependency (pulled in automatically via `Package.swift`'s `dependencies`; resolved automatically by `swift build`, no manual Xcode steps needed)
- [x] Bind the default shortcut ⌃⌥N to show/hide the floating widget
- [x] **Verified**: switching to another app in the foreground, pressing ⌃⌥N correctly hides/shows the widget again
- Known limitation (not a bug, this is what stage 4 addresses): if a video enters macOS's true full-screen mode (its own Space), the floating widget won't show up there yet — that's exactly what stage 4 ("staying on top in full screen") is meant to solve

---

## Stage 4: Staying on top in full screen (key verification item) ✅ Done

- [x] Add the `.nonactivatingPanel` style and full `collectionBehavior` (`.canJoinAllSpaces` + `.fullScreenAuxiliary` + `.stationary` + `.ignoresCycle`) to the floating window
- [x] Apply the same treatment to the list window (missed at first — see the gotchas below)
- [x] **Verified**: with a video playing full screen, the floating widget floats on top and text can be typed into it normally; clicking into the input box doesn't kick the video out of full screen; tapping "List" shows the list window correctly over the full-screen view too; note editing works correctly

### Gotchas (stage 4)
This step also took a lot of repeated debugging; recorded here:

1. **Adding `.nonactivatingPanel` + `.fullScreenAuxiliary` to the floating widget alone isn't enough** — the widget displayed correctly over full-screen video, but the list window opened by tapping "List" simply refused to appear over the full-screen view (it could only be seen after returning to the regular desktop). The reason was that the list window was still a normal focus-stealing window/panel at the time (`.titled` but without `.nonactivatingPanel`). **The list window also needs to be an `NSPanel` + `.nonactivatingPanel`** (it can keep `.titled`/`.closable` etc. at the same time — the two don't conflict) for its behavior to match the floating widget.
2. **Don't call `NSApp.activate(ignoringOtherApps: true)` in any "show/toggle window" logic** — calling it while a full-screen video is playing kicks the system out of the full-screen Space back to the regular desktop (this was the other reason "you had to go back to the desktop to see the list"). This call should only be used once, right at app **launch**; showing/hiding windows afterward only needs `makeKeyAndOrderFront` / `orderOut`.
3. **Windows need to be created before entering full screen** — if a new window is only created for the first time after another app is already in full screen, the system won't necessarily put that new window into that full-screen Space. The list window is now created up front at app launch just like the floating widget (hidden immediately with `orderOut`), and tapping "List" just calls `makeKeyAndOrderFront` on the window that already exists, instead of creating it on demand.
4. Debugging this kind of issue also required strictly following the stage 1 lessons: change one variable at a time, repackage, confirm only one process is running, then test.

---

## Stage 6: Pink UI polish ✅ Done

The user chose to do this step first (skipping stage 5, to come back to it later).

- [x] Added `Theme.swift`: a shared `Color.brandPink` brand color constant (not using Assets.xcassets' AccentColor — managing a resource catalog in a plain SPM executable is fiddly, and defining the color as a code constant is more reliable with the same visual result)
- [x] Save/Done/add-tag buttons use `.buttonStyle(.borderedProminent) + .tint(Color.brandPink)`; icon buttons (list, tags) use pink `foregroundStyle`
- [x] Font changed uniformly to `.font(.system(.body, design: .rounded))` (rounded style)
- [x] Note list switched from `List` to `ScrollView + LazyVStack`, with each note as a rounded card (`cornerRadius(12)` + light shadow), making the card style easier to achieve
- [x] **Verified**: the floating widget, list, tag management, and edit window are all visually consistent, pink is carried throughout, and every action is obvious at a glance

---

## Stage 5: Image/screenshot support ✅ Done

- [x] Added an `imageData: Data?` field to the `Note` model (optional field, doesn't have the migration concerns that `colorHex` did)
- [x] The floating widget supports dragging an image in from Finder (`.onDrop`), with the image and text sharing the same input box container
- [x] The list shows image thumbnails, and the edit window can view/remove the image too
- [x] Thumbnails support tapping to view a larger version (`ThumbnailImageView`, opens a bigger image preview)
- [x] **Verified**: dragging an image into the floating widget, saving, and seeing the image in both the list and edit window; tapping a thumbnail enlarges it

### Gotchas (stage 5)
- **A "paste image" icon button that read directly from the clipboard was tried at first, and this button simply would not respond to clicks** no matter what was changed (different icon, layout safeguards). The root cause was never found, so this feature was dropped in favor of drag-and-drop only (confirmed sufficient by the user). Worth keeping in mind if clipboard-paste support is ever revisited.
- **The `TextEditor` clipping bug (see stage 1) doesn't affect this part**, since the image preview uses `Image`, and the text portion was already using the `TextField(axis: .vertical)` swapped in during stage 1 — no repeat of that particular bug here.
- The image and input box were originally two separate blocks (a standalone image preview box and a standalone text input box); the user found this "ugly," with the image positioned oddly and the input box no longer growing with the window. Fixed by putting the image and text into the same rounded container as a single "input area," with the input box using `.frame(maxWidth: .infinity, maxHeight: .infinity)` again to grow with the window.

### Extra change: UI switched to English (requested by the user)
- [x] All UI text (buttons, menus, window titles, placeholders) changed from Chinese to English; both note input boxes' placeholder text was simply left blank
- [x] The existing default tags "法语学习"/"常规" were renamed once, via a one-time migration, to "French Learning"/"General" (`AppDelegate.renameLegacyChineseTagsIfNeeded()`); new installs seed the English names directly
- Project docs (`docs/`, `dev-log/`) stayed in Chinese at the time, since only the app UI itself was translated; an English `README.md` was added to the GitHub repo. (Update, 2026-07-14: the docs and dev logs have since been translated to English too — see below.)

---

## Bugfix: Enter key didn't create a new line in the input box (2026-07-14)

- Problem: the user reported that typing in either input box (the floating widget's quick input, or the note edit window) and pressing Enter selected all the text instead of inserting a newline.
- Investigation: `TextField(axis: .vertical)` (noted in the stage 1 gotchas) itself has this Enter-key bug (it triggers select-all instead of inserting a newline), and `TextEditor` has the rendering-clipping bug on this machine — so neither of SwiftUI's built-in options could be used.
- Fix: added `Sources/NoteWidget/Views/MultilineTextField.swift`, a hand-rolled `NSViewRepresentable` wrapping a plain `NSTextView`, giving full control over the behavior instead of depending on either buggy SwiftUI component. Both the floating widget's and the note edit window's input boxes were switched to this new component.
- [x] **Verified**: the user confirmed by testing that Enter now creates a new line correctly in the floating widget's input box

### Rule for any new input box going forward (supersedes the stage 1 gotcha)
- Don't use `TextField(axis: .vertical)` (Enter selects all the text instead of creating a new line)
- Don't use `TextEditor` (text rendering gets clipped on this machine)
- Always use `MultilineTextField(text:)` from `Sources/NoteWidget/Views/MultilineTextField.swift`

---

## Repo language cleanup (2026-07-14)

- The user asked for no Chinese text to appear anywhere on GitHub. All project docs (`docs/`, `dev-log/`) and `CLAUDE.md` were translated to English, and the Chinese-named doc files were renamed to English filenames (e.g. `01-需求文档.md` → `01-requirements.md`).
- Existing git commit history (which has some Chinese commit messages) was intentionally left as-is per the user's choice, to avoid rewriting published history with a force-push. Only new commits going forward use English messages.
- Two Chinese string literals remain in `AppDelegate.swift` (`"法语学习"`, `"常规"`) — these are intentional and must stay as-is, since they match the exact legacy tag names stored in existing users' local databases for the one-time rename migration to work; they aren't display text.

---

## Current status

Stages 0-6 are all done, with core functionality and visual polish working end to end; the Enter-key newline bug has also been fixed (see above), and the repo docs/filenames have been fully translated to English (see above). There's no new planned stage right now — if new ideas come up, continue from here.
