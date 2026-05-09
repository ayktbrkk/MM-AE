# Zaman Yolculari Design Decisions

## Current Priority

Validate one strong loop before adding more history content:

1. Keşfet: küçük, güvenli bir tarihsel diorama alanında dolaş.
2. Eşlikçiyle fark et: Arda/Eda yakındaki obje veya landmark hakkında kısa tepki versin.
3. Tarihsel obje topla: not, telgraf, rota, bildiri veya temsil izi gibi somut bir ipucu al.
4. Karar ver: görsel karar kartıyla tarihsel nedeni düşün.
5. Destek node'u kur: liman, telgraf, halk, meydan veya temsil noktalarını güçlendir.
6. Bilgi kartıyla öğren: sonuç kısa, affedici ve tarihsel olarak net açıklansın.

If this loop feels good, the same structure can scale to Havza, Amasya, Erzurum, Sivas, and Ankara.

## Reference Player

- Design anchor: 7-8 yaş.
- 5-6 yaş support comes later through voice, icons, and slower text pacing.
- 9-10 yaş depth comes through optional badges, clearer cause/effect, and slightly richer strategy feedback.
- Do not split the game into age modes; split complexity through optional helper prompts and content density.

## Narrative Architecture

- The player remains Arda or Eda at all times.
- Historical figures are guides, not avatars the child replaces.
- Each unit should have:
  - a grounded exploration space
  - 2-4 clue interactions
  - 1 decision gate
  - 1 strategic or social challenge
  - 1 reflective payoff

## Strategy Layer

- Keep the strategy layer thematic, not generic.
- Reuse the same base verbs across units:
  - collect support
  - place support
  - withstand pressure
- The strategy layer is valid only if the child can connect each node to a historical/social function.
- Samsun support nodes must mean:
  - Liman: observe the situation.
  - Telgraf: communicate safely.
  - Halk: build civic trust.
  - Kararsızlık Dalgası: test whether those supports make the first step stronger.
- Reskin the pressure per unit:
  - Samsun: indecision
  - Havza: fear and silence
  - Amasya: uncertainty
  - Congresses: fragmentation
  - Ankara: scarcity and distance

## Open World Diorama Rules

- Strategy nodes should look like part of the world, not a separate battle screen.
- Mini map and route panels stay hidden by default in open-world pilot scenes.
- Active objective readability comes from path, light, landmark, node halo, and the bottom action button.
- PaperTown is a design and architecture reference, not a direct 3D dependency.
- Arda/Eda companion reactions should teach by noticing, not by lecturing.

## Main Risks To De-Risk First

- Narrative clarity: does the child understand why they are in the dream world?
- Interaction clarity: do inspect/build/decide actions feel different enough?
- Educational clarity: is the history lesson visible through play, not only through dialogue?
- Scope drift: avoid building more maps before the first loop feels complete.
- Emotional clarity: do Arda/Eda feel like real companions before custom world art expands?
- Strategy clarity: does the support-node layer feel like historical decision-making, not generic tower defense?

## Hard Gates

- No new unit world should be expanded before the Samsun loop passes a 7-8 yaş playtest.
- No broad asset replacement should outrank Arda/Eda portrait readability.
- No new strategy mechanic should be added until the current support-node loop is understood without adult explanation.
- No downloaded asset or code may be integrated before license and commercial-use terms are stored in `assets/licenses/`.

## Current Technical Snapshot

- `scripts/world.gd` currently owns the playable loop: room exploration, Bandirma clues, Samsun decision, Samsun support nodes, and later prototype transitions.
- `scenes/dialogue_overlay.tscn` and `scripts/dialogue_overlay.gd` already exist and work as the modern dialogue surface.
- Dialogue currently supports active left/right speaker focus, chapter label, speaker name, typewriter reveal, and tap-to-continue.
- Missing dialogue dependency: expression-based portrait routing. This is the next concrete implementation step before broad world art replacement.
- `scenes/main.tscn` is still an older decision-panel prototype and should not be treated as the active gameplay surface.

---

# world.gd Modularizasyon Plani

## 1. Mevcut Durum

