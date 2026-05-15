# Master Planner Godot Analysis & DeepSeek Execution Packages

> Role directive: This document treats GPT-5.5 as Senior Game Director, Technical Lead, Systems Architect, and Production Planner. DeepSeek V4 Pro is the implementation engineer. This plan is analysis-first and intentionally avoids full production-code rewrites.

**Project:** MMAE / Bandırma Yolculuğu  
**Engine:** Godot 4.6.2, portrait Android-first, GDScript  
**Date:** 2026-05-14  
**Primary Goal:** Turn the current educational historical adventure into a scalable, maintainable, performant, visually polished, commercially viable indie game without breaking the existing playable loop.

---

## PROJECT OVERVIEW

### Genre, Audience, and Product Shape

- **Genre:** Child-facing pop-history educational adventure with light open-world diorama exploration, collectible clues, ethical choices, support-building, and wave/encounter gates.
- **Target audience:** 5-10 year old Turkish-speaking players, likely parent/teacher-approved, mobile portrait.
- **Current loop:** Choose Arda/Eda -> collect zone clues -> make a historical decision -> build support nodes -> overcome a wave -> move to next historical zone.
- **Content scope:** 9 playable zones and 31 events: room, Bandırma, Samsun, Havza, Amasya, Kongreler, Ankara, Sakarya, Final.
- **Commercial frame:** Strong educational identity and culturally specific subject. Best commercial path is premium/parent-safe or institutional/educational distribution before live-service monetization.

### Current Technical Maturity

- The project is beyond prototype: it has save/load, audio settings, overlay stack, Android export config, world captures, headless verification scripts, translated UI text, and multiple acceptance gates.
- The codebase is not yet production-shaped: several key scripts are too large and mix data, view, orchestration, content, and behavior.
- Existing tests are valuable and should be treated as a production safety net before any refactor.

### Architecture Snapshot

- Main scene: `res://scenes/main_menu.tscn`
- World scene: `res://scenes/world.tscn`
- Autoloads:
  - `AudioManager` -> `scripts/audio_manager.gd`
  - `SaveManager` -> `scripts/save_manager.gd`
  - `UIAnimation` -> plugin UID
- Core world modules:
  - `scripts/world.gd` orchestrates scene lifecycle and module wiring.
  - `scripts/world_state.gd` stores runtime state and serializes save data.
  - `scripts/world_builder.gd` builds all zone geometry and paper-diorama layers.
  - `scripts/world_marker.gd` spawns all zone markers and marker visuals.
  - `scripts/world_zone.gd` owns interaction routing, zone setup, decisions, and collection logic.
  - `scripts/world_wave.gd` owns support-building and wave completion.
  - `scripts/world_ui.gd` owns HUD, overlays, minimap, guidance, theme sync, captures, and runtime UI behavior.
  - `scripts/world_player.gd` owns character choice, movement, companion behavior, and nearby marker detection.

### Current Strengths

- Complete playable educational arc exists from room through Final.
- The paper-diorama direction is coherent and differentiated for a local cultural/educational market.
- Overlay system is centralized enough to test input blocking and back/cancel behavior.
- Save/load and lifecycle risks are already partially covered by headless tests.
- Art pipeline has moved toward structured SVG paper assets, with `asset_slot` metadata used for capture and validation.
- Recent Bandırma/Samsun/P5 work improved repeatable visual acceptance.

### Current Weaknesses

- `world_builder.gd` is 3000+ lines and is the largest scale risk.
- `world_zone.gd`, `world_ui.gd`, and `world_marker.gd` still contain too many responsibilities.
- Zone content is hardcoded across scripts instead of being resource-driven.
- Marker positions, zone goals, companion spots, support requirements, wave ids, and copy are split across multiple files.
- Many `get_node()` hard paths make scene changes risky.
- There are many old check/log output files in the repo root, which weakens production hygiene.
- Real audio assets are missing; procedural placeholders are acceptable for dev but not commercial release.
- Android release is not complete: release signing, device smoke, performance profiling, and release candidate checklist remain open.

### Biggest Opportunities

- Convert zone definitions into typed `Resource` assets or JSON-backed validated data.
- Split world building by zone into focused builder modules or scene components.
- Add a lightweight tutorial/onboarding layer for the first 3 minutes.
- Add a reward journal / collection album to improve retention without predatory monetization.
- Replace placeholder audio with a small, high-quality historical-adventure sound pack.
- Add device performance gates and capture-based visual regression for Android.

---

## CRITICAL ISSUES

### 1. Zone Data Is Hardcoded Across Multiple Systems

**Why it matters:** Adding or changing a zone currently requires edits in `world_builder.gd`, `world_marker.gd`, `world_zone.gd`, `world_wave.gd`, translations, captures, and tests. That creates regression risk and slows content expansion.

**Impact:** High production drag, high bug risk, hard to outsource content work.

**Risk if ignored:** Every new chapter becomes a custom engineering task instead of a content task.

### 2. World Builder Is a Monolith

