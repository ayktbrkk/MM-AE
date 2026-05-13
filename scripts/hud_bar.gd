extends Control

const _ui_styles := preload("res://scripts/ui_style_factory.gd")
const _ui_tokens := preload("res://scripts/ui_tokens.gd")

# 5-kollu yildiz icon texture'i (kenney yedegi)
static func _star_texture() -> Texture2D:
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for y in 32:
		for x in 32:
			var dx := float(x - 16)
			var dy := float(y - 16)
			var dist := sqrt(dx * dx + dy * dy)
			if dist <= 14.0:
				image.set_pixel(x, y, Color(0.98, 0.82, 0.20, 0.95))
	return ImageTexture.create_from_image(image)

static var STAR_TEXTURE := _star_texture()

@onready var _colors := preload("res://scripts/colors.gd")

@onready var top_panel: PanelContainer = $TopPanel
@onready var chip_panel: PanelContainer = $ChapterChip
@onready var title_label: Label = $TopPanel/TopMargin/TopContent/TitleLabel
@onready var objective_label: Label = $TopPanel/TopMargin/TopContent/ObjectiveLabel
@onready var progress_label: Label = $TopPanel/TopMargin/TopContent/ProgressRow/ProgressLabel
@onready var star_icon: TextureRect = $TopPanel/TopMargin/TopContent/ProgressRow/StarGroup/StarIcon
@onready var star_label: Label = $TopPanel/TopMargin/TopContent/ProgressRow/StarGroup/StarLabel
@onready var chip_label: Label = $ChapterChip/ChipMargin/ChipLabel

var status_panel: PanelContainer
var compact_objective_label: Label
var compact_progress_label: Label
var star_counter_panel: PanelContainer
var compact_star_icon: TextureRect
var compact_star_label: Label
var star_feedback_panel: PanelContainer
var star_feedback_label: Label
var star_feedback_timer: Timer
var star_feedback_tween: Tween
var objective_hint_panel: PanelContainer
var objective_hint_label: Label
var objective_hint_timer: Timer
var objective_hint_tween: Tween
var _theme_accent := _colors.UI_BADGE_GOLD
var _last_objective := ""
var _last_progress := ""
var _last_star_count := -1

func _ready() -> void:
	star_icon.texture = STAR_TEXTURE
	_build_compact_layout()
	_apply_styles()
	sync_layout()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		sync_layout()

func set_title(value: String) -> void:
	title_label.text = value

func set_objective(value: String) -> void:
	objective_label.text = value
	if compact_objective_label != null:
		compact_objective_label.text = value
	if value == _last_objective:
		return
	_last_objective = value
	_show_objective_hint(value)
	_pulse_panel(status_panel, 1.02)

func set_progress(value: String) -> void:
	progress_label.text = value
	if compact_progress_label != null:
		compact_progress_label.text = value
	if value == _last_progress:
		return
	_last_progress = value
	_pulse_panel(status_panel, 1.015)

func set_chip(value: String) -> void:
	chip_label.text = value

func set_star_count(value: int) -> void:
	var previous_count := _last_star_count
	_last_star_count = value
	star_label.text = "x%d" % value
	if compact_star_label != null:
		compact_star_label.text = "x%d" % value
	_pulse_panel(star_counter_panel, 1.04)
	if previous_count >= 0 and value > previous_count:
		_show_star_feedback(value - previous_count)

func apply_theme(top_fill: Color, top_border: Color, chip_fill: Color, chip_border: Color, accent_fill := _colors.UI_BADGE_GOLD) -> void:
	_theme_accent = accent_fill
	_apply_panel_style(chip_panel, chip_fill, chip_border, 24)
	if status_panel != null:
		_apply_panel_style(status_panel, Color(top_fill.r, top_fill.g, top_fill.b, 0.94), Color(top_border.r, top_border.g, top_border.b, 0.92), 18, 3)
	if star_counter_panel != null:
		_apply_panel_style(star_counter_panel, Color(_colors.DESIGN_STORY_INK.r, _colors.DESIGN_STORY_INK.g, _colors.DESIGN_STORY_INK.b, 0.64), Color(1.0, 1.0, 1.0, 0.10), 24, 2)
	if star_feedback_panel != null:
		_apply_panel_style(star_feedback_panel, Color(accent_fill.r, accent_fill.g, accent_fill.b, 0.94), Color(top_border.r, top_border.g, top_border.b, 0.50), 18, 3)
	if objective_hint_panel != null:
		_apply_panel_style(objective_hint_panel, Color(top_fill.r, top_fill.g, top_fill.b, 0.92), Color(accent_fill.r, accent_fill.g, accent_fill.b, 0.48), 14, 2)
	if compact_progress_label != null:
		compact_progress_label.add_theme_color_override("font_color", Color(top_border.r, top_border.g, top_border.b, 0.82))