| Metrik | Deger |
|--------|-------|
| Dosya | [`scripts/world.gd`](scripts/world.gd) |
| Toplam satir | **4,651** |
| Fonksiyon sayisi | ~250+ |
| `@onready var` sayisi | ~40+ |
| `const` preload sayisi | ~108 |
| State degiskeni sayisi | ~50+ |
| Kapsanan chapter/dunya | room, bandirma, samsun_rift, havza, amasya, kongreler |

## 2. Hedef Modul Yapisi

```
world.tscn
└── World (Node2D) — scripts/world.gd [ORCHESTRATOR]
    ├── WorldState (Node) — scripts/world_state.gd [STATE]
    ├── WorldBuilder (Node) — scripts/world_builder.gd [BUILDER]
    ├── WorldMarker (Node) — scripts/world_marker.gd [MARKER]
    └── WorldWave (Node) — scripts/world_wave.gd [WAVE]
```

**Tum moduller `extends Node`** — Inheritance yok, Composition var.
Her modul `scripts/` altinda ayri bir `.gd` dosyasi.
Her modul kendi `@onready var _colors := preload(...)` ve `@onready var _questions := preload(...)` referansini tasir.

## 3. Modul Detaylari

### 3.1 — MODUL 1: [`world_state.gd`](scripts/world_state.gd) (~250-350 satir)

**Gorev:** Oyun state'ini merkezi tutar. Chapter, event index, karakter secimi, goal/progress bilgisi.

#### Export Edilen Fonksiyonlar (Public API)

```gdscript
## Karakter secimi
func select_character(character_name: String) -> void
func get_selected_character() -> String
func is_character_selected() -> bool

## Chapter / Alan yonetimi
func get_current_chapter() -> int
func get_current_area() -> String
func set_chapter(value: int) -> void
func set_area(area_name: String) -> void

## Event / Index yonetimi
func get_event_index() -> int
func set_event_index(value: int) -> void
func advance_event() -> void
func get_question_data(event_key: String) -> Dictionary

## Goal / Progress
func get_current_goal() -> String
func set_goal(goal_text: String) -> void
func get_progress() -> float
func set_progress(value: float) -> void
func get_chip_text() -> String

## Collection counters
func get_collected_count() -> int
func increment_collected() -> void
func is_item_collected(item_name: String) -> bool
func mark_item_collected(item_name: String) -> void

## Decision state
func is_decision_shown(decision_key: String) -> bool
func mark_decision_shown(decision_key: String) -> void
```

#### Sinyaller

```gdscript
signal character_selected(character_name: String)
signal chapter_changed(chapter: int)
signal area_changed(area_name: String)
signal goal_updated(goal_text: String)
signal progress_updated(value: float)
signal event_advanced(event_index: int)
signal item_collected(item_name: String, kind: String)
signal decision_made(decision_key: String, option: String)
```

#### world.gd'den Tasinacak Satir Araliklari

| Satir | Icerik |
|-------|--------|
| 1-199 | const preload'lar, enum'lar, state degiskenleri (karakter_secimi, chapter, area, event_index, goal, progress, collected_count, vs.) |
| 80-150 | `enum MarkerKind`, `enum MarkerStyle`, event index sabitleri (`QUEST_ROOM_STORY_INTRO`, `QUEST_SAMSUN_RIFT_UNIT`, etc.) |
| 301-433 | Karakter secimi: `_show_character_choice_panel()`, `_on_character_selected()`, `_on_close_romantic_card()` |
| ~3700-3740 | `_set_goal()`, `_update_objective()`, `_update_progress()`, `_current_chip_text()` |
| ~ | `_mark_marker_collected()` state kismi |

**Toplam: ~350 satir**

#### Bagimliliklar

- `res://scripts/colors.gd` — `@onready var _colors`
- `res://assets/data/questions.gd` — `@onready var _questions`
- **Bagli oldugu diger moduller:** Yok (en alt katman)
- **Diger modullerin ona bagimliligi:** Tum moduller `WorldState`'e referansla state sorgular

---

