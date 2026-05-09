extends Control

signal continue_pressed

const STAR_TEXTURE := preload("res://kenney/kenney_ui-pack/PNG/Blue/Default/star.png")
const BADGE_TEXTURE := preload("res://kenney/kenney_medals/PNG/flat_medal3.png")
const CONTINUE_ICON := preload("res://kenney/kenney_ui-pack/PNG/Blue/Default/arrow_decorative_e_small.png")
@onready var _colors := preload("res://scripts/colors.gd")

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
@onready var continue_button: Button = $Center/InfoCard/CardMargin/CardContent/ContinueButton

var elapsed := 0.0

func _ready() -> void:
	icon_texture.texture = BADGE_TEXTURE
	reward_star.texture = STAR_TEXTURE
	for sparkle in [sparkle_a, sparkle_b, sparkle_c]:
		sparkle.texture = STAR_TEXTURE
		sparkle.modulate = Color(1, 1, 1, 0.0)
	continue_button.icon = CONTINUE_ICON
	continue_button.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_apply_styles()
	continue_button.pressed.connect(func() -> void:
		continue_pressed.emit()
	)
	visible = false

func _process(delta: float) -> void:
	if not visible:
		return
	elapsed += delta
	var shimmer := (sin(elapsed * 1.8) + 1.0) * 0.5
	reward_halo.color.a = 0.10 + (shimmer * 0.045)
	reward_star.scale = Vector2.ONE * (1.0 + (0.06 * sin(elapsed * 4.2)))
	icon_texture.rotation = sin(elapsed * 1.8) * 0.04
	icon_glow.scale = Vector2.ONE * (1.0 + (0.03 * sin(elapsed * 2.6)))
	_animate_sparkle(sparkle_a, 0.0, 5.2)
	_animate_sparkle(sparkle_b, 0.8, 4.6)
	_animate_sparkle(sparkle_c, 1.45, 4.9)

func present(config: Dictionary) -> void:
	tag_label.text = String(config.get("tag_text", "Tarih Kartı"))
	title_label.text = String(config.get("title", "Bilgi Kartı"))
	body_label.text = String(config.get("text", ""))
	reward_label.text = String(config.get("reward_text", "Yeni tarih yıldızı kazandın"))
	icon_texture.texture = config.get("icon_texture", BADGE_TEXTURE)
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

func hide_overlay() -> void:
	visible = false

func _animate_sparkle(sparkle: TextureRect, phase: float, speed: float) -> void:
	var pulse := (sin((elapsed + phase) * speed) + 1.0) * 0.5
	sparkle.scale = Vector2.ONE * (0.74 + (pulse * 0.18))
	sparkle.rotation = sin((elapsed + phase) * 1.9) * 0.18
	sparkle.modulate.a = 0.36 + (pulse * 0.28)

func _apply_styles() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.98, 0.95, 0.88, 0.98)
	style.border_color = Color(0.05, 0.24, 0.32)
	style.set_border_width_all(4)
	style.set_corner_radius_all(28)
	style.shadow_color = Color(0.05, 0.06, 0.08, 0.26)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 8)
	panel.add_theme_stylebox_override("panel", style)
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(1, 1, 1, 0.72)
	frame_style.border_color = Color(0.90, 0.78, 0.58)
	frame_style.set_border_width_all(4)
	frame_style.set_corner_radius_all(28)
	frame_style.shadow_color = Color(0.55, 0.35, 0.12, 0.16)
	frame_style.shadow_size = 8
	frame_style.shadow_offset = Vector2(0, 5)
	illustration_frame.add_theme_stylebox_override("panel", frame_style)
	_apply_button_style(continue_button, _colors.POP_DEEP_TURQUOISE)
	tag_label.add_theme_color_override("font_color", Color(0.02, 0.44, 0.56))
	title_label.add_theme_color_override("font_color", Color(0.17, 0.19, 0.25))
	body_label.add_theme_color_override("font_color", Color(0.25, 0.25, 0.30))
	reward_label.add_theme_color_override("font_color", Color(0.86, 0.42, 0.08))

func _apply_button_style(target: Button, fill: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = fill
	normal.set_corner_radius_all(20)
	normal.border_color = fill.lightened(0.18)
	normal.set_border_width_all(3)
	normal.shadow_color = Color(0.05, 0.06, 0.08, 0.22)
	normal.shadow_size = 6
	normal.shadow_offset = Vector2(0, 4)
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = fill.darkened(0.14)
	pressed.set_corner_radius_all(20)
	pressed.border_color = fill.lightened(0.10)
	pressed.set_border_width_all(3)
	pressed.shadow_color = Color(0.05, 0.06, 0.08, 0.12)
	pressed.shadow_size = 3
	pressed.shadow_offset = Vector2(0, 2)
	target.add_theme_stylebox_override("normal", normal)
	target.add_theme_stylebox_override("hover", normal)
	target.add_theme_stylebox_override("pressed", pressed)
	target.add_theme_color_override("font_color", Color.WHITE)
	target.add_theme_constant_override("icon_max_width", 42)
	target.add_theme_constant_override("h_separation", 18)
