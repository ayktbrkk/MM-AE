# Package 7 Journal Runtime Acceptance Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Package 7 Journal / Tarih Defteri sistemini smoke seviyesinden gerçek oyuncu runtime kabulüne çıkarmak ve görsel kanıtla kapatmak.

**Architecture:** Yeni büyük sistem eklenmeyecek. Mevcut `JournalOverlay`, `WorldState`, `WorldUI`, `InfoCardOverlay`, `SaveManager` ve `questions.gd` hattı korunacak; sadece acceptance boşlukları, runtime testleri, görsel capture ve dokümantasyon tamamlanacak. P10 accepted baseline bozulmayacak.

**Tech Stack:** Godot 4.6.2, GDScript, PowerShell gate runners, existing overlay stack, existing save/state model.

---

## Current Accepted Baseline

DeepSeek başlamadan önce şu gerçekliği kabul etmelidir:

- P10 accepted baseline var: `artifacts/logs/p10_smoke_20260515_094948.md`
- `tools/run_p10_smoke_gate.ps1 -SkipAdbDeviceSmoke` son çalışmada `P10_SMOKE_GATE_OK` üretmiştir.
- `tools/verify_tutorial_contract.gd` 63/63 geçmiştir.
- `test/test_accessibility_smoke.gd` 6/6 geçmiştir.
- `test/test_journal_smoke.gd` 10/10 geçmiştir.
- Package 7 şu an `RUNTIME_DATA_FLOW_PREPARED` seviyesindedir, ama henüz gerçek oyuncu görsel kabulü yoktur.

DeepSeek bu baseline’ı bozarsa yeni feature geliştirmeye devam etmeyecek; önce bozduğu gate’i onaracaktır.

---

## File Responsibility Map

- `scripts/journal_overlay.gd`
  - Journal UI görünümü, kart/bölüm sekmeleri, stats satırı, close/cancel davranışı.

- `scenes/journal_overlay.tscn`
  - Journal scene node hiyerarşisi. Sadece gerekli ise dokunulacak.

- `scripts/world_state.gd`
  - Journal kart/bölüm runtime state’i ve getter/setter API’si.

- `scripts/world_ui.gd`
  - HUD Journal butonu, overlay registration, info card → journal kayıt hattı.

- `scripts/world_zone.gd`
  - Decision info card’larına `card_id` taşıma noktaları.

- `scripts/main_menu.gd`
  - Ana menü Journal butonu ve save’den Journal açma akışı.

- `test/test_journal_smoke.gd`
  - Journal’ın script/scene/data mapping smoke testi. Gerekirse 10/10 üstüne küçük runtime assertion eklenebilir.

- `tools/verify_journal_runtime_contract.gd`
  - Oluşturulacak yeni contract test. WorldState + JournalOverlay + save-like data ile gerçek runtime kabulünü doğrular.

- `tools/capture_world_render.gd`
  - Var olan capture aracı. Değiştirmeden kullanılacak; ancak Journal capture için yeni parametre gerekiyorsa minimal ve geri uyumlu ek yapılabilir.

- `docs/EXECUTION_TRACKING.md`
  - Package 7 final kabul kaydı.

- `docs/ROO_FINAL_REPORT_FOR_GPT55.md`
  - GPT 5.5’e sunulacak final özet.

---

## Non-Negotiable Rules

- Yeni Journal ekonomi sistemi, achievement, monetization, analytics veya geniş progression sistemi ekleme.
- Existing dirty worktree içindeki alakasız değişiklikleri revert etme.
- P10 accepted baseline korunmalı.
- `SMOKE_TEST_PASS`, `RUNTIME_CONTRACT_PASS` ve `VISUAL_ACCEPTED` statüleri ayrı tutulmalı.
- Screenshot/capture gerçek kanıt yoksa `VISUAL_ACCEPTED` yazma.
- Device smoke cihaz yoksa SKIP kalabilir; bu Package 7 kabulünü bloke etmez.

---

## Chunk 1: Baseline Reconfirmation

### Task 1: P10 ve Journal Baseline’ı Yeniden Doğrula

**Files:**
- Read: `artifacts/logs/p10_smoke_20260515_094948.md`
- Read: `test/test_journal_smoke.gd`
- No code changes.

