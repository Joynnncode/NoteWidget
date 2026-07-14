# Requirements

## One-line description

A floating sticky-note app for Mac: always stays on top of other websites/desktops/apps, so notes can be jotted down anytime (e.g. while watching a French-learning video, or copying down a line while browsing). All notes are saved automatically and sorted newest-first.

## Who it's for

Personal use only, on the user's own Mac. No cross-platform support, no sharing with others, no account login, no cloud sync needed.

## Core requirements

1. **Floating note widget**: a small window that always stays on top, including:
   - while browsing the web
   - while using other apps
   - **while watching a video in full screen** (key scenario, e.g. a full-screen French-learning video)
2. **Show/hide**: the widget is visible by default; also supports a global keyboard shortcut (no need to switch to this app first) to quickly hide/show it, default shortcut **⌃⌥N (Control+Option+N)**.
3. **Note list main window**: a separate window showing all saved notes, **sorted newest-first**.
4. **Content types**:
   - Phase 1: plain text (typed manually, or copy-pasted from a webpage/video caption)
   - Later phase: support pasting/dragging in images or screenshots
5. **Categories/tags**: notes can have a simple tag (e.g. "French Learning" vs "General"), and the list can be filtered by tag.
6. **Data storage**: fully local on the Mac, no account login, no iCloud sync needed.
7. **Visual style**: clean, intuitive; **pink as the primary accent color**; every action should be obvious at a glance (save, open list, pick a tag) — no icon-guessing.

## Explicitly out of scope

- No cross-platform support (Windows/web)
- No sharing with others / no App Store listing / no paid developer account notarization
- No account system, no cloud sync
- No image/screenshot support in phase 1 (planned for a later phase)
- No complex multi-level folder categorization, just simple tags

## Related docs

- Technical design: [02-technical-design.md](02-technical-design.md)
- Design spec: [03-design-spec.md](03-design-spec.md)
- Execution plan: [04-execution-plan.md](04-execution-plan.md)
