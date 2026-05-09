extends Control

signal choice_selected(context: String, choice: String)

const ARDA_TEXTURE := preload("res://assets/art/characters/arda/portrait_arda_idle.svg")
const EDA_TEXTURE := preload("res://assets/art/characters/eda/portrait_eda_idle.svg")
const CHOICE_ICON := preload("res://kenney/kenney_ui-pack/PNG/Blue/Default/arrow_decorative_e_small.png")
@onready var _colors := preload("res://scripts/colors.gd")

@onready var backdrop: ColorRect = $Backdrop
@onready var top_glow: ColorRect = $TopGlow
@onready var bottom_fog: ColorRect = $BottomFog
@onready var panel: PanelContainer = $Center/DecisionPanel
@onready var chapter_label: Label = $Center/DecisionPanel/DecisionMargin/DecisionContent/HeaderRow/HeaderText/ChapterLabel
@onready var title_label: Label = $Center/DecisionPanel/DecisionMargin/DecisionContent/HeaderRow/HeaderText/TitleLabel
@onready var prompt_label: Label = $Center/DecisionPanel/DecisionMargin/DecisionContent/PromptLabel
@onready var decision_divider: ColorRect = $Center/DecisionPanel/DecisionMargin/DecisionContent/DecisionDivider
@onready var arda_glow: ColorRect = $Center/DecisionPanel/DecisionMargin/DecisionContent/CharacterRow/ArdaGlow
@onready var eda_glow: ColorRect = $Center/DecisionPanel/DecisionMargin/DecisionContent/CharacterRow/EdaGlow
@onready var arda_card: PanelContainer = $Center/DecisionPanel/DecisionMargin/DecisionContent/CharacterRow/ArdaCard
@onready var eda_card: PanelContainer = $Center/DecisionPanel/DecisionMargin/DecisionContent/CharacterRow/EdaCard
@onready var arda_button: Button = $Center/DecisionPanel/DecisionMargin/DecisionContent/ChoiceRow/ArdaButton
@onready var eda_button: Button = $Center/DecisionPanel/DecisionMargin/DecisionContent/ChoiceRow/EdaButton
@onready var arda_portrait: TextureRect = $Center/DecisionPanel/DecisionMargin/DecisionContent/CharacterRow/ArdaCard/CardMargin/CardContent/Portrait
@onready var eda_portrait: TextureRect = $Center/DecisionPanel/DecisionMargin/DecisionContent/CharacterRow/EdaCard/CardMargin/CardContent/Portrait
@onready var arda_subtitle: Label = $Center/DecisionPanel/DecisionMargin/DecisionContent/CharacterRow/ArdaCard/CardMargin/CardContent/SubTitle
@onready var eda_subtitle: Label = $Center/DecisionPanel/DecisionMargin/DecisionContent/CharacterRow/EdaCard/CardMargin/CardContent/SubTitle

var current_context := ""
var elapsed := 0.0

func _ready() -> void:
	_apply_styles()
	arda_portrait.texture = ARDA_TEXTURE
	eda_portrait.texture = EDA_TEXTURE
	arda_button.icon = CHOICE_ICON
	eda_button.icon = CHOICE_ICON
	arda_button.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	eda_button.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	arda_button.pressed.connect(func() -> void:
		_emit_choice("a")
	)
	eda_button.pressed.connect(func() -> void:
		_emit_choice("b")
	)
	visible = false

func _process(delta: float) -> void:
	if not visible:
		return
	elapsed += delta
	top_glow.color.a = 0.10 + (0.02 * sin(elapsed * 0.9))
	bottom_fog.color.a = 0.18 + (0.03 * sin((elapsed * 0.9) + 0.8))
	decision_divider.color.a = 0.48 + (0.08 * sin(elapsed * 1.2))
	arda_portrait.position.y = sin(elapsed * 1.8) * 2.0
	eda_portrait.position.y = sin((elapsed * 1.8) + 0.7) * 2.0
	arda_glow.color.a = 0.12 + (0.03 * sin(elapsed * 1.6))
	eda_glow.color.a = 0.12 + (0.03 * sin((elapsed * 1.6) + 0.8))

