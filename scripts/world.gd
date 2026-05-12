## MMAE - Ana Oyun Orchestrator
## ==============================
## R5 refactoring: 3079 satırdan modüler mimariye dönüştürüldü.
## Sadece orkestrasyon katmanı: modülleri kurar, event akışını yönetir.
##
## Modüller:
##   - WorldPlayer (scripts/world_player.gd) — karakter, hareket, companion
##   - WorldUI    (scripts/world_ui.gd)    — overlay, HUD, stiller, minimap
##   - WorldZone  (scripts/world_zone.gd)  — zone geçişleri, etkileşim, kararlar

extends Node2D

# ---------------------------------------------------------------------------
# SABİTLER
# ---------------------------------------------------------------------------
const WORLD_SIZE := Vector2(1600, 2200)
const PLAYER_SPEED := 430.0
const INTERACT_DISTANCE := 150.0

# Event index sabitleri — questions.gd EVENTS dizisine referans
const EVENT_STORY_ROOM_1 := 0
const EVENT_STORY_ROOM_2 := 1
const EVENT_STORY_SHIP := 2
const EVENT_DECISION_SAMSUN := 3
const EVENT_DECISION_HAVZA := 4
const EVENT_DECISION_AMASYA := 5
const EVENT_DECISION_KONGRE := 6
const EVENT_STORY_HAVZA_ROAD := 7
const EVENT_DECISION_HAVZA_CALL := 8
const EVENT_DECISION_HAVZA_TELGRAF := 9
const EVENT_STORY_AMASYA_ARRIVAL := 10
const EVENT_DECISION_AMASYA_IDEA := 11
const EVENT_STORY_AMASYA_DECISIONS := 12
const EVENT_DECISION_AMASYA_CONGRESS := 13
const EVENT_STORY_ERZURUM_OPEN := 14
const EVENT_DECISION_ERZURUM_MANDA := 15
const EVENT_STORY_ERZURUM_HEYET := 16
const EVENT_STORY_SIVAS_OPEN := 17
const EVENT_DECISION_SIVAS_UNITY := 18
const EVENT_STORY_SIVAS_HEYET := 19
const EVENT_STORY_ANKARA_ROAD := 20
const EVENT_DECISION_ANKARA_CENTER := 21
const EVENT_STORY_ANKARA_MECLIS := 22
const EVENT_DECISION_ANKARA_GUC := 23
const EVENT_STORY_SAKARYA_PRE := 24
const EVENT_DECISION_SAKARYA_STRATEGY := 25
const EVENT_STORY_SAKARYA_BATTLE := 26
const EVENT_DECISION_SAKARYA_AFTERMATH := 27
const EVENT_STORY_FINAL_CUMHURIYET := 28
const EVENT_DECISION_FINAL_VISION := 29
const EVENT_STORY_FINAL_WAKE := 30

const _colors := preload("res://scripts/colors.gd")
const _textures := preload("res://scripts/textures.gd")
const _questions := preload("res://assets/data/questions.gd")


# ---------------------------------------------------------------------------
# @ONREADY — SAHNE AĞACI REFERANSLARI
# ---------------------------------------------------------------------------
# Mevcut modüller (world.tscn child node'ları)
@onready var _state: Node = $WorldState
@onready var _builder: Node = $WorldBuilder
@onready var _marker: Node = $WorldMarker
@onready var _wave: Node = $WorldWave

# Sahne referansları (orchestrator & modüllerin erişimi için)
@onready var props: Node2D = $Props
@onready var markers: Node2D = $Markers
@onready var foreground_props: Node2D = $ForegroundProps
@onready var player: Node2D = $Player
@onready var companion: Node2D = $Companion
@onready var character_panel: PanelContainer = $CanvasLayer/HUD/CharacterPanel
@onready var interact_button: Button = $CanvasLayer/HUD/InteractButton
@onready var dialogue_continue: Button = $CanvasLayer/HUD/DialoguePanel/DialogueMargin/DialogueContent/DialogueContinue
@onready var dialogue_panel: PanelContainer = $CanvasLayer/HUD/DialoguePanel

# Karakter paneli alt bileşenleri (world_wave.gd _world üzerinden erişir)
@onready var character_title: Label = $CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/CharacterTitle
@onready var character_text: Label = $CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/CharacterText
@onready var arda_button: Button = $CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/ArdaButton
@onready var eda_button: Button = $CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/EdaButton

# Yeni modüller (programatik olarak _ready()'de eklenecek)
var _player_mod: Node
var _ui_mod: Node
var _zone_mod: Node

