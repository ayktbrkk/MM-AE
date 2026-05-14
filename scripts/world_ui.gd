## MMAE - UI ve Overlay Yönetimi Modülü
## =======================================
## R5 refactoring: world.gd'den ayrıştırıldı.
## Overlay API (dialogue, info_card, decision), stiller, HUD, minimap,
## route panel, guidance arrow, area theme, progress, idle animasyonları.
##
## Kullanım: world.gd tarafından preload edilip initialize() ile kurulur.

class_name WorldUI
extends Node

var _world: Node2D

# UI state
var panel_mode := "character"
var current_dialogue_callback: Callable
var _post_transition_actions: Array[Callable] = []

# Minimap
var minimap_panel: PanelContainer
var minimap_marker_layer: Control
var minimap_player_dot: ColorRect
var minimap_target_dot: ColorRect
var minimap_title_label: Label
var minimap_marker_dots: Dictionary = {}

# Route
var route_panel: PanelContainer
var route_node_dots: Dictionary = {}
var route_node_labels: Dictionary = {}

# Guidance
var guidance_arrow: Node2D
var guidance_arrow_icon: Sprite2D
var guidance_arrow_label_panel: PanelContainer
var guidance_arrow_label: Label

# Atmosphere
var ambient_top_alpha := 0.12
var ambient_horizon_alpha := 0.08
var ambient_fog_alpha := 0.10
var ambient_rift_edge_alpha := 0.04
var ambient_crimson_alpha := 0.04

# Samsun goal visuals
var samsun_goal_visuals: Dictionary = {}
var samsun_open_world_overview_time_left := 0.0

var elapsed_time := 0.0

const _textures := preload("res://scripts/textures.gd")
const _colors := preload("res://scripts/colors.gd")
const _gui_frame := preload("res://scripts/gui_frame.gd")
const _ui_styles := preload("res://scripts/ui_style_factory.gd")
const _ui_tokens := preload("res://scripts/ui_tokens.gd")
const LOADING_OVERLAY_SCENE := preload("res://scenes/loading_overlay.tscn")
const MIN_INTERACT_TOUCH_SIZE := _ui_tokens.TOUCH_TARGET_PRIMARY
const MIN_DIALOGUE_TOUCH_SIZE := _ui_tokens.TOUCH_TARGET_MIN

# Overlay Manager
var _overlay_manager: OverlayManager
var _canvas_root: CanvasLayer
var _overlay_host: Node
var _hud_root: Control
var _hud_bar: Node
var _interact_button: Button
var _character_panel: PanelContainer
var _character_title: Label
var _character_text: Label
var _character_arda_button: Button
var _character_eda_button: Button
var _dialogue_panel: PanelContainer
var _dialogue_continue_button: Button
var _dialogue_overlay: Node
var _decision_overlay: Node
var _info_card_overlay: Node
var _chapter_transition_overlay: Node
var _exit_confirm_overlay: CanvasLayer
var _loading_overlay: CanvasLayer


func initialize(world: Node2D) -> void:
	_world = world
	_cache_ui_references()
	_apply_touch_target_defaults()
	sync_hud_layout()
	_setup_overlay_manager()


func _cache_ui_references() -> void:
	_canvas_root = _world.get_node("CanvasLayer")
	_hud_root = _canvas_root.get_node("HUD")
	_hud_bar = _hud_root.get_node("HudBar")
	_interact_button = _hud_root.get_node("InteractButton")
	_character_panel = _hud_root.get_node("CharacterPanel")
	_character_title = _character_panel.get_node("CharacterMargin/CharacterContent/CharacterTitle")
	_character_text = _character_panel.get_node("CharacterMargin/CharacterContent/CharacterText")
	_character_arda_button = _character_panel.get_node("CharacterMargin/CharacterContent/ArdaButton")
	_character_eda_button = _character_panel.get_node("CharacterMargin/CharacterContent/EdaButton")
	_dialogue_panel = _hud_root.get_node("DialoguePanel")
	_dialogue_continue_button = _dialogue_panel.get_node("DialogueMargin/DialogueContent/DialogueContinue")
	_dialogue_overlay = _hud_root.get_node("DialogueOverlay")
	_decision_overlay = _hud_root.get_node("DecisionOverlay")
	_info_card_overlay = _hud_root.get_node("InfoCardOverlay")
	_chapter_transition_overlay = _hud_root.get_node("ChapterTransitionOverlay")
	_overlay_host = _canvas_root.get_node_or_null(OverlayManager.OVERLAY_HOST_NAME)
	if _overlay_host == null:
		_overlay_host = Node.new()
		_overlay_host.name = OverlayManager.OVERLAY_HOST_NAME
		_canvas_root.add_child(_overlay_host)


func _apply_touch_target_defaults() -> void:
	_interact_button.custom_minimum_size.x = maxf(_interact_button.custom_minimum_size.x, MIN_INTERACT_TOUCH_SIZE)
	_interact_button.custom_minimum_size.y = maxf(_interact_button.custom_minimum_size.y, MIN_INTERACT_TOUCH_SIZE)
	_dialogue_continue_button.custom_minimum_size.x = maxf(_dialogue_continue_button.custom_minimum_size.x, MIN_DIALOGUE_TOUCH_SIZE)
	_dialogue_continue_button.custom_minimum_size.y = maxf(_dialogue_continue_button.custom_minimum_size.y, MIN_DIALOGUE_TOUCH_SIZE)


func sync_hud_layout() -> void:
	if _world == null or _hud_root == null:
		return
	var viewport_size := _world.get_viewport_rect().size
	var side_margin := _gui_frame.safe_area_side(viewport_size)
	var top_margin := _gui_frame.safe_area_top(viewport_size)
	var bottom_margin := _gui_frame.safe_area_bottom(viewport_size)
	_sync_world_panels(side_margin, top_margin, bottom_margin, viewport_size)
	if _hud_bar != null and _hud_bar.has_method("sync_layout"):
		_hud_bar.call("sync_layout")


func _sync_world_panels(side_margin: float, top_margin: float, bottom_margin: float, viewport_size: Vector2) -> void:
	var interact_height := maxf(_interact_button.custom_minimum_size.y, _ui_tokens.TOUCH_TARGET_PRIMARY)
	_interact_button.offset_left = side_margin
	_interact_button.offset_right = -side_margin
	_interact_button.offset_bottom = -bottom_margin
	_interact_button.offset_top = _interact_button.offset_bottom - interact_height

	var dialogue_height := clampf(viewport_size.y * _ui_tokens.WORLD_DIALOGUE_HEIGHT_RATIO, _ui_tokens.WORLD_DIALOGUE_HEIGHT_MIN, _ui_tokens.WORLD_DIALOGUE_HEIGHT_MAX)
	_dialogue_panel.offset_left = side_margin
	_dialogue_panel.offset_right = -side_margin
	_dialogue_panel.offset_bottom = _interact_button.offset_top - _ui_tokens.HUD_STACK_GAP
	_dialogue_panel.offset_top = _dialogue_panel.offset_bottom - dialogue_height

	var sidebar_top := maxf(_ui_tokens.WORLD_SIDEBAR_TOP_OFFSET, top_margin + _ui_tokens.WORLD_SIDEBAR_TOP_GAP)
	if minimap_panel != null:
		minimap_panel.offset_right = -side_margin
		minimap_panel.offset_left = minimap_panel.offset_right - _ui_tokens.WORLD_MINIMAP_WIDTH
		minimap_panel.offset_top = sidebar_top
		minimap_panel.offset_bottom = minimap_panel.offset_top + _ui_tokens.WORLD_MINIMAP_HEIGHT
	if route_panel != null:
		route_panel.offset_left = side_margin
		route_panel.offset_top = sidebar_top
		route_panel.offset_right = route_panel.offset_left + _ui_tokens.WORLD_ROUTE_WIDTH
		route_panel.offset_bottom = route_panel.offset_top + _ui_tokens.WORLD_ROUTE_HEIGHT


