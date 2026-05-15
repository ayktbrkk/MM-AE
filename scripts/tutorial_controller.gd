## MMAE - Tutorial Controller (Package 6)
## =======================================
## İlk çalıştırmada 5 fazlı tutorial rehberi.
## Non-blocking: touch input'u engellemez, sadece görsel ipuçları gösterir.
## Skip kalıcıdır (settings.json), continue akışını bozmaz.
##
## Kullanım: WorldUI tarafından initialize() edilir.
##
## Tutorial Fazları:
##   0. CHOOSE_CHARACTER — karakter seçimine yönlendirme
##   1. TAP_MOVE_TO_FIRST_NOTE — ilk nota dokunmayı gösterme
##   2. COLLECT_CLUE — ipucu toplama
##   3. OPEN_DECISION — karar ekranını açma
##   4. BUILD_SUPPORT — destek inşa etme
##   5. COMPLETED — tutorial bitti

class_name TutorialController
extends Node

# ---------------------------------------------------------------------------
# SABİTLER
# ---------------------------------------------------------------------------
const _colors := preload("res://scripts/colors.gd")
const _ui_tokens := preload("res://scripts/ui_tokens.gd")
const _ui_styles := preload("res://scripts/ui_style_factory.gd")

enum Phase {
	NONE = -1,
	CHOOSE_CHARACTER = 0,
	TAP_MOVE_TO_FIRST_NOTE = 1,
	COLLECT_CLUE = 2,
	OPEN_DECISION = 3,
	BUILD_SUPPORT = 4,
	COMPLETED = 5,
}

const PHASE_COUNT: int = 5
const HIGHLIGHT_RING_RADIUS := 60.0
const CALLOUT_ANCHOR_Y_OFFSET := -80.0
const HIGHLIGHT_PULSE_SPEED := 3.5

# ---------------------------------------------------------------------------
# SİNYALLER
# ---------------------------------------------------------------------------
signal phase_changed(phase_index: int, phase_name: String)
signal tutorial_skipped()
signal tutorial_completed()

# ---------------------------------------------------------------------------
# STATE
# ---------------------------------------------------------------------------
var _current_phase: int = Phase.NONE
var _world: Node2D
var _ui_mod: Node

# Tutorial UI elemanları
var _callout_panel: PanelContainer
var _callout_label: Label
var _callout_arrow: Sprite2D
var _highlight_ring: Node2D
var _highlight_pulse: Node2D
var _skip_button: Button
var _tutorial_layer: CanvasLayer
var _elapsed: float = 0.0

# Hedef pozisyon (highlight ring'in takip edeceği nokta)
var _target_world_pos: Vector2 = Vector2.ZERO
var _has_target_position: bool = false

# Aktif mi?
var _is_active: bool = false

# Callout pozisyon sabiti
var _callout_offset := Vector2(0.0, -120.0)


func initialize(world: Node2D, ui_mod: Node) -> void:
	"""WorldUI tarafından initialize edilir."""
	_world = world
	_ui_mod = ui_mod
	_build_tutorial_ui()


# ---------------------------------------------------------------------------
# TUTORIAL UI KURULUMU
# ---------------------------------------------------------------------------

