class_name UIStyleFactory
extends RefCounted

const _tokens := preload("res://scripts/ui_tokens.gd")
const _colors := preload("res://scripts/colors.gd")

static var _panel_cache: Dictionary = {}
static var _button_cache: Dictionary = {}


static func panel_style(
	fill: Color,
	border: Color,
	radius: int,
	border_width := _tokens.BORDER_BOLD,
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


static func cached_panel_style(
	fill: Color,
	border: Color,
	radius: int,
	border_width := _tokens.BORDER_BOLD,
	shadow_color := Color(0, 0, 0, 0),
	shadow_size := 0,
	shadow_offset := Vector2.ZERO,
	corner_radii: Dictionary = {}
) -> StyleBoxFlat:
	var cache_key := "panel|%s|%s|%d|%d|%s|%d|%s|%s|%s|%s|%s" % [
		str(fill),
		str(border),
		radius,
		border_width,
		str(shadow_color),
		shadow_size,
		str(shadow_offset),
		int(corner_radii.get("top_left", radius)),
		int(corner_radii.get("top_right", radius)),
		int(corner_radii.get("bottom_right", radius)),
		int(corner_radii.get("bottom_left", radius)),
	]
	if not _panel_cache.has(cache_key):
		_panel_cache[cache_key] = panel_style(fill, border, radius, border_width, shadow_color, shadow_size, shadow_offset, corner_radii)
	return _panel_cache[cache_key]


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


static func cached_button_state_style(
	fill: Color,
	radius: int,
	border_color := Color(0, 0, 0, 0),
	border_width := 0,
	shadow_color := Color(0, 0, 0, 0),
	shadow_size := 0,
	shadow_offset := Vector2.ZERO
) -> StyleBoxFlat:
	var cache_key := "button|%s|%d|%s|%d|%s|%d|%s" % [
		str(fill),
		radius,
		str(border_color),
		border_width,
		str(shadow_color),
		shadow_size,
		str(shadow_offset),
	]
	if not _button_cache.has(cache_key):
		_button_cache[cache_key] = button_state_style(fill, radius, border_color, border_width, shadow_color, shadow_size, shadow_offset)
	return _button_cache[cache_key]


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


static func panel_variant_names() -> PackedStringArray:
	return PackedStringArray([
		"dialogue_panel",
		"decision_panel",
		"decision_card_arda",
		"decision_card_eda",
		"info_panel",
		"info_illustration_frame",
		"chapter_transition_panel",
	])


static func button_variant_names() -> PackedStringArray:
	return PackedStringArray([
		"decision_arda",
		"decision_eda",
		"info_secondary",
		"info_continue",
	])


static func panel_variant(name: String) -> StyleBoxFlat:
	match name:
		"dialogue_panel":
			return cached_panel_style(
				Color(0.97, 0.94, 0.86, 0.94),
				Color(0.28, 0.23, 0.19),
				_tokens.RADIUS_LG,
				_tokens.BORDER_BOLD,
				Color(0, 0, 0, 0),
				0,
				Vector2.ZERO,
				{"top_left": _tokens.RADIUS_2XL, "top_right": _tokens.RADIUS_2XL, "bottom_left": _tokens.RADIUS_LG, "bottom_right": _tokens.RADIUS_LG}
			)
		"decision_panel":
			return cached_panel_style(Color(0.97, 0.95, 0.90), Color(0.25, 0.22, 0.18), 28, _tokens.BORDER_BOLD, Color(0.05, 0.06, 0.08, 0.22), _tokens.SHADOW_SIZE_LG, _tokens.SHADOW_OFFSET_LG)
		"decision_card_arda":
			return cached_panel_style(Color(1.0, 0.84, 0.64), _colors.POP_CRIMSON, 22, _tokens.BORDER_BOLD, Color(0.05, 0.06, 0.08, 0.22), _tokens.SHADOW_SIZE_LG, _tokens.SHADOW_OFFSET_LG)
		"decision_card_eda":
			return cached_panel_style(Color(0.74, 0.94, 0.94), _colors.POP_DEEP_TURQUOISE, 22, _tokens.BORDER_BOLD, Color(0.05, 0.06, 0.08, 0.22), _tokens.SHADOW_SIZE_LG, _tokens.SHADOW_OFFSET_LG)
		"info_panel":
			return cached_panel_style(Color(0.98, 0.95, 0.88, 0.98), Color(0.05, 0.24, 0.32), _tokens.RADIUS_2XL, _tokens.BORDER_BOLD, Color(0.05, 0.06, 0.08, 0.26), _tokens.SHADOW_SIZE_XL, _tokens.SHADOW_OFFSET_XL)
		"info_illustration_frame":
			return cached_panel_style(Color(1, 1, 1, 0.72), Color(0.90, 0.78, 0.58), _tokens.RADIUS_2XL, _tokens.BORDER_BOLD, Color(0.55, 0.35, 0.12, 0.16), 8, Vector2(0, 5))
		"chapter_transition_panel":
			return cached_panel_style(Color(0.97, 0.94, 0.86, 0.96), _colors.POP_DEEP_TURQUOISE, _tokens.RADIUS_XL, _tokens.BORDER_BOLD, Color(0.04, 0.05, 0.08, 0.28), _tokens.SHADOW_SIZE_XL, _tokens.SHADOW_OFFSET_XL)
		_:
			push_warning("Unknown panel style variant: %s" % name)
			return cached_panel_style(Color.WHITE, Color.TRANSPARENT, _tokens.RADIUS_BASE)


static func apply_panel_variant(target: PanelContainer, name: String) -> void:
	target.add_theme_stylebox_override("panel", panel_variant(name))


static func button_variant(name: String) -> Dictionary:
	match name:
		"decision_arda":
			return {
				"normal": cached_button_state_style(_colors.POP_CRIMSON, _tokens.RADIUS_MD, _colors.POP_CRIMSON.lightened(0.18), _tokens.BORDER_REGULAR, Color(0.05, 0.06, 0.08, 0.22), _tokens.SHADOW_SIZE_MD, _tokens.SHADOW_OFFSET_MD),
				"pressed": cached_button_state_style(_colors.POP_CRIMSON.darkened(0.18), _tokens.RADIUS_MD, _colors.POP_CRIMSON.lightened(0.10), _tokens.BORDER_REGULAR, Color(0.05, 0.06, 0.08, 0.14), _tokens.SHADOW_SIZE_XS, Vector2(0, 2)),
				"font_color": Color.WHITE,
				"font_disabled_color": Color(1, 1, 1, 0.62),
				"font_size": _tokens.FONT_ACTION,
				"icon_max_width": 42,
				"h_separation": _tokens.SPACE_LG_PLUS,
			}
		"decision_eda":
			return {
				"normal": cached_button_state_style(_colors.POP_DEEP_TURQUOISE, _tokens.RADIUS_MD, _colors.POP_DEEP_TURQUOISE.lightened(0.18), _tokens.BORDER_REGULAR, Color(0.05, 0.06, 0.08, 0.22), _tokens.SHADOW_SIZE_MD, _tokens.SHADOW_OFFSET_MD),
				"pressed": cached_button_state_style(_colors.POP_DEEP_TURQUOISE.darkened(0.18), _tokens.RADIUS_MD, _colors.POP_DEEP_TURQUOISE.lightened(0.10), _tokens.BORDER_REGULAR, Color(0.05, 0.06, 0.08, 0.14), _tokens.SHADOW_SIZE_XS, Vector2(0, 2)),
				"font_color": Color.WHITE,
				"font_disabled_color": Color(1, 1, 1, 0.62),
				"font_size": _tokens.FONT_ACTION,
				"icon_max_width": 42,
				"h_separation": _tokens.SPACE_LG_PLUS,
			}
		"info_secondary":
			return {
				"normal": cached_button_state_style(Color(1, 1, 1, 0.76), _tokens.RADIUS_BASE, Color(0.05, 0.24, 0.32, 0.34), _tokens.BORDER_REGULAR, Color(0.05, 0.06, 0.08, 0.14), _tokens.SPACE_3XS, _tokens.SHADOW_OFFSET_SM),
				"pressed": cached_button_state_style(Color(0.93, 0.91, 0.86, 0.96), _tokens.RADIUS_BASE, Color(0.05, 0.24, 0.32, 0.42), _tokens.BORDER_REGULAR, Color(0.05, 0.06, 0.08, 0.10), _tokens.SHADOW_SIZE_XS, _tokens.SHADOW_OFFSET_XS),
				"font_color": Color(1, 1, 1, 1),
				"font_disabled_color": Color(1, 1, 1, 0.62),
				"font_size": _tokens.FONT_LABEL_XL,
			}
		"info_continue":
			return {
				"normal": cached_button_state_style(_colors.POP_DEEP_TURQUOISE, _tokens.RADIUS_BASE, _colors.POP_DEEP_TURQUOISE.lightened(0.18), _tokens.BORDER_REGULAR, Color(0.05, 0.06, 0.08, 0.22), _tokens.SHADOW_SIZE_MD, _tokens.SHADOW_OFFSET_MD),
				"pressed": cached_button_state_style(_colors.POP_DEEP_TURQUOISE.darkened(0.14), _tokens.RADIUS_BASE, _colors.POP_DEEP_TURQUOISE.lightened(0.10), _tokens.BORDER_REGULAR, Color(0.05, 0.06, 0.08, 0.12), _tokens.SHADOW_SIZE_XS, Vector2(0, 2)),
				"font_color": Color.WHITE,
				"font_disabled_color": Color(1, 1, 1, 0.62),
				"icon_max_width": 42,
				"h_separation": _tokens.SPACE_LG,
			}
		_:
			push_warning("Unknown button style variant: %s" % name)
			return {
				"normal": cached_button_state_style(Color(0.6, 0.6, 0.6), _tokens.RADIUS_BASE),
				"pressed": cached_button_state_style(Color(0.5, 0.5, 0.5), _tokens.RADIUS_BASE),
				"font_color": Color.WHITE,
				"font_disabled_color": Color(1, 1, 1, 0.62),
			}


static func apply_button_variant(target: Button, name: String) -> void:
	var variant := button_variant(name)
	apply_button_style(
		target,
		variant.get("normal"),
		variant.get("pressed"),
		variant.get("hover"),
		variant.get("disabled"),
		variant.get("font_color", Color.WHITE),
		variant.get("font_disabled_color", Color(1, 1, 1, 0.62)),
		int(variant.get("font_size", -1)),
		int(variant.get("icon_max_width", -1)),
		int(variant.get("h_separation", -1))
	)