**Why it matters:** `scripts/world_builder.gd` owns all zone geometry, paper assets, helper primitives, landmark symbols, and visual registration. It is difficult to review, profile, or safely refactor.

**Impact:** High technical debt and high merge-conflict risk.

**Risk if ignored:** Visual changes will keep creating accidental overlap, capture drift, and hidden regressions.

### 3. World UI Is a Mixed Responsibility Hub

**Why it matters:** `scripts/world_ui.gd` handles overlay registration, HUD layout, minimap, route panel, guidance arrow, visual effects, camera focus, theme sync, capture-related visibility, and save persistence hooks.

**Impact:** Medium-high. It works, but every UI polish change touches a sensitive shared file.

**Risk if ignored:** Android safe-area and lifecycle fixes will become fragile.

### 4. Production Release Gates Are Not Yet Fully Device-Based

**Why it matters:** Headless checks are strong, but mobile release confidence requires emulator/physical-device smoke and performance observation.

**Impact:** High for Android release.

**Risk if ignored:** Bugs may appear only on device: system bar overlap, background/resume issues, loading stutter, audio resume issues.

### 5. Audio and Feedback Are Still Prototype-Level

**Why it matters:** The game targets children; feedback, sound, and reward cadence are core to comprehension and retention.

**Impact:** High for perceived quality.

**Risk if ignored:** The game will feel educational but not premium.

---

## ARCHITECTURE REVIEW

### Folder Structure

**Good:**
- `scripts/`, `scenes/`, `assets/art/`, `translations/`, `tools/`, and `docs/` are clearly separated.
- `assets/art/world/<zone>/` gives art a scalable home.
- `tools/` contains targeted verification scripts, which is excellent.

**Problems:**
- Repo root contains many historical `godot_*`, `check_*`, and output text files. These should move to `artifacts/logs/` or be ignored.
- Unity remnants exist under `assets/Scenes`, `assets/Settings`, and `Packages`; they confuse project ownership unless intentionally retained for migration reference.
- Zone definitions are not centralized.

### Scene Composition

**Good:**
- `world.tscn` has clean top-level sections: `WorldState`, `WorldBuilder`, `WorldMarker`, `WorldWave`, `Props`, `Markers`, `ForegroundProps`, `Player`, `Companion`, `CanvasLayer`.
- Overlays are separate scenes.

**Problems:**
- The runtime modules rely heavily on exact node paths.
- Some systems are dynamically created in `_ready()` rather than authored as explicit child nodes. This is fine for modules, but it makes editor inspection harder.

### Script Responsibilities

**Healthy responsibilities:**
- `world.gd` has been reduced from a prior giant orchestrator and is now readable.
- `world_state.gd` is focused enough to keep.
- `overlay_manager.gd` is a solid central contract.

**Unhealthy responsibilities:**
- `world_builder.gd`: all zones + all geometry + all visual helper primitives.
- `world_ui.gd`: overlay, HUD, minimap, guidance, effects, camera, lifecycle, capture behavior.
- `world_zone.gd`: zone setup, collection, decision answers, transitions, callbacks, copy fallback.
- `world_marker.gd`: marker data, marker visuals, marker animation, marker cleanup.

### Signal Architecture

**Good:**
- Signals exist for state changes, overlays, audio, wave events, builder visual registration.

**Weak point:**
- Most modules still use direct calls through the world reference instead of subscribing to a small event bus or state events. This is not fatal, but it limits modularity.

### Global State

**Good:**
- Autoload use is moderate: audio, save, UI animation.

**Risk:**
- `SaveManager.pending_entry_action` is runtime-only global state. It is practical but should remain tightly scoped and covered by flow tests.

### Data-Driven Opportunities

Immediate candidates for `Resource` data:
- Zone id, display title, chip title, theme id.
- Goal kind and setup goal text key.
- Item counters and required support count.
- Marker list: kind, title key, text key, position.
- Companion reaction spots.
- Support/wave config now in `world_wave.gd::ZONE_CONFIG`.
- Capture acceptance config: camera, hidden UI, expected overlays.

### Ideal Architecture Evolution

Do not rewrite the whole game. Evolve in layers:

1. Add typed zone definition resources while keeping old code paths.
2. Move marker definitions out of `world_marker.gd`.
3. Move zone setup data out of `world_zone.gd`.
4. Split `world_builder.gd` into zone-specific builder files after data contracts are covered.
5. Split `world_ui.gd` into HUD, guidance, minimap, and camera helper components only after tests exist.

---

## GAME DESIGN REVIEW

### Player Onboarding

Current onboarding is functional but text-heavy. The first session asks a child to understand character choice, notes, markers, decisions, support building, and waves.

**Needed improvement:** Add a guided first-run tutorial that uses visual prompts, not long explanations.

### Retention and Reward Loop

Current reward loop:
- collect clue -> info/reward burst -> goal update -> decision/wave.

**Missing retention layer:**
- No persistent collection album.
- No chapter stars/medals summary.
- No parent/teacher progress view.
- No simple replay motivation.

### Progression

Current progression is linear and complete. That is acceptable for an educational story game.

