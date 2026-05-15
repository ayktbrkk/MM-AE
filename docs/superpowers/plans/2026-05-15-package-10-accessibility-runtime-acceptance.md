# Package 10 Accessibility Runtime Acceptance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move Package 10 from smoke/focus acceptance to real runtime accessibility acceptance with persistence, overlay behavior, and visual proof.

**Architecture:** Keep the existing accessibility system: `SaveManager` owns `text_speed`, `large_text`, and `high_contrast`; `AccessibilityPanel` edits those values; dialogue/info/decision overlays react to them. Do not add a new settings framework, profile system, or UI theme manager in this package. Add narrowly scoped runtime verifiers and capture proof around the current implementation.

**Tech Stack:** Godot 4.6.2, GDScript, SceneTree script verifiers, existing P10 smoke gate, existing capture tooling.

---

## Current Baseline

Package 7 and Package 8A are accepted:

- Package 7 commit: `aa16aa57` — Journal runtime accepted.
- Package 8A commit: `1e094e2a` — Audio runtime accepted.
- Current P10 smoke baseline remains green: `P10_SMOKE_GATE_OK`.
- Existing accessibility files:
  - `scripts/save_manager.gd`
  - `scripts/accessibility_panel.gd`
  - `scenes/accessibility_panel.tscn`
  - `scripts/main_menu.gd`
  - `scripts/dialogue_overlay.gd`
  - `scripts/info_card_overlay.gd`
  - `scripts/decision_overlay.gd`
  - `test/test_accessibility_smoke.gd`
  - `tools/verify_ui_focus_accessibility.gd`

The current gap is not compile/focus. The gap is runtime proof:

- Settings must persist and reload.
- The panel must mutate settings during a real scene run.
- Dialogue, info card, and decision overlays must reflect large text and high contrast.
- Dialogue typewriter speed must respond to `text_speed`.
- Visual proof must show readable accessibility UI and no overlap.

---

## Non-Negotiable Rules

- Do not remove or rewrite the existing `SaveManager` accessibility fields.
- Do not replace existing overlays or introduce a new accessibility architecture.
- Do not change Package 7 Journal or Package 8A Audio behavior unless a failing regression proves it is required.
- Do not mark Package 10 as `RUNTIME_ACCEPTED` without all runtime contract, persistence, P10 gate, and visual evidence.
- If visual capture cannot be produced, mark status as `RUNTIME_CONTRACT_PASS / VISUAL_PENDING`, not accepted.
- Keep production scope small. This is an acceptance hardening package, not a full accessibility redesign.

---

## File Responsibility Map

- Modify: `scripts/accessibility_panel.gd`
  - Only if runtime testing reveals settings cannot be changed safely, focus is not restored, or state refresh is missing.
- Modify: `scripts/main_menu.gd`
  - Only if the accessibility overlay cannot be opened, closed, focused, or captured reliably.
- Modify: `scripts/dialogue_overlay.gd`
  - Only if `text_speed`, `large_text`, or `high_contrast` does not actually affect runtime presentation.
- Modify: `scripts/info_card_overlay.gd`
  - Only if large text/high contrast does not actually affect runtime presentation.
- Modify: `scripts/decision_overlay.gd`
  - Only if large text/high contrast does not actually affect runtime presentation.
- Create: `tools/verify_accessibility_runtime_contract.gd`
  - Runtime verifier for settings persistence, panel mutation, overlay large text, overlay contrast, and typewriter speed.
- Create or extend: `tools/capture_accessibility_runtime.gd`
  - Dedicated capture script only if `tools/capture_world_render.gd` cannot cleanly open the accessibility panel.
- Modify: `docs/EXECUTION_TRACKING.md`
  - Add Package 10 runtime acceptance evidence.
- Modify or create: `docs/ACCESSIBILITY_RUNTIME_ACCEPTANCE.md`
  - Short acceptance report with commands, output markers, and visual checklist.

---

## Task 1: Baseline Reconfirmation

