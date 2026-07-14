# Project Notes (working guide for Claude Code)

## What this project is

A floating sticky-note app for Mac (always-on-top, for jotting down notes while watching videos/browsing the web; notes are saved sorted newest-first). The user has no coding background and is fully non-technical — communicate in simple, clear language, and every step needs concrete, run-it-and-check verification; a successful compile alone is never enough to call something done.

## Standard file paths

- **Requirements**: `docs/01-requirements.md` — feature requirements, usage scenarios, explicitly out-of-scope items
- **Technical design**: `docs/02-technical-design.md` — tech stack, project structure, key technical points (staying on top, global shortcut, data model, etc.)
- **Design spec**: `docs/03-design-spec.md` — pink theme, fonts, spacing, UI element conventions
- **Execution plan**: `docs/04-execution-plan.md` — staged task checklist, marks current progress; check/update this before and after every dev session
- **Dev log**: `dev-log/YYYY-MM-DD.md` — each day's done items + to-dos; conventions in `dev-log/README.md`

## How to work (important)

1. **Advance one small step at a time**: strictly follow the stage order in `docs/04-execution-plan.md` — don't implement a pile of features across multiple stages in one go. After each small step, actually run and verify it before continuing.
2. **Before starting each dev session**: first check "Current status" in `docs/04-execution-plan.md` to see where things left off and what's next; recent `dev-log/` entries are also useful.
3. **After wrapping up a chunk of work**:
   - Update the checkbox states and "Current status" for the relevant stage in `docs/04-execution-plan.md`
   - Create or update that day's log file in `dev-log/`, recording what was done and what's left to do
4. **Communicating with a non-technical user**: explain progress/issues in plain language, avoiding unnecessary jargon; for steps that require the user to do something themselves (e.g. Xcode setup, Apple ID login), give clear step-by-step instructions.
5. **Verification before claiming done**: after finishing each stage, the app must actually be run to verify the corresponding behavior (see the "Verified" item for each stage in `docs/04-execution-plan.md`) — a successful compile alone is not enough to report something as done.
6. **When requirements change**: if the user proposes a new requirement or a change of direction, update `docs/01-requirements.md` first, updating the technical design/design spec too if needed, before touching any code.
