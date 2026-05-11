extends Control

signal continue_pressed

# ---------------------------------------------------------------------------
# Portre ekspresyon texture'lari — P5: Portre ekspresyon routing
# ---------------------------------------------------------------------------
const ARDA_IDLE_TEXTURE := preload("res://assets/art/characters/arda/portrait_arda_idle.svg")
const ARDA_HAPPY_TEXTURE := preload("res://assets/art/characters/arda/portrait_arda_happy.svg")
const ARDA_THINKING_TEXTURE := preload("res://assets/art/characters/arda/portrait_arda_thinking.svg")
const EDA_IDLE_TEXTURE := preload("res://assets/art/characters/eda/portrait_eda_idle.svg")
const EDA_HAPPY_TEXTURE := preload("res://assets/art/characters/eda/portrait_eda_happy.svg")
const EDA_THINKING_TEXTURE := preload("res://assets/art/characters/eda/portrait_eda_thinking.svg")
const TAU := 2.0 * PI
@onready var _colors := preload("res://scripts/colors.gd")
@onready var _textures := preload("res://scripts/textures.gd")

# Karakter bazli ekspresyon texture haritasi — { character: { expression: texture } }
const ARDA_EXPRESSIONS := {
	"idle": ARDA_IDLE_TEXTURE,
	"happy": ARDA_HAPPY_TEXTURE,
	"thinking": ARDA_THINKING_TEXTURE,
}
const EDA_EXPRESSIONS := {
	"idle": EDA_IDLE_TEXTURE,
	"happy": EDA_HAPPY_TEXTURE,
	"thinking": EDA_THINKING_TEXTURE,
}

@onready var left_portrait: TextureRect = $PortraitLayer/LeftPortrait
@onready var right_portrait: TextureRect = $PortraitLayer/RightPortrait
@onready var left_glow: ColorRect = $PortraitLayer/LeftGlow
@onready var right_glow: ColorRect = $PortraitLayer/RightGlow
@onready var backdrop_soft: ColorRect = $BackdropSoft
@onready var panel_glow: ColorRect = $PanelGlow
@onready var stage_light_left: ColorRect = $PortraitLayer/StageLightLeft
@onready var stage_light_right: ColorRect = $PortraitLayer/StageLightRight
@onready var panel: PanelContainer = $BottomArea/DialoguePanel
@onready var chapter_label: Label = $BottomArea/DialoguePanel/DialogueMargin/DialogueContent/HeaderRow/HeaderText/ChapterLabel
@onready var name_label: Label = $BottomArea/DialoguePanel/DialogueMargin/DialogueContent/HeaderRow/HeaderText/NameLabel
@onready var body_label: RichTextLabel = $BottomArea/DialoguePanel/DialogueMargin/DialogueContent/BodyText
@onready var continue_row: HBoxContainer = $BottomArea/DialoguePanel/DialogueMargin/DialogueContent/ContinueRow
@onready var continue_icon: TextureRect = $BottomArea/DialoguePanel/DialogueMargin/DialogueContent/ContinueRow/ContinueIcon
@onready var continue_label: Label = $BottomArea/DialoguePanel/DialogueMargin/DialogueContent/ContinueRow/ContinueLabel

var speaker_side_current := "left"
var left_light_alpha := 0.08
var right_light_alpha := 0.08
var reveal_tween: Tween
var left_portrait_base_position := Vector2.ZERO
var right_portrait_base_position := Vector2.ZERO
var left_glow_base_position := Vector2.ZERO
var right_glow_base_position := Vector2.ZERO
var stage_light_left_base_position := Vector2.ZERO
var stage_light_right_base_position := Vector2.ZERO
var _continue_row_base_x: float

func get_overlay_type() -> int:
	return OverlayManager.OverlayType.DIALOGUE

func _ready() -> void:
	left_portrait.texture = ARDA_IDLE_TEXTURE
	right_portrait.texture = EDA_IDLE_TEXTURE
	continue_icon.texture = _textures.CONTINUE_ICON
	left_portrait_base_position = left_portrait.position
	right_portrait_base_position = right_portrait.position
	left_glow_base_position = left_glow.position
	right_glow_base_position = right_glow.position
	stage_light_left_base_position = stage_light_left.position
	stage_light_right_base_position = stage_light_right.position
	_continue_row_base_x = continue_row.position.x
	_apply_styles()
	hide_overlay()
	_start_idle_animations()

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance_or_continue()
	elif event is InputEventScreenTouch and event.pressed:
		_advance_or_continue()