func _setup_overlay_manager() -> void:
	"""Overlay Manager'ı kur ve tüm overlay'leri kaydet."""
	_overlay_manager = OverlayManager.new()
	_overlay_manager.name = "OverlayManager"
	_overlay_host.add_child(_overlay_manager)

	_overlay_manager.register_overlay(OverlayManager.OverlayType.DIALOGUE, _dialogue_overlay)
	_overlay_manager.register_overlay(OverlayManager.OverlayType.DECISION, _decision_overlay)
	_overlay_manager.register_overlay(OverlayManager.OverlayType.INFO_CARD, _info_card_overlay)
	_overlay_manager.register_overlay(OverlayManager.OverlayType.CHAPTER_TRANSITION, _chapter_transition_overlay)
	_loading_overlay = LOADING_OVERLAY_SCENE.instantiate()
	add_child(_loading_overlay)
	_overlay_manager.register_overlay(OverlayManager.OverlayType.LOADING, _loading_overlay)
	
	# P2-13: Çıkış onay overlay'ini programatik olarak oluştur ve kaydet
	var exit_confirm_scene := preload("res://scenes/exit_confirm_overlay.tscn")
	_exit_confirm_overlay = exit_confirm_scene.instantiate()
	add_child(_exit_confirm_overlay)
	_overlay_manager.register_overlay(OverlayManager.OverlayType.EXIT_CONFIRM, _exit_confirm_overlay)


func get_overlay_manager() -> OverlayManager:
	return _overlay_manager


func get_character_choice_buttons() -> Array[Button]:
	return [_character_arda_button, _character_eda_button]


func get_interact_button() -> Button:
	return _interact_button


func get_dialogue_continue_button() -> Button:
	return _dialogue_continue_button


func get_overlay(type) -> Node:
	return _overlay_manager.get_overlay_node(type)


func get_loading_overlay() -> Node:
	return get_overlay(OverlayManager.OverlayType.LOADING)


func stage_loading_request(request: Dictionary) -> bool:
	var loading_overlay := get_loading_overlay()
	if loading_overlay == null or not loading_overlay.has_method("stage_request"):
		return false
	return bool(loading_overlay.call("stage_request", request))


func show_loading_request(request: Dictionary) -> bool:
	if not stage_loading_request(request):
		return false
	_overlay_manager.show(OverlayManager.OverlayType.LOADING, request)
	return true


func hide_overlay(type) -> void:
	_overlay_manager.hide(type)


func is_world_input_blocked() -> bool:
	return _character_panel.visible or _dialogue_panel.visible or _overlay_manager.active_blocks_world_input()


func restore_world_hud_after_load() -> void:
	panel_mode = "character"
	_interact_button.visible = true
	_interact_button.disabled = false
	_character_panel.visible = false


func show_support_panel(title: String, body: String, button_a_text: String, button_b_text: String) -> void:
	panel_mode = "support"
	_character_title.text = title
	_character_text.text = body
	_character_arda_button.text = button_a_text
	_character_eda_button.text = button_b_text
	_character_panel.visible = true
	_interact_button.visible = false


func hide_support_panel() -> void:
	panel_mode = "character"
	_character_panel.visible = false
	_interact_button.visible = true


func is_exit_confirm_visible() -> bool:
	return _overlay_manager.is_visible(OverlayManager.OverlayType.EXIT_CONFIRM)


func show_exit_confirm() -> void:
	_overlay_manager.show(OverlayManager.OverlayType.EXIT_CONFIRM)


func hide_exit_confirm() -> void:
	_overlay_manager.hide(OverlayManager.OverlayType.EXIT_CONFIRM)


func has_closeable_overlay() -> bool:
	return _dialogue_panel.visible or _overlay_manager.has_closeable_active_overlay()


func handle_global_cancel() -> bool:
	if has_closeable_overlay():
		close_dialogue()
		return true
	if is_exit_confirm_visible():
		hide_exit_confirm()
		return true
	if not is_world_input_blocked():
		show_exit_confirm()
		return true
	return false


# ---------------------------------------------------------------------------
# OVERLAY API
# ---------------------------------------------------------------------------

func show_dialogue(title: String, text: String, callback: Callable, expression: String = "idle") -> void:
	if not callback.is_valid() and _queue_after_transition(Callable(self, "_show_dialogue_now").bind(title, text, callback, expression)):
		return
	_show_dialogue_now(title, text, callback, expression)


func _show_dialogue_now(title: String, text: String, callback: Callable, expression: String = "idle") -> void:
	current_dialogue_callback = callback
	_overlay_manager.show(OverlayManager.OverlayType.DIALOGUE, {
		"chapter": _current_chip_text(),
		"speaker": title,
		"text": text,
		"speaker_side": _speaker_side_for_title(title),
		"expression": expression,
	})
	_interact_button.disabled = true
	# P1.3: Diyalog acilinca gecis sesi
	_play_transition_sfx()


func show_info_card(title: String, text: String, reward_text: String, callback: Callable, card_kind := "resource") -> void:
	if _queue_after_transition(Callable(self, "_show_info_card_now").bind(title, text, reward_text, callback, card_kind)):
		return
	_show_info_card_now(title, text, reward_text, callback, card_kind)


func _show_info_card_now(title: String, text: String, reward_text: String, callback: Callable, card_kind := "resource") -> void:
	current_dialogue_callback = callback
	panel_mode = "info_card"
	_overlay_manager.show(OverlayManager.OverlayType.INFO_CARD, {
		"tag_text": _info_tag_text(card_kind),
		"title": title,
		"text": text,
		"reward_text": reward_text,
		"icon_texture": _info_icon(card_kind),
		"accent_color": _info_accent(card_kind)
	})
	_interact_button.disabled = true
	# P1.3: Bilgi karti acilinca gecis sesi
	_play_transition_sfx()


func show_decision(event_index: int, context: String) -> void:
	"""Karar overlay'ini göster."""
	if _queue_after_transition(Callable(self, "_show_decision_now").bind(event_index, context)):
		return
	_show_decision_now(event_index, context)


func _show_decision_now(event_index: int, context: String) -> void:
	"""Karar overlay'ini göster."""
	var questions := preload("res://assets/data/questions.gd")
	var event: Dictionary = questions.localized_event(event_index, _current_hero_name())
	panel_mode = "decision"
	_overlay_manager.show(OverlayManager.OverlayType.DECISION, {
		"context": context,
		"chapter": event.get("chapter", "Karar Anı"),
		"title": event.get("chapter", "Karar Anı") + " - Karar",
		"prompt": event.get("story", ""),
		"option_a": event.get("option_a", ""),
		"option_b": event.get("option_b", ""),
	})
	_interact_button.visible = false
	_character_panel.visible = false
	# P1.3: Karar acilinca gecis sesi
	_play_transition_sfx()


func _current_hero_name() -> String:
	if _world == null:
		return ""
	var player_mod: Node = _world.get_node_or_null("WorldPlayer")
	if player_mod == null:
		return ""
	return String(player_mod.get("hero_name"))


func close_dialogue() -> void:
	"""Aktif overlay'i kapat ve callback'i çağır."""
	var closed_callback_surface := _dialogue_panel.visible
	var active_overlay := _overlay_manager.get_active()
	if active_overlay == OverlayManager.OverlayType.DIALOGUE or active_overlay == OverlayManager.OverlayType.INFO_CARD:
		closed_callback_surface = true
	if _overlay_manager.has_closeable_active_overlay():
		_overlay_manager.hide_active_closeable_overlay()
	elif _dialogue_panel.visible:
		_dialogue_panel.visible = false
	else:
		return
	_interact_button.disabled = has_closeable_overlay()
	if closed_callback_surface and current_dialogue_callback.is_valid():
		var callback := current_dialogue_callback
		current_dialogue_callback = Callable()
		callback.call()


func show_chapter_transition(title: String, subtitle: String) -> void:
	"""Bölüm geçiş overlay'ini göster."""
	_overlay_manager.show(OverlayManager.OverlayType.CHAPTER_TRANSITION, {
		"chapter": title,
		"subtitle": subtitle,
		"progress_text": _chapter_loading_text(title),
	})
	# Ses: bölüme göre bgm değiştir
	_play_bgm_track(_bgm_for_chapter(title))
	# P1.3: Bölüm geçiş sesi
	_play_transition_sfx()
	# P7: Bölüm geçişinde otomatik kaydet
	_save_game()


func flush_post_transition_actions() -> void:
	if _post_transition_actions.is_empty():
		return
	var actions: Array[Callable] = _post_transition_actions.duplicate()
	_post_transition_actions.clear()
	for action in actions:
		if action.is_valid():
			action.call_deferred()


