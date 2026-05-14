extends Control

signal transition_finished

const _gui_frame := preload("res://scripts/gui_frame.gd")
const _ui_styles := preload("res://scripts/ui_style_factory.gd")
const _ui_tokens := preload("res://scripts/ui_tokens.gd")
const _overlay_tween_helper := preload("res://scripts/overlay_tween_helper.gd")

@onready var _colors := preload("res://scripts/colors.gd")

@onready var backdrop: ColorRect = $Backdrop
@onready var dream_mist: ColorRect = $DreamMist
@onready var route_line: ColorRect = $RouteLayer/RouteLine
@onready var route_dot_a: ColorRect = $RouteLayer/RouteDotA
@onready var route_dot_b: ColorRect = $RouteLayer/RouteDotB
@onready var route_dot_c: ColorRect = $RouteLayer/RouteDotC
@onready var center: CenterContainer = $Center
@onready var panel: PanelContainer = $Center/TransitionPanel
@onready var chapter_label: Label = $Center/TransitionPanel/PanelMargin/PanelContent/ChapterLabel
@onready var subtitle_label: Label = $Center/TransitionPanel/PanelMargin/PanelContent/SubTitle
@onready var progress_label: Label = $Center/TransitionPanel/PanelMargin/PanelContent/ProgressLabel

const TAU := 2.0 * PI
var rift_shards: Array[Polygon2D] = []
var _dream_mist_base_y: float
var _transition_tween: Tween
var _idle_tweens: Array[Tween] = []

func get_overlay_type() -> int:
	return OverlayManager.OverlayType.CHAPTER_TRANSITION

func _ready() -> void:
	_apply_styles()
	_build_rift_fx()
	_dream_mist_base_y = dream_mist.position.y
	get_viewport().size_changed.connect(_sync_layout)
	_sync_layout()
	visible = false
	_start_idle_animations()


func _exit_tree() -> void:
	if get_viewport().size_changed.is_connected(_sync_layout):
		get_viewport().size_changed.disconnect(_sync_layout)


func _sync_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var safe_rect := _gui_frame.safe_area_rect(viewport_size)
	center.offset_left = safe_rect.position.x
	center.offset_top = safe_rect.position.y
	center.offset_right = -(viewport_size.x - safe_rect.end.x)
	center.offset_bottom = -(viewport_size.y - safe_rect.end.y)
	panel.custom_minimum_size = Vector2(
		minf(760.0, maxf(420.0, safe_rect.size.x - 96.0)),
		minf(280.0, maxf(220.0, safe_rect.size.y * 0.24))
	)


func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_skip_transition()
		accept_event()
	elif event is InputEventScreenTouch and event.pressed:
		_skip_transition()
		accept_event()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_skip_transition()
		get_viewport().set_input_as_handled()

func _start_idle_animations() -> void:
	_stop_idle_animations()
	# Dream mist drift — sin(elapsed * 1.4), periyot 2*PI/1.4
	var tween_mist := create_tween().set_loops()
	tween_mist.tween_method(_animate_mist, 0.0, TAU, 4.48799)
	_idle_tweens.append(tween_mist)

	# Route dot scale pulse — sin(elapsed * 4.0), periyot 2*PI/4.0
	var tween_dots := create_tween().set_loops()
	tween_dots.tween_method(_animate_dots, 0.0, TAU, 1.57080)
	_idle_tweens.append(tween_dots)

	# Rift shard drift — çoklu frekans (0.9/0.7/0.8) tek tween'de
	var tween_rift := create_tween().set_loops()
	tween_rift.tween_method(_animate_rift, 0.0, TAU, 7.85398)
	_idle_tweens.append(tween_rift)


func _stop_idle_animations() -> void:
	_overlay_tween_helper.cancel_many(_idle_tweens)
	_idle_tweens.clear()


func _animate_mist(v: float) -> void:
	dream_mist.position.y = _dream_mist_base_y + sin(v) * 6.0


func _animate_dots(v: float) -> void:
	route_dot_a.scale = Vector2.ONE * (0.92 + (0.06 * sin(v)))
	route_dot_b.scale = Vector2.ONE * (0.92 + (0.06 * sin(v + 0.7)))
	route_dot_c.scale = Vector2.ONE * (0.92 + (0.06 * sin(v + 1.4)))


func _animate_rift(v: float) -> void:
	for shard in rift_shards:
		var base: Vector2 = shard.get_meta("base_position")
		var phase: float = shard.get_meta("phase")
		# v: 0→TAU, freq=0.8 base; scale others relative
		shard.position = base + Vector2(
			sin(v * 1.125 + phase) * 14.0,
			cos(v * 0.875 + phase) * 16.0
		)
		shard.rotation = sin(v + phase) * 0.12

