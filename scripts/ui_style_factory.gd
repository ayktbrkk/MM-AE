class_name UIStyleFactory
extends RefCounted


static func panel_style(
	fill: Color,
	border: Color,
	radius: int,
	border_width := 4,
	shadow_color := Color(0, 0, 0, 0),
	shadow_size := 0,
	shadow_offset := Vector2.ZERO,
	corner_radii: Dictionary = {}
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	if corner_radii.is_empty():
		style.set_corner_radius_all(radius)
	else:
		style.corner_radius_top_left = int(corner_radii.get("top_left", radius))
		style.corner_radius_top_right = int(corner_radii.get("top_right", radius))
		style.corner_radius_bottom_right = int(corner_radii.get("bottom_right", radius))
		style.corner_radius_bottom_left = int(corner_radii.get("bottom_left", radius))
	style.shadow_color = shadow_color
	style.shadow_size = shadow_size
	style.shadow_offset = shadow_offset
	return style


static func button_state_style(
	fill: Color,
	radius: int,
	border_color := Color(0, 0, 0, 0),
	border_width := 0,
	shadow_color := Color(0, 0, 0, 0),
	shadow_size := 0,
	shadow_offset := Vector2.ZERO
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = shadow_color
	style.shadow_size = shadow_size
	style.shadow_offset = shadow_offset
	return style


static func apply_button_style(
	target: Button,
	normal: StyleBoxFlat,
	pressed: StyleBoxFlat,
	hover: StyleBoxFlat = null,
	disabled: StyleBoxFlat = null,
	font_color := Color.WHITE,
	font_disabled_color := Color(1, 1, 1, 0.62),
	font_size := -1,
	icon_max_width := -1,
	h_separation := -1
) -> void:
	target.add_theme_stylebox_override("normal", normal)
	target.add_theme_stylebox_override("hover", normal if hover == null else hover)
	target.add_theme_stylebox_override("pressed", pressed)
	if disabled != null:
		target.add_theme_stylebox_override("disabled", disabled)
	target.add_theme_color_override("font_color", font_color)
	if disabled != null:
		target.add_theme_color_override("font_disabled_color", font_disabled_color)
	if font_size >= 0:
		target.add_theme_font_size_override("font_size", font_size)
	if icon_max_width >= 0:
		target.add_theme_constant_override("icon_max_width", icon_max_width)
	if h_separation >= 0:
		target.add_theme_constant_override("h_separation", h_separation)