### 3.2 — MODUL 2: [`world_builder.gd`](scripts/world_builder.gd) (~2,000-2,200 satir)

**Gorev:** Dunyalarin prosedurel insasi. Geometry primitives, dekorasyon, paper asset katmanlari, kenney objeleri.

#### Export Edilen Fonksiyonlar

```gdscript
## Core builders — orchestrator cagirir
func build_room() -> void
func build_ship() -> void
func build_samsun_rift() -> void
func build_havza_world() -> void
func build_amasya_world() -> void
func build_kongreler_world() -> void

## Decorators
func decorate_room() -> void
func decorate_ship(difficulty: int) -> void
func decorate_samsun_diorama_pilot() -> void
func decorate_samsun_rift() -> void
func decorate_havza() -> void
func decorate_amasya() -> void
func decorate_kongreler() -> void

## Public API (world.gd'nin public fonksiyonlari)
func add_diorama_ground_blob(center: Vector2, radius: float, color: Color) -> Node2D
func add_paper_path(points: PackedVector2Array, width: float, color: Color) -> Line2D
func add_foreground_frame() -> void
func add_prop_cluster(cluster_data: Dictionary) -> void
func add_historical_landmark(data: Dictionary) -> void
func add_strategy_node(data: Dictionary) -> void
func add_companion_reaction_spot(spot_data: Dictionary) -> void

## Clear / Reset
func clear_world() -> void

## Visual queries
func get_world_container() -> Node2D
func get_character_root() -> Node2D
```

#### Sinyaller

```gdscript
signal world_built(chapter: int, area_name: String)
signal world_cleared()
signal visual_added(node: Node2D, category: String)
```

#### world.gd'den Tasinacak Satir Araliklari

| Satir | Icerik |
|-------|--------|
| 434-610 | `_build_room()`, `_add_rect()`, `_add_room_depth_pass()`, `_add_open_world_start_depth_pass()`, room geometry primitives (`_add_room_polygon`, `_add_room_rect`, `_add_room_floor_rect`, etc.), paper asset layer, glow, character positioning |
| 611-1060 | Decoration primitives: `_add_crimson_flag()`, `_add_rift_shard()`, `_add_soft_blob()`, `_add_path_ribbon()`, `_add_light_pool()`, `_add_samsun_ground_plates()`, `_add_ship_room_plates()`, Samsun path ribbon, support paths, landmark pads, discovery spots, env clusters, harbor identity |
| 1061-1468 | More primitives: atmosphere washes, path caps, node shadows, `_add_samsun_env_prop()`, `_add_samsun_paper_asset_layer()`, `_add_story_banner()`, `_add_asset_slot_prop()`, `_add_decorative_speckles()`, `_add_sprite_prop()`, `_add_paper_cutout_asset()`, `_add_foreground_paper_cutout_asset()`, `_add_backdrop_prop()`, `_add_kenney_prop()`, `_add_kenney_building()`, `_add_kenney_npc()` |
| 1469-1865 | Strategy tokens/cards, location signs, way arrows, discovery badges, breadcrumbs |
| 2208-2430 | `_setup_character_outlines()`, `_remove_duplicate_character_sprites()`, `_create_character_outline()`, `_create_period_accessory()`, `_sync_character_outline_textures()`, sketch tiles, Havza/Amasya building helpers, **public API** (`add_diorama_ground_blob()`, `add_paper_path()`, etc.) |
| 2431-3266 | World building entry points: `_spawn_markers()` (room), `_build_ship()`, `_spawn_ship_markers()`, `_build_samsun_rift()`, `_build_havza_world()`, `_build_amasya_world()`, `_build_kongreler_world()`, decoration functions, marker spawning (without `_add_marker` — marker logic marker modulune) |

**Toplam: ~2,100 satir**

#### Bagimliliklar

- `res://scripts/colors.gd`
- `res://assets/data/questions.gd`
- `WorldState` — chapter/area bilgisi icin
- **Bagli oldugu diger moduller:** Yok (sadece state sorgular)

---

### 3.3 — MODUL 3: [`world_marker.gd`](scripts/world_marker.gd) (~600-700 satir)

