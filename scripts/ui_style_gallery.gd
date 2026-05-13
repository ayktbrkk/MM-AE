@tool
extends Control

const _ui_styles := preload("res://scripts/ui_style_factory.gd")
const _ui_tokens := preload("res://scripts/ui_tokens.gd")

func _ready() -> void:
	_rebuild()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED and is_node_ready():
		_rebuild()


func _rebuild() -> void:
	for child in get_children():
		child.queue_free()

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _ui_tokens.SPACE_3XL)
	margin.add_theme_constant_override("margin_top", _ui_tokens.SPACE_3XL)
	margin.add_theme_constant_override("margin_right", _ui_tokens.SPACE_3XL)
	margin.add_theme_constant_override("margin_bottom", _ui_tokens.SPACE_3XL)
	scroll.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", _ui_tokens.SPACE_2XL)
	margin.add_child(stack)

	stack.add_child(_make_section_title("Panel Variants"))
	for panel_name in _ui_styles.panel_variant_names():
		stack.add_child(_make_panel_preview(panel_name))

	stack.add_child(_make_section_title("Button Variants"))
	for button_name in _ui_styles.button_variant_names():
		stack.add_child(_make_button_preview(button_name))


func _make_section_title(value: String) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", _ui_tokens.FONT_TITLE_LG)
	return label


func _make_panel_preview(panel_name: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 120)
	_ui_styles.apply_panel_variant(panel, panel_name)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _ui_tokens.SPACE_XL)
	margin.add_theme_constant_override("margin_top", _ui_tokens.SPACE_LG)
	margin.add_theme_constant_override("margin_right", _ui_tokens.SPACE_XL)
	margin.add_theme_constant_override("margin_bottom", _ui_tokens.SPACE_LG)
	panel.add_child(margin)

	var label := Label.new()
	label.text = panel_name
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", _ui_tokens.FONT_BODY_XL)
	margin.add_child(label)
	return panel


func _make_button_preview(button_name: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", _ui_tokens.SPACE_LG)

	var label := Label.new()
	label.text = button_name
	label.custom_minimum_size = Vector2(260, 0)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)

	var button := Button.new()
	button.text = "Preview"
	button.custom_minimum_size = Vector2(280, _ui_tokens.TOUCH_TARGET_MIN)
	_ui_styles.apply_button_variant(button, button_name)
	row.add_child(button)
	return row