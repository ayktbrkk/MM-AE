extends Control
class_name DreamIntroOverlay

const TAU := 2.0 * PI
const _ui_styles := preload("res://scripts/ui_style_factory.gd")
const _ui_tokens := preload("res://scripts/ui_tokens.gd")
const _overlay_tween_helper := preload("res://scripts/overlay_tween_helper.gd")

signal intro_finished

@onready var _colors := preload("res://scripts/colors.gd")

@onready var dimmer: ColorRect = $Dimmer
@onready var glow: ColorRect = $Glow
@onready var center_wrap: CenterContainer = $CenterWrap
@onready var panel: PanelContainer = $CenterWrap/Panel
@onready var book_glow: ColorRect = $CenterWrap/Panel/Margin/Content/BookGlow
@onready var title_label: Label = $CenterWrap/Panel/Margin/Content/Title
@onready var body_label: Label = $CenterWrap/Panel/Margin/Content/Body
@onready var hint_label: Label = $CenterWrap/Panel/Margin/Content/Hint

var rift_shards: Array[Polygon2D] = []

# Idle tween referansları
var _idle_tweens: Array[Tween] = []

func get_overlay_type() -> int:
	return OverlayManager.OverlayType.DREAM_INTRO

func _ready() -> void:
	_apply_styles()
	_build_rift_fx()
	_sync_layout()
	hide_overlay()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_sync_layout()

func present(title: String, body: String) -> void:
	_stop_idle_animations()
	title_label.text = title
	body_label.text = body
	_sync_layout()
	visible = true
	dimmer.color.a = 0.0
	glow.color.a = 0.0
	for shard in rift_shards:
		shard.color.a = 0.0
	panel.modulate = Color(1, 1, 1, 0.0)
	panel.scale = Vector2(0.94, 0.94)
	hint_label.modulate = Color(1, 1, 1, 0.0)
	book_glow.color.a = 0.0

	var tween := create_tween()
	_start_idle_animations()
	tween.tween_property(dimmer, "color:a", 0.78, 0.28)
	tween.parallel().tween_property(glow, "color:a", 0.34, 0.38)
	for shard in rift_shards:
		tween.parallel().tween_property(shard, "color:a", 0.18, 0.30)
	tween.parallel().tween_property(book_glow, "color:a", 0.22, 0.28)
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.24)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.28)
	tween.tween_interval(0.8)
	tween.tween_property(hint_label, "modulate:a", 1.0, 0.18)
	tween.tween_interval(0.26)
	tween.tween_property(panel, "modulate:a", 0.0, 0.22)
	tween.parallel().tween_property(dimmer, "color:a", 0.0, 0.24)
	tween.parallel().tween_property(glow, "color:a", 0.0, 0.24)
	tween.parallel().tween_property(book_glow, "color:a", 0.0, 0.18)
	for shard in rift_shards:
		tween.parallel().tween_property(shard, "color:a", 0.0, 0.18)
	tween.tween_callback(_finish_intro)


func show_overlay(config: Dictionary = {}) -> void:
	present(String(config.get("title", "")), String(config.get("body", "")))

func _start_idle_animations() -> void:
	_stop_idle_animations()

	# 1. book_glow scale.x pulse (sin(elapsed * 2.0))
	var t1 := create_tween().set_loops()
	t1.tween_method(
		func(v: float) -> void:
			book_glow.scale.x = 1.0 + sin(v) * 0.025,
		0.0, TAU, TAU / 2.0
	)
	_idle_tweens.append(t1)

	# 2. book_glow color.a pulse (sin(elapsed * 2.4))
	var t2 := create_tween().set_loops()
	t2.tween_method(
		func(v: float) -> void:
			book_glow.color.a = 0.12 + sin(v) * 0.04,
		0.0, TAU, TAU / 2.4
	)
	_idle_tweens.append(t2)

	# 3-6. Rift shard animasyonları (4 frekans grubu)
	_tween_rift_pos_x()
	_tween_rift_pos_y()
	_tween_rift_rotation()
	_tween_rift_scale()

func _tween_rift_pos_x() -> void:
	# X pozisyon: sin(elapsed * 0.9 + phase) * 16.0
	var t := create_tween().set_loops()
	t.tween_method(
		func(v: float) -> void:
			for shard in rift_shards:
				var phase: float = shard.get_meta("phase")
				shard.position.x = shard.get_meta("base_position").x + sin(v + phase) * 16.0,
		0.0, TAU, TAU / 0.9
	)
	_idle_tweens.append(t)

