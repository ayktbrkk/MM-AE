extends Control

signal transition_finished

@onready var _colors := preload("res://scripts/colors.gd")

@onready var backdrop: ColorRect = $Backdrop
@onready var dream_mist: ColorRect = $DreamMist
@onready var route_line: ColorRect = $RouteLayer/RouteLine
@onready var route_dot_a: ColorRect = $RouteLayer/RouteDotA
@onready var route_dot_b: ColorRect = $RouteLayer/RouteDotB
@onready var route_dot_c: ColorRect = $RouteLayer/RouteDotC
@onready var panel: PanelContainer = $Center/TransitionPanel
@onready var chapter_label: Label = $Center/TransitionPanel/PanelMargin/PanelContent/ChapterLabel
@onready var subtitle_label: Label = $Center/TransitionPanel/PanelMargin/PanelContent/SubTitle

const TAU := 2.0 * PI
var rift_shards: Array[Polygon2D] = []
var _dream_mist_base_y: float

func get_overlay_type() -> int:
	return OverlayManager.OverlayType.CHAPTER_TRANSITION

func _ready() -> void:
	_apply_styles()
	_build_rift_fx()
	_dream_mist_base_y = dream_mist.position.y
	visible = false
	_start_idle_animations()

func _start_idle_animations() -> void:
	# Dream mist drift — sin(elapsed * 1.4), periyot 2*PI/1.4
	var tween_mist := create_tween().set_loops()
	tween_mist.tween_method(
		func(v: float) -> void:
			dream_mist.position.y = _dream_mist_base_y + sin(v) * 6.0,
		0.0, TAU, 4.48799
	)

	# Route dot scale pulse — sin(elapsed * 4.0), periyot 2*PI/4.0
	var tween_dots := create_tween().set_loops()
	tween_dots.tween_method(
		func(v: float) -> void:
			route_dot_a.scale = Vector2.ONE * (0.92 + (0.06 * sin(v)))
			route_dot_b.scale = Vector2.ONE * (0.92 + (0.06 * sin(v + 0.7)))
			route_dot_c.scale = Vector2.ONE * (0.92 + (0.06 * sin(v + 1.4))),
		0.0, TAU, 1.57080
	)

	# Rift shard drift — çoklu frekans (0.9/0.7/0.8) tek tween'de
	var tween_rift := create_tween().set_loops()
	tween_rift.tween_method(
		func(v: float) -> void:
			for shard in rift_shards:
				var base: Vector2 = shard.get_meta("base_position")
				var phase: float = shard.get_meta("phase")
				# v: 0→TAU, freq=0.8 base; scale others relative
				shard.position = base + Vector2(
					sin(v * 1.125 + phase) * 14.0,
					cos(v * 0.875 + phase) * 16.0
				)
				shard.rotation = sin(v + phase) * 0.12,
		0.0, TAU, 7.85398
	)

func present(chapter: String, subtitle: String) -> void:
	chapter_label.text = chapter
	subtitle_label.text = subtitle
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
	var tween := create_tween()
	tween.tween_property(backdrop, "color:a", 0.76, 0.20)
	tween.parallel().tween_property(dream_mist, "color:a", 0.18, 0.26)
	tween.parallel().tween_property(route_line, "color:a", 0.55, 0.24)
	for shard in rift_shards:
		tween.parallel().tween_property(shard, "color:a", 0.18, 0.24)
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.16)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.18)
	tween.parallel().tween_property(panel, "position:y", 0.0, 0.18)
	tween.tween_property(route_dot_a, "color:a", 0.85, 0.10)
	tween.parallel().tween_property(route_dot_a, "scale", Vector2.ONE, 0.12)
	tween.tween_property(route_dot_b, "color:a", 0.85, 0.10)
	tween.parallel().tween_property(route_dot_b, "scale", Vector2.ONE, 0.12)
	tween.tween_property(route_dot_c, "color:a", 0.85, 0.10)
	tween.parallel().tween_property(route_dot_c, "scale", Vector2.ONE, 0.12)
	tween.tween_interval(0.78)
	tween.tween_property(panel, "modulate:a", 0.0, 0.16)
	tween.parallel().tween_property(backdrop, "color:a", 0.0, 0.22)
	tween.parallel().tween_property(dream_mist, "color:a", 0.0, 0.22)
	tween.parallel().tween_property(route_line, "color:a", 0.0, 0.18)
	for dot in [route_dot_a, route_dot_b, route_dot_c]:
		tween.parallel().tween_property(dot, "color:a", 0.0, 0.18)
	for shard in rift_shards:
		tween.parallel().tween_property(shard, "color:a", 0.0, 0.18)
	tween.tween_callback(Callable(self, "_finish"))

func _finish() -> void:
	visible = false
	transition_finished.emit()

func _build_rift_fx() -> void:
	var centers := [
		Vector2(250, 690),
		Vector2(840, 710),
		Vector2(300, 1050),
		Vector2(800, 1080),
	]
	for index in range(centers.size()):
		var shard := Polygon2D.new()
		var size := Vector2(24 + (index % 2) * 10, 70 + (index % 3) * 14)
		shard.position = centers[index]
		shard.color = Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.0)
		shard.z_index = 4
		shard.polygon = PackedVector2Array([
			Vector2(0, -size.y * 0.5),
			Vector2(size.x * 0.42, 0),
			Vector2(0, size.y * 0.5),
			Vector2(-size.x * 0.42, 0),
		])
		shard.set_meta("base_position", shard.position)
		shard.set_meta("phase", float(index) * 0.83)
		add_child(shard)
		move_child(shard, 3)
		rift_shards.append(shard)

func _apply_styles() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.97, 0.94, 0.86, 0.96)
	style.border_color = _colors.POP_DEEP_TURQUOISE
	style.set_border_width_all(4)
	style.set_corner_radius_all(26)
	style.shadow_color = Color(0.04, 0.05, 0.08, 0.28)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 8)
	panel.add_theme_stylebox_override("panel", style)
	chapter_label.add_theme_color_override("font_color", _colors.POP_CRIMSON)
	subtitle_label.add_theme_color_override("font_color", Color(0.30, 0.32, 0.40))