**Better progression target:**
- Keep story linear.
- Add optional mastery: chapter badges, historical journal cards, replayable decision recap.

### Game Feel

Strengths:
- Companion, reward burst, marker halo, paper art, transition overlays.

Gaps:
- Movement and interaction feedback can be richer.
- Support placement could feel more tactile.
- Wave completion can use more celebratory but short child-friendly feedback.

### Accessibility

Strengths:
- Large portrait UI.
- Turkish localization file.
- Focus/accessibility verifier exists.

Gaps:
- No explicit dyslexia-friendly mode.
- No narration/voiceover plan.
- No subtitle speed or text size option.
- Some historical terms may need child-friendly glossary cards.

### Monetization Strategy

Do not add aggressive monetization. Recommended options:

1. **Premium paid app** for families.
2. **School/institution bundle** with teacher guide.
3. **Free demo + paid full story unlock**.
4. **Optional printable activity pack** outside the app.

Avoid ads and consumable currencies; they conflict with child-safe educational trust.

---

## PERFORMANCE REVIEW

### Main Risks

- Large procedural node count from paper cutouts, polygons, marker decorations, and reward effects.
- `_process()` in `world.gd` calls multiple update systems every frame.
- Marker animations run across all markers via `animate_feedback()`.
- SVG textures and many layered CanvasItems may stress lower-end Android devices.
- Loading overlay uses threaded request behavior, but device stutter still needs real profiling.

### Existing Good Practices

- Headless parse and flow checks exist.
- Loading overlay cancellation is covered.
- UI animations are tween-based in many areas.
- Android portrait resolution is fixed and known.

### Optimization Roadmap

1. Add performance measurement gates before optimizing blindly.
2. Track node counts per zone in a verifier.
3. Add optional marker animation throttle for non-nearby markers.
4. Convert repeated decorative primitives into cached scenes or MultiMesh-like batching where practical.
5. Ensure SVG import sizes are bounded; avoid runtime scale extremes.
6. Profile low-end Android: startup time, first world load, zone transition, overlay open, heavy zones.

### Performance Anti-Patterns To Avoid

- Do not convert everything to a custom ECS.
- Do not pool every node before measuring.
- Do not add shaders/post-processing before Android frame stability is proven.
- Do not split monoliths and optimize in the same task.

---

## VISUAL REVIEW

### Art Direction

The paper-diorama direction is the right identity: tactile, warm, educational, and distinctive. It can sit near modern premium indie design language if UI and feedback are tightened.

Reference philosophy:
- **Hades:** strong reward feedback, readable hierarchy.
- **Hollow Knight:** restrained atmosphere and silhouette clarity.
- **Dead Cells:** punchy moment-to-moment feedback.
- **Rift of the NecroDancer:** bold rhythm, clear UI motion language.
- **Brotato / Vampire Survivors:** instant readability and reward cadence.

### UI Consistency

Recent work improved HUD readability, but the UI still risks repeated labels and heavy text. Keep the rule:

- One active objective surface at a time.
- Marker labels are for spatial targets.
- HUD objective is for next action.
- Dialogue/info card is for historical meaning.

### Visual Hierarchy

The best captures are those where:
- Top HUD has one compact goal.
- World labels do not sit under HUD.
- Guidance arrow/halo supports navigation without repeating copy.
- Marker cards are readable and not edge-clipped.

### Visual Polish Opportunities

- More consistent transition vocabulary per chapter.
- Small paper flutter or stamp feedback on clue collection.
- Support placement "fold-out" animation.
- Better wave start anticipation and completion burst.
- Subtle camera nudge toward target only when it helps comprehension.
- Real audio and short stingers will multiply perceived quality.

---

## QUICK WINS

1. **Root hygiene cleanup plan**
   - Move old `godot_*.txt`, `check_*.txt`, and output files to `artifacts/logs/` or ignore/remove after confirmation.
   - Impact: cleaner repo and safer onboarding for new agents.

2. **Run P10 smoke gate**
   - Use `tools/verify_app_lifecycle_contract.gd`, `tools/validate_game_flow.gd`, overlay/focus checks, and parse check as one command.
   - Impact: faster release confidence.

3. **Add zone node-count verifier**
   - Capture per-zone total CanvasItem/Node2D count.
   - Impact: measurable performance baseline.

4. **Create a child-friendly glossary data file**
   - Define terms like `milli irade`, `telgraf`, `kongre`, `cumhuriyet`.
   - Impact: educational clarity and parent trust.

5. **Audio replacement list**
   - List exact BGM/SFX placeholders and desired real audio.
   - Impact: high perceived polish for low engineering risk.

---

## HIGH IMPACT IMPROVEMENTS

### A. Resource-Driven Zone Definitions

Move marker lists, setup goals, support requirements, companion spots, and wave ids into data resources.

**Impact:** Expansion becomes content work, not code surgery.

**Risk:** Medium. Must be incremental and tested per zone.

### B. Builder Decomposition

Split `world_builder.gd` into common primitives plus zone builders.

