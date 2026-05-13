extends Control

signal continue_pressed

const _ui_styles := preload("res://scripts/ui_style_factory.gd")
const _ui_tokens := preload("res://scripts/ui_tokens.gd")
const _overlay_tween_helper := preload("res://scripts/overlay_tween_helper.gd")

@onready var _colors := preload("res://scripts/colors.gd")
@onready var _textures := preload("res://scripts/textures.gd")

@onready var backdrop: ColorRect = $Backdrop
@onready var reward_halo: ColorRect = $RewardHalo
@onready var sparkle_a: TextureRect = $SparkleA
@onready var sparkle_b: TextureRect = $SparkleB
@onready var sparkle_c: TextureRect = $SparkleC
@onready var panel: PanelContainer = $Center/InfoCard
@onready var tag_label: Label = $Center/InfoCard/CardMargin/CardContent/TagLabel
@onready var title_label: Label = $Center/InfoCard/CardMargin/CardContent/TitleLabel
@onready var body_label: Label = $Center/InfoCard/CardMargin/CardContent/BodyLabel
@onready var illustration_frame: PanelContainer = $Center/InfoCard/CardMargin/CardContent/IconRow/IllustrationFrame
@onready var icon_glow: ColorRect = $Center/InfoCard/CardMargin/CardContent/IconRow/IllustrationFrame/IllustrationMargin/IllustrationStack/IconGlow
@onready var icon_texture: TextureRect = $Center/InfoCard/CardMargin/CardContent/IconRow/IllustrationFrame/IllustrationMargin/IllustrationStack/IconTexture
@onready var reward_star: TextureRect = $Center/InfoCard/CardMargin/CardContent/RewardRow/RewardStar
@onready var reward_label: Label = $Center/InfoCard/CardMargin/CardContent/RewardRow/RewardLabel
@onready var back_button: Button = $Center/InfoCard/CardMargin/CardContent/ActionRow/BackButton
@onready var continue_button: Button = $Center/InfoCard/CardMargin/CardContent/ActionRow/ContinueButton

# Idle tween referansları
var _idle_tweens: Array[Tween] = []

func get_overlay_type() -> int:
	return OverlayManager.OverlayType.INFO_CARD

func _ready() -> void:
	icon_texture.texture = _textures.BADGE_TEXTURE
	reward_star.texture = _textures.STAR_TEXTURE
	for sparkle in [sparkle_a, sparkle_b, sparkle_c]:
		sparkle.texture = _textures.STAR_TEXTURE
		sparkle.modulate = Color(1, 1, 1, 0.0)
	back_button.text = "Kapat"
	continue_button.icon = _textures.CONTINUE_ICON
	continue_button.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_apply_styles()
	back_button.pressed.connect(_emit_continue)
	continue_button.pressed.connect(_emit_continue)
	visible = false


func _emit_continue() -> void:
	continue_pressed.emit()

func _start_idle_animations() -> void:
	_stop_idle_animations()

	# 1. reward_halo alpha shimmer (sin(elapsed * 1.8))
	var t1 := create_tween().set_loops()
	t1.tween_method(_animate_reward_halo, 0.0, TAU, TAU / 1.8)
	_idle_tweens.append(t1)

	# 2. reward_star scale pulse (sin(elapsed * 4.2))
	var t2 := create_tween().set_loops()
	t2.tween_method(_animate_reward_star, 0.0, TAU, TAU / 4.2)
	_idle_tweens.append(t2)

	# 3. icon_texture rotation (sin(elapsed * 1.8))
	var t3 := create_tween().set_loops()
	t3.tween_method(_animate_icon_texture, 0.0, TAU, TAU / 1.8)
	_idle_tweens.append(t3)

	# 4. icon_glow scale pulse (sin(elapsed * 2.6))
	var t4 := create_tween().set_loops()
	t4.tween_method(_animate_icon_glow, 0.0, TAU, TAU / 2.6)
	_idle_tweens.append(t4)

	# 5-7. Sparkle animasyonları (scale + rotation + alpha)
	_tween_sparkle(sparkle_a, 0.0, 5.2)
	_tween_sparkle(sparkle_b, 0.8, 4.6)
	_tween_sparkle(sparkle_c, 1.45, 4.9)


