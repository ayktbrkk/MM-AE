# Bandırma Yolculuğu — Geliştirme Özeti

## Session: UI Improvements → Full Content & Audio (2026-05-10/11)

Bu session'da 3 ana dalgada ilerleme kaydedildi:

| Dalga | Kapsam | Durum |
|-------|--------|-------|
| **P0** | Visibility guards, touch targets, Tween+loop | ✅ Tamam |
| **P1** | Texture DRY, world.gd modularizasyon, OverlayManager, Event routing, 3 eksik builder, Ses sistemi | ✅ Tamam |
| **P2** | Empty _process cleanup, DRY icons, SVG opt., settings audio, exit dialog, loading overlay | ✅ Tamam |
| **Doğrulama** | Godot headless: 3 test, 0 hata | ✅ Tamam |

---

### 1. R6: Texture DRY (`scripts/textures.gd`)

- **Problem:** ~80 texture sabiti 5+ scriptte tekrar ediyordu (tahmini 266 satır duplikasyon)
- **Çözüm:** [`scripts/textures.gd`](scripts/textures.gd) oluşturuldu — tüm `preload(...)` ve `const ..._TEXTURE` sabitleri merkezi dosyada
- **Kullanım patterni:**
  ```gdscript
  @onready var _tex := preload("res://scripts/textures.gd")
  # _tex.PORTRAIT_ARDA_IDLE_TEXTURE
  ```
- **Güncellenen scriptler:** chapter_transition_overlay, decision_overlay, dialogue_overlay, hud_bar, info_card_overlay, main_menu

### 2. R5: world.gd Modularizasyon (3079 → 227 satır)

- **world.gd** — Orchestrator (227 satır), sadece routing + lifecycle
- **world_player.gd** — Player movement, interaction (~700 satır)
- **world_ui.gd** — UI bağlantıları, overlay routing (~1,087 satır)
- **world_zone.gd** — Zone transitions, goal management, event routing (~800 satır)
- **world_builder.gd** — Zone building (~3,146 satır)
- **world_marker.gd** — Marker spawning (~814 satır)
- **world_wave.gd** — Wave mechanics (~406 satır)
- **world_state.gd** — State management (~80 satır)

**Composition via Preload Pattern:**
```gdscript
# world.gd
@onready var _player_mod := WorldPlayer.new()
@onready var _ui_mod := WorldUI.new()
func _ready() -> void:
    _player_mod.initialize(self)
    _ui_mod.initialize(self)
```

### 3. R1/R2: OverlayManager + CanvasLayer Sistemi

- [`scripts/overlay_manager.gd`](scripts/overlay_manager.gd) — Stack-based overlay yönetimi
- `OverlayType` enum: DIALOGUE (50), DECISION (60), INFO_CARD (70), CHAPTER_TRANSITION (80), DREAM_INTRO (90), EXIT_CONFIRM (100), LOADING (110)
- `register_overlay(owner, overlay_type, canvas_layer)` — reparent + layer mapping
- `push_overlay()`, `pop_overlay()`, `is_overlay_active()` — stack API
- **Güncellenen overlay'ler:** chapter_transition_overlay, decision_overlay, dialogue_overlay, dream_intro_overlay, info_card_overlay

### 4. P0 Bug Fixes

| Hata | Dosya | Düzeltme |
|------|-------|----------|
| Node ismi mismatch | world_zone.gd:39-40,46-47 | `"PlayerMod"` → `"WorldPlayer"`, `"UIMod"` → `"WorldUI"` |
| Eksik portre değişkeni | decision_overlay.gd | `_arda_portrait_base_y`, `_eda_portrait_base_y` eklendi |
| `nil` kullanımı | world_zone.gd (7 yer) | `nil` → `null` |
| class_name çakışması | save_manager.gd | `class_name SaveManager` kaldırıldı |

### 5. P1.1: Event Routing (31 Event, 9 Zone)

- [`world_zone.gd`](scripts/world_zone.gd) — `CHAPTER_EVENT_CHAINS` dict'i tüm zone-event mapping'ini içerir
- `BUILT_ZONES` feature flag: hangi zone'ların oynanabilir olduğunu kontrol eder
- `trigger_event_chain(zone: String) -> void:` — zone'a göre event zincirini başlatır
- 9 zone, 31 event tamamen wired

### 6. P2: 6 İyileştirme