- [ ] **Step 1: P10 baseline logunu oku**

Run:

```powershell
Get-Content artifacts/logs/p10_smoke_20260515_094948.md
```

Expected:

```text
Result: PASS
parse-check OK
validate-game-flow OK
verify-app-lifecycle OK
verify-overlay-input-contract OK
verify-ui-focus-accessibility OK
device-smoke SKIP
```

- [ ] **Step 2: Journal smoke testini çalıştır**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://test/test_journal_smoke.gd --quit
```

Expected:

```text
JOURNAL SMOKE TEST RAPORU
Gecen: 10
Basarisiz: 0
EXIT_CODE: 0
```

- [ ] **Step 3: P10’u tekrar çalıştır**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tools/run_p10_smoke_gate.ps1 -SkipAdbDeviceSmoke
```

Expected:

```text
P10_SMOKE_GATE_OK
```

- [ ] **Step 4: Eğer Step 2 veya Step 3 fail ise dur**

Expected action:

```text
Do not continue Package 7 work. Fix the failing baseline first.
```

---

## Chunk 2: Journal Runtime Contract

### Task 2: `verify_journal_runtime_contract.gd` Oluştur

**Files:**
- Create: `tools/verify_journal_runtime_contract.gd`
- Modify only if needed: `test/test_journal_smoke.gd`

**Objective:** Journal’ın sadece scene olarak yüklenmesini değil, gerçek runtime state/veri akışını doğrulamak.

- [ ] **Step 1: Contract test dosyasını oluştur**

Create `tools/verify_journal_runtime_contract.gd`.

Required checks:

- `JournalOverlay` scene load + instantiate.
- `WorldState` instantiate.
- `WorldState.mark_card_collected("samsun_first_decision")`
- `WorldState.mark_chapter_completed("samsun_cards")`
- `WorldState.get_collected_card_ids()` returns `["samsun_first_decision"]`
- `WorldState.get_completed_chapters()` returns `["samsun_cards"]`
- `JournalOverlay.show_overlay({"card_ids": ["samsun_first_decision"], "chapter_ids": ["samsun_cards"]})`
- Cards grid has exactly 1 card button.
- Chapters list has exactly 1 chapter row.
- Stats label contains `Kart: 1` and `Bölüm: 1`
- `JournalOverlay._get_card_data("samsun_first_decision")` does not fall back to plain ID formatting.
- `JournalOverlay._get_chapter_data("samsun_cards")` returns a non-empty readable name.
- Print `JOURNAL_RUNTIME_CONTRACT_OK` on success.
- Exit non-zero on failure.

Suggested skeleton:

```gdscript
extends MainLoop

const JOURNAL_SCENE := preload("res://scenes/journal_overlay.tscn")
const WORLD_STATE_SCRIPT := preload("res://scripts/world_state.gd")

var _failed := 0

func _initialize() -> void:
	var journal := JOURNAL_SCENE.instantiate()
	var state := WORLD_STATE_SCRIPT.new()

	state.mark_card_collected("samsun_first_decision")
	state.mark_chapter_completed("samsun_cards")

	_assert_eq(state.get_collected_card_ids(), ["samsun_first_decision"], "card ids")
	_assert_eq(state.get_completed_chapters(), ["samsun_cards"], "chapter ids")

	journal.show_overlay({
		"card_ids": ["samsun_first_decision"],
		"chapter_ids": ["samsun_cards"],
		"tab": "cards",
	})

	# Resolve nodes with get_node_or_null and validate counts/text.
	# Print errors with push_error and _failed += 1.

	if _failed == 0:
		print("JOURNAL_RUNTIME_CONTRACT_OK")
		OS.set_exit_code(0)
	else:
		OS.set_exit_code(1)

	journal.free()
	state.free()

func _idle(_delta: float) -> bool:
	return false
```

DeepSeek must adapt node paths to actual `scenes/journal_overlay.tscn`.

