extends Control

const STAR_TEXTURE := preload("res://kenney/kenney_ui-pack/PNG/Blue/Default/star.png")

@onready var _colors := preload("res://scripts/colors.gd")

@onready var top_panel: PanelContainer = $TopPanel
@onready var chip_panel: PanelContainer = $ChapterChip
@onready var title_label: Label = $TopPanel/TopMargin/TopContent/TitleLabel
@onready var objective_label: Label = $TopPanel/TopMargin/TopContent/ObjectiveLabel
@onready var progress_label: Label = $TopPanel/TopMargin/TopContent/ProgressRow/ProgressLabel
@onready var star_icon: TextureRect = $TopPanel/TopMargin/TopContent/ProgressRow/StarGroup/StarIcon
@onready var star_label: Label = $TopPanel/TopMargin/TopContent/ProgressRow/StarGroup/StarLabel
@onready var chip_label: Label = $ChapterChip/ChipMargin/ChipLabel

var star_counter_panel: PanelContainer
var compact_star_icon: TextureRect
var compact_star_label: Label
var objective_hint_panel: PanelContainer
var objective_hint_label: Label
var objective_hint_timer: Timer
var objective_hint_tween: Tween

func _ready() -> void:
	star_icon.texture = STAR_TEXTURE
	_build_compact_layout()
	_apply_styles()

func set_title(value: String) -> void:
	title_label.text = value

func set_objective(value: String) -> void:
	objective_label.text = value
	_show_objective_hint(value)

func set_progress(value: String) -> void:
	progress_label.text = value

func set_chip(value: String) -> void:
	chip_label.text = value

func set_star_count(value: int) -> void:
	star_label.text = "x%d" % value
	if compact_star_label != null:
		compact_star_label.text = "x%d" % value

func apply_theme(top_fill: Color, top_border: Color, chip_fill: Color, chip_border: Color) -> void:
	_apply_panel_style(chip_panel, chip_fill, chip_border, 24)
	if star_counter_panel != null:
		_apply_panel_style(star_counter_panel, Color(_colors.DESIGN_STORY_INK.r, _colors.DESIGN_STORY_INK.g, _colors.DESIGN_STORY_INK.b, 0.64), Color(1.0, 1.0, 1.0, 0.10), 24, 2)
	if objective_hint_panel != null:
		_apply_panel_style(objective_hint_panel, Color(top_fill.r, top_fill.g, top_fill.b, 0.88), Color(top_border.r, top_border.g, top_border.b, 0.42), 14, 2)

func _apply_styles() -> void:
	top_panel.visible = false
	_apply_panel_style(chip_panel, _colors.EDA_TEAL, Color(0.15, 0.24, 0.22), 24)
	chip_label.add_theme_color_override("font_color", Color.WHITE)
	chip_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color(0.05, 0.10, 0.16))
	objective_label.add_theme_color_override("font_color", Color(0.21, 0.22, 0.28))
	progress_label.add_theme_color_override("font_color", Color(0.32, 0.34, 0.40))
	star_label.add_theme_color_override("font_color", Color(0.86, 0.42, 0.08))
	if compact_star_label != null:
		compact_star_label.add_theme_color_override("font_color", _colors.UI_BADGE_GOLD)
		compact_star_label.add_theme_font_size_override("font_size", 24)
	if objective_hint_label != null:
		objective_hint_label.add_theme_color_override("font_color", Color(_colors.DESIGN_STORY_INK.r, _colors.DESIGN_STORY_INK.g, _colors.DESIGN_STORY_INK.b, 0.86))
		objective_hint_label.add_theme_font_size_override("font_size", 20)
		_show_objective_hint(objective_label.text)

