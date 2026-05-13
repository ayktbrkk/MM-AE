# Godot Engine Official Demo Shortlist

Source organization: https://github.com/godotengine
Primary source repo: https://github.com/godotengine/godot-demo-projects
License: MIT (see each copied demo's license/source files).

This folder contains a small shortlist of official Godot demo projects that are directly useful for this game's current needs.

Included demos

- gui_multiple_resolutions
  - Why: Reference for portrait/mobile UI scaling, margins, stretch settings, and safe HUD placement.
  - Most relevant to: overlay layout stability, Android portrait support.

- gui_theming_override
  - Why: Shows runtime stylebox/color overrides for Control-based UI.
  - Most relevant to: moving more UI styling away from ad-hoc procedural duplication.

- gui_rich_text_bbcode
  - Why: Reference for richer text presentation with RichTextLabel and BBCode.
  - Most relevant to: dialogue, info cards, chapter text emphasis.

- gui_translation
  - Why: Official example for CSV/PO translation flows and font handling.
  - Most relevant to: future localization support in this project.

- gui_pseudolocalization
  - Why: Lets UI be stress-tested for overflow before real translations are added.
  - Most relevant to: validating dialogue/info card/button layouts across longer strings.

- 2d_tween
  - Why: Clean examples of advanced tween usage.
  - Most relevant to: overlay transitions, HUD emphasis, marker motion polish.

Notes

- These are reference/demo projects, not installed addons.
- They were downloaded selectively to avoid bloating the workspace with the full demo repository.
- If needed later, additional official demos can be copied from godotengine/godot-demo-projects using the same approach.