# WorldWave modülünün _world üzerinden eriştiği state değişkenleri
var selected_build_marker: Node2D = null
var panel_mode: String = "character"


# ---------------------------------------------------------------------------
# _ready — ORCHESTRATOR KURULUMU
# ---------------------------------------------------------------------------
func _ready() -> void:
	# 1. State başlangıç değerleri
	_state.set_zone_item_total("units", 3)
	_state.set_zone_item_total("ship_clues", 2)
	_state.set_zone_item_total("havza_clues", 2)
	_state.set_zone_item_total("amasya_clues", 2)
	_state.set_zone_item_total("kongre_clues", 2)
	_state.increment_item_count("units", 0)
	_state.increment_item_count("ship_clues", 0)
	_state.increment_item_count("havza_clues", 0)
	_state.increment_item_count("amasya_clues", 0)
	_state.increment_item_count("kongre_clues", 0)

	# 2. Canvas katmanı
	$CanvasLayer.layer = 10

	# 3. Modülleri kur (preload + new + add_child + initialize)
	_player_mod = WorldPlayer.new()
	_player_mod.name = "WorldPlayer"
	_ui_mod = WorldUI.new()
	_ui_mod.name = "WorldUI"
	_zone_mod = WorldZone.new()
	_zone_mod.name = "WorldZone"
	add_child(_player_mod)
	add_child(_ui_mod)
	add_child(_zone_mod)
	_player_mod.initialize(self)
	_ui_mod.initialize(self)
	_zone_mod.initialize(self)

	# 4. UI temel kurulum (UI modülü üzerinden)
	_ui_mod.apply_ui_styles()
	_ui_mod.build_minimap_hud()
	_ui_mod.build_guidance_arrow()
	_ui_mod.build_route_hud()

	# 5. Karakter görsel kurulum (Player modülü üzerinden)
	_player_mod.build_character_choice_identity_row()
	_player_mod.setup_character_outlines()
	_player_mod.enforce_world_character_z_index()

	# 6. Oyun dünyası kurulumu: builder → marker → wave
	_builder.build_world("room", self)
	_marker.spawn_markers("room", self)
	_wave.setup(self)

	# 7. Sinyal bağlantıları
	_builder.goal_visual_registered.connect(_on_builder_goal_visual_registered)
	_connect_ui()

	# 8. Oyun başlangıcı — karakter seçimi
	_enter_requested_flow()

	# 9. Touch boyutları
	interact_button.custom_minimum_size = Vector2(104, 104)
	dialogue_continue.custom_minimum_size = Vector2(88, 88)

	# 10. Ses — placeholder BGM baslat (assets/audio/ bos oldugu surece procedural)
	AudioManager.play_bgm("BGM_EXPLORE")

	# 11. Idle animasyonlarını başlat
	_player_mod.start_idle_animations()
	_ui_mod.start_idle_animations()


func _enter_requested_flow() -> void:
	var entry_action := SaveManager.pending_entry_action
	SaveManager.pending_entry_action = ""
	if entry_action == "continue" and SaveManager.has_save():
		if _restore_saved_game(SaveManager.load_game()):
			print("[World] Kayit yuklendi, akış devam ettirildi.")
			return
	if SaveManager.has_save():
		print("[World] Kayit bulundu. Yeni oyun karakter secim ekrani gosteriliyor.")
	_player_mod.reset_panel_for_character_choice()
	_player_mod.set_character_choice_visible(true)
	_state.set_goal("unit", "Karakterini seç. Sonra odada dolaşıp ünite notlarını topla ve rüya yolculuğunu başlat.")
	_ui_mod.update_progress()


func _restore_saved_game(save_data: Dictionary) -> bool:
	if save_data.is_empty():
		return false

	_state.from_dict(save_data)
	_player_mod.apply_hero_selection(_state.selected_character)
	_ui_mod.panel_mode = "character"
	panel_mode = "character"
	_zone_mod.restore_saved_zone(_state.current_zone)
	_restore_saved_positions(save_data)
	_ui_mod.update_objective(_state.current_goal_text)
	_ui_mod.update_progress()
	_ui_mod.refresh_minimap_markers()
	interact_button.visible = true
	interact_button.disabled = false
	character_panel.visible = false
	return true


func _restore_saved_positions(save_data: Dictionary) -> void:
	var player_pos := _vector2_from_save(save_data.get("player_position", {}), player.position)
	var companion_pos := _vector2_from_save(save_data.get("companion_position", {}), companion.position)
	player.position = player_pos
	companion.position = companion_pos
	_player_mod.target_position = player_pos
	_player_mod.has_target = false


