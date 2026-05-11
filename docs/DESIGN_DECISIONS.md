# Design Decisions — Bandırma Yolculuğu

## Current Priority

**Prototype stabilizasyonu → Android Build.** Mevcut prototip 9 bölge, 31 event, 13 procedural ses ile içerik olarak tamamlandı. Sıradaki adımlar: gerçek ses dosyaları, Android build, E2E test.

## Reference Player

Toca Life World (Toca Boca):
- **3-4 katman geometrisi** (arkaplan → oynanabilir alan → önplan)
- **Tap-to-explore** (npc'lerle etkileşim)
- **Günlük hayat rutinleri**
- **Zaman baskısı yok**

## Narrative Architecture

Oyuncu Arda/Eda olarak kalır, tarihi figürlerin yerine geçmez. Mustafa Kemal, Halide Edip gibi figürler yan karakter olarak yer alır.

### Hikaye Bölümleri (31 Event — [`questions.gd`](assets/data/questions.gd))

| Perde | Bölge | Event'ler | Tema |
|-------|-------|-----------|------|
| Perde 1: Uyanış | room | 0-2 | Zaman yolculuğu başlangıcı |
| | bandirma | 3-4 | Bandırma Vapuru'na binme |
| | samsun_rift | 5-6 | Samsun'a varış |
| Perde 2: Örgütlenme | havza | 7-9 | Havza genelgesi |
| | amasya | 10-13 | Amasya görüşmeleri |
| | kongreler | 14-19 | Erzurum/Sivas kongreleri |
| Perde 3: Mücadele | ankara | 20-23 | Meclis'in açılışı |
| | sakarya | 24-27 | Sakarya/Büyük Taarruz |
| | final | 28-30 | Lozan/Cumhuriyet |

Her event `kind: "story"` (diyalog ağırlıklı) veya `kind: "decision"` (A/B kararı) olarak etiketlenir.

## Strategy Layer

Her bölümde oyuncunun stratejik bir katmanı yönetmesi beklenir:

| Bölge | Strateji | Mekanik |
|-------|----------|---------|
| Havza | Gözlem | Noktaları keşfet |
| Amasya | İletişim | Doğru mesajları ilet |
| Kongreler | Güven | Delegeleri ikna et |
| Ankara (yeni) | Örgütlenme | Meclis üyelerini topla |
| Sakarya (yeni) | Savunma | Cepheleri koru |
| Final (yeni) | Diplomasi | Anlaşmaları yönet |

## Open World Diorama Rules

1. **Yatay scroll** — her bölge soldan sağa keşfedilir
2. **5 katman** — sky, terrain, path, landmark, foreground
3. **Karakter + marker** — oynanabilir karakter ve etkileşim noktaları
4. **Wave spawn** — belirli bölgelerde düşman/engel dalgaları
5. **Zone transition** — bölge sonunda chapter transition overlay

## Main Risks To De-Risk First

| Risk | Durum |
|------|-------|
| Performans (mobile) | ✅ _process yok, Tween+loop, SVG lightweight |
| İçerik tamamlanmamış bölgeler | ✅ 9/9 bölge built, 31/31 event wired |
| Ses eksikliği | ✅ 13 procedural placeholder |
| Overlay karmaşası | ✅ CanvasLayer stack, merkezi yönetim |
| Texture duplikasyonu | ✅ textures.gd DRY |

## Hard Gates

1. ✅ Herhangi bir anda build alınabilir — headless validation pass
2. ✅ Static typing — tüm değişkenler tipli
3. ✅ Godot 4.x sözdizimi — @onready, @export, signal
4. ✅ Composition over Inheritance — modular architecture
5. ✅ Signal tabanlı iletişim — loosely coupled

## Current Technical Snapshot

| Metrik | Değer |
|--------|-------|
| Godot sürümü | 4.6.2 stable |
| Toplam script | 22 `.gd` dosyası |
| Toplam sahne | 10 `.tscn` dosyası |
| Ortalama script satırı | ~400 |
| Modül sayısı | 7 (world_state, builder, marker, wave, player, ui, zone) |
| Overlay tipi | 7 (CanvasLayer 50-110) |
| Ses dosyası | 13 procedural (6 BGM + 7 SFX) |
| Event | 31 |
| Bölge | 9 (tümü built) |
| Autoload | 2 (AudioManager, SaveManager) |

---

## 1. Mevcut Durum

✅ `world.gd` 227 satıra indirildi (orchestrator).
✅ 7 modül: world_state, world_builder, world_marker, world_wave, world_player, world_ui, world_zone.
✅ OverlayManager ile CanvasLayer stack sistemi.
✅ textures.gd ile merkezi texture yönetimi.
✅ AudioManager ile 13 procedural placeholder ses.
✅ CHAPTER_EVENT_CHAINS ile 31 event routing.
✅ BUILT_ZONES feature flag.
✅ Godot headless doğrulama: 3 test, 0 hata.

## 2. Hedef Modül Yapısı (MEVCUT — UYGULANDI)

```
world.gd (Orchestrator - 227 satır)
├── $WorldState (world_state.gd)
├── $WorldBuilder (world_builder.gd)
├── @onready var _player_mod := WorldPlayer.new()
├── @onready var _ui_mod := WorldUI.new()
├── @onready var _zone_mod := WorldZone.new()
├── @onready var _marker_mod := WorldMarker.new()
└── @onready var _wave_mod := WorldWave.new()
```

### Composition via Preload Pattern

```gdscript
# world.gd
@onready var _player_mod := WorldPlayer.new()

func _ready() -> void:
    _player_mod.initialize(self)

# world_player.gd
extends Node

var _world: Node

func initialize(world: Node) -> void:
    _world = world
```

Bu pattern sayesinde:
- Her modül `Node` extend eder, scene tree'de yer almaz
- `initialize(self)` ile orchestrator referansı alır
- Sinyaller doğrudan modüller arasında bağlanır
- Gevşek bağlı (loosely coupled) mimari

### Texture DRY Pattern

```gdscript
# textures.gd — merkezi dosya
const PORTRAIT_ARDA_IDLE_TEXTURE := preload("res://assets/art/characters/arda/portrait_arda_idle.svg")

# Kullanıcı script
@onready var _tex := preload("res://scripts/textures.gd")
# _tex.PORTRAIT_ARDA_IDLE_TEXTURE
```

### OverlayManager CanvasLayer Stack

```
OverlayType:
  DIALOGUE          → CanvasLayer 50
  DECISION          → CanvasLayer 60
  INFO_CARD         → CanvasLayer 70
  CHAPTER_TRANSITION → CanvasLayer 80
  DREAM_INTRO       → CanvasLayer 90
  EXIT_CONFIRM      → CanvasLayer 100
  LOADING           → CanvasLayer 110

API:
  register_overlay(owner, overlay_type, canvas_layer)
  push_overlay(overlay_type)
  pop_overlay()
  is_overlay_active(overlay_type) -> bool
```

### Feature Flags Pattern

```gdscript
const BUILT_ZONES := ["room", "bandirma", "samsun_rift", "havza", 
                       "amasya", "kongreler", "ankara", "sakarya", "final"]
const CHAPTER_EVENT_CHAINS := {
    "room": [0, 1, 2],
    "bandirma": [3, 4],
    "samsun_rift": [5, 6],
    "havza": [7, 8, 9],
    "amasya": [10, 11, 12, 13],
    "kongreler": [14, 15, 16, 17, 18, 19],
    "ankara": [20, 21, 22, 23],
    "sakarya": [24, 25, 26, 27],
    "final": [28, 29, 30],
}
```

### Procedural Audio Pattern

```gdscript
# AudioManager.gd — autoload
static func _generate_tone(freq: float, duration: float, 
                           volume: float = 0.3) -> AudioStreamWAV:
    var audio := AudioStreamWAV.new()
    audio.format = AudioStreamWAV.FORMAT_16_BITS
    audio.mix_rate = 22050
    var data := PackedByteArray()
    var sample_count: int = int(audio.mix_rate * duration)
    for i in sample_count:
        var value: float = sin(2.0 * PI * freq * i / audio.mix_rate) * volume
        var sample: int = int(value * 16384)
        data.append(sample & 0xFF)
        data.append((sample >> 8) & 0xFF)
    audio.data = data
    return audio
```

---

## Modül Detayları

### 3.1 — MODÜL 1: [`world_state.gd`](scripts/world_state.gd) (~80 satır) ✅

**Implementasyon:** world_state.gd

- Current event index, chapter state, zone track
- `get_current_event_index()`, `get_current_zone_name()`
- `is_event_completed(index)`, `mark_event_completed(index)`
- `get_decision_result(event_index)` — doğru/yanlış takibi

#### Sinyaller
- `event_completed(index: int)`
- `decision_made(event_index: int, correct: bool)`

#### world.gd'den Taşınan Satır Aralıkları
- Event index değişkenleri
- Chapter state yönetimi

#### Bağımlılıklar
- Bağımsız — en düşük seviye modül

### 3.2 — MODÜL 2: [`world_builder.gd`](scripts/world_builder.gd) (~3,146 satır) ✅

**Implementasyon:** world_builder.gd

**9 zone builder:**
1. `build_room()` — Oda sahnesi
2. `build_bandirma()` — Bandırma Vapuru
3. `build_samsun_rift()` — Samsun rift
4. `build_havza()` — Havza
5. `build_amasya()` — Amasya
6. `build_kongreler()` — Kongreler
7. `build_ankara()` — Ankara/Meclis ✅ (yeni)
8. `build_sakarya()` — Sakarya/Büyük Taarruz ✅ (yeni)
9. `build_final()` — Final/Lozan/Cumhuriyet ✅ (yeni)

**Her builder:**
- Sky katmanı (arkaplan SVG)
- Terrain katmanı (zemin SVG)
- Path katmanı (yol SVG)
- Landmark katmanı (dönüm noktası SVG)
- Foreground katmanı (önplan SVG)
- Character spawn
- Marker setup (etkileşim noktaları)

#### Public API
- `build_world(zone: String) -> void` — zone'a göre builder seçer
- `clear_world() -> void` — tüm katmanları temizler
- `get_marker_positions(zone: String) -> Array[Vector2]`
- `get_zone_bounds(zone: String) -> Vector2`

#### Sinyaller
- `world_built(zone: String)`
- `world_cleared()`

#### world.gd'den Taşınan Satır Aralıkları
- Tüm builder fonksiyonları
- SVG asset loading
- Marker pozisyonları

#### Bağımlılıklar
- `world_state.gd` — event index sorguları
- `world_marker.gd` — marker spawn
- `world_wave.gd` — wave spawn
- `textures.gd` — texture sabitleri

### 3.3 — MODÜL 3: [`world_marker.gd`](scripts/world_marker.gd) (~814 satır) ✅

**Implementasyon:** world_marker.gd

- Marker spawning (builder tarafından çağrılır)
- Interaction + feedback (Tween animasyonları)
- Pulse/glow loop (Tween ile, _process yok)

#### Sinyaller
- `marker_interacted(marker_id: String)`

#### Bağımlılıklar
- `world_state.gd` — event bazlı marker durumu

### 3.4 — MODÜL 4: [`world_wave.gd`](scripts/world_wave.gd) (~406 satır) ✅

**Implementasyon:** world_wave.gd

- Wave mechanics (zone 2+)
- Wave state, goal tracking
- Tween-based spawn animation

#### Sinyaller
- `wave_completed(wave_id: int)`
- `all_waves_completed()`

#### Bağımlılıklar
- `world_state.gd` — event bazlı wave tetikleme

### 3.5 — MODÜL 5: [`world.gd`](scripts/world.gd) — ORCHESTRATOR (227 satır) ✅

**Implementasyon:** world.gd

**Scene tree node referansları — sadece orkestratorda:**
```gdscript
@onready var _state: Node = $WorldState
@onready var _builder: Node = $WorldBuilder
```

**Composition modülleri (preload + initialize):**
```gdscript
@onready var _player_mod := WorldPlayer.new()
@onready var _ui_mod := WorldUI.new()
@onready var _zone_mod := WorldZone.new()
@onready var _marker_mod := WorldMarker.new()
@onready var _wave_mod := WorldWave.new()

func _ready() -> void:
    _player_mod.initialize(self)
    _ui_mod.initialize(self)
    _zone_mod.initialize(self)
    _marker_mod.initialize(self, _state, _builder)
    _wave_mod.initialize(self, _state)
```

#### Orkestratordaki Sorumluluklar
- **Lifecycle:** `_ready()`, `_physics_process(delta)`, modül initialize
- **UI Connections:** overlay routing, sinyal bağlantıları
- **Player:** input handling (touch/drag)
- **World Transitions:** zone değişimleri
- **Overlay Management:** OverlayManager API çağrıları
- **HUD Building:** goal güncelleme, minimap
- **Animation:** Tween animasyonları

#### world.gd'de KALAN Satır Aralıkları
- Node referansları (25-45)
- Modül initialize (50-70)
- _ready sinyal bağlantıları (80-130)
- _physics_process routing (140-160)
- Zone transition handler (170-200)
- Public API fonksiyonları (210-227)

---

## 4. Sinyal Bağlantı Şeması

```
world.gd (Orchestrator)
  │
  ├──> _player_mod
  │     └── signal interaction_detected(area)
  │           → _zone_mod._on_interaction_detected(area)
  │           → _ui_mod._on_interaction_detected(area)
  │
  ├──> _ui_mod
  │     ├── signal dialogue_requested(text, speaker, portrait)
  │     │     → OverlayManager → dialogue_overlay
  │     ├── signal decision_requested(event_data)
  │     │     → OverlayManager → decision_overlay
  │     ├── signal info_card_requested(title, body, icon)
  │     │     → OverlayManager → info_card_overlay
  │     └── signal chapter_transition_requested(chapter, title)
  │           → OverlayManager → chapter_transition_overlay
  │
  ├──> _zone_mod
  │     ├── signal zone_entered(zone_name)
  │     │     → _ui_mod._on_zone_entered(zone_name)
  │     │     → _player_mod._on_zone_entered(zone_name)
  │     └── signal goal_updated(goal_text)
  │           → _ui_mod._on_goal_updated(goal_text)
  │
  ├──> _marker_mod
  │     └── signal marker_interacted(marker_id)
  │           → _zone_mod._on_marker_interacted(marker_id)
  │
  ├──> _wave_mod
  │     └── signal wave_completed(wave_id)
  │           → _zone_mod._on_wave_completed(wave_id)
  │
  └──> AudioManager (Autoload)
        ├── signal bgm_volume_changed(value)
        ├── signal sfx_volume_changed(value)
        └── → main_menu.gd, world_ui.gd
```

### Kodda Sinyal Bağlantıları (Orkestratör _ready içinde)

```gdscript
func _ready() -> void:
    # Player → Zone
    _player_mod.interaction_detected.connect(_zone_mod._on_interaction_detected)
    # Player → UI
    _player_mod.interaction_detected.connect(_ui_mod._on_interaction_detected)
    # Zone → UI
    _zone_mod.zone_entered.connect(_ui_mod._on_zone_entered)
    _zone_mod.goal_updated.connect(_ui_mod._on_goal_updated)
    # Marker → Zone
    _marker_mod.marker_interacted.connect(_zone_mod._on_marker_interacted)
    # Wave → Zone
    _wave_mod.wave_completed.connect(_zone_mod._on_wave_completed)
    _wave_mod.all_waves_completed.connect(_zone_mod._on_all_waves_completed)
```

---

## 5. Implementasyon Sırası (TAMAMLANDI — Tüm Adımlar)

### Adım 1: Modül İskeletlerini Oluştur ✅
- 7 modül dosyası oluşturuldu
- Her modül `extends Node`, `initialize(world)`, sinyaller

### Adım 2: State Modülüne Taşıma ✅
- Event index, chapter state, zone track

### Adım 3: Builder Modülüne Taşıma ✅
- 9 zone builder (room → final)
- SVG asset loading, marker setup

### Adım 4: Marker Modülüne Taşıma ✅
- Marker spawning, interaction, feedback

### Adım 5: Wave Modülüne Taşıma ✅
- Wave mechanics, state, goal tracking

### Adım 6: Orkestratörü Temizle ✅
- world.gd 3079 → 227 satır

### Adım 7: Son Test ve Düzeltme ✅
- P0 bug fixes
- Godot headless validation (3 test, 0 hata)

---

## 6. Bağımlılık Grafiği

```
world_state.gd (bağımsız)
      ↑
world_builder.gd → world_state.gd, world_marker.gd, world_wave.gd, textures.gd
      ↑
world_marker.gd → world_state.gd
      ↑
world_wave.gd → world_state.gd
      ↑
world_player.gd (bağımsız — sadece input)
      ↑
world_ui.gd → OverlayManager, AudioManager
      ↑
world_zone.gd → world_state.gd, world_builder.gd
      ↑
world.gd (Orchestrator — tüm modülleri initialize eder)
```

### Önemli Kural
- Modüller birbirine doğrudan referans vermez
- İletişim sadece sinyaller ve orchestrator üzerinden
- `initialize(self)` ile verilen `_world` referansı sadece scene tree erişimi için

---

## 7. Risk Değerlendirmesi

| Risk | Olasılık | Etki | Çözüm |
|------|----------|------|-------|
| Modül çakışması | Düşük | Yüksek | Sinyal bazlı iletişim, gevşek bağlı |
| Performans | Düşük | Orta | _process yok, Tween+loop, SVG lightweight |
| Memory (texture) | Düşük | Düşük | textures.gd merkezi, preload paylaşımı |
| Overlay z-index | Düşük | Orta | CanvasLayer sistemi (50-110) |
| Event chain hatası | Düşük | Yüksek | CHAPTER_EVENT_CHAINS dict, feature flag |

### Azaltma Stratejileri
- Her modül kendi `_ready`'sinde `assert` ile bağımlılıkları kontrol eder
- OverlayManager `register_overlay` ile çakışma kontrolü
- BUILT_ZONES ile eksik bölgelerde auto-skip
- Godot headless validation CI'a eklenebilir

---

## 8. Nihai Klasör Yapısı

```
scripts/
├── world.gd                    # Orchestrator (227 satır)
├── world_state.gd              # State management
├── world_builder.gd            # 9 zone builder (~3,146 satır)
├── world_marker.gd             # Marker spawning
├── world_wave.gd               # Wave mechanics
├── world_player.gd             # Player interaction
├── world_ui.gd                 # UI connections
├── world_zone.gd               # Zone transitions
├── main_menu.gd                # Ana menü
├── audio_manager.gd            # Procedural audio (autoload)
├── overlay_manager.gd          # Stack-based overlay yönetimi
├── textures.gd                 # Merkezi texture sabitleri
├── save_manager.gd             # JSON settings (autoload)
├── colors.gd                   # Merkezi renk sabitleri
├── dialogue_overlay.gd         # Diyalog overlay
├── decision_overlay.gd         # Karar overlay
├── info_card_overlay.gd        # Bilgi kartı overlay
├── chapter_transition_overlay.gd # Bölüm geçiş overlay
├── dream_intro_overlay.gd      # Rüya giriş overlay
├── exit_confirm_overlay.gd     # Çıkış onay overlay
├── loading_overlay.gd          # Yükleniyor overlay
└── hud_bar.gd                  # HUD göstergeleri
```

---

*Son güncelleme: 2026-05-11*