**Files:**
- Read only: `artifacts/logs/`
- Read only: `docs/EXECUTION_TRACKING.md`
- Run: existing test/gate scripts

- [ ] **Step 1: Confirm latest commit and clean state**

Run:

```powershell
git status --short
git log -1 --oneline
```

Expected:

```text
1e094e2a feat(package-8a): Audio runtime acceptance - AUDIO_RUNTIME_CONTRACT_OK
```

`git status --short` should be empty before starting. If it is not empty, do not revert anything; record the dirty files in the final report and continue carefully.

- [ ] **Step 2: Run existing accessibility smoke**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://test/test_accessibility_smoke.gd --quit
```

Expected:

```text
ACCESSIBILITY_SMOKE_OK
```

If the current script prints a different existing success marker, record the exact marker and do not rename it unless tests already expect the new name.

- [ ] **Step 3: Run existing UI focus verifier**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_ui_focus_accessibility.gd --quit
```

Expected:

```text
UI_FOCUS_EXIT=0
```

- [ ] **Step 4: Run P10 gate**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tools/run_p10_smoke_gate.ps1 -SkipAdbDeviceSmoke
```

Expected:

```text
P10_SMOKE_GATE_OK
```

Stop the package if this baseline fails. Fixing baseline regression comes before runtime acceptance.

---

## Task 2: Accessibility Runtime Contract Verifier

**Files:**
- Create: `tools/verify_accessibility_runtime_contract.gd`
- Modify only if failing for real behavior: `scripts/accessibility_panel.gd`, `scripts/dialogue_overlay.gd`, `scripts/info_card_overlay.gd`, `scripts/decision_overlay.gd`

- [ ] **Step 1: Create the verifier skeleton**

Create `tools/verify_accessibility_runtime_contract.gd` with this structure:

```gdscript
extends SceneTree

const ACCESSIBILITY_PANEL_SCENE := "res://scenes/accessibility_panel.tscn"
const DIALOGUE_SCENE := "res://scenes/dialogue_overlay.tscn"
const INFO_CARD_SCENE := "res://scenes/info_card_overlay.tscn"
const DECISION_SCENE := "res://scenes/decision_overlay.tscn"

var _passed: int = 0
var _failed: int = 0
var _errors: PackedStringArray = []

func _initialize() -> void:
	print(">>> Accessibility Runtime Contract Test Basladi")
	await process_frame
	await _run_all()
	_print_report()
	if _failed > 0:
		quit(1)
		return
	print("  ACCESSIBILITY_RUNTIME_CONTRACT_OK")
	quit(0)

func _run_all() -> void:
	_reset_accessibility_defaults()
	await _test_save_manager_persistence()
	await _test_accessibility_panel_mutates_settings()
	await _test_dialogue_large_text_and_contrast()
	await _test_dialogue_text_speed_changes_reveal()
	await _test_info_card_large_text_and_contrast()
	await _test_decision_large_text_and_contrast()

func _reset_accessibility_defaults() -> void:
	SaveManager.text_speed = "normal"
	SaveManager.large_text = false
	SaveManager.high_contrast = false
```

Keep the script as `extends SceneTree`, matching existing runtime verifiers.

- [ ] **Step 2: Add assertion helpers**

Add these helpers to the same file:

```gdscript
func _pass(message: String) -> void:
	_passed += 1
	print("  PASS [%s]" % message)

func _fail(message: String) -> void:
	_failed += 1
	_errors.append(message)
	push_error(message)

func _assert_true(value: bool, message: String) -> void:
	if value:
		_pass(message)
	else:
		_fail(message)

func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual == expected:
		_pass(message)
	else:
		_fail("%s | expected=%s actual=%s" % [message, str(expected), str(actual)])

func _print_report() -> void:
	print("")
	print("Accessibility Runtime Contract Sonucu:")
	print("  PASS: %d" % _passed)
	print("  FAIL: %d" % _failed)
	for error in _errors:
		print("  ERROR: %s" % error)