- [ ] **Step 2: Contract testini önce çalıştır**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_journal_runtime_contract.gd --quit
```

Expected:

```text
JOURNAL_RUNTIME_CONTRACT_OK
exit code 0
```

- [ ] **Step 3: Eğer fail ederse minimal düzeltme yap**

Likely files:

- `scripts/journal_overlay.gd`
- `scripts/world_state.gd`
- `scenes/journal_overlay.tscn`

Allowed fixes:

- Missing getter.
- Stats label override count bug.
- Empty label visibility bug.
- Card/chapter node path mismatch.

Not allowed:

- New Journal feature category.
- New save format migration.
- New progression logic.

- [ ] **Step 4: Journal smoke testini tekrar çalıştır**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://test/test_journal_smoke.gd --quit
```

Expected:

```text
Basarisiz: 0
EXIT_CODE: 0
```

---

## Chunk 3: Real Gameplay Journal Acceptance

### Task 3: Oyun İçi Journal Akışını Doğrula

**Files:**
- Prefer no code changes.
- If needed, minimally modify: `tools/validate_game_flow.gd`
- If needed, create: `tools/verify_journal_gameplay_contract.gd`

**Objective:** Oyuncu doğru karar/info-card akışından sonra Journal’da kartı görebilmeli.

- [ ] **Step 1: Mevcut flow’da kart ID’si gerçekten save’e yazılıyor mu doğrula**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/validate_game_flow.gd --quit
```

Expected:

```text
FLOW_VALIDATION_OK
```

- [ ] **Step 2: Save içinde `collected_card_ids` oluşuyor mu kontrol et**

DeepSeek `user://savegame.json` path’ini Godot üzerinden okuyacak küçük one-off verifier kullanmalı; PowerShell ile doğrudan kullanıcı appdata path tahmini yapma.

Preferred implementation:

Create `tools/verify_journal_save_contract.gd` if no existing equivalent exists.

Required checks:

- `SaveManager.load_game()` returns non-empty after flow validation.
- Save has `collected_card_ids`.
- `collected_card_ids` includes `samsun_first_decision` after correct Samsun decision, or explain if current flow only records cards after info card presentation and test should drive that presentation.
- Print `JOURNAL_SAVE_CONTRACT_OK`.

- [ ] **Step 3: Eğer save kart ID üretmiyorsa gerçek nedeni ayır**

Possible outcomes:

- `InfoCardOverlay.card_viewed` fires before connection.
- `WorldUI._on_info_card_viewed()` receives empty `card_id`.
- `world_zone.gd` correct decision path does not pass `card_id`.
- `persist_runtime_state()` is not called after card collection.

Fix only the smallest broken link.

- [ ] **Step 4: Contract testlerini çalıştır**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_journal_runtime_contract.gd --quit
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_journal_save_contract.gd --quit
```

Expected:

```text
JOURNAL_RUNTIME_CONTRACT_OK
JOURNAL_SAVE_CONTRACT_OK
```

---

## Chunk 4: Visual Acceptance

### Task 4: Journal Görsel Kabul Capture’ı Üret

**Files:**
- Use: `tools/capture_world_render.gd`
- Create/update artifact: `artifacts/captures/journal_runtime_acceptance.png` or existing capture convention.
- Modify only if needed: `tools/capture_world_render.gd`

**Objective:** Journal’ın gerçek UI görünümünü kanıtlamak.

- [ ] **Step 1: Var olan capture aracının Journal overlay açmayı destekleyip desteklemediğini kontrol et**

Run:

```powershell
Select-String -Path tools/capture_world_render.gd -Pattern "journal|OverlayType.JOURNAL|show_journal|capture"
```

- [ ] **Step 2: Eğer destek yoksa minimal parametre ekle**

Allowed addition:

- Capture script config ile `JournalOverlay` açabilsin.
- Test data olarak `card_ids=["samsun_first_decision"]`, `chapter_ids=["samsun_cards"]` kullanılabilir.
- Capture sırasında transition overlay kapalı kalmalı.

Not allowed:

- Capture tool’u genel automation framework’e çevirmek.
- P10 overlay manager davranışını değiştirmek.

- [ ] **Step 3: Desktop capture al**

Run command must follow existing project convention. If no convention exists, use Godot script invocation:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_world_render.gd -- --mode journal --output artifacts/captures/journal_runtime_acceptance.png
```

Expected:

```text
Capture saved
```