func _apply_styles() -> void:
	top_panel.visible = false
	_apply_panel_style(chip_panel, _colors.EDA_TEAL, Color(0.15, 0.24, 0.22), 24)
	chip_label.add_theme_color_override("font_color", Color.WHITE)
	chip_label.add_theme_font_size_override("font_size", _ui_tokens.FONT_LABEL_LG)
	title_label.add_theme_color_override("font_color", Color(0.05, 0.10, 0.16))
	objective_label.add_theme_color_override("font_color", Color(0.21, 0.22, 0.28))
	progress_label.add_theme_color_override("font_color", Color(0.32, 0.34, 0.40))
	star_label.add_theme_color_override("font_color", Color(0.86, 0.42, 0.08))
	if status_panel != null:
		_apply_panel_style(status_panel, Color(_colors.DESIGN_CREAM_PAPER.r, _colors.DESIGN_CREAM_PAPER.g, _colors.DESIGN_CREAM_PAPER.b, 0.94), Color(0.18, 0.28, 0.24, 0.88), 18, 3)
	if compact_objective_label != null:
		compact_objective_label.add_theme_color_override("font_color", Color(_colors.DESIGN_STORY_INK.r, _colors.DESIGN_STORY_INK.g, _colors.DESIGN_STORY_INK.b, 0.96))
		compact_objective_label.add_theme_font_size_override("font_size", _ui_tokens.FONT_LABEL_LG)
	if compact_progress_label != null:
		compact_progress_label.add_theme_color_override("font_color", Color(0.23, 0.27, 0.32, 0.84))
		compact_progress_label.add_theme_font_size_override("font_size", _ui_tokens.FONT_LABEL_SM)
	if compact_star_label != null:
		compact_star_label.add_theme_color_override("font_color", _colors.UI_BADGE_GOLD)
		compact_star_label.add_theme_font_size_override("font_size", _ui_tokens.FONT_BODY_LG)
	if star_feedback_label != null:
		star_feedback_label.add_theme_color_override("font_color", Color.WHITE)
		star_feedback_label.add_theme_font_size_override("font_size", _ui_tokens.FONT_LABEL_SM)
	if objective_hint_label != null:
		objective_hint_label.add_theme_color_override("font_color", Color(_colors.DESIGN_STORY_INK.r, _colors.DESIGN_STORY_INK.g, _colors.DESIGN_STORY_INK.b, 0.86))
		objective_hint_label.add_theme_font_size_override("font_size", _ui_tokens.FONT_LABEL_MD)
		if objective_label.text.strip_edges() != "":
			_show_objective_hint(objective_label.text)