func _start_idle_animations() -> void:
	# Portreler ve glow'lar — sin(elapsed * 2.0), periyot PI
	var tween_portraits := create_tween().set_loops()
	tween_portraits.tween_method(
		func(v: float) -> void:
			left_portrait.position = left_portrait_base_position + Vector2(0.0, sin(v) * 3.0)
			right_portrait.position = right_portrait_base_position + Vector2(0.0, sin(v + 0.8) * 3.0)
			left_glow.position = left_glow_base_position + Vector2(0.0, sin(v) * 2.0)
			right_glow.position = right_glow_base_position + Vector2(0.0, sin(v + 0.8) * 2.0),
		0.0, TAU, PI
	)

	# Stage ışıkları — sin(elapsed * 1.5), periyot 2*PI/1.5
	var tween_stage := create_tween().set_loops()
	tween_stage.tween_method(
		func(v: float) -> void:
			stage_light_left.position = stage_light_left_base_position + Vector2(0.0, sin(v) * 4.0)
			stage_light_right.position = stage_light_right_base_position + Vector2(0.0, sin(v + 0.7) * 4.0),
		0.0, TAU, 4.18879
	)

	# Continue row — sin(elapsed * 2.8), periyot 2*PI/2.8
	var tween_continue := create_tween().set_loops()
	tween_continue.tween_method(
		func(v: float) -> void:
			continue_row.position.x = _continue_row_base_x + sin(v) * 2.0,
		0.0, TAU, 2.244
	)

	# Glow alphaları — breath pattern (sin(elapsed * 1.35)), periyot 2*PI/1.35
	var tween_glow := create_tween().set_loops()
	tween_glow.tween_method(
		func(v: float) -> void:
			var breath := (sin(v) + 1.0) * 0.5
			panel_glow.color.a = 0.08 + (breath * 0.035)
			stage_light_left.color.a = left_light_alpha + (breath * 0.035)
			stage_light_right.color.a = right_light_alpha + ((1.0 - breath) * 0.035),
		0.0, TAU, 4.654
	)

func present(config: Dictionary) -> void:
	chapter_label.text = String(config.get("chapter", "Bölüm"))
	name_label.text = String(config.get("speaker", "Anlatıcı"))
	body_label.text = String(config.get("text", ""))
	var speaker_side := String(config.get("speaker_side", "left"))
	var expression := String(config.get("expression", "idle"))
	speaker_side_current = speaker_side

	# Ekspresyon routing — konuşmacıya göre portre texture'ini değiştir
	_apply_portrait_expression(speaker_side, expression)

	left_portrait.modulate = Color(1, 1, 1, 1.0 if speaker_side == "left" else 0.42)
	right_portrait.modulate = Color(1, 1, 1, 1.0 if speaker_side == "right" else 0.42)
	left_glow.color = Color(_colors.POP_CRIMSON.r, 0.25, 0.16, 0.22 if speaker_side == "left" else 0.08)
	right_glow.color = Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.20 if speaker_side == "right" else 0.08)
	left_light_alpha = 0.16 if speaker_side == "left" else 0.04
	right_light_alpha = 0.16 if speaker_side == "right" else 0.04
	stage_light_left.color = Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, left_light_alpha)
	stage_light_right.color = Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, right_light_alpha)
	left_portrait.scale = Vector2.ONE * (1.0 if speaker_side == "left" else 0.94)
	right_portrait.scale = Vector2.ONE * (1.0 if speaker_side == "right" else 0.94)
	visible = true
	backdrop_soft.color.a = 0.0
	panel_glow.color.a = 0.0
	panel.scale = Vector2(0.97, 0.97)
	panel.position.y = 18.0
	panel.modulate = Color(1, 1, 1, 0.0)
	body_label.visible_ratio = 0.0
	if reveal_tween and reveal_tween.is_running():
		reveal_tween.kill()
	var tween := create_tween()
	tween.tween_property(backdrop_soft, "color:a", 0.16, 0.16)
	tween.parallel().tween_property(panel_glow, "color:a", 0.10, 0.20)
	tween.tween_property(panel, "modulate:a", 1.0, 0.16)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.18)
	tween.parallel().tween_property(panel, "position:y", 0.0, 0.18)
	tween.parallel().tween_property(left_glow, "scale", Vector2.ONE, 0.18)
	tween.parallel().tween_property(right_glow, "scale", Vector2.ONE, 0.18)
	reveal_tween = create_tween()
	var reveal_duration := clampf(float(body_label.text.length()) * 0.012, 0.28, 1.15)
	reveal_tween.tween_property(body_label, "visible_ratio", 1.0, reveal_duration)

func hide_overlay() -> void:
	visible = false

func _advance_or_continue() -> void:
	if body_label.visible_ratio < 0.98:
		if reveal_tween and reveal_tween.is_running():
			reveal_tween.kill()
		body_label.visible_ratio = 1.0
		return
	continue_pressed.emit()

func _apply_styles() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.97, 0.94, 0.86, 0.94)
	style.border_color = Color(0.28, 0.23, 0.19)
	style.set_border_width_all(4)
	style.corner_radius_top_left = 28
	style.corner_radius_top_right = 28
	style.corner_radius_bottom_left = 22
	style.corner_radius_bottom_right = 22
	panel.add_theme_stylebox_override("panel", style)
	chapter_label.add_theme_color_override("font_color", _colors.POP_DEEP_TURQUOISE)
	name_label.add_theme_color_override("font_color", Color(0.17, 0.18, 0.24))
	body_label.add_theme_color_override("default_color", Color(0.20, 0.21, 0.27))
	continue_label.add_theme_color_override("font_color", _colors.POP_DEEP_TURQUOISE)
	left_glow.color = Color(_colors.POP_CRIMSON.r, 0.25, 0.16, 0.12)
	right_glow.color = Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.12)
	stage_light_left.color = Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.08)
	stage_light_right.color = Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.08)

func _apply_portrait_expression(speaker_side: String, expression: String) -> void:
	"""Konuşmacı tarafına ve ekspresyon tipine göre portre texture'ını günceller."""
	var texture_map: Dictionary = ARDA_EXPRESSIONS if speaker_side == "left" else EDA_EXPRESSIONS
	var target_portrait: TextureRect = left_portrait if speaker_side == "left" else right_portrait
	target_portrait.texture = texture_map.get(expression, texture_map["idle"])