func present(config: Dictionary) -> void:
	current_context = String(config.get("context", ""))
	chapter_label.text = String(config.get("chapter", "Karar Anı"))
	title_label.text = String(config.get("title", "Bir karar ver"))
	prompt_label.text = String(config.get("prompt", ""))
	arda_button.text = String(config.get("option_a", ""))
	eda_button.text = String(config.get("option_b", ""))
	arda_subtitle.text = String(config.get("arda_hint", "Hızlı ama cesur"))
	eda_subtitle.text = String(config.get("eda_hint", "Düşünceli ve planlı"))
	arda_glow.visible = false
	eda_glow.visible = false
	arda_glow.scale = Vector2.ONE * 0.96
	eda_glow.scale = Vector2.ONE * 0.96
	arda_card.scale = Vector2.ONE
	eda_card.scale = Vector2.ONE
	arda_portrait.scale = Vector2.ONE
	eda_portrait.scale = Vector2.ONE
	visible = true
	backdrop.color = Color(0.06, 0.08, 0.12, 0.0)
	top_glow.color = Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.0)
	bottom_fog.color = Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.0)
	panel.scale = Vector2(0.94, 0.94)
	panel.position.y = 18.0
	panel.modulate = Color(1, 1, 1, 0.0)
	arda_card.modulate = Color(1, 1, 1, 0.0)
	eda_card.modulate = Color(1, 1, 1, 0.0)
	arda_card.position.y = 18.0
	eda_card.position.y = 18.0
	var tween := create_tween()
	tween.tween_property(backdrop, "color:a", 0.72, 0.18)
	tween.parallel().tween_property(top_glow, "color:a", 0.10, 0.18)
	tween.parallel().tween_property(bottom_fog, "color:a", 0.18, 0.20)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.18)
	tween.parallel().tween_property(panel, "position:y", 0.0, 0.18)
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.16)
	tween.tween_property(arda_card, "modulate:a", 1.0, 0.10)
	tween.parallel().tween_property(arda_card, "position:y", 0.0, 0.14)
	tween.tween_property(eda_card, "modulate:a", 1.0, 0.10)
	tween.parallel().tween_property(eda_card, "position:y", 0.0, 0.14)

func dismiss() -> void:
	if not visible:
		return
	var tween := create_tween()
	tween.tween_property(backdrop, "color:a", 0.0, 0.14)
	tween.parallel().tween_property(top_glow, "color:a", 0.0, 0.12)
	tween.parallel().tween_property(bottom_fog, "color:a", 0.0, 0.12)
	tween.parallel().tween_property(panel, "scale", Vector2(0.96, 0.96), 0.14)
	tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.12)
	tween.tween_callback(func() -> void:
		visible = false
	)

func _emit_choice(choice: String) -> void:
	if choice == "a":
		arda_card.scale = Vector2.ONE * 1.03
		arda_portrait.scale = Vector2.ONE * 1.04
	else:
		eda_card.scale = Vector2.ONE * 1.03
		eda_portrait.scale = Vector2.ONE * 1.04
	choice_selected.emit(current_context, choice)
	dismiss()

func _apply_styles() -> void:
	_add_panel_style(panel, Color(0.97, 0.95, 0.90), Color(0.25, 0.22, 0.18), 28)
	_add_panel_style(arda_card, Color(1.0, 0.84, 0.64), _colors.POP_CRIMSON, 22)
	_add_panel_style(eda_card, Color(0.74, 0.94, 0.94), _colors.POP_DEEP_TURQUOISE, 22)
	_add_button_style(arda_button, _colors.POP_CRIMSON)
	_add_button_style(eda_button, _colors.POP_DEEP_TURQUOISE)
	chapter_label.add_theme_color_override("font_color", Color(0.02, 0.44, 0.56))
	title_label.add_theme_color_override("font_color", Color(0.16, 0.18, 0.24))
	prompt_label.add_theme_color_override("font_color", Color(0.23, 0.24, 0.30))

func _add_panel_style(target: PanelContainer, fill: Color, border: Color, radius: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(4)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.05, 0.06, 0.08, 0.22)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 7)
	target.add_theme_stylebox_override("panel", style)

func _add_button_style(target: Button, fill: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = fill
	normal.set_corner_radius_all(18)
	normal.border_color = fill.lightened(0.18)
	normal.set_border_width_all(3)
	normal.shadow_color = Color(0.05, 0.06, 0.08, 0.22)
	normal.shadow_size = 6
	normal.shadow_offset = Vector2(0, 4)
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = fill.darkened(0.18)
	pressed.set_corner_radius_all(18)
	pressed.border_color = fill.lightened(0.10)
	pressed.set_border_width_all(3)
	pressed.shadow_color = Color(0.05, 0.06, 0.08, 0.14)
	pressed.shadow_size = 3
	pressed.shadow_offset = Vector2(0, 2)
	target.add_theme_stylebox_override("normal", normal)
	target.add_theme_stylebox_override("hover", normal)
	target.add_theme_stylebox_override("pressed", pressed)
	target.add_theme_color_override("font_color", Color.WHITE)
	target.add_theme_constant_override("icon_max_width", 42)
	target.add_theme_constant_override("h_separation", 18)