**Impact:** Lower merge conflicts and easier art iteration.

**Risk:** Medium-high. Only do after visual acceptance tests are stable.

### C. First-Run Tutorial Layer

Add a 3-minute guided tutorial for character choice, movement, clue, decision, and support.

**Impact:** Higher completion rate for children.

**Risk:** Medium. Must not block replay or continue flow.

### D. Journal / Album Progression

Add a persistent "Tarih Defteri" where collected cards and chapter badges appear.

**Impact:** Retention, parent/teacher value, replay motivation.

**Risk:** Medium. Needs save schema migration.

### E. Android Release Pipeline

Finalize debug/release separation, signing, smoke checklist, device performance observations, and RC notes.

**Impact:** Commercial readiness.

**Risk:** High if delayed until the end.

---

## TECHNICAL DEBT

### High Priority

- `world_builder.gd` size and mixed responsibilities.
- Zone data scattered across scripts.
- `world_ui.gd` as a multi-system UI hub.
- Release signing undefined.
- No real device performance baseline.

### Medium Priority

- Marker visuals and marker data in one file.
- Save schema lacks explicit migration tests for future progression features.
- Translation coverage exists but not all gameplay copy is fully externalized.
- Old root logs and Unity remnants create repository noise.

### Low Priority

- Some procedural visual helpers could become reusable scenes.
- Minimap/route panels can be optional mode-specific components.
- More editor tooling can come after data model stabilizes.

---

## ROADMAP

### Short-Term Roadmap

| Priority | Task | Complexity | Risk | Dependencies | Expected Impact |
|---|---|---:|---:|---|---|
| CRITICAL | Finish P10 device/emulator smoke gate | M | M | Android SDK/device | Release confidence |
| CRITICAL | Create P11 performance observation report | S-M | M | P10 | Low-end Android risk visibility |
| HIGH | Root hygiene and artifact cleanup | S | L | none | Cleaner production repo |
| HIGH | Zone node-count/performance verifier | S | L | current tools | Measurable optimization baseline |
| HIGH | Audio replacement specification | S | L | AudioManager map | Premium feel plan |

### Mid-Term Roadmap

| Priority | Task | Complexity | Risk | Dependencies | Expected Impact |
|---|---|---:|---:|---|---|
| CRITICAL | Resource-driven zone definition pilot for Bandırma/Samsun | M | M | existing flow tests | Scalable content architecture |
| HIGH | Marker data extraction from `world_marker.gd` | M | M | zone resource pilot | Safer marker iteration |
| HIGH | Tutorial layer for first 3 minutes | M | M | stable UI contracts | Better child onboarding |
| HIGH | Journal/album progression MVP | M | M-H | save migration plan | Retention and parent value |
| MEDIUM | Builder split by zone family | L | M-H | data contracts + visual tests | Maintainability |

### Long-Term Roadmap

| Priority | Task | Complexity | Risk | Dependencies | Expected Impact |
|---|---|---:|---:|---|---|
| HIGH | Full audio production pass | M | M | audio spec | Commercial polish |
| HIGH | Release candidate pipeline | M | M | P10/P11/P12 | Store readiness |
| MEDIUM | Teacher/parent progress mode | M | M | journal data | Institutional appeal |
| MEDIUM | Accessibility options | M | M | UI settings | Broader usability |
| LOW | Optional DLC/extra chapter framework | L | M | resource-driven content | Future expansion |

---

## DEEPSEEK IMPLEMENTATION PACKAGES

### Package 1: P10 Android Lifecycle Smoke Gate Finalization

**OBJECTIVE**

Finalize P10 by making lifecycle/navigation validation repeatable through one local command and, when a device is present, one adb-driven smoke checklist.

**CONTEXT**

Inspect first:
- `tools/verify_app_lifecycle_contract.gd`
- `tools/validate_game_flow.gd`
- `docs/ANDROID_RELEASE_CHECKLIST.md`
- `docs/EXECUTION_PACKAGES_PLAN.md`
- `scripts/main_menu.gd`
- `scripts/world.gd`
- `scripts/loading_overlay.gd`

**IMPLEMENTATION DETAILS**

- If `tools/run_p10_smoke_gate.ps1` already exists, verify it runs parse, app lifecycle, flow, overlay, focus, and UI regression gates.
- If missing, create a PowerShell runner that calls:
  - Godot `--headless --check-only --path . --quit`
  - `res://tools/verify_app_lifecycle_contract.gd`
  - `res://tools/validate_game_flow.gd`
  - `res://tools/verify_overlay_input_contract.gd`
  - `res://tools/verify_ui_focus_accessibility.gd`
- Add optional adb detection:
  - Check `adb` in PATH.
  - Check `$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe`.
  - If no device, print `DEVICE_SMOKE_SKIPPED_NO_ADB_OR_DEVICE` and exit success only if code gates passed.
- Update `docs/ANDROID_RELEASE_CHECKLIST.md` with the exact runner command.

**FILES TO MODIFY**