- [ ] **Step 4: Capture dosyasını doğrula**

Run:

```powershell
Test-Path artifacts/captures/journal_runtime_acceptance.png
```

Expected:

```text
True
```

Manual visual acceptance checklist:

- Journal panel ekranda okunur.
- Kartlar sekmesinde en az 1 kart görünür.
- Kart başlığı fallback ID gibi değil, anlamlı başlıktır.
- Stats satırında `Kart: 1 | Bölüm: 1` veya yerel metin karşılığı görünür.
- Close button görünür ve taşmaz.
- Text overlap yok.
- Backdrop/overlay stack world input’u bloke edecek şekilde görünür.

---

## Chunk 5: Final Gates and Documentation

### Task 5: Regression Gates

**Files:**
- No code changes unless failures occur.

- [ ] **Step 1: Journal runtime contract**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_journal_runtime_contract.gd --quit
```

Expected:

```text
JOURNAL_RUNTIME_CONTRACT_OK
```

- [ ] **Step 2: Journal smoke**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://test/test_journal_smoke.gd --quit
```

Expected:

```text
Basarisiz: 0
```

- [ ] **Step 3: P10 smoke gate**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tools/run_p10_smoke_gate.ps1 -SkipAdbDeviceSmoke
```

Expected:

```text
P10_SMOKE_GATE_OK
```

- [ ] **Step 4: Accessibility smoke**

Run:

```powershell
.\Godot_v4.6.2-stable_win64_console.exe --path . --script res://test/test_accessibility_smoke.gd --quit
```

Expected:

```text
Basarisiz: 0
```

### Task 6: Dokümantasyon Güncelle

**Files:**
- Modify: `docs/EXECUTION_TRACKING.md`
- Modify: `docs/ROO_FINAL_REPORT_FOR_GPT55.md`
- Optional modify: `docs/ROADMAP.md`

- [ ] **Step 1: `EXECUTION_TRACKING.md` içine Package 7 final acceptance bölümü ekle**

Required content:

```markdown
## Package 7 Journal Runtime Acceptance (2026-05-15)

Status: ✅ RUNTIME_ACCEPTED

Evidence:
- JOURNAL_RUNTIME_CONTRACT_OK
- JOURNAL_SAVE_CONTRACT_OK
- Journal smoke 10/10
- P10_SMOKE_GATE_OK
- Visual capture: artifacts/captures/journal_runtime_acceptance.png
```

- [ ] **Step 2: `ROO_FINAL_REPORT_FOR_GPT55.md` içine kısa final rapor ekle**

Required content:

```markdown
Package 7 moved from SMOKE_TEST_PASS to RUNTIME_ACCEPTED.
No new systems were introduced.
P10 baseline remains green.
```

- [ ] **Step 3: Eğer visual capture alınamadıysa dürüst yaz**

Use:

```markdown
Status: RUNTIME_CONTRACT_PASS, VISUAL_PENDING
```

Do not write `VISUAL_ACCEPTED` without image artifact.

---

## Acceptance Criteria

Package 7 only reaches `RUNTIME_ACCEPTED` when all are true:

- `verify_journal_runtime_contract.gd` prints `JOURNAL_RUNTIME_CONTRACT_OK`.
- Save contract prints `JOURNAL_SAVE_CONTRACT_OK`, or DeepSeek documents why save acceptance is covered by existing `validate_game_flow.gd`.
- Journal smoke remains green.
- P10 smoke remains green with `P10_SMOKE_GATE_OK`.
- Visual capture exists and shows readable Journal UI with real card data.
- No new feature systems were added.
- No unrelated dirty work was reverted.

If visual capture is not completed, final status must be:

```text
Package 7: RUNTIME_CONTRACT_PASS / VISUAL_PENDING
```

not:

```text
Package 7: RUNTIME_ACCEPTED
```

---

## Final DeepSeek Prompt

DeepSeek V4 Pro, implement this plan exactly. Keep scope narrow. Your job is not to redesign Journal; your job is to prove and harden the existing Journal runtime path.

Start with Chunk 1. Stop immediately if P10 baseline fails. Use small commits/checkpoints if committing is part of your workflow. Update the tracking docs only after the corresponding proof exists.