func _build_compact_layout() -> void:
	top_panel.visible = false
	chip_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	chip_panel.offset_left = 24.0
	chip_panel.offset_top = 18.0
	chip_panel.offset_right = 300.0
	chip_panel.offset_bottom = 74.0
	chip_panel.custom_minimum_size = Vector2(276, 56)
	chip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	star_counter_panel = PanelContainer.new()
	star_counter_panel.name = "StarCounter"
	star_counter_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	star_counter_panel.offset_left = -168.0
	star_counter_panel.offset_top = 18.0
	star_counter_panel.offset_right = -24.0
	star_counter_panel.offset_bottom = 74.0
	star_counter_panel.custom_minimum_size = Vector2(144, 56)
	star_counter_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(star_counter_panel)

	var star_margin := MarginContainer.new()
	star_margin.add_theme_constant_override("margin_left", 16)
	star_margin.add_theme_constant_override("margin_top", 8)
	star_margin.add_theme_constant_override("margin_right", 16)
	star_margin.add_theme_constant_override("margin_bottom", 8)
	star_counter_panel.add_child(star_margin)

	var star_row := HBoxContainer.new()
	star_row.alignment = BoxContainer.ALIGNMENT_CENTER
	star_row.add_theme_constant_override("separation", 8)
	star_margin.add_child(star_row)

	compact_star_icon = TextureRect.new()
	compact_star_icon.texture = STAR_TEXTURE
	compact_star_icon.custom_minimum_size = Vector2(32, 32)
	compact_star_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	compact_star_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	compact_star_icon.modulate = _colors.UI_BADGE_GOLD
	star_row.add_child(compact_star_icon)

	compact_star_label = Label.new()
	compact_star_label.text = star_label.text
	compact_star_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	compact_star_label.add_theme_font_size_override("font_size", 24)
	compact_star_label.add_theme_color_override("font_color", _colors.UI_BADGE_GOLD)
	star_row.add_child(compact_star_label)

	objective_hint_panel = PanelContainer.new()
	objective_hint_panel.name = "ObjectiveHint"
	objective_hint_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	objective_hint_panel.offset_left = 24.0
	objective_hint_panel.offset_top = 84.0
	objective_hint_panel.offset_right = 700.0
	objective_hint_panel.offset_bottom = 152.0
	objective_hint_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(objective_hint_panel)

	var hint_margin := MarginContainer.new()
	hint_margin.add_theme_constant_override("margin_left", 16)
	hint_margin.add_theme_constant_override("margin_top", 8)
	hint_margin.add_theme_constant_override("margin_right", 16)
	hint_margin.add_theme_constant_override("margin_bottom", 8)
	objective_hint_panel.add_child(hint_margin)

	objective_hint_label = Label.new()
	objective_hint_label.text = objective_label.text
	objective_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_hint_label.clip_text = true
	objective_hint_label.max_lines_visible = 2
	objective_hint_label.add_theme_font_size_override("font_size", 20)
	objective_hint_label.add_theme_color_override("font_color", Color(_colors.DESIGN_STORY_INK.r, _colors.DESIGN_STORY_INK.g, _colors.DESIGN_STORY_INK.b, 0.86))
	hint_margin.add_child(objective_hint_label)

	objective_hint_timer = Timer.new()
	objective_hint_timer.one_shot = true
	objective_hint_timer.wait_time = 5.0
	objective_hint_timer.timeout.connect(_on_objective_hint_timeout)
	add_child(objective_hint_timer)

func _show_objective_hint(value: String) -> void:
	if objective_hint_panel == null or objective_hint_label == null:
		return
	if objective_hint_tween != null:
		objective_hint_tween.kill()
	objective_hint_label.text = value
	objective_hint_panel.visible = value.strip_edges() != ""
	objective_hint_panel.modulate.a = 1.0
	if not objective_hint_panel.visible:
		return
	objective_hint_timer.start()

func _on_objective_hint_timeout() -> void:
	if objective_hint_panel == null or not objective_hint_panel.visible:
		return
	objective_hint_tween = create_tween()
	objective_hint_tween.tween_property(objective_hint_panel, "modulate:a", 0.0, 0.35)
	objective_hint_tween.finished.connect(func() -> void:
		if objective_hint_panel != null:
			objective_hint_panel.visible = false
	)

func _apply_panel_style(panel: PanelContainer, fill: Color, border: Color, radius: int, border_width := 4) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.03, 0.05, 0.08, 0.22)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0, 3)
	panel.add_theme_stylebox_override("panel", style)