**Gorev:** Marker sistemi — spawn, goruntu, animasyon, etkilesim, toplama, destek paneli.

#### Export Edilen Fonksiyonlar

```gdscript
## Marker spawning (builder tarafindan cagrilir)
func spawn_room_markers() -> void
func spawn_ship_markers() -> void
func spawn_samsun_rift_markers() -> void
func spawn_havza_markers() -> void
func spawn_amasya_markers() -> void
func spawn_kongreler_markers() -> void

## Interaction
func get_nearest_interactable(max_distance: float) -> Dictionary
func get_interact_button_text() -> String
func interact() -> void  # dispatches to collect/logic

## Feedback
func animate_marker_feedback(marker: Node2D) -> void
func set_marker_label_visibility(marker: Node2D, visible: bool) -> void
func hide_nearby_collection_world_visuals() -> void
func hide_visual_tree() -> void

## Queries
func is_marker(name: String) -> bool
func get_marker(name: String) -> Node2D
func get_collected_markers() -> Array[String]
```

#### Sinyaller

```gdscript
signal marker_activated(marker_name: String, kind: String, position: Vector2)
signal marker_collected(marker_name: String, kind: String, position: Vector2)
signal item_collected(item_name: String, kind: String)
signal support_requested(support_type: String, position: Vector2)
```

#### world.gd'den Tasinacak Satir Araliklari

| Satir | Icerik |
|-------|--------|
| 2431-2470 | `_spawn_markers()` (room) |
| 2480-2580 | Ship marker spawning |
| 2580-2700 | Samsun rift marker spawning |
| 2700-2800 | Havza marker spawning |
| 2800-2900 | Amasya marker spawning |
| 2900-3000 | Kongreler marker spawning |
| 3000-3266 | `_add_marker()` construction (shadow, pedestal, halo, beacon, ring, shine, icon, sparkles, labels), `_add_marker_setpiece()`, marker style functions, `_marker_color()`, `_marker_icon()`, `_tooltip_icon_text()` |
| 3267-3350 | `_animate_marker_feedback()`, `_set_marker_label_visibility()`, `_update_nearby_marker()`, `_interact_button_text()`, `_interact()` |
| 3701-3850 | `_collect_unit()`, `_collect_ship_clue()`, `_collect_havza_clue()`, `_collect_amasya_clue()`, `_collect_kongre_clue()`, `_collect_leadership_resource()`, `_mark_marker_collected()` |
| 3850-3950 | `_show_support_panel()`, `_build_support()`, `_add_built_support_visual()` |

**Toplam: ~680 satir**

#### Bagimliliklar

- `res://scripts/colors.gd`
- `res://assets/data/questions.gd`
- `WorldState` — item collected state sorgusu
- `WorldBuilder` — support visual ekleme icin `add_strategy_node()` cagrisi
- **Sinyal üzerinden iletisim:** `WorldWave`'e `support_requested` sinyali gonderir

---

### 3.4 — MODUL 4: [`world_wave.gd`](scripts/world_wave.gd) (~400-500 satir)

**Gorev:** Dalga / strateji mekanigi. Support node kurulumu, dalga baslatma, tamamlama.

#### Export Edilen Fonksiyonlar

```gdscript
## Wave mechanics
func start_confusion_wave(target_count: int) -> void
func start_havza_wave(target_count: int) -> void
func start_amasya_wave(target_count: int) -> void
func start_kongre_wave(target_count: int) -> void

## Wave state
func is_wave_active() -> bool
func get_current_wave_name() -> String
func get_wave_progress() -> float
func cancel_wave() -> void

## Support
func place_support_node(node_type: String, position: Vector2) -> void
func get_placed_support_nodes() -> Array[Dictionary]
```

#### Sinyaller

```gdscript
signal wave_started(wave_name: String, target_count: int)
signal wave_progress(progress: float)
signal wave_completed(wave_name: String)
signal wave_failed()
signal support_node_placed(node_type: String, position: Vector2, node: Node2D)
```

#### world.gd'den Tasinacak Satir Araliklari