func _vector2_from_save(raw_value: Variant, fallback: Vector2) -> Vector2:
	if raw_value is Dictionary:
		var point := raw_value as Dictionary
		if point.has("x") and point.has("y"):
			return Vector2(float(point.get("x", fallback.x)), float(point.get("y", fallback.y)))
	return fallback


func _on_hero_chosen(hero_name: String, companion_name: String) -> void:
	var intro_text := "%s ve %s odadaki notlara yaklaşır. Önce ünite notlarını topla; ardından Bandırma yolculuğu başlayacak." % [hero_name, companion_name]
	_state.set_goal("unit", intro_text)
	_ui_mod.update_progress()
	_ui_mod.show_dialogue(hero_name, intro_text, Callable())


# ---------------------------------------------------------------------------
# _process — ORCHESTRATOR ANA DÖNGÜ
# ---------------------------------------------------------------------------
func _process(delta: float) -> void:
	_ui_mod.elapsed_time += delta
	if is_instance_valid(_player_mod.nearby_marker):
		_marker.animate_feedback(markers, _ui_mod.elapsed_time, _player_mod.nearby_marker, _state.current_goal_kind)
	_player_mod.update_movement_feedback()
	_player_mod.update_companion_reaction()
	_player_mod.update_nearby_marker()
	_ui_mod.update_minimap()
	_ui_mod.update_guidance_arrow()
	_ui_mod.update_samsun_camera_focus(delta)
	_ui_mod.update_route_hud()


# ---------------------------------------------------------------------------
# _physics_process — HAREKET FİZİĞİ
# ---------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	if character_panel.visible or dialogue_panel.visible \
		or _ui_mod.is_any_overlay_visible():
		return

	_player_mod.move_player(delta)
	_player_mod.update_companion(delta)
	_player_mod.update_nearby_marker()


# ---------------------------------------------------------------------------
# _unhandled_input — DOKUNMATİK / FARE GİRDİSİ
# ---------------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	# P2-13: Android geri tuşu — çıkış onay diyalogu yönetimi
	if event.is_action_pressed("ui_cancel"):
		var om: OverlayManager = _ui_mod._overlay_manager
		if om.is_visible(OverlayManager.OverlayType.EXIT_CONFIRM):
			var exit_overlay: CanvasLayer = om.get_overlay_node(OverlayManager.OverlayType.EXIT_CONFIRM)
			exit_overlay.hide_overlay()
			get_viewport().set_input_as_handled()
			return
		elif not character_panel.visible and not dialogue_panel.visible \
			and not _ui_mod.is_any_overlay_visible():
			var exit_overlay: CanvasLayer = om.get_overlay_node(OverlayManager.OverlayType.EXIT_CONFIRM)
			exit_overlay.show_overlay()
			get_viewport().set_input_as_handled()
			return

	if character_panel.visible or dialogue_panel.visible \
		or _ui_mod.is_any_overlay_visible():
		return

	_player_mod.handle_unhandled_input(event)


# ---------------------------------------------------------------------------
# SİNYAL BAĞLANTILARI
# ---------------------------------------------------------------------------
func _connect_ui() -> void:
	"""UI buton ve overlay sinyallerini orchestrator seviyesine bağla."""
	var arda_btn: Button = $CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/ArdaButton
	var eda_btn: Button = $CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/EdaButton

	arda_btn.pressed.connect(_on_panel_button_pressed.bind("a"))
	eda_btn.pressed.connect(_on_panel_button_pressed.bind("b"))
	interact_button.pressed.connect(_on_interact_pressed)
	dialogue_continue.pressed.connect(_on_dialogue_continue)
	
	# Overlay sinyalleri — OverlayManager üzerinden node referansları
	var om: OverlayManager = _ui_mod._overlay_manager
	om.get_overlay_node(OverlayManager.OverlayType.DECISION).choice_selected.connect(_on_decision_overlay_choice)
	om.get_overlay_node(OverlayManager.OverlayType.DIALOGUE).continue_pressed.connect(_on_dialogue_continue)
	om.get_overlay_node(OverlayManager.OverlayType.INFO_CARD).continue_pressed.connect(_on_dialogue_continue)
	om.get_overlay_node(OverlayManager.OverlayType.CHAPTER_TRANSITION).transition_finished.connect(_on_transition_finished)