func _build_tutorial_ui() -> void:
	"""Tutorial CanvasLayer'ını ve UI elemanlarını kur."""
	# Tutorial için ayrı CanvasLayer — HUD üstünde ama input engellemez
	_tutorial_layer = CanvasLayer.new()
	_tutorial_layer.name = "TutorialLayer"
	_tutorial_layer.layer = 45  # HUD layer 10 ile DIALOGUE layer 50 arasında
	# CanvasLayer Control değildir, mouse_filter özelliği yoktur
	_tutorial_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_tutorial_layer)

	# Callout panel (ok + metin)
	_callout_panel = PanelContainer.new()
	_callout_panel.name = "TutorialCallout"
	_callout_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_callout_panel.visible = false
	_callout_panel.add_theme_stylebox_override(
		"panel",
		_ui_styles.panel_style(
			Color(_colors.DESIGN_CREAM_PAPER.r, _colors.DESIGN_CREAM_PAPER.g, _colors.DESIGN_CREAM_PAPER.b, 0.94),
			Color(_colors.POP_DEEP_TURQUOISE.r, _colors.POP_DEEP_TURQUOISE.g, _colors.POP_DEEP_TURQUOISE.b, 0.64),
			14,
			3,
			Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.20),
			5,
			Vector2(0.0, 2.0)
		)
	)
	_tutorial_layer.add_child(_callout_panel)

	var callout_margin := MarginContainer.new()
	callout_margin.add_theme_constant_override("margin_left", _ui_tokens.SPACE_SM)
	callout_margin.add_theme_constant_override("margin_top", _ui_tokens.SPACE_XS)
	callout_margin.add_theme_constant_override("margin_right", _ui_tokens.SPACE_SM)
	callout_margin.add_theme_constant_override("margin_bottom", _ui_tokens.SPACE_XS)
	callout_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_callout_panel.add_child(callout_margin)

	_callout_label = Label.new()
	_callout_label.name = "CalloutLabel"
	_callout_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_callout_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_callout_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_callout_label.add_theme_font_size_override("font_size", _ui_tokens.FONT_LABEL_MD)
	_callout_label.add_theme_color_override("font_color", Color(_colors.DESIGN_STORY_INK.r, _colors.DESIGN_STORY_INK.g, _colors.DESIGN_STORY_INK.b, 0.96))
	_callout_label.add_theme_color_override("font_outline_color", Color(_colors.DESIGN_CREAM_PAPER.r, _colors.DESIGN_CREAM_PAPER.g, _colors.DESIGN_CREAM_PAPER.b, 0.20))
	_callout_label.add_theme_constant_override("outline_size", 1)
	_callout_label.custom_minimum_size = Vector2(200.0, 36.0)
	callout_margin.add_child(_callout_label)

	# Callout oku (Sprite2D olarak world space'te)
	_callout_arrow = Sprite2D.new()
	_callout_arrow.name = "CalloutArrow"
	_callout_arrow.texture = preload("res://scripts/textures.gd").GAME_ARROW_UP_TEXTURE
	_callout_arrow.scale = Vector2(0.5, 0.5)
	_callout_arrow.modulate = Color(_colors.POP_DEEP_TURQUOISE.r, _colors.POP_DEEP_TURQUOISE.g, _colors.POP_DEEP_TURQUOISE.b, 0.90)
	_callout_arrow.visible = false
	_tutorial_layer.add_child(_callout_arrow)

	# Highlight ring (dünya uzayında hedef etrafında)
	_highlight_ring = Node2D.new()
	_highlight_ring.name = "HighlightRing"
	_highlight_ring.visible = false
	_tutorial_layer.add_child(_highlight_ring)

	var ring := Polygon2D.new()
	ring.name = "RingPolygon"
	ring.color = Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.28)
	var segments := 32
	var points: PackedVector2Array = []
	for i in range(segments):
		var angle := TAU * float(i) / float(segments)
		points.append(Vector2(cos(angle), sin(angle)) * HIGHLIGHT_RING_RADIUS)
	ring.polygon = points
	_highlight_ring.add_child(ring)

	var ring_outline := Polygon2D.new()
	ring_outline.name = "RingOutline"
	ring_outline.color = Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.52)
	var outer_points: PackedVector2Array = []
	for i in range(segments):
		var angle := TAU * float(i) / float(segments)
		outer_points.append(Vector2(cos(angle), sin(angle)) * (HIGHLIGHT_RING_RADIUS + 4.0))
	ring_outline.polygon = outer_points
	_highlight_ring.add_child(ring_outline)
	_highlight_ring.move_child(ring_outline, 0)

	# Pulse efekti
	_highlight_pulse = Polygon2D.new()
	_highlight_pulse.name = "RingPulse"
	_highlight_pulse.color = Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.0)
	var pulse_points: PackedVector2Array = []
	for i in range(segments):
		var angle := TAU * float(i) / float(segments)
		pulse_points.append(Vector2(cos(angle), sin(angle)) * HIGHLIGHT_RING_RADIUS)
	_highlight_pulse.polygon = pulse_points
	_highlight_ring.add_child(_highlight_pulse)

	# Skip butonu (sağ üst köşe)
	_skip_button = Button.new()
	_skip_button.name = "TutorialSkipButton"
	_skip_button.text = "Tutorial'ı geç"
	_skip_button.visible = false
	_skip_button.mouse_filter = Control.MOUSE_FILTER_PASS
	_skip_button.add_theme_font_size_override("font_size", _ui_tokens.FONT_LABEL_SM)
	_add_skip_button_style()
	_skip_button.size = Vector2(140.0, 36.0)
	_skip_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_skip_button.offset_top = _ui_tokens.SPACE_SM
	_skip_button.offset_right = -_ui_tokens.SPACE_SM
	_skip_button.offset_left = _skip_button.offset_right - 140.0
	_skip_button.offset_bottom = _skip_button.offset_top + 36.0
	_skip_button.pressed.connect(_on_skip_pressed)
	_tutorial_layer.add_child(_skip_button)