func _queue_after_transition(action: Callable) -> bool:
	if not _overlay_manager.is_effectively_visible(OverlayManager.OverlayType.CHAPTER_TRANSITION):
		return false
	_post_transition_actions.append(action)
	return true


func _play_transition_sfx() -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null:
		audio_manager.call("play_sfx", "SFX_TRANSITION")


func _play_bgm_track(track_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null:
		audio_manager.call("play_bgm", track_name)


func _is_overlay_effectively_visible(type: int) -> bool:
	return _overlay_manager.is_effectively_visible(type)


func is_any_overlay_visible() -> bool:
	var active_overlay := _overlay_manager.get_active()
	return active_overlay >= 0 and _overlay_manager.is_effectively_visible(active_overlay)


# ---------------------------------------------------------------------------
# OVERLAY YARDIMCI FONKSİYONLAR
# ---------------------------------------------------------------------------

func _speaker_side_for_title(title: String) -> String:
	var state: Node = _world.get_node("WorldState")
	if title.contains("Eda"):
		return "right"
	if title.contains("Arda"):
		return "left"
	return "right" if state.selected_character == "eda" else "left"


func _info_tag_text(card_kind: String) -> String:
	match card_kind:
		"unit":
			return "Ünite Notu"
		"ship":
			return "Bandırma İpucu"
		"havza":
			return "Genelge İpucu"
		"amasya":
			return "Bildiri İpucu"
		"kongre":
			return "Kongre İpucu"
		"decision":
			return "Doğru Karar"
		"support":
			return "Liderlik Kaynağı"
		_:
			return "Tarih Kartı"


func _info_icon(card_kind: String) -> Texture2D:
	match card_kind:
		"unit":
			return _textures.NOTE_ICON
		"ship":
			return _textures.PORTAL_ICON
		"havza":
			return _textures.TALK_ICON
		"amasya":
			return _textures.NOTE_ICON
		"kongre":
			return _textures.TALK_ICON
		"decision":
			return _textures.DECISION_ICON
		"support":
			return _textures.BADGE_ICON
		_:
			return _textures.RESOURCE_ICON


func _info_accent(card_kind: String) -> Color:
	match card_kind:
		"unit":
			return Color(0.95, 0.75, 0.28, 0.18)
		"ship":
			return Color(0.34, 0.63, 0.95, 0.18)
		"havza":
			return Color(0.80, 0.88, 0.36, 0.18)
		"amasya":
			return Color(0.92, 0.84, 0.44, 0.18)
		"kongre":
			return Color(0.90, 0.70, 0.38, 0.18)
		"decision":
			return Color(0.95, 0.55, 0.28, 0.18)
		"support":
			return Color(0.74, 0.95, 0.38, 0.18)
		_:
			return Color(0.95, 0.75, 0.28, 0.18)


func _current_chip_text() -> String:
	var state: Node = _world.get_node("WorldState")
	match state.current_zone:
		"ship":
			return "Bandırma Vapuru"
		"samsun_rift":
			return "Samsun Rüyası"
		"havza":
			return "Havza Genelgesi"
		"amasya":
			return "Amasya Genelgesi"
		"kongreler":
			return "Kongreler"
		"ankara":
			return "Ankara: Meclis ve İrade"
		"sakarya":
			return "Sakarya ve Büyük Taarruz"
		"final":
			return "Final: Cumhuriyet"
		_:
			return "Sınav Gecesi"


func _bgm_for_chapter(chapter_title: String) -> String:
	match chapter_title:
		"Bandırma Vapuru":
			return "bgm_bandirma"
		"Samsun Rüyası":
			return "bgm_samsun"
		"Havza Genelgesi":
			return "bgm_havza"
		"Amasya Genelgesi":
			return "bgm_amasya"
		"Kongreler":
			return "bgm_kongre"
		_:
			return "bgm_default"


func _chapter_loading_text(chapter_title: String) -> String:
	match chapter_title:
		"Bandırma Vapuru":
			return "Gemi ve rota hazırlanıyor..."
		"Samsun Ruyasi":
			return "Kıyı ve ilk hedefler beliriyor..."
		"Havza Genelgesi":
			return "Meydan ve çağrı noktaları hazırlanıyor..."
		"Amasya Genelgesi":
			return "Bildiri masası ve karar izi kuruluyor..."
		"Kongreler":
			return "Delegeler ve konuşma alanı yerleşiyor..."
		"Ankara: Meclis ve İrade":
			return "Meclis salonu ve rota çizgisi hazırlanıyor..."
		"Sakarya ve Büyük Taarruz":
			return "Cephe ve hedef hattı yükleniyor..."
		"Final: Cumhuriyet":
			return "Kutlama alanı ve son sahne hazırlanıyor..."
		_:
			return "Sahne hazırlanıyor..."


# ---------------------------------------------------------------------------
# MINIMAP
# ---------------------------------------------------------------------------

func build_minimap_hud() -> void:
	"""Minimap panelini oluştur."""
	minimap_panel = PanelContainer.new()
	minimap_panel.name = "MiniMapPanel"
	minimap_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	minimap_panel.offset_left = -310
	minimap_panel.offset_top = 270
	minimap_panel.offset_right = -28
	minimap_panel.offset_bottom = 558
	_add_panel_style(minimap_panel, Color(0.98, 0.94, 0.78, 0.86), Color(0.10, 0.25, 0.30, 0.92), 16)
	_hud_root.add_child(minimap_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _ui_tokens.SPACE_SM_PLUS)
	margin.add_theme_constant_override("margin_top", _ui_tokens.SPACE_SM)
	margin.add_theme_constant_override("margin_right", _ui_tokens.SPACE_SM_PLUS)
	margin.add_theme_constant_override("margin_bottom", _ui_tokens.SPACE_SM_PLUS)
	minimap_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", _ui_tokens.SPACE_XS)
	margin.add_child(content)

	minimap_title_label = Label.new()
	minimap_title_label.text = "Rota"
	minimap_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	minimap_title_label.add_theme_font_size_override("font_size", _ui_tokens.FONT_LABEL_NAV)
	minimap_title_label.add_theme_color_override("font_color", Color(0.10, 0.14, 0.18, 0.88))
	content.add_child(minimap_title_label)

	var map_frame := PanelContainer.new()
	map_frame.custom_minimum_size = _ui_tokens.MINIMAP_FRAME_SIZE
	_add_panel_style(map_frame, Color(0.08, 0.25, 0.30, 0.64), Color(1.0, 0.84, 0.42, 0.60), 12)
	content.add_child(map_frame)

	minimap_marker_layer = Control.new()
	minimap_marker_layer.custom_minimum_size = _ui_tokens.MINIMAP_MARKER_LAYER_SIZE
	minimap_marker_layer.clip_contents = true
	map_frame.add_child(minimap_marker_layer)

	var horizon := ColorRect.new()
	horizon.color = Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.08)
	horizon.set_anchors_preset(Control.PRESET_FULL_RECT)
	minimap_marker_layer.add_child(horizon)

	minimap_target_dot = _make_minimap_dot(Color(1.0, 0.92, 0.38, 0.88), 16.0)
	minimap_target_dot.visible = false
	minimap_marker_layer.add_child(minimap_target_dot)

	minimap_player_dot = _make_minimap_dot(Color(1.0, 1.0, 1.0, 0.96), 18.0)
	minimap_marker_layer.add_child(minimap_player_dot)
	refresh_minimap_markers()
	sync_hud_layout()


func _make_minimap_dot(color: Color, size_value: float) -> ColorRect:
	var dot := ColorRect.new()
	dot.color = color
	dot.size = Vector2(size_value, size_value)
	dot.custom_minimum_size = Vector2(size_value, size_value)
	return dot


func _world_to_minimap(world_pos: Vector2) -> Vector2:
	var map_size := Vector2(220, 182)
	var world_size := Vector2(1600, 2200)
	if minimap_marker_layer != null and minimap_marker_layer.size.x > 0.0 and minimap_marker_layer.size.y > 0.0:
		map_size = minimap_marker_layer.size
	return Vector2(
		clamp(world_pos.x / world_size.x, 0.0, 1.0) * map_size.x,
		clamp(world_pos.y / world_size.y, 0.0, 1.0) * map_size.y
	)


