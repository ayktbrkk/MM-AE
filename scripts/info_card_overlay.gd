extends Control

signal continue_pressed

const _rich_text := preload("res://scripts/rich_text_utils.gd")
const _ui_focus := preload("res://scripts/ui_focus_helper.gd")
const _ui_text := preload("res://scripts/ui_text.gd")
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
@onready var body_label: RichTextLabel = $Center/InfoCard/CardMargin/CardContent/BodyLabel
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
	tag_label.text = _ui_text.text(_ui_text.INFO_DEFAULT_TAG, "Tarih Kartı")
	title_label.text = _ui_text.text(_ui_text.INFO_DEFAULT_TITLE, "Bilgi Kartı")
	body_label.text = _rich_text.centered(_ui_text.text(_ui_text.INFO_DEFAULT_BODY, "Kısa ve anlaşılır tarih bilgisi burada görünür."))
	reward_label.text = _ui_text.text(_ui_text.INFO_DEFAULT_REWARD, "Yeni tarih yıldızı kazandın")
	back_button.text = _ui_text.text(_ui_text.INFO_BACK, "Kapat")
	continue_button.text = _ui_text.text(_ui_text.INFO_CONTINUE, "Devam Et")
	continue_button.icon = _textures.CONTINUE_ICON
	continue_button.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_apply_styles()
	_configure_focus_navigation()
	back_button.pressed.connect(_emit_continue)
	continue_button.pressed.connect(_emit_continue)
	visible = false


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if _matches_action(event, &"ui_cancel"):
		_emit_continue()
		get_viewport().set_input_as_handled()


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
	tag_label.text = String(config.get("tag_text", _ui_text.text(_ui_text.INFO_DEFAULT_TAG, "Tarih Kartı")))
	title_label.text = String(config.get("title", _ui_text.text(_ui_text.INFO_DEFAULT_TITLE, "Bilgi Kartı")))
	body_label.text = _rich_text.centered(String(config.get("text", _ui_text.text(_ui_text.INFO_DEFAULT_BODY, "Kısa ve anlaşılır tarih bilgisi burada görünür."))))
	reward_label.text = String(config.get("reward_text", _ui_text.text(_ui_text.INFO_DEFAULT_REWARD, "Yeni tarih yıldızı kazandın")))
	icon_texture.texture = config.get("icon_texture", _textures.BADGE_TEXTURE)
	icon_glow.color = Color(config.get("accent_color", Color(0.95, 0.75, 0.28, 0.18)))
	visible = true
	_ui_focus.grab_preferred(continue_button, [continue_button, back_button])
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
	_overlay_tween_helper.fade_color_alpha(tween, backdrop, 0.68, 0.16)
	_overlay_tween_helper.fade_color_alpha(tween, reward_halo, 0.12, 0.20)
	_overlay_tween_helper.panel_pop_in(tween, panel)
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


func _matches_action(event: InputEvent, action: StringName) -> bool:
	var action_event := event as InputEventAction
	if action_event != null:
		return action_event.pressed and action_event.action == action
	return event.is_action_pressed(action)

func _apply_styles() -> void:
	_ui_styles.apply_panel_variant(panel, "info_panel")
	_ui_styles.apply_panel_variant(illustration_frame, "info_illustration_frame")
	_ui_styles.apply_button_variant(back_button, "info_secondary")
	_ui_styles.apply_button_variant(continue_button, "info_continue")
	tag_label.add_theme_color_override("font_color", Color(0.02, 0.44, 0.56))
	title_label.add_theme_color_override("font_color", Color(0.17, 0.19, 0.25))
	body_label.add_theme_color_override("default_color", Color(0.25, 0.25, 0.30))
	body_label.add_theme_constant_override("line_separation", _ui_tokens.LINE_SEPARATION_RICH)
	reward_label.add_theme_color_override("font_color", Color(0.86, 0.42, 0.08))
	back_button.add_theme_color_override("font_color", Color(0.17, 0.19, 0.25))


func _configure_focus_navigation() -> void:
	_ui_focus.configure_linear([back_button, continue_button], _ui_focus.AXIS_HORIZONTAL)


func _freeze_for_capture() -> void:
	_stop_idle_animations()
	backdrop.color.a = 0.68
	reward_halo.color.a = 0.12
	panel.scale = Vector2.ONE
	panel.position.y = 0.0
	panel.modulate = Color.WHITE
	icon_texture.scale = Vector2.ONE
	icon_texture.rotation = 0.0
	icon_glow.scale = Vector2.ONE
	reward_star.scale = Vector2.ONE
	for sparkle in [sparkle_a, sparkle_b, sparkle_c]:
		sparkle.rotation = 0.0
		sparkle.scale = Vector2.ONE * 0.86