func _add_skip_button_style() -> void:
	var fill := Color(0.24, 0.30, 0.34, 0.78)
	var hover := Color(0.30, 0.36, 0.42, 0.88)
	var pressed := fill.darkened(0.14)
	var normal := _ui_styles.button_state_style(fill, 10)
	var hover_style := _ui_styles.button_state_style(hover, 10)
	var pressed_style := _ui_styles.button_state_style(pressed, 10)
	_ui_styles.apply_button_style(_skip_button, normal, pressed_style, hover_style, normal)


# ---------------------------------------------------------------------------
# TUTORIAL KONTROL
# ---------------------------------------------------------------------------

func is_tutorial_active() -> bool:
	return _is_active


func get_current_phase() -> int:
	return _current_phase


func start_tutorial() -> void:
	"""Tutorial'ı başlat (yeni kayıt)."""
	if _is_active:
		return
	_is_active = true
	_set_phase(Phase.CHOOSE_CHARACTER)


func skip_tutorial() -> void:
	"""Tutorial'ı kalıcı olarak geç."""
	_set_phase(Phase.COMPLETED)
	_hide_all()
	_is_active = false
	SaveManager.save_setting("tutorial_completed", true)
	tutorial_skipped.emit()


func _on_skip_pressed() -> void:
	skip_tutorial()


func _set_phase(phase_index: int) -> void:
	"""Faz değiştir ve UI'yi güncelle."""
	if _current_phase == phase_index:
		return
	_current_phase = phase_index
	phase_changed.emit(phase_index, _phase_name(phase_index))

	if phase_index >= Phase.COMPLETED:
		_complete_tutorial()
		return

	_update_callout_for_phase(phase_index)


func _complete_tutorial() -> void:
	"""Tutorial tamamlandı."""
	_hide_all()
	_is_active = false
	SaveManager.save_setting("tutorial_completed", true)
	tutorial_completed.emit()


# ---------------------------------------------------------------------------
# FAZ YÖNETİMİ
# ---------------------------------------------------------------------------

func advance_phase() -> void:
	"""Bir sonraki faza geç (dışarıdan tetiklenir)."""
	if not _is_active:
		return
	var next_phase := _current_phase + 1
	if next_phase >= Phase.COMPLETED:
		_complete_tutorial()
		return
	_set_phase(next_phase)


func notify_character_selected() -> void:
	"""Karakter seçildiğinde faz 0 -> faz 1'e geç."""
	if _is_active and _current_phase == Phase.CHOOSE_CHARACTER:
		advance_phase()


func notify_first_note_tapped() -> void:
	"""İlk nota dokunulduğunda faz 1 -> faz 2'ye geç."""
	if _is_active and _current_phase == Phase.TAP_MOVE_TO_FIRST_NOTE:
		advance_phase()