func clear_minimap_markers() -> void:
	for dot in minimap_marker_dots.values():
		if is_instance_valid(dot):
			dot.queue_free()
	minimap_marker_dots.clear()


func refresh_minimap_markers() -> void:
	if minimap_marker_layer == null:
		return
	clear_minimap_markers()
	var markers: Node2D = _world.get_node("Markers")
	var state: Node = _world.get_node("WorldState")
	for marker in markers.get_children():
		if bool(marker.get_meta("collected", false)):
			continue
		var kind := String(marker.get_meta("kind", ""))
		var dot := _make_minimap_dot(_minimap_color(kind), 12.0 if kind != state.current_goal_kind else 16.0)
		var pos := _world_to_minimap(marker.position)
		dot.position = pos - (dot.size * 0.5)
		dot.set_meta("marker_ref", marker)
		minimap_marker_layer.add_child(dot)
		minimap_marker_dots[marker.get_instance_id()] = dot
	minimap_marker_layer.move_child(minimap_target_dot, minimap_marker_layer.get_child_count() - 1)
	minimap_marker_layer.move_child(minimap_player_dot, minimap_marker_layer.get_child_count() - 1)
	update_minimap()


func update_minimap() -> void:
	if minimap_panel == null or minimap_marker_layer == null:
		return
	var state: Node = _world.get_node("WorldState")
	var player_node: Node2D = _world.get_node("Player")
	var hide_panel: bool = state.current_zone == "room" or state.current_zone == "ship" or state.current_zone == "samsun_rift" or state.current_zone == "ankara" or state.current_zone == "sakarya" or state.current_zone == "final"
	minimap_panel.visible = not hide_panel
	if not minimap_panel.visible:
		return
	if minimap_title_label != null:
		minimap_title_label.text = _minimap_title()
	var player_pos := _world_to_minimap(player_node.position)
	minimap_player_dot.position = player_pos - (minimap_player_dot.size * 0.5)
	minimap_player_dot.color.a = 0.82 + (0.12 * sin(elapsed_time * 3.4))

	var player_mod: Node = _world.get_node("WorldPlayer")
	if player_mod.has_target:
		var target_pos := _world_to_minimap(player_mod.target_position)
		minimap_target_dot.position = target_pos - (minimap_target_dot.size * 0.5)
		minimap_target_dot.visible = true
	else:
		minimap_target_dot.visible = false

	var markers: Node2D = _world.get_node("Markers")
	for marker in markers.get_children():
		var key := marker.get_instance_id()
		if not minimap_marker_dots.has(key):
			continue
		var dot: ColorRect = minimap_marker_dots[key]
		if not is_instance_valid(dot):
			continue
		dot.visible = marker.visible and not bool(marker.get_meta("collected", false))
		if marker == player_mod.nearby_marker:
			dot.scale = Vector2.ONE * (1.22 + 0.10 * sin(elapsed_time * 5.0))
		else:
			dot.scale = Vector2.ONE


func _minimap_color(kind: String) -> Color:
	match kind:
		"unit", "ship_clue", "havza_clue", "amasya_clue", "kongre_clue":
			return Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.90)
		"npc":
			return Color(_colors.POP_TURQUOISE.r, _colors.POP_TURQUOISE.g, _colors.POP_TURQUOISE.b, 0.86)
		"portal", "wave_start", "havza_wave", "amasya_wave", "kongre_wave":
			return Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.90)
		"decision", "havza_decision", "amasya_decision", "kongre_decision":
			return Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.90)
		"resource":
			return Color(0.64, 1.0, 0.42, 0.88)
		"build_spot":
			return Color(1.0, 0.70, 0.24, 0.88)
		_:
			return Color(1.0, 1.0, 1.0, 0.74)


func _minimap_title() -> String:
	var state: Node = _world.get_node("WorldState")
	match state.current_zone:
		"ship":
			return "Bandırma Rotası"
		"samsun_rift":
			return "Samsun Haritası"
		"havza":
			return "Havza Haritası"
		"amasya":
			return "Amasya Haritası"
		"ankara":
			return "Ankara Haritası"
		"sakarya":
			return "Sakarya Haritası"
		"final":
			return "Cumhuriyet Haritası"
		"kongreler":
			return "Kongre Haritası"
		_:
			return "Oda Rotası"


# ---------------------------------------------------------------------------
# GUIDANCE ARROW
# ---------------------------------------------------------------------------

func build_guidance_arrow() -> void:
	"""Yön oku oluştur (player child'ı olarak)."""
	var player_node: Node2D = _world.get_node("Player")
	guidance_arrow = Node2D.new()
	guidance_arrow.name = "GuidanceArrow"
	guidance_arrow.position = Vector2(0, -150)
	guidance_arrow.visible = false
	guidance_arrow.z_index = 20
	player_node.add_child(guidance_arrow)

	var plate := Polygon2D.new()
	plate.name = "GuidancePlate"
	plate.color = Color(_colors.DESIGN_CREAM_PAPER.r, _colors.DESIGN_CREAM_PAPER.g, _colors.DESIGN_CREAM_PAPER.b, 0.92)
	plate.polygon = PackedVector2Array([
		Vector2(-46, -34),
		Vector2(46, -34),
		Vector2(56, 0),
		Vector2(46, 34),
		Vector2(-46, 34),
		Vector2(-56, 0),
	])
	guidance_arrow.add_child(plate)

	var plate_outline := Polygon2D.new()
	plate_outline.name = "GuidancePlateOutline"
	plate_outline.color = Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.76)
	plate_outline.polygon = PackedVector2Array([
		Vector2(-52, -40),
		Vector2(52, -40),
		Vector2(64, 0),
		Vector2(52, 40),
		Vector2(-52, 40),
		Vector2(-64, 0),
	])
	guidance_arrow.add_child(plate_outline)
	guidance_arrow.move_child(plate_outline, 0)

	guidance_arrow_icon = Sprite2D.new()
	guidance_arrow_icon.texture = _textures.GAME_ARROW_UP_TEXTURE
	guidance_arrow_icon.scale = Vector2(0.62, 0.62)
	guidance_arrow_icon.modulate = Color(_colors.POP_DEEP_TURQUOISE.r, _colors.POP_DEEP_TURQUOISE.g, _colors.POP_DEEP_TURQUOISE.b, 0.96)
	guidance_arrow_icon.z_index = 1
	guidance_arrow.add_child(guidance_arrow_icon)

	guidance_arrow_label_panel = PanelContainer.new()
	guidance_arrow_label_panel.name = "GuidanceLabelPanel"
	guidance_arrow_label_panel.position = Vector2(-140, 44)
	guidance_arrow_label_panel.custom_minimum_size = _ui_tokens.GUIDANCE_LABEL_SIZE
	guidance_arrow_label_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	guidance_arrow_label_panel.add_theme_stylebox_override(
		"panel",
		_ui_styles.panel_style(
			Color(_colors.DESIGN_CREAM_PAPER.r, _colors.DESIGN_CREAM_PAPER.g, _colors.DESIGN_CREAM_PAPER.b, 0.94),
			Color(_colors.POP_DEEP_TURQUOISE.r, _colors.POP_DEEP_TURQUOISE.g, _colors.POP_DEEP_TURQUOISE.b, 0.58),
			18,
			3,
			Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.22),
			6,
			Vector2(0, 3)
		)
	)
	guidance_arrow.add_child(guidance_arrow_label_panel)

	var guidance_margin := MarginContainer.new()
	guidance_margin.add_theme_constant_override("margin_left", _ui_tokens.SPACE_SM)
	guidance_margin.add_theme_constant_override("margin_top", _ui_tokens.SPACE_XS)
	guidance_margin.add_theme_constant_override("margin_right", _ui_tokens.SPACE_SM)
	guidance_margin.add_theme_constant_override("margin_bottom", _ui_tokens.SPACE_XS)
	guidance_arrow_label_panel.add_child(guidance_margin)

	guidance_arrow_label = Label.new()
	guidance_arrow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guidance_arrow_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	guidance_arrow_label.add_theme_font_size_override("font_size", _ui_tokens.FONT_LABEL_MD)
	guidance_arrow_label.add_theme_color_override("font_color", Color(_colors.DESIGN_STORY_INK.r, _colors.DESIGN_STORY_INK.g, _colors.DESIGN_STORY_INK.b, 0.96))
	guidance_arrow_label.add_theme_color_override("font_outline_color", Color(_colors.DESIGN_CREAM_PAPER.r, _colors.DESIGN_CREAM_PAPER.g, _colors.DESIGN_CREAM_PAPER.b, 0.26))
	guidance_arrow_label.add_theme_constant_override("outline_size", 1)
	guidance_margin.add_child(guidance_arrow_label)