func _build_compact_layout() -> void:
	top_panel.visible = false
	chip_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	chip_panel.offset_left = _ui_tokens.SAFE_AREA_SIDE_MIN
	chip_panel.offset_top = _ui_tokens.SAFE_AREA_TOP_MIN
	chip_panel.offset_right = chip_panel.offset_left + _ui_tokens.HUD_CHIP_WIDTH
	chip_panel.offset_bottom = chip_panel.offset_top + _ui_tokens.CHIP_HEIGHT
	chip_panel.custom_minimum_size = Vector2(276, _ui_tokens.CHIP_HEIGHT)
	chip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip_panel.z_index = 3

	status_panel = PanelContainer.new()
	status_panel.name = "StatusPanel"
	status_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	status_panel.offset_left = _ui_tokens.SAFE_AREA_SIDE_MIN
	status_panel.offset_top = chip_panel.offset_bottom + _ui_tokens.SPACE_SM
	status_panel.offset_right = status_panel.offset_left + _ui_tokens.HUD_STATUS_WIDTH_MAX
	status_panel.offset_bottom = status_panel.offset_top + _ui_tokens.STATUS_PANEL_HEIGHT
	status_panel.custom_minimum_size = Vector2(676, _ui_tokens.STATUS_PANEL_HEIGHT)
	status_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_panel.z_index = 2
	add_child(status_panel)

	var status_margin := MarginContainer.new()
	status_margin.add_theme_constant_override("margin_left", _ui_tokens.SPACE_LG)
	status_margin.add_theme_constant_override("margin_top", _ui_tokens.SPACE_SM)
	status_margin.add_theme_constant_override("margin_right", _ui_tokens.SPACE_LG)
	status_margin.add_theme_constant_override("margin_bottom", _ui_tokens.SPACE_SM)
	status_panel.add_child(status_margin)

	var status_content := VBoxContainer.new()
	status_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_content.add_theme_constant_override("separation", _ui_tokens.SPACE_2XS)
	status_margin.add_child(status_content)

	compact_objective_label = Label.new()
	compact_objective_label.text = objective_label.text
	compact_objective_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	compact_objective_label.custom_minimum_size = Vector2(0, _ui_tokens.FONT_BODY_XL)
	compact_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	compact_objective_label.clip_text = false
	compact_objective_label.max_lines_visible = 2
	status_content.add_child(compact_objective_label)

	compact_progress_label = Label.new()
	compact_progress_label.text = progress_label.text
	compact_progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	compact_progress_label.custom_minimum_size = Vector2(0, _ui_tokens.FONT_BODY_LG)
	compact_progress_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	compact_progress_label.clip_text = false
	compact_progress_label.max_lines_visible = 2
	status_content.add_child(compact_progress_label)

	star_counter_panel = PanelContainer.new()
	star_counter_panel.name = "StarCounter"
	star_counter_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	star_counter_panel.offset_left = -(_ui_tokens.HUD_STAR_WIDTH + _ui_tokens.SAFE_AREA_SIDE_MIN)
	star_counter_panel.offset_top = chip_panel.offset_top
	star_counter_panel.offset_right = -_ui_tokens.SAFE_AREA_SIDE_MIN
	star_counter_panel.offset_bottom = star_counter_panel.offset_top + _ui_tokens.CHIP_HEIGHT
	star_counter_panel.custom_minimum_size = Vector2(144, _ui_tokens.CHIP_HEIGHT)
	star_counter_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	star_counter_panel.z_index = 3
	add_child(star_counter_panel)

	var star_margin := MarginContainer.new()
	star_margin.add_theme_constant_override("margin_left", _ui_tokens.SPACE_MD)
	star_margin.add_theme_constant_override("margin_top", _ui_tokens.SPACE_XS)
	star_margin.add_theme_constant_override("margin_right", _ui_tokens.SPACE_MD)
	star_margin.add_theme_constant_override("margin_bottom", _ui_tokens.SPACE_XS)
	star_counter_panel.add_child(star_margin)

	var star_row := HBoxContainer.new()
	star_row.alignment = BoxContainer.ALIGNMENT_CENTER
	star_row.add_theme_constant_override("separation", _ui_tokens.SPACE_XS)
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
	compact_star_label.add_theme_font_size_override("font_size", _ui_tokens.FONT_BODY_LG)
	compact_star_label.add_theme_color_override("font_color", _colors.UI_BADGE_GOLD)
	star_row.add_child(compact_star_label)

	star_feedback_panel = PanelContainer.new()
	star_feedback_panel.name = "StarFeedback"
	star_feedback_panel.visible = false
	star_feedback_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	star_feedback_panel.offset_left = -(_ui_tokens.HUD_FEEDBACK_WIDTH + _ui_tokens.SAFE_AREA_SIDE_MIN)
	star_feedback_panel.offset_top = status_panel.offset_top
	star_feedback_panel.offset_right = -_ui_tokens.SAFE_AREA_SIDE_MIN
	star_feedback_panel.offset_bottom = star_feedback_panel.offset_top + _ui_tokens.STAR_PANEL_HEIGHT
	star_feedback_panel.custom_minimum_size = Vector2(220, _ui_tokens.STAR_PANEL_HEIGHT)
	star_feedback_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	star_feedback_panel.z_index = 2
	add_child(star_feedback_panel)

	var star_feedback_margin := MarginContainer.new()
	star_feedback_margin.add_theme_constant_override("margin_left", _ui_tokens.SPACE_MD)
	star_feedback_margin.add_theme_constant_override("margin_top", _ui_tokens.SPACE_XS)
	star_feedback_margin.add_theme_constant_override("margin_right", _ui_tokens.SPACE_MD)
	star_feedback_margin.add_theme_constant_override("margin_bottom", _ui_tokens.SPACE_XS)
	star_feedback_panel.add_child(star_feedback_margin)

	star_feedback_label = Label.new()
	star_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	star_feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	star_feedback_margin.add_child(star_feedback_label)

	star_feedback_timer = Timer.new()
	star_feedback_timer.one_shot = true
	star_feedback_timer.wait_time = 1.45
	star_feedback_timer.timeout.connect(_on_star_feedback_timeout)
	add_child(star_feedback_timer)

	objective_hint_panel = PanelContainer.new()
	objective_hint_panel.name = "ObjectiveHint"
	objective_hint_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	objective_hint_panel.offset_left = _ui_tokens.SAFE_AREA_SIDE_MIN
	objective_hint_panel.offset_top = status_panel.offset_bottom + _ui_tokens.SPACE_SM
	objective_hint_panel.offset_right = objective_hint_panel.offset_left + _ui_tokens.HUD_STATUS_WIDTH_MAX
	objective_hint_panel.offset_bottom = objective_hint_panel.offset_top + _ui_tokens.HUD_HINT_HEIGHT
	objective_hint_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	objective_hint_panel.visible = false
	objective_hint_panel.z_index = 1
	add_child(objective_hint_panel)

	var hint_margin := MarginContainer.new()
	hint_margin.add_theme_constant_override("margin_left", _ui_tokens.SPACE_MD)
	hint_margin.add_theme_constant_override("margin_top", _ui_tokens.SPACE_XS)
	hint_margin.add_theme_constant_override("margin_right", _ui_tokens.SPACE_MD)
	hint_margin.add_theme_constant_override("margin_bottom", _ui_tokens.SPACE_XS)
	objective_hint_panel.add_child(hint_margin)

	objective_hint_label = Label.new()
	objective_hint_label.text = objective_label.text
	objective_hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	objective_hint_label.custom_minimum_size = Vector2(0, _ui_tokens.FONT_BODY_XL)
	objective_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_hint_label.clip_text = false
	objective_hint_label.max_lines_visible = 2
	objective_hint_label.add_theme_font_size_override("font_size", _ui_tokens.FONT_LABEL_MD)
	objective_hint_label.add_theme_color_override("font_color", Color(_colors.DESIGN_STORY_INK.r, _colors.DESIGN_STORY_INK.g, _colors.DESIGN_STORY_INK.b, 0.86))
	hint_margin.add_child(objective_hint_label)

	objective_hint_timer = Timer.new()
	objective_hint_timer.one_shot = true
	objective_hint_timer.wait_time = 3.8
	objective_hint_timer.timeout.connect(_on_objective_hint_timeout)
	add_child(objective_hint_timer)


