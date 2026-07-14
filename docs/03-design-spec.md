# Design Spec

Corresponding requirements: [01-requirements.md](01-requirements.md).

## Design principles

Clean, intuitive. The user is non-technical, so every action should be obvious at a glance: the save button should be obvious, the entry point to open the list should be obvious, tag selection should be obvious — no hidden gestures or icon-guessing.

## Theme color

- Primary accent: **pink** (`Assets.xcassets/AccentColor`, reference value `#FF2D78` or a nearby system `.pink`), set as the global `.tint()`/`.accentColor()`, inherited by default by buttons, selected states, and icons.
- Selected tag filter button: filled pink; unselected: outlined/gray.

## Font

- System font with a rounded design (`Font.system(.body, design: .rounded)`), friendlier and less stark.
- Heading-style text ("Save" button, window titles) uses `.headline` / `.title3`; other body text uses the default `.body`.

## Spacing & card style

- 8pt grid: padding increases in steps of 8 / 16 / 24.
- Note cards: rounded corners `cornerRadius(12)` + a light shadow `shadow(radius: 2)`, making the floating widget look like a "sticky note," with the same card feel carried through each item in the note list.

## Key UI elements

- **Floating note widget (FloatingWidgetView)**:
  - A text input area (`TextEditor`)
  - A tag picker (`Menu`/`Picker` showing the current tag + a dropdown arrow, not a hidden gesture)
  - An obvious pink "Save" button (solid fill, not just an icon)
  - A small "open list" entry point (icon button, pink)

- **Note list main window (NoteListView)**:
  - Top: a tag filter bar (horizontally arranged pill buttons, including "All")
  - List: each note shows a text excerpt (truncated to 2-3 lines), a tag badge (small dot or colored pill), and a relative timestamp (e.g. "3 hours ago")
  - Sorted newest-first

## Acceptance criteria

- After opening the app, without any instructions, the user should immediately understand: where to type, where to tap to save, where to tap to see all notes, and how to pick a tag.
- The overall visual style is consistent, with pink carried through both the floating widget and the list window, and no jarring default-blue system controls.
