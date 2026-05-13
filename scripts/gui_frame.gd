class_name GUIFrame
extends RefCounted

const _ui_tokens := preload("res://scripts/ui_tokens.gd")

static func safe_area_side(viewport_size: Vector2) -> float:
	return maxf(_ui_tokens.SAFE_AREA_SIDE_MIN, viewport_size.x * _ui_tokens.SAFE_AREA_SIDE_RATIO)


static func safe_area_top(viewport_size: Vector2) -> float:
	return maxf(_ui_tokens.SAFE_AREA_TOP_MIN, viewport_size.y * _ui_tokens.SAFE_AREA_TOP_RATIO)


static func safe_area_bottom(viewport_size: Vector2) -> float:
	return maxf(_ui_tokens.SAFE_AREA_BOTTOM_MIN, viewport_size.y * _ui_tokens.SAFE_AREA_BOTTOM_RATIO)


static func safe_area_rect(viewport_size: Vector2) -> Rect2:
	var side := safe_area_side(viewport_size)
	var top := safe_area_top(viewport_size)
	var bottom := safe_area_bottom(viewport_size)
	return Rect2(
		Vector2(side, top),
		Vector2(
			maxf(0.0, viewport_size.x - (side * 2.0)),
			maxf(0.0, viewport_size.y - top - bottom)
		)
	)


static func apply_safe_area_offsets(control: Control, viewport_size: Vector2) -> Rect2:
	var side := safe_area_side(viewport_size)
	var top := safe_area_top(viewport_size)
	var bottom := safe_area_bottom(viewport_size)
	control.offset_left = side
	control.offset_right = -side
	control.offset_top = top
	control.offset_bottom = -bottom
	return Rect2(
		Vector2(side, top),
		Vector2(
			maxf(0.0, viewport_size.x - (side * 2.0)),
			maxf(0.0, viewport_size.y - top - bottom)
		)
	)