func sync_layout() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var side_margin := maxf(_ui_tokens.SAFE_AREA_SIDE_MIN, viewport_size.x * _ui_tokens.SAFE_AREA_SIDE_RATIO)
	var top_margin := maxf(_ui_tokens.SAFE_AREA_TOP_MIN, viewport_size.y * _ui_tokens.SAFE_AREA_TOP_RATIO)
	var chip_width := maxf(220.0, minf(_ui_tokens.HUD_CHIP_WIDTH, viewport_size.x - (side_margin * 2.0) - _ui_tokens.HUD_STAR_WIDTH - _ui_tokens.SPACE_LG))
	var status_width := maxf(320.0, minf(_ui_tokens.HUD_STATUS_WIDTH_MAX, viewport_size.x - (side_margin * 2.0) - _ui_tokens.HUD_STAR_WIDTH - _ui_tokens.SPACE_LG))
	var chip_top := top_margin - _ui_tokens.SPACE_XS

	chip_panel.offset_left = side_margin
	chip_panel.offset_top = chip_top
	chip_panel.offset_right = chip_panel.offset_left + chip_width
	chip_panel.offset_bottom = chip_panel.offset_top + _ui_tokens.CHIP_HEIGHT

	star_counter_panel.offset_left = -(side_margin + _ui_tokens.HUD_STAR_WIDTH)
	star_counter_panel.offset_top = chip_top
	star_counter_panel.offset_right = -side_margin
	star_counter_panel.offset_bottom = star_counter_panel.offset_top + _ui_tokens.CHIP_HEIGHT

	status_panel.offset_left = side_margin
	status_panel.offset_top = chip_panel.offset_bottom + _ui_tokens.SPACE_SM
	status_panel.offset_right = status_panel.offset_left + status_width
	status_panel.offset_bottom = status_panel.offset_top + _ui_tokens.STATUS_PANEL_HEIGHT

	objective_hint_panel.offset_left = side_margin
	objective_hint_panel.offset_top = status_panel.offset_bottom + _ui_tokens.SPACE_SM
	objective_hint_panel.offset_right = objective_hint_panel.offset_left + status_width
	objective_hint_panel.offset_bottom = objective_hint_panel.offset_top + _ui_tokens.HUD_HINT_HEIGHT

	star_feedback_panel.offset_left = -(side_margin + _ui_tokens.HUD_FEEDBACK_WIDTH)
	star_feedback_panel.offset_top = status_panel.offset_top
	star_feedback_panel.offset_right = -side_margin
	star_feedback_panel.offset_bottom = star_feedback_panel.offset_top + _ui_tokens.STAR_PANEL_HEIGHT