```

- [ ] **Step 3: Add persistence test**

Add:

```gdscript
func _test_save_manager_persistence() -> void:
	print("")
	print("TEST: SaveManager accessibility persistence")
	SaveManager.text_speed = "slow"
	SaveManager.large_text = true
	SaveManager.high_contrast = true
	SaveManager.save_setting("text_speed", SaveManager.text_speed)
	SaveManager.save_setting("large_text", SaveManager.large_text)
	SaveManager.save_setting("high_contrast", SaveManager.high_contrast)

	SaveManager.text_speed = "normal"
	SaveManager.large_text = false
	SaveManager.high_contrast = false
	SaveManager.load_accessibility_settings()

	_assert_eq(SaveManager.text_speed, "slow", "text_speed setting reloads")
	_assert_eq(SaveManager.large_text, true, "large_text setting reloads")
	_assert_eq(SaveManager.high_contrast, true, "high_contrast setting reloads")
```

If this test pollutes user settings, add a final cleanup that restores `"normal"`, `false`, `false` using the same public setters and `save_setting()` calls.

- [ ] **Step 4: Add panel mutation test**

Add:

```gdscript
func _test_accessibility_panel_mutates_settings() -> void:
	print("")
	print("TEST: AccessibilityPanel mutates SaveManager")
	_reset_accessibility_defaults()
	var panel: Control = load(ACCESSIBILITY_PANEL_SCENE).instantiate()
	root.add_child(panel)
	await process_frame
	await process_frame

	panel.call("_on_speed_selected", "fast")
	panel.call("_on_large_text_toggled", true)
	panel.call("_on_high_contrast_toggled", true)

	_assert_eq(SaveManager.text_speed, "fast", "panel changes text_speed")
	_assert_eq(SaveManager.large_text, true, "panel changes large_text")
	_assert_eq(SaveManager.high_contrast, true, "panel changes high_contrast")

	panel.queue_free()
	await process_frame
```

If direct private method calls are rejected by project standards, press the actual buttons instead:

```gdscript
var fast_btn: Button = panel.get_node("%FastBtn")
fast_btn.pressed.emit()
```

Use the direct method route only because existing test files already inspect internals and this is an acceptance verifier.

- [ ] **Step 5: Add dialogue large text/high contrast test**

Add:

```gdscript
func _test_dialogue_large_text_and_contrast() -> void:
	print("")
	print("TEST: DialogueOverlay applies large text and high contrast")
	SaveManager.large_text = true
	SaveManager.high_contrast = true
	SaveManager.text_speed = "normal"

	var dialogue: Control = load(DIALOGUE_SCENE).instantiate()
	root.add_child(dialogue)
	await process_frame
	dialogue.call("present", {
		"chapter": "Test Bolumu",
		"speaker": "Arda",
		"text": "Bu metin buyuk ve yuksek kontrast ile okunabilir olmali.",
		"speaker_side": "left"
	})
	await process_frame

	var body: RichTextLabel = dialogue.get_node("BottomArea/DialoguePanel/DialogueMargin/DialogueContent/BodyText")
	var font_size: int = int(body.get_theme_font_size("font_size"))
	var outline_size: int = int(body.get_theme_constant("outline_size"))

	_assert_true(font_size >= 28, "dialogue body uses large text font size")
	_assert_true(outline_size >= 4, "dialogue body uses high contrast outline")

	dialogue.queue_free()
	await process_frame