func update_guidance_arrow() -> void:
	if guidance_arrow == null or guidance_arrow_icon == null:
		return
	var state: Node = _world.get_node("WorldState")
	var player_node: Node2D = _world.get_node("Player")
	var marker_mod: Node = _world.get_node("WorldMarker")
	var markers: Node2D = _world.get_node("Markers")
	var objective_hint_visible := is_objective_hint_visible()
	_sync_location_sign_visibility(objective_hint_visible)

	if state.current_zone == "samsun_rift":
		_hide_guidance_arrow()
		return
	var blocked := is_world_input_blocked()
	var target_marker: Node2D = marker_mod.get_guidance_marker(markers, state.current_goal_kind)
	if blocked or target_marker == null:
		_hide_guidance_arrow()
		return
	var direction := target_marker.global_position - player_node.global_position
	var distance := direction.length()
	if distance < 150.0 * 1.45:
		_hide_guidance_arrow()
		return
	guidance_arrow.visible = true
	guidance_arrow.scale = Vector2.ONE * (1.0 + 0.05 * sin(elapsed_time * 4.0))
	guidance_arrow_icon.rotation = direction.angle() + (PI * 0.5)
	if guidance_arrow_label_panel != null:
		guidance_arrow_label_panel.visible = not objective_hint_visible
	guidance_arrow_label.text = String(target_marker.get_meta("title", "Hedef"))


func _hide_guidance_arrow() -> void:
	guidance_arrow.visible = false
	if guidance_arrow_label_panel != null:
		guidance_arrow_label_panel.visible = false


func is_objective_hint_visible() -> bool:
	return _hud_bar != null and _hud_bar.has_method("is_objective_hint_visible") and _hud_bar.is_objective_hint_visible()


func _sync_location_sign_visibility(objective_hint_visible: bool) -> void:
	if _world == null:
		return
	var state: Node = _world.get_node("WorldState")
	var should_hide_location_sign: bool = objective_hint_visible or not _should_show_objective_hint(state.current_zone)
	var foreground_props := _world.get_node_or_null("ForegroundProps")
	if foreground_props == null:
		return
	for child in foreground_props.get_children():
		if not child.has_meta("asset_slot"):
			continue
		var slot_id := String(child.get_meta("asset_slot", ""))
		if slot_id.contains("location_sign"):
			(child as CanvasItem).visible = not should_hide_location_sign


# ---------------------------------------------------------------------------
# ROUTE HUD
# ---------------------------------------------------------------------------

func build_route_hud() -> void:
	"""Yol haritası panelini oluştur."""
	route_panel = PanelContainer.new()
	route_panel.name = "RoutePanel"
	route_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	route_panel.offset_left = 28
	route_panel.offset_top = 270
	route_panel.offset_right = 250
	route_panel.offset_bottom = 592
	_add_panel_style(route_panel, Color(0.98, 0.94, 0.78, 0.82), Color(0.12, 0.22, 0.26, 0.90), 16)
	_hud_root.add_child(route_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _ui_tokens.SPACE_SM_PLUS)
	margin.add_theme_constant_override("margin_top", _ui_tokens.SPACE_SM)
	margin.add_theme_constant_override("margin_right", _ui_tokens.SPACE_SM_PLUS)
	margin.add_theme_constant_override("margin_bottom", _ui_tokens.SPACE_SM_PLUS)
	route_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", _ui_tokens.SPACE_XS)
	margin.add_child(content)

	var title := Label.new()
	title.text = "Yolculuk"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", _ui_tokens.FONT_LABEL_NAV)
	title.add_theme_color_override("font_color", Color(0.10, 0.14, 0.18, 0.88))
	content.add_child(title)

	for step in _route_steps():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", _ui_tokens.SPACE_XS)
		content.add_child(row)

		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(_ui_tokens.ROUTE_NODE_DOT_SIZE, _ui_tokens.ROUTE_NODE_DOT_SIZE)
		dot.size = Vector2(_ui_tokens.ROUTE_NODE_DOT_SIZE, _ui_tokens.ROUTE_NODE_DOT_SIZE)
		row.add_child(dot)

		var label := Label.new()
		label.text = String(step["label"])
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", _ui_tokens.FONT_LABEL_SM)
		row.add_child(label)

		var area_key := String(step["area"])
		route_node_dots[area_key] = dot
		route_node_labels[area_key] = label
	update_route_hud()
	sync_hud_layout()


func _route_steps() -> Array:
	return [
		{"area": "room", "label": "Oda"},
		{"area": "ship", "label": "Bandırma"},
		{"area": "samsun_rift", "label": "Samsun"},
		{"area": "havza", "label": "Havza"},
		{"area": "amasya", "label": "Amasya"},
		{"area": "kongreler", "label": "Kongre"},
	]


func _route_index(area_key: String) -> int:
	var steps := _route_steps()
	for index in range(steps.size()):
		if String(steps[index]["area"]) == area_key:
			return index
	return 0


func update_route_hud() -> void:
	if route_panel == null:
		return
	var state: Node = _world.get_node("WorldState")
	var hide_panel: bool = state.current_zone == "room" or state.current_zone == "samsun_rift" or state.current_zone == "ankara" or state.current_zone == "sakarya" or state.current_zone == "final"
	route_panel.visible = not hide_panel
	if not route_panel.visible:
		return
	var active_index := _route_index(state.current_zone)
	for step in _route_steps():
		var area_key := String(step["area"])
		var index := _route_index(area_key)
		if not route_node_dots.has(area_key):
			continue
		var dot: ColorRect = route_node_dots[area_key]
		var label: Label = route_node_labels[area_key]
		if index < active_index:
			dot.color = Color(0.58, 0.92, 0.52, 0.88)
			label.add_theme_color_override("font_color", Color(0.12, 0.24, 0.18, 0.74))
		elif index == active_index:
			dot.color = Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.86 + 0.10 * sin(elapsed_time * 3.0))
			label.add_theme_color_override("font_color", Color(0.10, 0.14, 0.18, 0.92))
		else:
			dot.color = Color(0.28, 0.34, 0.38, 0.42)
			label.add_theme_color_override("font_color", Color(0.18, 0.20, 0.24, 0.44))


# ---------------------------------------------------------------------------
# PROGRESS & OBJECTIVE
# ---------------------------------------------------------------------------