func present(chapter: String, subtitle: String, progress_text := "Sahne hazırlanıyor...") -> void:
	chapter_label.text = chapter
	subtitle_label.text = subtitle
	progress_label.text = progress_text
	visible = true
	backdrop.color = Color(0.08, 0.10, 0.16, 0.0)
	dream_mist.color = Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.0)
	route_line.color = Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.0)
	for dot in [route_dot_a, route_dot_b, route_dot_c]:
		dot.color = Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.0)
		dot.scale = Vector2.ONE * 0.82
	for shard in rift_shards:
		shard.color.a = 0.0
	panel.modulate = Color(1, 1, 1, 0.0)
	panel.scale = Vector2(0.95, 0.95)
	panel.position.y = 18.0
	progress_label.modulate = Color(1, 1, 1, 0.0)
	_transition_tween = _overlay_tween_helper.replace(self, _transition_tween, Callable(self, "_clear_transition_tween"))
	var tween := _transition_tween
	_overlay_tween_helper.fade_color_alpha(tween, backdrop, 0.76, 0.20)
	_overlay_tween_helper.fade_color_alpha(tween, dream_mist, 0.18, 0.26)
	_overlay_tween_helper.fade_color_alpha(tween, route_line, 0.55, 0.24)
	for shard in rift_shards:
		_overlay_tween_helper.fade_modulate_alpha(tween, shard, 0.18, 0.24)
	_overlay_tween_helper.panel_pop_in(tween, panel)
	_overlay_tween_helper.fade_modulate_alpha(tween, progress_label, 1.0, 0.20)
	tween.tween_property(route_dot_a, "color:a", 0.85, 0.10)
	tween.parallel().tween_property(route_dot_a, "scale", Vector2.ONE, 0.12)
	tween.tween_property(route_dot_b, "color:a", 0.85, 0.10)
	tween.parallel().tween_property(route_dot_b, "scale", Vector2.ONE, 0.12)
	tween.tween_property(route_dot_c, "color:a", 0.85, 0.10)
	tween.parallel().tween_property(route_dot_c, "scale", Vector2.ONE, 0.12)
	tween.tween_interval(0.78)
	_overlay_tween_helper.panel_pop_out(tween, panel, 0.16, Vector2(0.97, 0.97))
	_overlay_tween_helper.fade_color_alpha(tween, backdrop, 0.0, 0.22)
	_overlay_tween_helper.fade_color_alpha(tween, dream_mist, 0.0, 0.22)
	_overlay_tween_helper.fade_color_alpha(tween, route_line, 0.0, 0.18)
	for dot in [route_dot_a, route_dot_b, route_dot_c]:
		_overlay_tween_helper.fade_color_alpha(tween, dot, 0.0, 0.18)
	for shard in rift_shards:
		_overlay_tween_helper.fade_modulate_alpha(tween, shard, 0.0, 0.18)
	tween.tween_callback(Callable(self, "_finish"))


func show_overlay(config: Dictionary = {}) -> void:
	present(
		String(config.get("chapter", "")),
		String(config.get("subtitle", "")),
		String(config.get("progress_text", "Sahne hazırlanıyor..."))
	)


func hide_overlay() -> void:
	_transition_tween = _overlay_tween_helper.cancel(_transition_tween)
	_stop_idle_animations()
	visible = false

func _finish() -> void:
	visible = false
	transition_finished.emit()


func _skip_transition() -> void:
	if not visible:
		return
	_transition_tween = _overlay_tween_helper.cancel(_transition_tween)
	_finish()


func _clear_transition_tween() -> void:
	_transition_tween = null

func _build_rift_fx() -> void:
	var centers := [
		Vector2(250, 690),
		Vector2(840, 710),
		Vector2(300, 1050),
		Vector2(800, 1080),
	]
	for index in range(centers.size()):
		var shard := Polygon2D.new()
		var shard_size := Vector2(24 + (index % 2) * 10, 70 + (index % 3) * 14)
		shard.position = centers[index]
		shard.color = Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.0)
		shard.z_index = 4
		shard.polygon = PackedVector2Array([
			Vector2(0, -shard_size.y * 0.5),
			Vector2(shard_size.x * 0.42, 0),
			Vector2(0, shard_size.y * 0.5),
			Vector2(-shard_size.x * 0.42, 0),
		])
		shard.set_meta("base_position", shard.position)
		shard.set_meta("phase", float(index) * 0.83)
		add_child(shard)
		move_child(shard, 3)
		rift_shards.append(shard)

func _apply_styles() -> void:
	_ui_styles.apply_panel_variant(panel, "chapter_transition_panel")
	chapter_label.add_theme_color_override("font_color", _colors.POP_CRIMSON)
	subtitle_label.add_theme_color_override("font_color", Color(0.30, 0.32, 0.40))
	progress_label.add_theme_color_override("font_color", Color(0.10, 0.32, 0.42, 0.78))
	progress_label.add_theme_font_size_override("font_size", _ui_tokens.FONT_LABEL_MD)


func _freeze_for_capture() -> void:
	_transition_tween = _overlay_tween_helper.cancel(_transition_tween)
	_stop_idle_animations()
	visible = true
	backdrop.color.a = 0.76
	dream_mist.position.y = _dream_mist_base_y
	dream_mist.color.a = 0.18
	route_line.color.a = 0.55
	for dot in [route_dot_a, route_dot_b, route_dot_c]:
		dot.color.a = 0.85
		dot.scale = Vector2.ONE
	panel.modulate = Color.WHITE
	panel.scale = Vector2.ONE
	panel.position.y = 0.0
	progress_label.modulate = Color.WHITE
	for shard in rift_shards:
		shard.position = shard.get_meta("base_position")
		shard.rotation = 0.0
		shard.color.a = 0.18