```

- [ ] **Step 6: Add dialogue text speed test**

Add:

```gdscript
func _test_dialogue_text_speed_changes_reveal() -> void:
	print("")
	print("TEST: DialogueOverlay text_speed changes reveal behavior")
	SaveManager.large_text = false
	SaveManager.high_contrast = false

	SaveManager.text_speed = "slow"
	var slow_dialogue: Control = load(DIALOGUE_SCENE).instantiate()
	root.add_child(slow_dialogue)
	await process_frame
	slow_dialogue.call("present", {
		"chapter": "Test",
		"speaker": "Arda",
		"text": "Yavas metin hizini olcmek icin yeterince uzun bir cumle gerekiyor.",
		"speaker_side": "left"
	})
	await process_frame
	var slow_body: RichTextLabel = slow_dialogue.get_node("BottomArea/DialoguePanel/DialogueMargin/DialogueContent/BodyText")
	var slow_ratio: float = slow_body.visible_ratio
	slow_dialogue.queue_free()
	await process_frame

	SaveManager.text_speed = "fast"
	var fast_dialogue: Control = load(DIALOGUE_SCENE).instantiate()
	root.add_child(fast_dialogue)
	await process_frame
	fast_dialogue.call("present", {
		"chapter": "Test",
		"speaker": "Arda",
		"text": "Yavas metin hizini olcmek icin yeterince uzun bir cumle gerekiyor.",
		"speaker_side": "left"
	})
	await process_frame
	var fast_body: RichTextLabel = fast_dialogue.get_node("BottomArea/DialoguePanel/DialogueMargin/DialogueContent/BodyText")
	var fast_ratio: float = fast_body.visible_ratio

	_assert_true(fast_ratio >= slow_ratio, "fast text speed reveals at least as much text as slow after one frame")

	fast_dialogue.queue_free()
	await process_frame
```

If this test is flaky because one frame is not enough, wait a fixed short window:

```gdscript
await create_timer(0.20).timeout
```

Use the same wait for both slow and fast. Expected: `fast_ratio > slow_ratio`.

- [ ] **Step 7: Add info card accessibility test**

Add:

```gdscript
func _test_info_card_large_text_and_contrast() -> void:
	print("")
	print("TEST: InfoCardOverlay applies large text and high contrast")
	SaveManager.large_text = true
	SaveManager.high_contrast = true

	var info_card: Control = load(INFO_CARD_SCENE).instantiate()
	root.add_child(info_card)
	await process_frame
	info_card.call("present", {
		"title": "Test Kart",
		"text": "Bu bilgi karti buyuk metin ve yuksek kontrast ayarlariyla okunmali.",
		"tag": "Test",
		"reward": "Kanıt"
	})
	await process_frame

	var title_label: Label = info_card.get_node("Center/InfoCard/CardMargin/CardContent/Title")
	var body_label: RichTextLabel = info_card.get_node("Center/InfoCard/CardMargin/CardContent/Body")
	var title_size: int = int(title_label.get_theme_font_size("font_size"))
	var body_size: int = int(body_label.get_theme_font_size("font_size"))
	var outline_size: int = int(body_label.get_theme_constant("outline_size"))

	_assert_true(title_size >= 26, "info card title uses large text font size")
	_assert_true(body_size >= 22, "info card body uses large text font size")
	_assert_true(outline_size >= 3, "info card body uses high contrast outline")

	info_card.queue_free()
	await process_frame
```

Verify node paths before committing. If the scene uses different node names, update paths to match the actual scene.

- [ ] **Step 8: Add decision overlay accessibility test**

Add:

```gdscript
func _test_decision_large_text_and_contrast() -> void:
	print("")
	print("TEST: DecisionOverlay applies large text and high contrast")
	SaveManager.large_text = true
	SaveManager.high_contrast = true

	var decision: Control = load(DECISION_SCENE).instantiate()
	root.add_child(decision)
	await process_frame
	decision.call("present", {
		"context": "accessibility-test",
		"chapter": "Test Karari",
		"title": "Okunabilir Karar",
		"prompt": "Oyuncu bu karari rahatca okuyabilmeli."
	})
	await process_frame

	var prompt_label: RichTextLabel = decision.get_node("Center/DecisionPanel/DecisionMargin/DecisionContent/Prompt")
	var prompt_size: int = int(prompt_label.get_theme_font_size("font_size"))
	var outline_size: int = int(prompt_label.get_theme_constant("outline_size"))

	_assert_true(prompt_size >= 24, "decision prompt uses large text font size")
	_assert_true(outline_size >= 3, "decision prompt uses high contrast outline")

	decision.queue_free()
	await process_frame