func notify_clue_collected() -> void:
	"""İpucu toplandığında faz 2 -> faz 3'e geç."""
	if _is_active and _current_phase == Phase.COLLECT_CLUE:
		advance_phase()


func notify_decision_opened() -> void:
	"""Karar ekranı açıldığında faz 3 -> faz 4'e geç."""
	if _is_active and _current_phase == Phase.OPEN_DECISION:
		advance_phase()


func notify_support_built() -> void:
	"""Destek inşa edildiğinde faz 4 -> tamamlandı."""
	if _is_active and _current_phase == Phase.BUILD_SUPPORT:
		advance_phase()


# ---------------------------------------------------------------------------
# CALLOUT VE HIGHLIGHT GÖSTERİMİ
# ---------------------------------------------------------------------------

func _update_callout_for_phase(phase_index: int) -> void:
	"""Faza göre callout metnini ve highlight hedefini ayarla."""
	match phase_index:
		Phase.CHOOSE_CHARACTER:
			_show_callout("Karakterini seç ve maceraya başla!")
			_hide_highlight()
		Phase.TAP_MOVE_TO_FIRST_NOTE:
			_show_callout("İpucu bulmak için nota dokun!")
			_highlight_first_note()
		Phase.COLLECT_CLUE:
			_show_callout("İpucunu topla, tarihi öğren!")
			_highlight_nearby_marker()
		Phase.OPEN_DECISION:
			_show_callout("Şimdi karar zamanı!")
			_highlight_decision_marker()
		Phase.BUILD_SUPPORT:
			_show_callout("Desteğini inşa et!")
			_highlight_build_spot()
		_:
			_hide_all()


func _show_callout(text: String) -> void:
	"""Callout panelini göster."""
	_callout_label.text = text
	_callout_panel.visible = true
	_callout_arrow.visible = true
	_skip_button.visible = true

	# Callout'u ekranın üst orta kısmına konumlandır
	_callout_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_callout_panel.offset_left = 0.0
	_callout_panel.offset_top = 0.0
	_callout_panel.offset_right = 0.0
	_callout_panel.offset_bottom = 0.0
	_callout_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_callout_panel.offset_top = _ui_tokens.SPACE_LG + 20.0  # safe area altı


func _hide_callout() -> void:
	_callout_panel.visible = false
	_callout_arrow.visible = false


func _hide_all() -> void:
	_hide_callout()
	_hide_highlight()
	_skip_button.visible = false


# ---------------------------------------------------------------------------
# HIGHLIGHT RING YÖNETİMİ
# ---------------------------------------------------------------------------

func _show_highlight(world_pos: Vector2) -> void:
	"""Highlight ring'i dünya koordinatında göster."""
	_target_world_pos = world_pos
	_has_target_position = true
	_highlight_ring.visible = true
	_sync_highlight_position()


func _hide_highlight() -> void:
	_highlight_ring.visible = false
	_has_target_position = false


func _sync_highlight_position() -> void:
	if _highlight_ring == null or not _has_target_position:
		return
	# CanvasLayer altında olduğu için dünya->ekran dönüşümü gerekli
	var camera: Camera2D = _world.get_node("Player/Camera2D")
	if camera == null:
		return
	var screen_pos := camera.get_canvas_transform() * _target_world_pos
	_highlight_ring.position = screen_pos

	# Callout arrow'u highlight'ın üstüne konumlandır
	if _callout_arrow.visible:
		_callout_arrow.position = screen_pos + Vector2(0.0, -HIGHLIGHT_RING_RADIUS - 30.0)


func set_highlight_target(world_pos: Vector2) -> void:
	"""Dışarıdan highlight hedefi güncelleme."""
	if _has_target_position:
		_target_world_pos = world_pos