| Satir | Icerik |
|-------|--------|
| 3950-4020 | `_start_confusion_wave()`, `_start_havza_wave()`, `_start_amasya_wave()`, `_start_kongre_wave()` |
| 4020-4080 | Wave state management, progress tracking |
| 4080-4150 | `_add_built_support_visual()` (marker'dan cagrilan destek goruntuleme) |
| 4150-4200 | Support node placement logic |

**Toplam: ~450 satir**

#### Bagimliliklar

- `res://scripts/colors.gd`
- `WorldState` — chapter/area bilgisi
- `WorldBuilder` — visual ekleme icin `add_strategy_node()`
- **Sinyal üzerinden iletisim:** `WorldMarker`'dan `support_requested` alir, `WorldBuilder`'a `support_node_placed` gonderir

---

### 3.5 — MODUL 5: ORCHESTRATOR [`world.gd`](scripts/world.gd) (~500-700 satir)

**Gorev:** Merkezi orkestrasyon. Input, lifecycle, UI baglantilari, overlay yonetimi, chapter gecisleri, player hareketi, HUD.

#### Orkestratordeki `@onready var` Referanslari (KORUNACAK)

```gdscript
## Scene tree node referanslari — sadece orkestratorda
@onready var _player: CharacterBody2D = $Player
@onready var _camera: Camera2D = $Camera2D
@onready var _world_container: Node2D = $WorldContainer
@onready var _character_root: Node2D = $CharacterRoot
@onready var _dialogue_overlay: CanvasLayer = $UI/DialogueOverlay
@onready var _decision_overlay: CanvasLayer = $UI/DecisionOverlay
@onready var _info_card_overlay: CanvasLayer = $UI/InfoCardOverlay
@onready var _chapter_transition: CanvasLayer = $UI/ChapterTransition
@onready var _hud_bar: CanvasLayer = $UI/HudBar
@onready var _minimap_container: Control = $UI/MinimapContainer
@onready var _guidance_arrow: Node2D = $UI/GuidanceArrow
@onready var _companion_label: Control = $UI/CompanionLabel
@onready var _action_button: Button = $UI/ActionButton
```

#### Orkestratordeki Modul Referanslari

```gdscript
@onready var _state: WorldState = $WorldState
@onready var _builder: WorldBuilder = $WorldBuilder
@onready var _marker: WorldMarker = $WorldMarker
@onready var _wave: WorldWave = $WorldWave
```

#### Orkestratordeki Fonksiyonlar

```gdscript
## Lifecycle
func _ready() -> void           # init sirasi: state -> builder -> marker -> wave -> UI
func _process(delta: float) -> void
func _physics_process(delta: float) -> void
func _unhandled_input(event: InputEvent) -> void

## UI Connections
func _connect_ui() -> void
func _connect_overlay_signals() -> void

## Player
func _move_player(delta: float) -> void
func _set_target(target_pos: Vector2) -> void

## World Transitions
func _enter_bandirma() -> void
func _setup_bandirma() -> void
func _enter_samsun_rift() -> void
func _setup_samsun_rift() -> void
func _enter_havza() -> void
func _setup_havza() -> void
func _enter_amasya() -> void
func _setup_amasya() -> void
func _enter_kongreler() -> void
func _setup_kongreler() -> void
func _finish_prototype() -> void

## Overlay Management
func _show_dialogue(dialogue_key: String) -> void
func _close_dialogue() -> void
func _show_event_decision(event_key: String) -> void
func _show_samsun_decision(event_key: String) -> void
func _on_decision_answer(option: String) -> void
func _show_info_card(card_data: Dictionary) -> void
func _show_chapter_transition(chapter: int, title: String) -> void

## HUD Building
func _build_minimap_hud() -> void
func _update_minimap() -> void
func _build_guidance_arrow() -> void
func _update_guidance_arrow() -> void
func _build_route_hud() -> void
func _update_route_hud() -> void
func _build_companion_reaction_label() -> void
func _update_companion_reaction(text: String) -> void
func _spawn_reward_burst(position: Vector2, count: int) -> void

## Animation
func _animate_world_fx(delta: float) -> void
func _animate_foreground_visual_fx(delta: float) -> void
func _animate_character_feedback(delta: float) -> void
func _paper_parallax_offset(delta: float) -> Vector2
func _update_samsun_camera_focus() -> void
func _start_samsun_open_world_overview() -> void
func _update_companion(delta: float) -> void

## Theme / UI
func _update_area_theme() -> void
func _apply_ui_styles() -> void
func _add_panel_style(panel: Panel) -> void
func _add_button_style(button: Button) -> void
func _format_marker_text(text: String) -> String
func _play_dream_transition() -> void
```

#### world.gd'de KALACAK Satir Araliklari

| Satir | Icerik |
|-------|--------|
| 200-300 | `_ready()`, `_process(delta)`, `_physics_process(delta)`, `_unhandled_input(event)`, `_connect_ui()` |
| 1866-2079 | HUD builders: minimap, guidance arrow, route hud, companion label, reward burst |
| 2079-2208 | Player movement: `_move_player()`, `_set_target()` |
| 3267-3700 | Animasyon: `_animate_world_fx()`, `_paper_parallax_offset()`, `_animate_foreground_visual_fx()`, `_update_samsun_goal_visuals()`, `_animate_character_feedback()`, `_update_samsun_camera_focus()`, `_start_samsun_open_world_overview()`, `_set_goal()`, `_play_dream_transition()`, `_update_companion()`, `_update_companion_reaction()` |
| 4201-4350 | `_show_event_decision()`, `_show_samsun_decision()`, `_on_decision_answer_a()`, `_on_decision_answer_b()`, `_enter_samsun_rift()`, `_setup_samsun_rift()`, `_enter_havza()`, `_setup_havza()`, `_enter_amasya()`, `_setup_amasya()`, `_enter_kongreler()`, `_setup_kongreler()`, `_finish_prototype()` |
| 4350-4550 | `_show_dialogue()`, `_show_info_card()`, `_close_dialogue()`, `_speaker_side_for_title()`, `_info_tag_text()`, `_info_icon()`, `_info_accent()`, `_show_chapter_transition()`, `_current_chip_text()` |
| 4550-4651 | `_update_objective()`, `_update_progress()`, `_update_area_theme()`, `_format_marker_text()`, `_apply_ui_styles()`, `_add_panel_style()`, `_add_button_style()` |

**Toplam: ~600 satir**

---

## 4. Sinyal Baglanti Semasi

```
world_marker.gd                    world.gd (orchestrator)              world_wave.gd
     │                                    │                                │
     ├─ marker_activated ─────────────►   │                                │
     │                               decide flow                          │
     │                                    ├─ wave_mechanics ───────────►   │
     │                                    │                                │
     │                                    │                         wave_started ────► (builder icin)
     │                                    │                         wave_completed ──► (UI update)
     │                                    │                         support_placed ──► (builder)
     │                                    │                                │
     ├─ marker_collected ─────────────►   │                                │
     │                               update state                          │
     │                                    │                                │
     │                                    │                                │
world_state.gd                      world.gd (orchestrator)              world_builder.gd
     │                                    │                                │
     ├─ state_changed ───────────────►   │                                │
     ├─ chapter_changed ─────────────► decide transition ── build_world ──►│
     ├─ character_selected ─────────► setup UI                            │
     ├─ goal_updated ───────────────► update HUD                          │
     │                                    │                         world_built ─────► (marker spawn)
```

### Kodda Sinyal Baglantilari (Orkestrator _ready icinde)

```gdscript
func _ready() -> void:
    # 1. State hazir
    add_child(_state)
    
    # 2. Builder hazir
    add_child(_builder)
    _builder.world_built.connect(_on_world_built)
    
    # 3. Marker hazir
    add_child(_marker)
    _marker.marker_activated.connect(_on_marker_activated)
    _marker.marker_collected.connect(_on_marker_collected)
    
    # 4. Wave hazir
    add_child(_wave)
    _wave.wave_completed.connect(_on_wave_completed)
    _wave.support_node_placed.connect(_on_support_node_placed)
    
    # 5. State sinyalleri
    _state.chapter_changed.connect(_on_chapter_changed)
    _state.character_selected.connect(_on_character_selected)
    _state.goal_updated.connect(_on_goal_updated)
```

---

## 5. Gecis Stratejisi (Migration Roadmap)

### Adim 1: Modul Iskeletlerini Olustur (`~/1 saat`)
- `world_state.gd` — `extends Node`, bos class
- `world_builder.gd` — `extends Node`, bos class
- `world_marker.gd` — `extends Node`, bos class
- `world_wave.gd` — `extends Node`, bos class
- `world.tscn`'de bu 4 node'u `World` kok node'unun altina ekle

### Adim 2: State Modulune Tasima (`~/2 saat`)
- State degiskenlerini (`const`, `enum`, state var) `world.gd`'den `world_state.gd`'ye kopyala
- Karakter secimi fonksiyonlarini tasi
- Sinyalleri ekle
- `_ready()`'de `_state` referansi uzerinden cagri yap
- **Test:** Oyun acilir, karakter secimi calisir

### Adim 3: Builder Modulune Tasima (`~/4 saat`)
- Tum `_build_*`, `_add_*`, `_decorate_*` fonksiyonlarini tasi
- Public API fonksiyonlarini (`add_diorama_ground_blob`, vb.) ekle
- `_clear_world()`'u tasi
- `world_built` sinyalini ekle
- Orkestrator'de `_builder.build_room()` vb. cagrilari guncelle
- **Test:** Her chapter dunyasi dogru insa edilir

### Adim 4: Marker Modulune Tasima (`~/3 saat`)
- Tum `_spawn_*_markers`, `_add_marker`, marker animasyon/fonksiyonlarini tasi
- `_interact()`, `_collect_*()`, `_mark_marker_collected()`'i tasi
- `_show_support_panel()`, `_build_support()`'u tasi
- Sinyalleri ekle (`marker_activated`, `marker_collected`, `support_requested`)
- Orkestrator'de `_interact()` cagrisini `_marker.interact()`'e yonlendir
- **Test:** Markerlar gorunur, etkilesim calisir, toplama calisir

### Adim 5: Wave Modulune Tasima (`~/2 saat`)
- Tum `_start_*_wave()` fonksiyonlarini tasi
- Wave state yonetimini tasi
- Sinyalleri ekle
- Orkestrator'de `_wave.start_confusion_wave()` vb. cagrilari guncelle
- **Test:** Dalga mekanigi calisir, support node'lari kurulur

### Adim 6: Orkestratoru Temizle (`~/2 saat`)
- `world.gd`'den tasinan fonksiyonlari sil
- `_ready()` siralamasini duzenle: state -> builder -> marker -> wave -> UI
- Tum sinyal baglantilarini `_ready()`'de merkezi olarak yap
- `@onready var` referanslari sadece orkestratorde kalsin
- `_process(delta)`'da modul cagrilari: `_builder.animate()` yerine direkt orkestrator animasyonu
- **Test:** Tum oyun dongusu (acilis -> karakter secimi -> room -> bandirma -> samsun -> havza -> amasya -> kongreler) sorunsuz calisir

### Adim 7: Son Test ve Duzeltme (`~/2 saat`)
- Her modulde bagimsiz `@onready var _colors` ve `@onready var _questions` oldugunu dogrula
- Gereksiz tekrar eden `const`'lari temizle
- `world.gd`'nin 600 satirin altinda oldugunu dogrula
- Tum sinyallerin dogru baglandigini dogrula
- **Test:** Tum akis 3 kez eksiksiz oynanir

---

## 6. Bagimlilik Grafigi

```
world_state.gd  ◄──── world_builder.gd  (state sorgulari: chapter, area)
                ◄──── world_marker.gd   (state sorgulari: collected, event_index)
                ◄──── world_wave.gd     (state sorgulari: chapter, area)
                ◄──── world.gd          (state sorgulari: her sey)

world_builder.gd  ◄──── world_marker.gd  (add_strategy_node() cagrisi)
                  ◄──── world_wave.gd    (add_strategy_node() cagrisi)
                  ◄──── world.gd         (build_world() cagrisi)

world_marker.gd  ────► world.gd          (marker_activated, marker_collected sinyalleri)
                 ────► world_wave.gd     (support_requested sinyali)

world_wave.gd    ────► world.gd          (wave_completed, wave_progress sinyalleri)
                 ────► world_builder.gd  (support_node_placed sinyali)
```

### Onemli Kural
- **Moduller arasi dogrudan fonksiyon cagrisi YOK** (sadece orkestrator uzerinden veya signal ile)
- **State sorgulari**: `_state.get_current_chapter()` gibi read-only cagrilara izin var
- **Builder cagrilari**: `_builder.add_strategy_node()` gibi visual ekleme cagrilarina izin var
- **Tum cross-module iletisim** oncelikle signal, sonra orkestrator uzerinden yonlendirme

---

## 7. Risk Degerlendirmesi

| Risk | Olasilik | Etki | Cozum |
|------|----------|------|-------|
| **@onready var kopmasi** | Yuksek | Kritik | Tum `$Path` referanslari sadece orkestratorde kalsin, moduller node referansini parameter olarak alsin |
| **Sinyal baglanti sirasi** | Orta | Yuksek | `_ready()`'de once child'lar eklenmeli, sonra `connect()` cagrilmali |
| **Builder'da _process kaybi** | Dusuk | Orta | Builder'da per-frame animasyon varsa, orkestrator `_process()`'inden cagrilmali |
| **const preload tekrari** | Yuksek | Dusuk | Her modul kendi `preload()`'unu alir, bu 108 preload x 4 = 432 preload demek — RAM etkisi ihmal edilebilir |
| **Wave state tutarsizligi** | Orta | Yuksek | Wave state'i `WorldState`'e tasinabilir veya `WorldWave` kendi Node olarak state'i tutabilir — ikincisi daha clean |
| **Gecis sirasinda hata** | Orta | Yuksek | Her adimdan sonra test et, bir sonraki adima gecmeden once tum akisi dene |
| **_mark_marker_collected parcasi** | Yuksek | Kritik | Bu fonksiyon hem state (mark collected) hem marker (hide visual) hem wave (start wave) isi yapar — dikkatlice bol |
| **clear_world cagrilari** | Orta | Yuksek | `_clear_world()` builder'da, ama marker/Wave state'lerini de temizlemeli — sinyal ile haber ver |

### Azaltma Stratejileri

1. **Her modulde**, orkestratorun `_ready()` sirasini beklemeden calisabilecek bagimsiz unit test fonksiyonlari yaz
2. **Gecis sirasinda**, her adimda `git commit` at — geri donulebilir olsun
3. **Kritik fonksiyonlarda** (`_interact`, `_mark_marker_collected`, `_show_event_decision`) signature'i degistirme, sadece body'yi module tasi
4. **Orkestratordeki `@onready var`'lara DOKUNMA** — sadece modul cagrilari ekle
5. **Modul icinde `print()`** ile debug loglari ekle, gecis tamamlaninca temizle

---

## 8. Nihai Klasor Yapisi

```
scripts/
├── world.gd                    # Orchestrator (~600 satir)
├── world_state.gd              # State yonetimi (~300 satir)
├── world_builder.gd            # Dunya insasi (~2,100 satir)
├── world_marker.gd             # Marker sistemi (~680 satir)
├── world_wave.gd               # Dalga mekanigi (~450 satir)
├── colors.gd                   # Renk sabitleri (degismedi)
├── dialogue_overlay.gd         # (degismedi)
├── decision_overlay.gd         # (degismedi)
├── info_card_overlay.gd        # (degismedi)
├── chapter_transition_overlay.gd  # (degismedi)
├── dream_intro_overlay.gd      # (degismedi)
├── hud_bar.gd                  # (degismedi)
└── main_menu.gd                # (degismedi)
```

**Toplam:** 4,651 satir -> 5 dosyada ~4,130 satir (%~500 satir azalma, tekrar eden preload'lar nedeniyle artis olabilir)
**Orkestrator:** 4,651 -> ~600 satir (%87 kuculme)