- `tools/run_p10_smoke_gate.ps1`
- `docs/ANDROID_RELEASE_CHECKLIST.md`
- `docs/EXECUTION_PACKAGES_PLAN.md`

**GODOT BEST PRACTICES**

- Do not simulate Android lifecycle by changing engine internals.
- Prefer existing verifier scripts over adding broad integration tests.
- Keep script output machine-readable.

**DO NOT BREAK**

- `verify_app_lifecycle_contract.gd`
- save/continue flow
- loading overlay cancellation
- menu back/exit-confirm behavior

**ACCEPTANCE CRITERIA**

- One PowerShell command runs all P10 automatic gates.
- It exits non-zero on any failed gate.
- It clearly reports whether device smoke was skipped or available.
- `APP_LIFECYCLE_CONTRACT_OK` appears in successful output.

**OPTIONAL POLISH**

- Emit a short markdown summary into `artifacts/logs/p10_smoke_<timestamp>.md`.

**TEST CHECKLIST**

- Run `powershell -ExecutionPolicy Bypass -File tools/run_p10_smoke_gate.ps1`.
- Run with adb absent and confirm graceful skip.
- Run `Godot_v4.6.2-stable_win64_console.exe --headless --check-only --path . --quit`.

---

### Package 2: Repository Hygiene and Artifact Policy

**OBJECTIVE**

Remove production confusion caused by old root-level logs and define where generated evidence belongs.

**CONTEXT**

Inspect first:
- repo root files matching `godot_*.txt`, `check_*.txt`, `*_output.txt`
- `.gitignore`
- `artifacts/`
- `docs/EXECUTION_PACKAGES_PLAN.md`

**IMPLEMENTATION DETAILS**

- Create `artifacts/logs/README.md` explaining temporary verification output.
- Update `.gitignore` to ignore root-level Godot/check output logs unless explicitly stored under `artifacts/logs/accepted/`.
- Do not delete existing tracked files unless user approves. If files are untracked, move them to `artifacts/logs/archive/` only after confirming they are not referenced.
- Add a short `docs/REPO_HYGIENE.md` explaining:
  - source files
  - generated captures
  - accepted captures
  - temporary logs

**FILES TO MODIFY**

- `.gitignore`
- `docs/REPO_HYGIENE.md`
- `artifacts/logs/README.md`

**GODOT BEST PRACTICES**

- Never ignore `.import` files for committed assets.
- Keep accepted visual evidence under `artifacts/renders/`.

**DO NOT BREAK**

- Existing accepted capture paths in docs.
- Godot import metadata.

**ACCEPTANCE CRITERIA**

- New agents can identify which generated files are safe to ignore.
- `git status --short --untracked-files=all` no longer gets polluted by temporary logs after a test run.

**OPTIONAL POLISH**

- Add `tools/clean_temp_logs.ps1` with dry-run default.

**TEST CHECKLIST**

- Run a headless check.
- Confirm new temporary output does not appear as untracked root clutter.

---

### Package 3: Zone Definition Resource Pilot

**OBJECTIVE**

Start moving zone gameplay data out of code by piloting `Resource`-driven definitions for Bandırma and Samsun only.

**CONTEXT**

Inspect first:
- `scripts/world_marker.gd`
- `scripts/world_zone.gd`
- `scripts/world_wave.gd`
- `scripts/world_state.gd`
- `translations/ui_texts.csv`
- `tools/validate_game_flow.gd`
- `tools/verify_samsun_benchmark_contract.gd`

**IMPLEMENTATION DETAILS**

- Create `scripts/data/zone_definition.gd` as a typed `Resource`.
- Fields should include:
  - `zone_id`
  - `display_title_key`
  - `setup_goal_key`
  - `goal_kind`
  - `item_counter_key`
  - `item_total`
  - `required_supports`
  - marker definitions as dictionaries or nested resources.
- Create resource files for `ship` and `samsun_rift` under `assets/data/zones/`.
- Add a loader helper that can return a definition by zone id.
- Wire only Bandırma/Samsun marker spawn through the new data path.
- Keep existing hardcoded fallback for all other zones.

**FILES TO MODIFY**

- Create `scripts/data/zone_definition.gd`
- Create `scripts/data/zone_marker_definition.gd` if nested resources are cleaner.
- Create `assets/data/zones/ship.tres`
- Create `assets/data/zones/samsun_rift.tres`
- Modify `scripts/world_marker.gd`
- Modify `scripts/world_zone.gd` only where necessary.
- Add `tools/verify_zone_definition_contract.gd`

**GODOT BEST PRACTICES**

- Use typed Resources for editor-friendly data.
- Keep resource loading deterministic.
- Avoid dynamic string parsing for core gameplay data.

**DO NOT BREAK**

- Bandırma loop.
- Samsun benchmark.
- save/continue.
- marker metadata keys: `kind`, `title`, `text`, `collected`.

**ACCEPTANCE CRITERIA**

- Bandırma and Samsun spawn from resource data.
- All existing tests still pass.
- `verify_zone_definition_contract.gd` confirms resource marker counts and required fields.