```

If `DecisionOverlay` uses a `Label` instead of `RichTextLabel`, update the variable type and keep the same font/outline assertions.

- [ ] **Step 9: Run the verifier and fix only real failures**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_accessibility_runtime_contract.gd --quit
```

Expected:

```text
ACCESSIBILITY_RUNTIME_CONTRACT_OK
```

If direct `SaveManager` usage in overlays fails in script mode, do not blanket-rewrite. Use the established safe access pattern from prior fixes:

```gdscript
func _get_save_manager() -> Node:
	return get_node_or_null("/root/SaveManager")
```

Then guard calls so normal game runtime keeps existing behavior and verifier mode does not crash.

---

## Task 3: Accessibility Capture Proof

**Files:**
- Prefer create: `tools/capture_accessibility_runtime.gd`
- Output: `artifacts/captures/accessibility_runtime_acceptance.png`

- [ ] **Step 1: Create a dedicated capture script if needed**

If `tools/capture_world_render.gd` cannot open the main menu accessibility overlay reliably, create `tools/capture_accessibility_runtime.gd`.

The script must:

- Instantiate `res://scenes/main_menu.tscn`.
- Add it to `root`.
- Wait at least two frames.
- Call `_on_accessibility_pressed()` or press `accessibility_button`.
- Set `SaveManager.large_text = true`.
- Set `SaveManager.high_contrast = true`.
- Wait two frames.
- Capture viewport image.
- Save to `artifacts/captures/accessibility_runtime_acceptance.png`.
- Print `ACCESSIBILITY_CAPTURE_OK`.

Expected command:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_accessibility_runtime.gd --quit
```

Expected output:

```text
ACCESSIBILITY_CAPTURE_OK
```

- [ ] **Step 2: Manual visual checklist**

Open or inspect:

```text
artifacts/captures/accessibility_runtime_acceptance.png
```

Checklist:

- Accessibility overlay is visible.
- Title, speed options, large text toggle, high contrast toggle, and close button are readable.
- No text overlaps another control.
- Panel fits in the viewport.
- Focus/default state is visually legible.
- Large text/high contrast state is reflected or clearly indicated.

If any item fails, fix layout before marking visual accepted.

---

## Task 4: Regression Gates

**Files:**
- Run only unless failures require targeted fixes.

- [ ] **Step 1: Run check-only**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --check-only --quit
```

Expected exit code: `0`.

- [ ] **Step 2: Run accessibility runtime contract**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_accessibility_runtime_contract.gd --quit
```

Expected:

```text
ACCESSIBILITY_RUNTIME_CONTRACT_OK
```

- [ ] **Step 3: Run existing accessibility smoke**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://test/test_accessibility_smoke.gd --quit
```

Expected success marker from current script.

- [ ] **Step 4: Run UI focus verifier**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_ui_focus_accessibility.gd --quit
```

Expected:

```text
UI_FOCUS_EXIT=0
```

- [ ] **Step 5: Run Package 7 and 8A regression verifiers**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_journal_runtime_contract.gd --quit
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_audio_runtime_contract.gd --quit
```

Expected:

```text
JOURNAL_RUNTIME_CONTRACT_OK
AUDIO_RUNTIME_CONTRACT_OK
```

- [ ] **Step 6: Run P10 smoke gate**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tools/run_p10_smoke_gate.ps1 -SkipAdbDeviceSmoke
```

Expected:

```text
P10_SMOKE_GATE_OK
```

---

## Task 5: Documentation and Status Update

**Files:**
- Modify: `docs/EXECUTION_TRACKING.md`
- Create or modify: `docs/ACCESSIBILITY_RUNTIME_ACCEPTANCE.md`
- Optional modify: `docs/ROO_FINAL_REPORT_FOR_GPT55.md`

- [ ] **Step 1: Create acceptance report**

Create `docs/ACCESSIBILITY_RUNTIME_ACCEPTANCE.md` with:

```markdown
# Accessibility Runtime Acceptance