| ID | Madde | Özet |
|----|-------|------|
| **9** | Boş `_process` temizliği | main_menu.gd, hud_bar.gd — gereksiz döngüler kaldırıldı |
| **10** | DRY icon sabitleri | textures.gd'ye procedural icon generator'lar eklendi |
| **11** | SVG .import optimizasyonu | 11 SVG dosyası optimize edildi |
| **12** | Settings audio sliders | main_menu.gd'ye BGM/SFX slider + SaveManager entegrasyonu |
| **13** | Exit confirm dialog | [`scenes/exit_confirm_overlay.tscn`](scenes/exit_confirm_overlay.tscn) + [`scripts/exit_confirm_overlay.gd`](scripts/exit_confirm_overlay.gd) — Android back button desteği |
| **14** | Loading overlay | [`scenes/loading_overlay.tscn`](scenes/loading_overlay.tscn) + [`scripts/loading_overlay.gd`](scripts/loading_overlay.gd) — 10 tarih bilgisi ipucu |

### 7. P1.2: 3 Eksik Bölüm Builder'ı (Ankara, Sakarya, Final/Lozan)

Her bölüm için: 5-6 SVG asset + 11 builder fonksiyonu (`build_zone_*` pattern'i)

| Bölge | Event'ler | SVG Assetler | Builder Fonksiyonları |
|-------|-----------|--------------|----------------------|
| **Ankara/Meclis** | 20-23 | 5 (sky, terrain, path, landmark, foreground) | 11 |
| **Sakarya/Büyük Taarruz** | 24-27 | 6 (sky, terrain, path, foreground, HQ, victory marker) | 11 |
| **Final/Lozan/Cumhuriyet** | 28-30 | 6 (sky, terrain, path, foreground, landmark, victory arch) | 11 |

**Yeni SVG Assetler:**
- [`assets/art/world/ankara/`](assets/art/world/ankara/) — 5 dosya
- [`assets/art/world/sakarya/`](assets/art/world/sakarya/) — 6 dosya
- [`assets/art/world/final/`](assets/art/world/final/) — 6 dosya

### 8. P1.3: Ses Sistemi — Procedural Placeholder

- [`scripts/audio_manager.gd`](scripts/audio_manager.gd) — Autoload singleton
- **13 procedural ses:** 6 BGM (room, bandirma, samsun, ankara, sakarya, final) + 7 SFX (click, confirm, deny, page_turn, chime, fanfare, transition)
- **Fallback zinciri:** placeholder cache → `assets/audio/` → talep üzerine üretim
- **API:** `play_bgm()`, `play_sfx()`, `stop_bgm()`, `set_bgm_volume()`, `set_sfx_volume()`
- **Bağlantılar:** main_menu.gd, world_ui.gd (dialogue/decision/info_card/chapter_transition)

### 9. Godot Headless Doğrulama

```
Test 1: --headless --check-only --path . --quit     → ✅ 0 hata
Test 2: --headless --quit --path .                   → ✅ 0 hata
Test 3: --headless --verbose --quit --path .          → ✅ 0 hata
```

**Toplam:** 3 test, 0 hata — proje stabil.

---

## 📁 Proje Klasör Yapısı

```
mmae/
├── assets/
│   ├── art/
│   │   ├── characters/arda/        # Arda portre + world sprite
│   │   │   ├── char_arda_world.svg
│   │   │   ├── portrait_arda_happy.svg
│   │   │   ├── portrait_arda_idle.svg
│   │   │   └── portrait_arda_thinking.svg (awaiting)
│   │   └── world/
│   │       ├── room/               # 3 SVG (Oda — giriş)
│   │       ├── bandirma/           # 3 SVG (Bandırma vapuru)
│   │       ├── samsun_rift/        # 3 SVG (Samsun rift)
│   │       ├── havza/              # 3 SVG
│   │       ├── amasya/             # 3 SVG
│   │       ├── kongreler/          # 3 SVG
│   │       ├── ankara/             # 5 SVG (YENİ)
│   │       └── sakarya/            # 6 SVG (YENİ)
│   │       ├── final/              # 6 SVG (YENİ)
│   └── data/
│       ├── questions.gd            # 31 event + tüm kararlar
│       └── learning_map.json
├── scenes/
│   ├── world.tscn                  # Ana oyun sahnesi
│   ├── main_menu.tscn
│   ├── dialogue_overlay.tscn
│   ├── decision_overlay.tscn
│   ├── info_card_overlay.tscn
│   ├── chapter_transition_overlay.tscn
│   ├── dream_intro_overlay.tscn
│   ├── exit_confirm_overlay.tscn   # YENİ
│   ├── loading_overlay.tscn        # YENİ
│   └── hud_bar.tscn
├── scripts/
│   ├── world.gd                    # Orchestrator (227 satır)
│   ├── world_state.gd              # State management
│   ├── world_builder.gd            # 9 zone builder (~3,146 satır)
│   ├── world_marker.gd             # Marker spawning
│   ├── world_wave.gd               # Wave mechanics
│   ├── world_player.gd             # Player interaction
│   ├── world_ui.gd                 # UI connections
│   ├── world_zone.gd               # Zone transitions
│   ├── main_menu.gd
│   ├── audio_manager.gd            # YENİ — Procedural audio
│   ├── overlay_manager.gd          # YENİ — Stack-based
│   ├── textures.gd                 # YENİ — Merkezi texture sabitleri
│   ├── save_manager.gd
│   ├── colors.gd
│   ├── dialogue_overlay.gd
│   ├── decision_overlay.gd
│   ├── info_card_overlay.gd
│   ├── chapter_transition_overlay.gd
│   ├── dream_intro_overlay.gd
│   ├── exit_confirm_overlay.gd     # YENİ
│   ├── loading_overlay.gd          # YENİ
│   └── hud_bar.gd
├── docs/                           # 8 doküman
├── tools/                          # analyze_artworks.py, capture, post_validate
├── artworks/                       # 3 referans PNG
└── project.godot
```

---

## Modül Detayları

### world.gd — Orchestrator (227 satır)

```
@onready var _player_mod := WorldPlayer.new()
@onready var _ui_mod := WorldUI.new()
@onready var _zone_mod := WorldZone.new()
@onready var _state: Node = $WorldState
@onready var _builder: Node = $WorldBuilder
```

Her modül `initialize(self)` ile world.gd referansını alır. Sinyaller modüller arasında doğrudan bağlanır, orchestrator sadece lifecycle'ı yönetir.

### Modül 1: world_state.gd (~80 satır)
- Current event index, chapter state, zone track

### Modül 2: world_builder.gd (~3,146 satır)
- 9 zone builder (room → bandirma → samsun_rift → havza → amasya → kongreler → ankara → sakarya → final)
- Her builder: sky, terrain, path, landmark, foreground, character, marker setup

### Modül 3: world_marker.gd (~814 satır)
- Marker spawning (builder tarafından çağrılır)
- Interaction + feedback (Tween animasyonları)
- Pulse/glow loop sistemi

### Modül 4: world_wave.gd (~406 satır)
- Wave mechanics (zone 2 ve sonrası)
- Wave state, goal tracking

### Modül 5: world_player.gd (~688 satır)
- Player movement (touch/drag), interaction raycast
- Character animation (procedural idle bob)

### Modül 6: world_ui.gd (~1,087 satır)
- HUD building, overlay routing, guidance arrow
- Dialogue/Decision/InfoCard/ChapterTransition event handling
- Ses bağlantıları (AudioManager)

### Modül 7: world_zone.gd (~1,312 satır)
- Zone transitions, goal management
- `CHAPTER_EVENT_CHAINS` — 31 event, 9 zone mapping
- `BUILT_ZONES` feature flag

---

## Kod Kokusu Geçmişi

### P1: Renk Sabiti Refaktörü
- `scripts/colors.gd` — tüm renk sabitleri merkezi dosyaya taşındı
- Önek kuralları: `POP_`, `DESIGN_`, `ART_`, `SHADOW_`, `UI_`, `ARDA_`/`EDA_`, `THEME_`

### P2: Ölü Kod Temizliği
- Kullanılmayan `@export` değişkenleri temizlendi
- Gereksiz import'lar kaldırıldı

### P3: Veri Odaklı Mimari — questions.gd
- `EVENTS` dizisi — 31 event, her biri `kind: "story"` veya `kind: "decision"`
- Karar yapısı: `option_a`, `option_b`, `correct`, `retry`, `info`

### P4: Modülerleştirme (Adım 1-7)
- world.gd 3079 → 227 satır
- 7 modül: world_state, world_builder, world_marker, world_wave, world_player, world_ui, world_zone

### P5: Portre Ekspresyon Routing
- `_on_dialogue_display(portrait_texture, expression)` ile portre yönetimi

### P6: Ses Sistemi (İlk Versiyon)
- AudioManager autoload + 13 procedural placeholder ses
- BGM/SFX volume kontrolü + SaveManager entegrasyonu

---

## Proje İstatistikleri

| Metrik | Değer |
|--------|-------|
| **Toplam script** | 22 `.gd` dosyası |
| **Toplam sahne** | 10 `.tscn` dosyası |
| **SVG asset** | ~40 dosya |
| **Event** | 31 (9 zone) |
| **Bölüm** | 9 (tümü built) |
| **Ses** | 13 procedural (6 BGM + 7 SFX) |
| **Doküman** | 8 `.md` dosyası |

---

## Mimari Pattern'ler

### Composition via Preload
```gdscript
# Modül oluşturma
@onready var _mod := ModuleClass.new()
# Başlatma (orchestrator referansı)
func _ready() -> void:
    _mod.initialize(self)
# Modül içinde
func initialize(world: Node) -> void:
    _world = world
```

### Texture DRY
```gdscript
@onready var _tex := preload("res://scripts/textures.gd")
# Kullanım: _tex.PORTRAIT_ARDA_IDLE_TEXTURE
```

### OverlayManager Stack
```gdscript
OverlayType.DIALOGUE → CanvasLayer 50
OverlayType.DECISION → CanvasLayer 60
OverlayType.INFO_CARD → CanvasLayer 70
OverlayType.CHAPTER_TRANSITION → CanvasLayer 80
OverlayType.DREAM_INTRO → CanvasLayer 90
OverlayType.EXIT_CONFIRM → CanvasLayer 100
OverlayType.LOADING → CanvasLayer 110
```

### Procedural SVG Generation
```gdscript
# Builder içinde inline SVG string → load("res://path")
const SVG_CONTENT := "<svg ...>"
func _write_svg(path: String, content: String) -> void:
    var file := FileAccess.open(path, FileAccess.WRITE)
    file.store_string(content)
    file.close()
```

### Feature Flags
```gdscript
const BUILT_ZONES := ["room", "bandirma", ..., "final"]
const CHAPTER_EVENT_CHAINS := {
    "room": [0, 1, 2],
    "bandirma": [3, 4],
    ...
}
```

### Procedural Audio
```gdscript
# AudioManager içinde
static func _generate_tone(freq: float, duration: float) -> AudioStreamWAV:
    var audio := AudioStreamWAV.new()
    audio.format = AudioStreamWAV.FORMAT_16_BITS
    audio.mix_rate = 22050
    var data := PackedByteArray()
    # sinüs dalgası üretimi
    return audio
```

---

## 📡 Sinyal Bağlantı Şeması

```
world.gd (Orchestrator)
  ├── _player_mod (WorldPlayer)
  │     └── signal interaction_detected(area: Area2D)
  │           → _zone_mod._on_interaction_detected(area)
  │           → _ui_mod._on_interaction_detected(area)
  ├── _ui_mod (WorldUI)
  │     ├── signal dialogue_requested(text: String, speaker: String, portrait: Texture2D)
  │     │     → OverlayManager → dialogue_overlay
  │     ├── signal decision_requested(event_data: Dictionary)
  │     │     → OverlayManager → decision_overlay
  │     ├── signal info_card_requested(title: String, body: String, icon: Texture2D)
  │     │     → OverlayManager → info_card_overlay
  │     └── signal chapter_transition_requested(chapter: String, title: String)
  │           → OverlayManager → chapter_transition_overlay
  ├── _zone_mod (WorldZone)
  │     ├── signal zone_entered(zone_name: String)
  │     │     → _ui_mod._on_zone_entered(zone_name)
  │     │     → _player_mod._on_zone_entered(zone_name)
  │     └── signal goal_updated(goal_text: String)
  │           → _ui_mod._on_goal_updated(goal_text)
  └── AudioManager (Autoload)
        ├── signal bgm_volume_changed(value: float)
        ├── signal sfx_volume_changed(value: float)
        └── → main_menu.gd, world_ui.gd
```

---

## Potansiyel Gelecek Geliştirmeler

### Kısa Vade
1. **Gerçek ses dosyaları** — `.ogg` formatında BGM + SFX placeholder'ları değiştir
2. **Android build** — export template + keystore + gradle build
3. **Achievement sistemi** — Toplanabilir öğeler + başarımlar

### Orta Vade
4. **World art upgrade** — Toca World kalitesinde SVG diorama
5. **Full seslendirme** — Karakter diyalogları için voice-over
6. **Multi-dil desteği** — İngilizce + Türkçe locale sistemi

### Uzun Vade
7. **Multiplayer / co-op** — İkinci oyuncu desteği
8. **Analytics** — Firebase + oyun içi telemetri
9. **Educational content management** — Öğretmen paneli

---

## 📚 Referans Dokümanlar

- [`docs/UI_IMPROVEMENT_ANALYSIS.md`](docs/UI_IMPROVEMENT_ANALYSIS.md) — UI analizi ve öneriler (R1-R20)
- [`docs/CURRENT_STATE_ANALYSIS.md`](docs/CURRENT_STATE_ANALYSIS.md) — Güncel durum analizi
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — Ürün yol haritası
- [`docs/DESIGN_DECISIONS.md`](docs/DESIGN_DECISIONS.md) — Tasarım kararları
- [`docs/ART_WORLD_ROADMAP.md`](docs/ART_WORLD_ROADMAP.md) — World art yol haritası
- [`docs/ART_ANALYSIS.md`](docs/ART_ANALYSIS.md) — Sanat analizi
- [`docs/VISUAL_DESIGN_SYSTEM.md`](docs/VISUAL_DESIGN_SYSTEM.md) — Görsel tasarım sistemi
- [`docs/SCENE_DESIGN.md`](docs/SCENE_DESIGN.md) — Sahne tasarımı
- [`docs/STORY_BIBLE.md`](docs/STORY_BIBLE.md) — Hikaye dokümanı

---

*Son güncelleme: 2026-05-11*
