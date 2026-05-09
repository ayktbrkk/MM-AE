extends Control

signal intro_finished

const POP_DEEP_TURQUOISE := Color(0.02, 0.47, 0.57)
# Artwork analizine göre güncellendi: #B82E1F (eski: 0.86, 0.05, 0.12)
const POP_CRIMSON := Color(0.72, 0.18, 0.12)
const POP_GOLD := Color(1.0, 0.70, 0.25)
const RIFT_BLUE := Color(0.22, 0.78, 1.0)

@onready var dimmer: ColorRect = $Dimmer
@onready var glow: ColorRect = $Glow
@onready var center_wrap: CenterContainer = $CenterWrap
@onready var panel: PanelContainer = $CenterWrap/Panel
@onready var book_glow: ColorRect = $CenterWrap/Panel/Margin/Content/BookGlow
@onready var title_label: Label = $CenterWrap/Panel/Margin/Content/Title
@onready var body_label: Label = $CenterWrap/Panel/Margin/Content/Body
@onready var hint_label: Label = $CenterWrap/Panel/Margin/Content/Hint

var is_playing := false
var elapsed := 0.0
var rift_shards: Array[Polygon2D] = []

func _ready() -> void:
	_apply_styles()
	_build_rift_fx()
	_sync_layout()
	hide_overlay()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_sync_layout()

func present(title: String, body: String) -> void:
	is_playing = true
	elapsed = 0.0
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

func _process(delta: float) -> void:
	if not visible:
		return
	elapsed += delta
	book_glow.scale.x = 1.0 + (sin(elapsed * 2.0) * 0.025)
	var color := book_glow.color
	color.a = max(color.a, 0.12 + (sin(elapsed * 2.4) * 0.04))
	book_glow.color = color
	_animate_rift_fx()

func hide_overlay() -> void:
	is_playing = false
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
	var panel_width: float = min(viewport_size.x - 88.0, 760.0)
	panel.custom_minimum_size = Vector2(panel_width, 0.0)
	glow.offset_left = -panel_width * 0.60
	glow.offset_right = panel_width * 0.60
	glow.offset_top = -min(viewport_size.y * 0.24, 420.0)
	glow.offset_bottom = min(viewport_size.y * 0.24, 420.0)

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
		var size := Vector2(28 + (index % 2) * 10, 82 + (index % 3) * 12)
		shard.position = centers[index]
		shard.color = Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, 0.0)
		shard.z_index = 2
		shard.polygon = PackedVector2Array([
			Vector2(0, -size.y * 0.5),
			Vector2(size.x * 0.42, 0),
			Vector2(0, size.y * 0.5),
			Vector2(-size.x * 0.42, 0),
		])
		shard.set_meta("base_position", shard.position)
		shard.set_meta("phase", float(index) * 0.77)
		add_child(shard)
		move_child(shard, 2)
		rift_shards.append(shard)

func _animate_rift_fx() -> void:
	for shard in rift_shards:
		var base_position: Vector2 = shard.get_meta("base_position")
		var phase: float = shard.get_meta("phase")
		shard.position = base_position + Vector2(sin(elapsed * 0.9 + phase) * 16.0, cos(elapsed * 0.7 + phase) * 18.0)
		shard.rotation = sin(elapsed * 0.8 + phase) * 0.12
		shard.scale = Vector2.ONE * (0.94 + (sin(elapsed * 1.3 + phase) * 0.05))

func _apply_styles() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.97, 0.94, 0.86, 0.95)
	style.border_color = POP_DEEP_TURQUOISE
	style.set_border_width_all(4)
	style.set_corner_radius_all(30)
	style.shadow_color = Color(0.03, 0.05, 0.08, 0.30)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 8)
	panel.add_theme_stylebox_override("panel", style)
	title_label.add_theme_color_override("font_color", POP_CRIMSON)
	body_label.add_theme_color_override("font_color", Color(0.19, 0.21, 0.28))
	hint_label.add_theme_color_override("font_color", POP_DEEP_TURQUOISE)