func _animate_reward_halo(v: float) -> void:
	reward_halo.color.a = 0.1225 + sin(v) * 0.0225


func _animate_reward_star(v: float) -> void:
	reward_star.scale = Vector2.ONE * (1.0 + sin(v) * 0.06)


func _animate_icon_texture(v: float) -> void:
	icon_texture.rotation = sin(v) * 0.04


func _animate_icon_glow(v: float) -> void:
	icon_glow.scale = Vector2.ONE * (1.0 + sin(v) * 0.03)


func _tween_sparkle(sparkle: TextureRect, phase: float, speed: float) -> void:
	# Scale + modulate.a: sin((elapsed + phase) * speed)
	var t_scale := create_tween().set_loops()
	t_scale.tween_method(_sparkle_scale_anim.bind(sparkle, phase, speed), 0.0, TAU, TAU / speed)
	_idle_tweens.append(t_scale)

	# Rotation: sin((elapsed + phase) * 1.9) * 0.18
	var t_rot := create_tween().set_loops()
	t_rot.tween_method(_sparkle_rot_anim.bind(sparkle, phase), 0.0, TAU, TAU / 1.9)
	_idle_tweens.append(t_rot)


func _sparkle_scale_anim(v: float, sparkle: TextureRect, phase: float, speed: float) -> void:
	var sv := sin(v + phase * speed)
	sparkle.scale = Vector2.ONE * (0.83 + sv * 0.09)
	sparkle.modulate.a = 0.5 + sv * 0.14


func _sparkle_rot_anim(v: float, sparkle: TextureRect, phase: float) -> void:
	sparkle.rotation = sin(v + phase * 1.9) * 0.18

func _stop_idle_animations() -> void:
	_overlay_tween_helper.cancel_many(_idle_tweens)
	_idle_tweens.clear()

func present(config: Dictionary) -> void:
	_stop_idle_animations()
	tag_label.text = String(config.get("tag_text", "Tarih Kartı"))
	title_label.text = String(config.get("title", "Bilgi Kartı"))
	body_label.text = String(config.get("text", ""))
	reward_label.text = String(config.get("reward_text", "Yeni tarih yıldızı kazandın"))
	icon_texture.texture = config.get("icon_texture", _textures.BADGE_TEXTURE)
	icon_glow.color = Color(config.get("accent_color", Color(0.95, 0.75, 0.28, 0.18)))
	visible = true
	backdrop.color = Color(0.08, 0.10, 0.14, 0.0)
	reward_halo.color = Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.0)
	panel.scale = Vector2(0.94, 0.94)
	panel.position.y = 20.0
	panel.modulate = Color(1, 1, 1, 0.0)
	icon_texture.scale = Vector2.ONE * 0.92
	icon_texture.rotation = 0.0
	icon_glow.scale = Vector2.ONE
	reward_star.scale = Vector2.ONE * 0.72
	for sparkle in [sparkle_a, sparkle_b, sparkle_c]:
		sparkle.modulate = Color(1, 0.86, 0.42, 0.0)
		sparkle.scale = Vector2.ONE * 0.72
	var tween := create_tween()
	tween.tween_property(backdrop, "color:a", 0.68, 0.16)
	tween.parallel().tween_property(reward_halo, "color:a", 0.12, 0.20)
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.14)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.18)
	tween.parallel().tween_property(panel, "position:y", 0.0, 0.18)
	tween.parallel().tween_property(icon_texture, "scale", Vector2.ONE, 0.18)
	tween.parallel().tween_property(reward_star, "scale", Vector2.ONE, 0.18)
	tween.parallel().tween_property(sparkle_a, "modulate:a", 0.72, 0.22)
	tween.parallel().tween_property(sparkle_b, "modulate:a", 0.58, 0.24)
	tween.parallel().tween_property(sparkle_c, "modulate:a", 0.48, 0.26)
	tween.finished.connect(_start_idle_animations)