func _on_panel_button_pressed(choice: String) -> void:
	"""Panel buton (karakter seçimi / destek kurma) routing.
	
	panel_mode (world_wave tarafından _world üzerinden yazılır) veya
	_ui_mod.panel_mode (world_zone tarafından ui_mod üzerinden yazılır)
	hangisi aktifse onu kullan.
	"""
	var active_mode: String = panel_mode
	if active_mode == "character":
		active_mode = _ui_mod.panel_mode
	if active_mode == "character":
		_player_mod.choose_hero("eda" if choice == "b" else "arda")
	elif active_mode == "support":
		_wave.build_support(choice)


func _on_interact_pressed() -> void:
	"""Interact (Yaklaş/Etkileşim) butonu — zone modülüne yönlendir."""
	_zone_mod.interact()


func _on_dialogue_continue() -> void:
	"""Diyalog/info kapat — callback varsa tetikle."""
	_ui_mod.close_dialogue()


func _on_decision_overlay_choice(context: String, choice: String) -> void:
	"""Karar overlay'inden gelen seçim — zone modülüne yönlendir."""
	_zone_mod.on_decision_overlay_choice(context, choice)


func _on_transition_finished() -> void:
	"""Bölüm geçiş animasyonu tamamlandı — CanvasLayer'ı temizle ve event chain'i başlat.
	
	1. OverlayManager.hide() ile chapter transition CanvasLayer'ını kapatır.
	   Bu, is_any_overlay_visible()'ın yanlış pozitif döndürmesini engeller.
	2. Sadece ship zone'u için event chain'i başlatır.
	   Diğer zone'lar kendi show_dialogue()'larını _setup_* içinde çağırır.
	"""
	_ui_mod._overlay_manager.hide(OverlayManager.OverlayType.CHAPTER_TRANSITION)
	if _state.current_zone == "ship":
		_zone_mod.trigger_event_chain()


# ---------------------------------------------------------------------------
# ZONE TRANSITION BRIDGE (world_wave.gd callback'leri için)
# ---------------------------------------------------------------------------
# world_wave.gd, dalga sonrası Callable(_world, "_enter_*") kullanır.
# Bu köprü fonksiyonlar, çağrıyı _zone_mod üzerinden world_zone.gd'ye iletir.

func _enter_havza() -> void:
	"""Köprü: world_wave.gd → world_zone.gd._enter_havza()"""
	_zone_mod._enter_havza()


func _enter_amasya() -> void:
	"""Köprü: world_wave.gd → world_zone.gd._enter_amasya()"""
	_zone_mod._enter_amasya()


func _enter_kongreler() -> void:
	"""Köprü: world_wave.gd → world_zone.gd._enter_kongreler()"""
	_zone_mod._enter_kongreler()


func _finish_prototype() -> void:
	"""Köprü: world_wave.gd → world_zone.gd.finish_prototype()"""
	_zone_mod.finish_prototype()


# ---------------------------------------------------------------------------
# WORLDWAVE BRIDGE FONKSİYONLARI
# ---------------------------------------------------------------------------
# world_wave.gd, _world (world.gd instance) üzerinden bu fonksiyonlara erişir.
# R5 refactoring sonrası UI/ZONE modüllerine yönlendirme yapılır.

func _show_dialogue(title: String, text: String, callback: Callable) -> void:
	"""world_wave.gd köprüsü: _world._show_dialogue → _ui_mod.show_dialogue."""
	_ui_mod.show_dialogue(title, text, callback)


func _update_progress() -> void:
	"""world_wave.gd köprüsü: _world._update_progress → _ui_mod.update_progress."""
	_ui_mod.update_progress()


func _refresh_minimap_markers() -> void:
	"""world_wave.gd köprüsü: _world._refresh_minimap_markers → _ui_mod.refresh_minimap_markers."""
	_ui_mod.refresh_minimap_markers()


func _set_goal(kind: String, text: String) -> void:
	"""world_wave.gd köprüsü: _world._set_goal → _zone_mod.set_goal."""
	_zone_mod.set_goal(kind, text)


func _spawn_reward_burst(center: Vector2, tint: Color, slot_prefix: String) -> void:
	"""world_wave.gd köprüsü: _world._spawn_reward_burst → _ui_mod.spawn_reward_burst."""
	_ui_mod.spawn_reward_burst(center, tint, slot_prefix)


# ---------------------------------------------------------------------------
# BUILDER SİNYAL KÖPRÜSÜ
# ---------------------------------------------------------------------------
func _on_builder_goal_visual_registered(slot_id: String, node: CanvasItem) -> void:
	"""Builder goal_visual_registered sinyalini UI modülüne ilet."""
	_ui_mod.on_builder_goal_visual_registered(slot_id, node)