**OPTIONAL POLISH**

- Add editor-only comments in resources for content designers.

**TEST CHECKLIST**

- `verify_zone_definition_contract.gd`
- `validate_game_flow.gd`
- `verify_samsun_benchmark_contract.gd`
- Godot `--headless --check-only --path . --quit`

---

### Package 4: Marker Data and Visual Split

**OBJECTIVE**

Separate marker definitions from marker rendering/animation logic.

**CONTEXT**

Inspect first:
- `scripts/world_marker.gd`
- new zone definition work from Package 3
- `tools/verify_p5_late_zone_benchmark_contract.gd`

**IMPLEMENTATION DETAILS**

- Create `scripts/marker/marker_factory.gd` or `scripts/world_marker_visuals.gd`.
- Move only marker visual construction helpers from `world_marker.gd`.
- Keep public API `spawn_markers(area_key, world_root)` stable.
- Leave marker animation in `world_marker.gd` for this package unless it can be moved with zero behavior change.

**FILES TO MODIFY**

- `scripts/world_marker.gd`
- Create `scripts/world_marker_visuals.gd`

**GODOT BEST PRACTICES**

- Avoid inheritance hierarchy for marker kinds.
- Use composition: data in definitions, visuals in factory, behavior in zone/player systems.

**DO NOT BREAK**

- Marker node names and metadata.
- Guidance marker detection.
- collection hiding visuals.

**ACCEPTANCE CRITERIA**

- `world_marker.gd` loses visual construction bulk.
- Existing marker visuals look unchanged in captures.
- All marker contract tests pass.

**OPTIONAL POLISH**

- Add a visual style table per marker kind.

**TEST CHECKLIST**

- `verify_bandirma_guidance_contract.gd`
- `verify_p5_late_zone_benchmark_contract.gd`
- `validate_game_flow.gd`

---

### Package 5: World Builder Decomposition Plan and First Extraction

**OBJECTIVE**

Reduce `world_builder.gd` risk by extracting one low-risk zone builder into a focused helper without changing visuals.

**CONTEXT**

Inspect first:
- `scripts/world_builder.gd`
- accepted captures under `artifacts/renders/`
- `tools/capture_world_render.gd`

**IMPLEMENTATION DETAILS**

- Do not split every zone at once.
- Extract only common primitive helpers or one stable zone such as `room` into `scripts/world_builders/room_builder.gd`.
- Keep `WorldBuilder.build_world(area_key, world_root)` public API stable.
- Add a capture comparison note for the extracted zone.

**FILES TO MODIFY**

- `scripts/world_builder.gd`
- Create `scripts/world_builders/room_builder.gd`
- Possibly create `scripts/world_builders/world_build_context.gd`

**GODOT BEST PRACTICES**

- Avoid circular dependencies.
- Pass a small context object or explicit references instead of global lookups.

**DO NOT BREAK**

- `asset_slot` metadata.
- capture reproducibility.
- P5 visual acceptance.

**ACCEPTANCE CRITERIA**

- Extracted zone builds with identical marker/path/art intent.
- Godot parse passes.
- Capture tool still works.

**OPTIONAL POLISH**

- Add a `WorldBuildContext` resource/class to reduce parameter clutter.

**TEST CHECKLIST**

- Capture extracted zone before/after.
- `capture_world_render.gd`
- `validate_game_flow.gd`
- parse check.

---

### Package 6: First-Run Tutorial Layer

**OBJECTIVE**

Add a lightweight tutorial for the first 3 minutes without blocking replay or continue.

**CONTEXT**

Inspect first:
- `scripts/world_player.gd`
- `scripts/world_ui.gd`
- `scripts/world_zone.gd`
- `scripts/world_state.gd`
- `scripts/save_manager.gd`
- `tools/validate_game_flow.gd`

**IMPLEMENTATION DETAILS**

- Add tutorial state to save/settings, not only runtime memory.
- Tutorial phases:
  1. choose character
  2. tap/move to first note
  3. collect clue
  4. open decision
  5. build support
- Use small callouts and highlight rings, not long text.
- Add skip/replay support from settings or menu.

**FILES TO MODIFY**

- `scripts/world_ui.gd`
- `scripts/world_player.gd`
- `scripts/world_state.gd`
- `scripts/save_manager.gd`
- `translations/ui_texts.csv`
- Create `tools/verify_tutorial_contract.gd`

**GODOT BEST PRACTICES**

- Do not pause the tree for tutorial hints.
- Keep touch input responsive.
- Use existing overlay/input blocking contract.

**DO NOT BREAK**

- continue flow
- character choice
- Bandırma benchmark
- lifecycle pause/resume

**ACCEPTANCE CRITERIA**

- New save sees tutorial.
- Existing save does not get trapped.
- Skip persists.
- Headless tutorial verifier passes.

**OPTIONAL POLISH**

- Add a parent-friendly "tutorial replay" button.

**TEST CHECKLIST**

- new game flow
- continue flow
- lifecycle verifier
- tutorial verifier

---

### Package 7: Journal / Tarih Defteri MVP