func update_progress() -> void:
	var state: Node = _world.get_node("WorldState")
	var progress := ""
	var star_count := 0

	if state.current_zone == "ship":
		progress = "Gemi ipuçları: %d/%d" % [state.get_item_count("ship_clues"), state.get_zone_item_total("ship_clues")]
		star_count = state.get_item_count("units") + state.get_item_count("ship_clues")
	elif state.current_zone == "samsun_rift":
		progress = "Liderlik: %d | Destek: %d/%d | Dalga: %d" % [state.leadership_points, state.built_supports, state.required_supports, state.wave_attempts]
		star_count = state.get_item_count("units") + state.get_item_count("ship_clues") + state.built_supports
	elif state.current_zone == "havza":
		progress = "Havza ipuçları: %d/%d | Liderlik: %d | Destek: %d/%d" % [state.get_item_count("havza_clues"), state.get_zone_item_total("havza_clues"), state.leadership_points, state.built_supports, state.required_supports]
		star_count = state.get_item_count("units") + state.get_item_count("ship_clues") + state.get_item_count("havza_clues") + state.built_supports
	elif state.current_zone == "amasya":
		progress = "Amasya ipuçları: %d/%d | Liderlik: %d | Destek: %d/%d" % [state.get_item_count("amasya_clues"), state.get_zone_item_total("amasya_clues"), state.leadership_points, state.built_supports, state.required_supports]
		star_count = state.get_item_count("units") + state.get_item_count("ship_clues") + state.get_item_count("havza_clues") + state.get_item_count("amasya_clues") + state.built_supports
	elif state.current_zone == "kongreler":
		progress = "Kongre ipuçları: %d/%d | Liderlik: %d | Destek: %d/%d" % [state.get_item_count("kongre_clues"), state.get_zone_item_total("kongre_clues"), state.leadership_points, state.built_supports, state.required_supports]
		star_count = state.get_item_count("units") + state.get_item_count("ship_clues") + state.get_item_count("havza_clues") + state.get_item_count("amasya_clues") + state.get_item_count("kongre_clues") + state.built_supports
	elif state.current_zone == "ankara":
		progress = "Ankara ipuçları: %d/%d | Liderlik: %d | Destek: %d/%d" % [state.get_item_count("ankara_clues"), state.get_zone_item_total("ankara_clues"), state.leadership_points, state.built_supports, state.required_supports]
		star_count = state.get_item_count("units") + state.get_item_count("ship_clues") + state.get_item_count("havza_clues") + state.get_item_count("amasya_clues") + state.get_item_count("kongre_clues") + state.get_item_count("ankara_clues") + state.built_supports
	elif state.current_zone == "sakarya":
		progress = "Sakarya ipuçları: %d/%d | Liderlik: %d | Destek: %d/%d" % [state.get_item_count("sakarya_clues"), state.get_zone_item_total("sakarya_clues"), state.leadership_points, state.built_supports, state.required_supports]
		star_count = state.get_item_count("units") + state.get_item_count("ship_clues") + state.get_item_count("havza_clues") + state.get_item_count("amasya_clues") + state.get_item_count("kongre_clues") + state.get_item_count("ankara_clues") + state.get_item_count("sakarya_clues") + state.built_supports
	elif state.current_zone == "final":
		progress = "Cumhuriyet ipuçları: %d/%d | Liderlik: %d | Destek: %d/%d" % [state.get_item_count("final_clues"), state.get_zone_item_total("final_clues"), state.leadership_points, state.built_supports, state.required_supports]
		star_count = state.get_item_count("units") + state.get_item_count("ship_clues") + state.get_item_count("havza_clues") + state.get_item_count("amasya_clues") + state.get_item_count("kongre_clues") + state.get_item_count("ankara_clues") + state.get_item_count("sakarya_clues") + state.get_item_count("final_clues") + state.built_supports
	else:
		progress = "Ünite notları: %d/%d" % [state.get_item_count("units"), state.get_zone_item_total("units")]
		star_count = state.get_item_count("units")

	_hud_bar.set_progress(progress)
	_hud_bar.set_star_count(star_count)


func update_objective(text: String) -> void:
	var state: Node = _world.get_node("WorldState")
	var title := "Zaman Yolcuları: Sınav Gecesi"
	var chip := "Sınav Gecesi"

	match state.current_zone:
		"ship":
			title = "Zaman Yolcuları: Bandırma"
			chip = "Bandırma Vapuru"
		"samsun_rift":
			title = "Zaman Yolcuları: Samsun Rüyası"
			chip = "Samsun Rüyası"
		"havza":
			title = "Zaman Yolcuları: Havza"
			chip = "Havza Genelgesi"
		"amasya":
			title = "Zaman Yolcuları: Amasya"
			chip = "Amasya Genelgesi"
		"kongreler":
			title = "Zaman Yolcuları: Kongreler"
			chip = "Kongreler"
		"ankara":
			title = "Zaman Yolcuları: Ankara"
			chip = "Ankara: Meclis ve İrade"
		"sakarya":
			title = "Zaman Yolcuları: Sakarya"
			chip = "Sakarya ve Büyük Taarruz"
		"final":
			title = "Zaman Yolcuları: Cumhuriyet"
			chip = "Final: Cumhuriyet"

	_hud_bar.set_title(title)
	_hud_bar.set_chip(chip)
	_hud_bar.set_objective(text, _should_show_objective_hint(state.current_zone))
	_update_area_theme()


func _should_show_objective_hint(zone: String) -> bool:
	return not ["samsun_rift", "ankara", "sakarya", "final"].has(zone)


# ---------------------------------------------------------------------------
# AREA THEME (atmosphere + HUD theme)
# ---------------------------------------------------------------------------

func _update_area_theme() -> void:
	var state: Node = _world.get_node("WorldState")
	var atmosphere_top_glow: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/TopGlow")
	var atmosphere_horizon_glow: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/HorizonGlow")
	var atmosphere_bottom_fog: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/BottomFog")
	var vignette_left: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/VignetteLeft")
	var vignette_right: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/VignetteRight")
	var rift_edge_left: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/RiftEdgeLeft")
	var rift_edge_right: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/RiftEdgeRight")
	var crimson_accent: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/CrimsonAccent")

	var top_fill := Color(0.97, 0.95, 0.86)
	var top_border := Color(0.32, 0.24, 0.16)
	var chip_fill := Color(0.20, 0.42, 0.38)
	var chip_border := Color(0.15, 0.24, 0.20)
	var action_fill := Color(0.20, 0.42, 0.38)
	var top_glow := Color(0.96, 0.72, 0.42, ambient_top_alpha)
	var horizon_glow := Color(0.78, 0.86, 1.0, ambient_horizon_alpha)
	var bottom_fog := Color(0.94, 0.96, 1.0, ambient_fog_alpha)
	var vignette := Color(0.04, 0.05, 0.08, 0.16)
	var rift_edge := Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, ambient_rift_edge_alpha)
	var crimson_line := Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, ambient_crimson_alpha)

	match state.current_zone:
		"room":
			ambient_top_alpha = 0.06
			ambient_horizon_alpha = 0.05
			ambient_fog_alpha = 0.04
			ambient_rift_edge_alpha = 0.0
			ambient_crimson_alpha = 0.0
			top_glow = Color(1.0, 0.78, 0.42, ambient_top_alpha)
			horizon_glow = Color(0.92, 0.82, 0.60, ambient_horizon_alpha)
			bottom_fog = Color(0.96, 0.92, 0.84, ambient_fog_alpha)
			vignette = Color(0.04, 0.05, 0.08, 0.12)
			rift_edge = Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.0)
			crimson_line = Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.0)
		"ship":
			top_fill = Color(0.90, 0.98, 1.0)
			top_border = Color(0.02, 0.36, 0.46)
			chip_fill = _colors.POP_DEEP_TURQUOISE
			chip_border = Color(0.02, 0.18, 0.24)
			action_fill = Color(0.03, 0.48, 0.60)
			ambient_top_alpha = 0.14
			ambient_horizon_alpha = 0.13
			ambient_fog_alpha = 0.14
			ambient_rift_edge_alpha = 0.055
			ambient_crimson_alpha = 0.060
			top_glow = Color(1.0, 0.70, 0.30, ambient_top_alpha)
			horizon_glow = Color(0.18, 0.86, 1.0, ambient_horizon_alpha)
			bottom_fog = Color(0.84, 0.98, 1.0, ambient_fog_alpha)
		"samsun_rift":
			top_fill = Color(0.90, 0.97, 1.0)
			top_border = Color(0.04, 0.42, 0.56)
			chip_fill = Color(0.08, 0.48, 0.62)
			chip_border = Color(0.04, 0.22, 0.32)
			action_fill = Color(0.08, 0.48, 0.62)
			ambient_top_alpha = 0.12
			ambient_horizon_alpha = 0.13
			ambient_fog_alpha = 0.10
			ambient_rift_edge_alpha = 0.070
			ambient_crimson_alpha = 0.045
			top_glow = Color(1.0, 0.68, 0.30, ambient_top_alpha)
			horizon_glow = Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, ambient_horizon_alpha)
			bottom_fog = Color(0.84, 0.94, 1.0, ambient_fog_alpha)
		"havza":
			top_fill = Color(0.95, 0.97, 0.88)
			top_border = Color(0.28, 0.40, 0.22)
			chip_fill = Color(0.39, 0.54, 0.26)
			chip_border = Color(0.22, 0.31, 0.14)
			action_fill = Color(0.39, 0.54, 0.26)
			ambient_top_alpha = 0.11
			ambient_horizon_alpha = 0.09
			ambient_fog_alpha = 0.10
			ambient_rift_edge_alpha = 0.040
			ambient_crimson_alpha = 0.030
			top_glow = Color(0.94, 0.82, 0.46, ambient_top_alpha)
			horizon_glow = Color(0.74, 0.92, 0.76, ambient_horizon_alpha)
			bottom_fog = Color(0.96, 1.0, 0.90, ambient_fog_alpha)
		"amasya":
			top_fill = Color(0.95, 0.93, 0.88)
			top_border = Color(0.56, 0.22, 0.16)
			chip_fill = Color(0.68, 0.30, 0.20)
			chip_border = Color(0.34, 0.22, 0.14)
			action_fill = Color(0.68, 0.30, 0.20)
			ambient_top_alpha = 0.10
			ambient_horizon_alpha = 0.08
			ambient_fog_alpha = 0.09
			ambient_rift_edge_alpha = 0.046
			ambient_crimson_alpha = 0.044
			top_glow = Color(0.96, 0.74, 0.42, ambient_top_alpha)
			horizon_glow = Color(0.82, 0.76, 0.96, ambient_horizon_alpha)
			bottom_fog = Color(0.96, 0.92, 0.88, ambient_fog_alpha)
		"kongreler":
			top_fill = Color(0.95, 0.92, 0.86)
			top_border = Color(0.56, 0.22, 0.16)
			chip_fill = Color(0.74, 0.24, 0.18)
			chip_border = Color(0.40, 0.22, 0.14)
			action_fill = Color(0.74, 0.24, 0.18)
			ambient_top_alpha = 0.11
			ambient_horizon_alpha = 0.08
			ambient_fog_alpha = 0.08
			ambient_rift_edge_alpha = 0.044
			ambient_crimson_alpha = 0.052
			top_glow = Color(0.98, 0.72, 0.38, ambient_top_alpha)
			horizon_glow = Color(0.90, 0.76, 0.58, ambient_horizon_alpha)
			bottom_fog = Color(0.98, 0.92, 0.84, ambient_fog_alpha)

	_hud_bar.apply_theme(top_fill, top_border, chip_fill, chip_border, action_fill)
	_add_button_style(_interact_button, Color("#F2BE63"))
	_add_button_style(_dialogue_continue_button, action_fill)
	atmosphere_top_glow.color = top_glow
	atmosphere_horizon_glow.color = horizon_glow
	atmosphere_bottom_fog.color = bottom_fog
	vignette_left.color = vignette
	vignette_right.color = vignette
	rift_edge.a = ambient_rift_edge_alpha
	crimson_line.a = ambient_crimson_alpha
	rift_edge_left.color = rift_edge
	rift_edge_right.color = rift_edge
	crimson_accent.color = crimson_line