func _show_objective_hint(value: String) -> void:
	if objective_hint_panel == null or objective_hint_label == null:
		return
	if objective_hint_tween != null:
		objective_hint_tween.kill()
	objective_hint_label.text = "Yeni hedef: %s" % value
	objective_hint_panel.visible = value.strip_edges() != ""
	objective_hint_panel.modulate.a = 1.0
	objective_hint_panel.scale = Vector2.ONE * 0.98
	if not objective_hint_panel.visible:
		return
	_pulse_panel(objective_hint_panel, 1.02)
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


func _show_star_feedback(delta: int) -> void:
	if star_feedback_panel == null or star_feedback_label == null or delta <= 0:
		return
	if star_feedback_tween != null:
		star_feedback_tween.kill()
	star_feedback_label.text = "+%d tarih yildizi" % delta
	star_feedback_panel.visible = true
	star_feedback_panel.modulate.a = 1.0
	star_feedback_panel.scale = Vector2.ONE * 0.96
	_pulse_panel(star_feedback_panel, 1.04)
	star_feedback_timer.start()


func _on_star_feedback_timeout() -> void:
	if star_feedback_panel == null or not star_feedback_panel.visible:
		return
	star_feedback_tween = create_tween()
	star_feedback_tween.tween_property(star_feedback_panel, "modulate:a", 0.0, 0.30)
	star_feedback_tween.finished.connect(func() -> void:
		if star_feedback_panel != null:
			star_feedback_panel.visible = false
	)


func _pulse_panel(target: Control, peak_scale: float) -> void:
	if target == null:
		return
	var tween := create_tween()
	target.scale = Vector2.ONE
	tween.tween_property(target, "scale", Vector2.ONE * peak_scale, 0.10)
	tween.tween_property(target, "scale", Vector2.ONE, 0.18)

func _apply_panel_style(panel: PanelContainer, fill: Color, border: Color, radius: int, border_width := 4) -> void:
	panel.add_theme_stylebox_override(
		"panel",
		_ui_styles.panel_style(fill, border, radius, border_width, Color(0.03, 0.05, 0.08, 0.22), 5, Vector2(0, 3))
	)