Date: 2026-05-15
Status: RUNTIME_ACCEPTED

## Evidence

- `ACCESSIBILITY_RUNTIME_CONTRACT_OK`
- Existing accessibility smoke passed
- `UI_FOCUS_EXIT=0`
- `P10_SMOKE_GATE_OK`
- Visual capture: `artifacts/captures/accessibility_runtime_acceptance.png`

## Scope

This pass validates the existing accessibility system at runtime:

- `SaveManager.text_speed`
- `SaveManager.large_text`
- `SaveManager.high_contrast`
- Accessibility panel mutation
- Dialogue overlay runtime response
- Info card overlay runtime response
- Decision overlay runtime response

## Not Included

- Screen reader support
- Full WCAG audit
- New theme system
- New profile/settings architecture
```

If visual capture is not produced, use `Status: RUNTIME_CONTRACT_PASS / VISUAL_PENDING`.

- [ ] **Step 2: Update execution tracking**

Append to `docs/EXECUTION_TRACKING.md`:

```markdown
## Package 10: Accessibility Runtime Acceptance (2026-05-15)

**Status:** ✅ RUNTIME_ACCEPTED

### Evidence

- `tools/verify_accessibility_runtime_contract.gd` → `ACCESSIBILITY_RUNTIME_CONTRACT_OK`
- `test/test_accessibility_smoke.gd` → PASS
- `tools/verify_ui_focus_accessibility.gd` → `UI_FOCUS_EXIT=0`
- `tools/run_p10_smoke_gate.ps1 -SkipAdbDeviceSmoke` → `P10_SMOKE_GATE_OK`
- Visual capture: `artifacts/captures/accessibility_runtime_acceptance.png`

### Notes

Package 10 is now accepted beyond smoke/focus checks. The runtime contract proves that persisted accessibility settings affect the active UI overlays used in the first-session experience.
```

If any item is missing, change the status accordingly.

- [ ] **Step 3: Commit**

Run:

```powershell
git status --short
git add tools/verify_accessibility_runtime_contract.gd tools/capture_accessibility_runtime.gd docs/ACCESSIBILITY_RUNTIME_ACCEPTANCE.md docs/EXECUTION_TRACKING.md scripts/accessibility_panel.gd scripts/main_menu.gd scripts/dialogue_overlay.gd scripts/info_card_overlay.gd scripts/decision_overlay.gd artifacts/captures/accessibility_runtime_acceptance.png
git commit -m "feat(package-10): accessibility runtime acceptance"
```

If a listed file was not changed or not created, omit it from `git add`.

---

## Acceptance Criteria

Package 10 can be marked `RUNTIME_ACCEPTED` only when all are true:

- `verify_accessibility_runtime_contract.gd` prints `ACCESSIBILITY_RUNTIME_CONTRACT_OK`.
- Existing accessibility smoke still passes.
- `verify_ui_focus_accessibility.gd` still prints `UI_FOCUS_EXIT=0`.
- Package 7 verifier still prints `JOURNAL_RUNTIME_CONTRACT_OK`.
- Package 8A verifier still prints `AUDIO_RUNTIME_CONTRACT_OK`.
- P10 smoke gate still prints `P10_SMOKE_GATE_OK`.
- `artifacts/captures/accessibility_runtime_acceptance.png` exists and passes visual checklist.
- Documentation clearly separates runtime acceptance from future full accessibility/WCAG work.

---

## Out of Scope

- New visual design language for the whole UI.
- Full WCAG 2.2 compliance.
- Screen reader narration.
- Controller remapping.
- Color-blind palettes across the full game.
- Production localization rewrite.

These belong in a later Package 10B or Package 12 polish pass.

---

## Recommended Next Package After This

If Package 10 is accepted, move to **Package 12A: First Session Commercial Polish Triage**.

Package 12A should not implement random polish items. It should rank and select only the top 3 first-session improvements backed by existing captures and runtime evidence.