func show_overlay(config: Dictionary = {}) -> void:
	present(config)

func hide_overlay() -> void:
	visible = false
	_stop_idle_animations()

func _apply_styles() -> void:
	panel.add_theme_stylebox_override(
		"panel",
		_ui_styles.panel_style(Color(0.98, 0.95, 0.88, 0.98), Color(0.05, 0.24, 0.32), _ui_tokens.RADIUS_2XL, _ui_tokens.BORDER_BOLD, Color(0.05, 0.06, 0.08, 0.26), _ui_tokens.SHADOW_SIZE_XL, _ui_tokens.SHADOW_OFFSET_XL)
	)
	illustration_frame.add_theme_stylebox_override(
		"panel",
		_ui_styles.panel_style(Color(1, 1, 1, 0.72), Color(0.90, 0.78, 0.58), _ui_tokens.RADIUS_2XL, _ui_tokens.BORDER_BOLD, Color(0.55, 0.35, 0.12, 0.16), 8, Vector2(0, 5))
	)
	_apply_secondary_button_style(back_button)
	_apply_button_style(continue_button, _colors.POP_DEEP_TURQUOISE)
	tag_label.add_theme_color_override("font_color", Color(0.02, 0.44, 0.56))
	title_label.add_theme_color_override("font_color", Color(0.17, 0.19, 0.25))
	body_label.add_theme_color_override("font_color", Color(0.25, 0.25, 0.30))
	reward_label.add_theme_color_override("font_color", Color(0.86, 0.42, 0.08))
	back_button.add_theme_color_override("font_color", Color(0.17, 0.19, 0.25))


func _apply_secondary_button_style(target: Button) -> void:
	var normal := _ui_styles.button_state_style(Color(1, 1, 1, 0.76), _ui_tokens.RADIUS_BASE, Color(0.05, 0.24, 0.32, 0.34), _ui_tokens.BORDER_REGULAR, Color(0.05, 0.06, 0.08, 0.14), _ui_tokens.SPACE_3XS, _ui_tokens.SHADOW_OFFSET_SM)
	var pressed := _ui_styles.button_state_style(Color(0.93, 0.91, 0.86, 0.96), _ui_tokens.RADIUS_BASE, Color(0.05, 0.24, 0.32, 0.42), _ui_tokens.BORDER_REGULAR, Color(0.05, 0.06, 0.08, 0.10), _ui_tokens.SHADOW_SIZE_XS, _ui_tokens.SHADOW_OFFSET_XS)
	_ui_styles.apply_button_style(target, normal, pressed, null, null, Color(1, 1, 1, 1), Color(1, 1, 1, 0.62), _ui_tokens.FONT_LABEL_XL)

func _apply_button_style(target: Button, fill: Color) -> void:
	var normal := _ui_styles.button_state_style(fill, _ui_tokens.RADIUS_BASE, fill.lightened(0.18), _ui_tokens.BORDER_REGULAR, Color(0.05, 0.06, 0.08, 0.22), _ui_tokens.SHADOW_SIZE_MD, _ui_tokens.SHADOW_OFFSET_MD)
	var pressed := _ui_styles.button_state_style(fill.darkened(0.14), _ui_tokens.RADIUS_BASE, fill.lightened(0.10), _ui_tokens.BORDER_REGULAR, Color(0.05, 0.06, 0.08, 0.12), _ui_tokens.SHADOW_SIZE_XS, Vector2(0, 2))
	_ui_styles.apply_button_style(target, normal, pressed, null, null, Color.WHITE, Color(1, 1, 1, 0.62), -1, 42, _ui_tokens.SPACE_LG)