**OBJECTIVE**

Add a persistent collection/journal layer that rewards learning and supports replay.

**CONTEXT**

Inspect first:
- `scripts/world_state.gd`
- `scripts/save_manager.gd`
- `scripts/info_card_overlay.gd`
- `assets/data/questions.gd`
- `translations/ui_texts.csv`

**IMPLEMENTATION DETAILS**

- Add `journal_entries_unlocked` to save data with migration-safe defaults.
- Unlock entries when clues or decisions complete.
- Add a journal button on main menu and optionally world HUD.
- Journal screen shows chapter cards: title, short child-friendly historical meaning, completion state.
- Keep v1 read-only; no complex filters.

**FILES TO MODIFY**

- `scripts/world_state.gd`
- `scripts/save_manager.gd`
- `scripts/main_menu.gd`
- `scenes/main_menu.tscn`
- Create `scenes/journal_overlay.tscn`
- Create `scripts/journal_overlay.gd`
- `translations/ui_texts.csv`
- `tools/verify_journal_save_contract.gd`

**GODOT BEST PRACTICES**

- Use a separate overlay scene.
- Use save schema defaults, not destructive migration.

**DO NOT BREAK**

- save version 1 loading.
- menu back button.
- settings overlay.

**ACCEPTANCE CRITERIA**

- Old saves load.
- New journal unlocks after collecting known items.
- Back/cancel closes journal before exit confirm.

**OPTIONAL POLISH**

- Add badge/stamp animation when a new journal entry unlocks.

**TEST CHECKLIST**

- journal save contract
- app lifecycle contract
- UI focus verifier

---

### Package 8: Audio Production Integration

**OBJECTIVE**

Replace procedural placeholder audio with real, small, mobile-safe audio assets.

**CONTEXT**

Inspect first:
- `scripts/audio_manager.gd`
- `docs/ROADMAP.md`
- `docs/VISUAL_DESIGN_SYSTEM.md`

**IMPLEMENTATION DETAILS**

- Create `docs/AUDIO_ASSET_LIST.md` listing required BGM and SFX.
- Add `assets/audio/bgm/` and `assets/audio/sfx/`.
- Keep procedural fallback if audio files are absent.
- Add loudness and loop notes.
- Add settings smoke test for BGM/SFX sliders.

**FILES TO MODIFY**

- `scripts/audio_manager.gd`
- `docs/AUDIO_ASSET_LIST.md`
- audio import files after assets are added
- `tools/verify_audio_contract.gd`

**GODOT BEST PRACTICES**

- Use `.ogg` for music loops.
- Keep short SFX compressed appropriately.
- Avoid large uncompressed WAV in mobile build.

**DO NOT BREAK**

- existing volume settings
- app pause/resume audio behavior
- headless audio skip behavior

**ACCEPTANCE CRITERIA**

- Game uses real audio when present.
- Procedural fallback still works in CI/headless.
- Audio pause/resume contract remains green.

**OPTIONAL POLISH**

- Add zone-specific ambient layers later, not in MVP.

**TEST CHECKLIST**

- audio contract
- app lifecycle contract
- manual settings slider smoke

---

### Package 9: Performance Observation and Node Count Gate

**OBJECTIVE**

Create measurable performance baselines before optimization work.

**CONTEXT**

Inspect first:
- `tools/capture_world_render.gd`
- `scripts/world_builder.gd`
- `scripts/world_marker.gd`
- `docs/ANDROID_RELEASE_CHECKLIST.md`

**IMPLEMENTATION DETAILS**

- Create `tools/measure_world_complexity.gd`.
- For each zone, instantiate world, transition/build zone, count:
  - total nodes
  - `Node2D`
  - `CanvasItem`
  - `Sprite2D`
  - `Polygon2D`
  - visible marker count
- Print machine-readable summary.
- Add thresholds as warnings first, not hard failures.
- Document results in `docs/PERFORMANCE_OBSERVATION.md`.

**FILES TO MODIFY**

- Create `tools/measure_world_complexity.gd`
- Create `docs/PERFORMANCE_OBSERVATION.md`
- Possibly update `tools/run_p10_smoke_gate.ps1` or create P11 runner.

**GODOT BEST PRACTICES**

- Measure before optimizing.
- Keep thresholds per zone.
- Do not reduce visuals blindly.

**DO NOT BREAK**

- capture tools
- world art acceptance

**ACCEPTANCE CRITERIA**

- One command prints complexity for all zones.
- P11 report includes worst zones and recommended profiling order.

**OPTIONAL POLISH**

- Add CSV output for tracking over time.

**TEST CHECKLIST**

- run complexity tool
- parse check
- capture worst zone

---

### Package 10: Accessibility and Reading Comfort Pass

**OBJECTIVE**

Improve readability and child accessibility without redesigning the full UI.

**CONTEXT**

Inspect first:
- `scripts/ui_tokens.gd`
- `scripts/hud_bar.gd`
- `scripts/dialogue_overlay.gd`
- `scripts/info_card_overlay.gd`
- `scripts/decision_overlay.gd`
- `translations/ui_texts.csv`
- `tools/verify_ui_focus_accessibility.gd`

