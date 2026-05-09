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

var elapsed := 0.0
var rift_shards: Array[Polygon2D] = []

func _ready() -> void:
	_apply_styles()
	_build_rift_fx()
	visible = false

func _process(delta: float) -> void:
	if not visible:
		return
	elapsed += delta
	var drift := sin(elapsed * 1.4)
	dream_mist.position.y = drift * 6.0
	route_dot_a.scale = Vector2.ONE * (0.92 + (0.06 * sin(elapsed * 4.0)))
	route_dot_b.scale = Vector2.ONE * (0.92 + (0.06 * sin((elapsed * 4.0) + 0.7)))
	route_dot_c.scale = Vector2.ONE * (0.92 + (0.06 * sin((elapsed * 4.0) + 1.4)))
	_animate_rift_fx()

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

func _animate_rift_fx() -> void:
	for shard in rift_shards:
		var base_position: Vector2 = shard.get_meta("base_position")
		var phase: float = shard.get_meta("phase")
		shard.position = base_position + Vector2(sin(elapsed * 0.9 + phase) * 14.0, cos(elapsed * 0.7 + phase) * 16.0)
		shard.rotation = sin(elapsed * 0.8 + phase) * 0.12

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