func _tween_rift_pos_y() -> void:
	# Y pozisyon: cos(elapsed * 0.7 + phase) * 18.0
	var t := create_tween().set_loops()
	t.tween_method(
		func(v: float) -> void:
			for shard in rift_shards:
				var phase: float = shard.get_meta("phase")
				shard.position.y = shard.get_meta("base_position").y + cos(v + phase) * 18.0,
		0.0, TAU, TAU / 0.7
	)
	_idle_tweens.append(t)

func _tween_rift_rotation() -> void:
	# Rotation: sin(elapsed * 0.8 + phase) * 0.12
	var t := create_tween().set_loops()
	t.tween_method(
		func(v: float) -> void:
			for shard in rift_shards:
				var phase: float = shard.get_meta("phase")
				shard.rotation = sin(v + phase) * 0.12,
		0.0, TAU, TAU / 0.8
	)
	_idle_tweens.append(t)

func _tween_rift_scale() -> void:
	# Scale: 0.94 + sin(elapsed * 1.3 + phase) * 0.05
	var t := create_tween().set_loops()
	t.tween_method(
		func(v: float) -> void:
			for shard in rift_shards:
				var phase: float = shard.get_meta("phase")
				shard.scale = Vector2.ONE * (0.94 + sin(v + phase) * 0.05),
		0.0, TAU, TAU / 1.3
	)
	_idle_tweens.append(t)

func _stop_idle_animations() -> void:
	_overlay_tween_helper.cancel_many(_idle_tweens)
	_idle_tweens.clear()

func hide_overlay() -> void:
	_stop_idle_animations()
	visible = false

func _sync_layout() -> void:
	var viewport_size := get_viewport_rect().size
	dimmer.offset_left = 0.0
	dimmer.offset_top = 0.0
	dimmer.offset_right = 0.0
	dimmer.offset_bottom = 0.0
	center_wrap.offset_left = 0.0
	center_wrap.offset_top = 0.0
	center_wrap.offset_right = 0.0
	center_wrap.offset_bottom = 0.0
	var panel_width: float = min(viewport_size.x - _ui_tokens.DREAM_PANEL_SIDE_MARGIN, _ui_tokens.DREAM_PANEL_MAX_WIDTH)
	panel.custom_minimum_size = Vector2(panel_width, 0.0)
	glow.offset_left = -panel_width * 0.60
	glow.offset_right = panel_width * 0.60
	glow.offset_top = -min(viewport_size.y * 0.24, _ui_tokens.DREAM_GLOW_MAX_HEIGHT)
	glow.offset_bottom = min(viewport_size.y * 0.24, _ui_tokens.DREAM_GLOW_MAX_HEIGHT)

func _finish_intro() -> void:
	hide_overlay()
	intro_finished.emit()

func _build_rift_fx() -> void:
	var centers := [
		Vector2(230, 600),
		Vector2(850, 620),
		Vector2(280, 1280),
		Vector2(840, 1320),
		Vector2(540, 960),
	]
	for index in range(centers.size()):
		var shard := Polygon2D.new()
		var shard_size := Vector2(28 + (index % 2) * 10, 82 + (index % 3) * 12)
		shard.position = centers[index]
		shard.color = Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.0)
		shard.z_index = 2
		shard.polygon = PackedVector2Array([
			Vector2(0, -shard_size.y * 0.5),
			Vector2(shard_size.x * 0.42, 0),
			Vector2(0, shard_size.y * 0.5),
			Vector2(-shard_size.x * 0.42, 0),
		])
		shard.set_meta("base_position", shard.position)
		shard.set_meta("phase", float(index) * 0.77)
		add_child(shard)
		move_child(shard, 2)
		rift_shards.append(shard)

func _apply_styles() -> void:
	panel.add_theme_stylebox_override(
		"panel",
		_ui_styles.panel_style(Color(0.97, 0.94, 0.86, 0.95), _colors.POP_DEEP_TURQUOISE, _ui_tokens.RADIUS_3XL, _ui_tokens.BORDER_BOLD, Color(0.03, 0.05, 0.08, 0.30), _ui_tokens.SHADOW_SIZE_XL, _ui_tokens.SHADOW_OFFSET_XL)
	)
	title_label.add_theme_color_override("font_color", _colors.POP_CRIMSON)
	body_label.add_theme_color_override("font_color", Color(0.19, 0.21, 0.28))
	hint_label.add_theme_color_override("font_color", _colors.POP_DEEP_TURQUOISE)