**IMPLEMENTATION DETAILS**

- Add settings for text speed and large text mode.
- Ensure dialogue/info/decision surfaces respect text mode.
- Add pseudolocalization smoke for long Turkish strings if not already active.
- Keep touch target minimums.

**FILES TO MODIFY**

- `scripts/main_menu.gd`
- `scripts/ui_tokens.gd`
- overlay scripts
- `SaveManager` settings API usage
- `tools/verify_ui_readability_contract.gd`

**GODOT BEST PRACTICES**

- Use theme/token changes rather than per-node magic numbers.
- Do not scale fonts with viewport width.

**DO NOT BREAK**

- focus verifier
- existing capture checklist
- Android portrait layout

**ACCEPTANCE CRITERIA**

- Large text mode does not clip primary overlay buttons.
- Text speed setting persists.
- UI focus/accessibility verifier passes.

**OPTIONAL POLISH**

- Add dyslexia-friendly font option only if a licensed font is available.

**TEST CHECKLIST**

- UI focus verifier
- screenshot checklist
- manual portrait capture

---

### Package 11: Release Candidate Pipeline

**OBJECTIVE**

Prepare a repeatable Android release candidate process.

**CONTEXT**

Inspect first:
- `export_presets.cfg`
- `project.godot`
- `docs/ANDROID_EXPORT_AUDIT.md`
- `docs/ANDROID_RELEASE_CHECKLIST.md`

**IMPLEMENTATION DETAILS**

- Define debug vs release preset expectations.
- Add signing checklist but do not commit secrets.
- Define version bump rules.
- Define architecture decision: whether `x86_64` stays for emulator builds only.
- Add final RC checklist:
  - build
  - install
  - launch
  - smoke
  - lifecycle
  - performance observation
  - final capture/log archive

**FILES TO MODIFY**

- `docs/ANDROID_RELEASE_CHECKLIST.md`
- `docs/ANDROID_EXPORT_AUDIT.md`
- possibly `export_presets.cfg` if adding a separate preset without secrets

**GODOT BEST PRACTICES**

- Never commit keystore passwords.
- Keep export presets deterministic.

**DO NOT BREAK**

- debug export
- current package id unless product decision changes

**ACCEPTANCE CRITERIA**

- A developer can produce an RC using only the documented steps and local secrets.
- Checklist distinguishes debug smoke from release signing.

**OPTIONAL POLISH**

- Add `tools/build_android_debug.ps1` and `tools/build_android_release_candidate.ps1` wrappers.

**TEST CHECKLIST**

- debug build command
- install on emulator/device if available
- run P10/P11 gates

---

### Package 12: Commercial Polish Backlog Grooming

**OBJECTIVE**

Turn broad polish ideas into production-sized backlog cards.

**CONTEXT**

Inspect first:
- `docs/ROADMAP.md`
- `docs/VISUAL_DESIGN_SYSTEM.md`
- `docs/STORY_BIBLE.md`
- `docs/EXECUTION_PACKAGES_PLAN.md`

**IMPLEMENTATION DETAILS**

Create `docs/COMMERCIAL_POLISH_BACKLOG.md` with sections:
- tutorial
- journal/progression
- audio
- accessibility
- parent/teacher mode
- store assets
- localization QA
- analytics/privacy decision

Each card must include:
- player value
- implementation scope
- risk
- acceptance criteria
- first test

**FILES TO MODIFY**

- Create `docs/COMMERCIAL_POLISH_BACKLOG.md`
- Update `docs/ROADMAP.md` with a link.

**GODOT BEST PRACTICES**

- Keep gameplay systems and store/marketing work separated.
- Do not add analytics until privacy policy and child-safety posture are decided.

**DO NOT BREAK**

- current MVP release sequence.

**ACCEPTANCE CRITERIA**

- Backlog is actionable by another model or human engineer.
- Each card has a clear "done" definition.

**OPTIONAL POLISH**

- Add priority labels: CRITICAL/HIGH/MEDIUM/LOW.

**TEST CHECKLIST**

- Documentation review only.
- Confirm no code changed.

---

## FINAL IMPLEMENTATION ORDER FOR DEEPSEEK

1. Package 1: P10 Android Lifecycle Smoke Gate Finalization.
2. Package 9: Performance Observation and Node Count Gate.
3. Package 11: Release Candidate Pipeline.
4. Package 2: Repository Hygiene and Artifact Policy.
5. Package 3: Zone Definition Resource Pilot.
6. Package 4: Marker Data and Visual Split.
7. Package 5: World Builder Decomposition.
8. Package 6: First-Run Tutorial Layer.
9. Package 7: Journal / Tarih Defteri MVP.
10. Package 8: Audio Production Integration.
11. Package 10: Accessibility and Reading Comfort Pass.
12. Package 12: Commercial Polish Backlog Grooming.

This order protects release confidence first, then improves scalability, then adds retention and commercial polish.