func _highlight_first_note() -> void:
	"""İlk nota marker'ını bul ve highlight et."""
	var markers: Node2D = _world.get_node_or_null("Markers")
	if markers == null:
		return
	for marker in markers.get_children():
		var kind := String(marker.get_meta("kind", ""))
		var collected := bool(marker.get_meta("collected", false))
		if kind == "unit" and not collected:
			_show_highlight(marker.global_position)
			return


func _highlight_nearby_marker() -> void:
	"""Player yakınındaki marker'ı highlight et."""
	var player_mod: Node = _world.get_node_or_null("WorldPlayer")
	if player_mod != null and is_instance_valid(player_mod.nearby_marker):
		_show_highlight(player_mod.nearby_marker.global_position)
		return
	# Fallback: ilk toplanmamış marker
	_highlight_first_note()


func _highlight_decision_marker() -> void:
	"""Decision marker'ını highlight et."""
	var markers: Node2D = _world.get_node_or_null("Markers")
	if markers == null:
		return
	for marker in markers.get_children():
		var kind := String(marker.get_meta("kind", ""))
		if kind == "decision" or kind.ends_with("_decision"):
			_show_highlight(marker.global_position)
			return


func _highlight_build_spot() -> void:
	"""Build spot marker'ını highlight et."""
	var markers: Node2D = _world.get_node_or_null("Markers")
	if markers == null:
		return
	for marker in markers.get_children():
		var kind := String(marker.get_meta("kind", ""))
		if kind == "build_spot":
			_show_highlight(marker.global_position)
			return
	# Fallback: herhangi bir decision marker
	_highlight_decision_marker()


# ---------------------------------------------------------------------------
# _process — ANİMASYON GÜNCELLEME
# ---------------------------------------------------------------------------

func _process(delta: float) -> void:
	if not _is_active:
		return

	_elapsed += delta

	# Highlight ring pulse animasyonu
	if _highlight_ring.visible and _has_target_position:
		_sync_highlight_position()

		# Pulse genişleme
		var pulse_scale := 1.0 + 0.15 * sin(_elapsed * HIGHLIGHT_PULSE_SPEED)
		var ring := _highlight_ring.get_node_or_null("RingPolygon") as Polygon2D
		if ring != null:
			ring.scale = Vector2(pulse_scale, pulse_scale)
			ring.color.a = 0.18 + 0.10 * sin(_elapsed * HIGHLIGHT_PULSE_SPEED)

		var outline := _highlight_ring.get_node_or_null("RingOutline") as Polygon2D
		if outline != null:
			outline.scale = Vector2(pulse_scale, pulse_scale)
			outline.color.a = 0.40 + 0.12 * sin(_elapsed * HIGHLIGHT_PULSE_SPEED + 0.5)

		# Pulse dalgası
		var pulse := _highlight_ring.get_node_or_null("RingPulse") as Polygon2D
		if pulse != null:
			var wave_phase := fmod(_elapsed * 1.5, 1.0)
			var wave_scale := 1.0 + wave_phase * 0.8
			pulse.scale = Vector2(wave_scale, wave_scale)
			pulse.color.a = 0.20 * (1.0 - wave_phase)

		# Callout arrow pulse
		if _callout_arrow.visible:
			_callout_arrow.position.y = _highlight_ring.position.y - HIGHLIGHT_RING_RADIUS - 30.0 - 4.0 * sin(_elapsed * 3.0)
			_callout_arrow.modulate.a = 0.70 + 0.20 * sin(_elapsed * 2.5)


# ---------------------------------------------------------------------------
# YARDIMCI
# ---------------------------------------------------------------------------

func _phase_name(phase_index: int) -> String:
	match phase_index:
		Phase.CHOOSE_CHARACTER:
			return "choose_character"
		Phase.TAP_MOVE_TO_FIRST_NOTE:
			return "tap_note"
		Phase.COLLECT_CLUE:
			return "collect_clue"
		Phase.OPEN_DECISION:
			return "open_decision"
		Phase.BUILD_SUPPORT:
			return "build_support"
		_:
			return "unknown"