# ---------------------------------------------------------------------------
# UI STILLERİ
# ---------------------------------------------------------------------------

func apply_ui_styles() -> void:
	var character_panel: PanelContainer = _character_panel
	var dialogue_panel: PanelContainer = _dialogue_panel
	var arda_btn: Button = _world.get_node("CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/ArdaButton")
	var eda_btn: Button = _world.get_node("CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/EdaButton")
	var interact_btn: Button = _interact_button
	var dialogue_continue_btn: Button = _dialogue_continue_button

	_add_panel_style(character_panel, Color(0.97, 0.95, 0.88), Color(0.20, 0.42, 0.38), 18)

	# Karakter identity stilleri (player_mod üzerinden)
	var player_mod: Node = _world.get_node("WorldPlayer")
	if player_mod.has_method("apply_character_identity_styles"):
		player_mod.apply_character_identity_styles()

	_add_panel_style(dialogue_panel, Color(0.98, 0.96, 0.88), Color(0.30, 0.22, 0.16), 18)
	_add_button_style(arda_btn, Color(0.80, 0.34, 0.24))
	_add_button_style(eda_btn, Color(0.17, 0.51, 0.48))
	_add_button_style(interact_btn, Color("#F2BE63"))
	_add_button_style(dialogue_continue_btn, Color(0.20, 0.42, 0.38))

	var character_title: Label = _world.get_node("CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/CharacterTitle")
	var character_text: Label = _world.get_node("CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/CharacterText")
	character_title.add_theme_color_override("font_color", Color(0.13, 0.15, 0.20, 0.96))
	character_text.add_theme_color_override("font_color", Color(0.22, 0.24, 0.30, 0.84))


func _add_panel_style(panel: PanelContainer, fill: Color, border: Color, radius: int) -> void:
	panel.add_theme_stylebox_override("panel", _ui_styles.panel_style(fill, border, radius))


func _add_button_style(button: Button, fill: Color) -> void:
	var normal := _ui_styles.button_state_style(fill, 16)
	var pressed := _ui_styles.button_state_style(fill.darkened(0.14), 16)
	var disabled := _ui_styles.button_state_style(Color(0.42, 0.42, 0.42, 0.55), 16)
	_ui_styles.apply_button_style(button, normal, pressed, null, disabled)


# ---------------------------------------------------------------------------
# SPAWN REWARD BURST
# ---------------------------------------------------------------------------

func spawn_reward_burst(center: Vector2, tint: Color, slot_prefix: String) -> void:
	"""Ödül toplama efekti (yıldız/nişan patlaması)."""
	var foreground_props: Node2D = _world.get_node("ForegroundProps")
	for index in range(7):
		var angle := TAU * float(index) / 7.0
		var distance := 50.0 + float(index % 3) * 20.0
		var pos := center + Vector2(cos(angle), sin(angle)) * distance
		var texture := _textures.GAME_STAR_TEXTURE if index % 2 == 0 else _textures.GAME_TARGET_TEXTURE
		var root := Node2D.new()
		root.position = pos
		root.z_index = 8
		root.set_meta("ambient_bob", true)
		root.set_meta("base_pos", pos)
		root.set_meta("phase", fmod(pos.x * 0.19 + pos.y * 0.11, TAU))
		root.set_meta("bob_amount", 2.5)
		if slot_prefix != "":
			root.set_meta("asset_slot", "%s.%02d" % [slot_prefix, index])

		var glow := Polygon2D.new()
		glow.color = Color(tint.r, tint.g, tint.b, 0.18)
		var scale_value := 0.58 + float(index % 2) * 0.10
		glow.polygon = PackedVector2Array([
			Vector2(-28, -18) * scale_value,
			Vector2(28, -18) * scale_value,
			Vector2(36, 0) * scale_value,
			Vector2(28, 18) * scale_value,
			Vector2(-28, 18) * scale_value,
			Vector2(-36, 0) * scale_value,
		])
		root.add_child(glow)

		var outline := Sprite2D.new()
		outline.texture = texture
		outline.scale = Vector2(scale_value * 0.46, scale_value * 0.46)
		outline.modulate = Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.26)
		outline.z_index = 0
		root.add_child(outline)

		var icon := Sprite2D.new()
		icon.texture = texture
		icon.scale = Vector2(scale_value * 0.38, scale_value * 0.38)
		icon.modulate = Color(1, 1, 1, 0.90)
		icon.z_index = 1
		root.add_child(icon)

		foreground_props.add_child(root)


# ---------------------------------------------------------------------------
# DREAM TRANSITION
# ---------------------------------------------------------------------------

func play_dream_transition(callback: Callable) -> void:
	"""Rüya geçiş efekti (fade)."""
	var dream_overlay: ColorRect = _world.get_node("CanvasLayer/DreamOverlay")
	dream_overlay.visible = true
	dream_overlay.color = Color(0.91, 0.89, 1.0, 0.0)
	var tween := create_tween()
	tween.tween_property(dream_overlay, "color:a", 1.0, 0.22)
	tween.tween_callback(callback)
	tween.tween_interval(0.08)
	tween.tween_property(dream_overlay, "color:a", 0.0, 0.28)
	tween.tween_callback(Callable(self, "_hide_dream_overlay"))


func _hide_dream_overlay() -> void:
	var dream_overlay: ColorRect = _world.get_node("CanvasLayer/DreamOverlay")
	dream_overlay.visible = false


# ---------------------------------------------------------------------------
# SAVE GAME
# ---------------------------------------------------------------------------

func _save_game() -> void:
	"""Oyun durumunu kaydet."""
	var state: Node = _world.get_node("WorldState")
	var player_mod: Node = _world.get_node("WorldPlayer")
	var player_node: Node2D = _world.get_node("Player")
	var companion_node: Node2D = _world.get_node("Companion")
	var save_data: Dictionary = state.to_dict()

	save_data["hero_name"] = player_mod.hero_name
	save_data["current_chapter"] = _current_chip_text()
	save_data["player_position"] = {"x": player_node.position.x, "y": player_node.position.y}
	save_data["companion_position"] = {"x": companion_node.position.x, "y": companion_node.position.y}

	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null:
		save_manager.call("save_game", save_data)


func persist_runtime_state() -> void:
	_save_game()


func dismiss_background_transients() -> void:
	if is_exit_confirm_visible():
		hide_exit_confirm()


# ---------------------------------------------------------------------------
# SAMSUN GOAL VISUALS & CAMERA
# ---------------------------------------------------------------------------

func on_builder_goal_visual_registered(slot_id: String, node: CanvasItem) -> void:
	"""Builder'dan gelen goal visual sinyalini kategorize eder."""
	var key := ""
	if slot_id.contains("resource") or slot_id.contains("discovery") or slot_id.contains("leadership") or slot_id.contains("courage") or slot_id.contains("glint") or slot_id.contains("rift"):
		key = "resource"
	elif slot_id.contains("harbor") or slot_id.contains("telegraph") or slot_id.contains("people"):
		key = "build_spot"
	elif slot_id.contains("wave_start"):
		key = "wave_start"
	if key.is_empty():
		return
	if not samsun_goal_visuals.has(key):
		samsun_goal_visuals[key] = []
	samsun_goal_visuals[key].append(node)


func update_samsun_camera_focus(delta: float) -> void:
	var player_camera: Camera2D = _world.get_node("Player/Camera2D")
	var player_node: Node2D = _world.get_node("Player")
	var state: Node = _world.get_node("WorldState")
	var character_panel: PanelContainer = _world.get_node("CanvasLayer/HUD/CharacterPanel")
	var dialogue_overlay: Node = _overlay_manager.get_overlay_node(OverlayManager.OverlayType.DIALOGUE)
	var info_card_overlay: Node = _overlay_manager.get_overlay_node(OverlayManager.OverlayType.INFO_CARD)
	var decision_overlay: Node = _overlay_manager.get_overlay_node(OverlayManager.OverlayType.DECISION)
	var markers: Node2D = _world.get_node("Markers")
	var marker_mod: Node = _world.get_node("WorldMarker")

	if player_camera == null:
		return
	var target_offset := Vector2.ZERO
	var target_zoom := Vector2(0.9, 0.9)
	if state.current_zone == "samsun_rift" and samsun_open_world_overview_time_left > 0.0:
		samsun_open_world_overview_time_left = max(0.0, samsun_open_world_overview_time_left - delta)
		target_offset = _samsun_overview_camera_offset()
		target_zoom = Vector2(0.56, 0.56)
		player_camera.offset = player_camera.offset.lerp(target_offset, min(delta * 1.55, 1.0))
		player_camera.zoom = player_camera.zoom.lerp(target_zoom, min(delta * 1.45, 1.0))
		return
	if state.current_zone == "samsun_rift" and not character_panel.visible and not dialogue_overlay.visible and not info_card_overlay.visible and not decision_overlay.visible:
		var player_mod: Node = _world.get_node("WorldPlayer")
		var focus_marker: Node2D = player_mod.nearby_marker if player_mod.nearby_marker != null else null
		if focus_marker == null:
			focus_marker = marker_mod.get_guidance_marker(markers, state.current_goal_kind)
		if focus_marker != null:
			var direction := focus_marker.global_position - player_node.global_position
			if direction.length() > 1.0:
				target_offset = direction.limit_length(120.0) * 0.22
				target_zoom = Vector2(0.92, 0.92)
	player_camera.offset = player_camera.offset.lerp(target_offset, min(delta * 3.0, 1.0))
	player_camera.zoom = player_camera.zoom.lerp(target_zoom, min(delta * 2.0, 1.0))


func start_samsun_open_world_overview() -> void:
	samsun_open_world_overview_time_left = 4.2


func _samsun_overview_camera_offset() -> Vector2:
	var player_node: Node2D = _world.get_node("Player")
	var diorama_center := Vector2(800, 1110)
	return diorama_center - player_node.position


# ---------------------------------------------------------------------------
# IDLE ANİMASYONLAR (UI ile ilgili)
# ---------------------------------------------------------------------------

func start_idle_animations() -> void:
	# 1. Interact button scale pulse
	var btn_tween: Tween = create_tween().set_loops()
	btn_tween.tween_method(_animate_button_pulse, 0.0, TAU, TAU / 3.2)

	# 2. Atmosphere glow alpha animasyonları
	var atmo_tween: Tween = create_tween().set_loops()
	atmo_tween.tween_method(_animate_atmosphere_glow, 0.0, TAU * 10.0, TAU * 10.0)

	# 3. Companion reaction label alpha pulse
	var label_tween: Tween = create_tween().set_loops()
	label_tween.tween_method(_animate_companion_reaction_alpha, 0.0, TAU, TAU / 3.0)


func _animate_button_pulse(phase: float) -> void:
	var interact_btn: Button = _world.get_node("CanvasLayer/HUD/InteractButton")
	var atmosphere_horizon_glow: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/HorizonGlow")
	var player_mod: Node = _world.get_node("WorldPlayer")
	interact_btn.scale = Vector2.ONE * (1.0 + (0.008 * sin(phase * 3.2))) if player_mod.nearby_marker != null else Vector2.ONE
	atmosphere_horizon_glow.scale = Vector2(1.0 + (0.01 * sin(phase * 0.9)), 1.0 + (0.02 * sin((phase * 0.7) + 0.6)))


func _animate_atmosphere_glow(phase: float) -> void:
	var state: Node = _world.get_node("WorldState")
	var atmosphere_top_glow: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/TopGlow")
	var atmosphere_horizon_glow: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/HorizonGlow")
	var atmosphere_bottom_fog: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/BottomFog")
	var rift_edge_left: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/RiftEdgeLeft")
	var rift_edge_right: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/RiftEdgeRight")
	var crimson_accent: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/CrimsonAccent")

	if state.current_zone == "room":
		return
	atmosphere_top_glow.color.a = ambient_top_alpha + (0.015 * sin(phase * 0.8))
	atmosphere_horizon_glow.color.a = ambient_horizon_alpha + (0.012 * sin((phase * 0.7) + 0.4))
	atmosphere_bottom_fog.color.a = ambient_fog_alpha + (0.014 * sin((phase * 1.1) + 0.8))
	rift_edge_left.color.a = ambient_rift_edge_alpha + (0.015 * sin((phase * 1.4) + 0.3))
	rift_edge_right.color.a = ambient_rift_edge_alpha + (0.015 * sin((phase * 1.4) + 1.1))
	crimson_accent.color.a = ambient_crimson_alpha + (0.010 * sin((phase * 1.0) + 0.6))


func _animate_companion_reaction_alpha(phase: float) -> void:
	var player_mod: Node = _world.get_node("WorldPlayer")
	if player_mod.companion_reaction_label == null or not player_mod.companion_reaction_label.visible:
		return
	player_mod.companion_reaction_label.modulate.a = 0.86 + (0.10 * sin(phase * 3.0))


# ---------------------------------------------------------------------------
# SAMSUN GOAL VISUALS ANİMASYONU
# ---------------------------------------------------------------------------

func update_samsun_goal_visuals(phase: float) -> void:
	var state: Node = _world.get_node("WorldState")
	if state.current_zone != "samsun_rift":
		return
	for key in samsun_goal_visuals.keys():
		var is_active: bool = String(key) == state.current_goal_kind
		var pulse := 0.035 + (0.018 * sin(fmod(phase * 2.4, TAU))) if is_active else 0.0
		for item in samsun_goal_visuals[key]:
			if not is_instance_valid(item):
				continue
			if item is Polygon2D:
				var polygon := item as Polygon2D
				var base_color: Color = polygon.get_meta("base_color", polygon.color)
				var color := base_color
				color.a = min(0.42, base_color.a + pulse)
				polygon.color = color
			elif item is Line2D:
				var line := item as Line2D
				var base_color: Color = line.get_meta("base_color", line.default_color)
				var color := base_color
				color.a = min(0.34, base_color.a + pulse)
				line.default_color = color
