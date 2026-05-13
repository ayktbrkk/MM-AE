class_name OverlayTweenHelper
extends RefCounted

const TRANS_STANDARD := Tween.TRANS_SINE
const EASE_STANDARD := Tween.EASE_OUT
const DURATION_ENTER := 0.18
const DURATION_EXIT := 0.14
const DURATION_BACKDROP := 0.20
const PANEL_POP_OFFSET := 18.0
const PANEL_POP_SCALE_IN := Vector2(0.94, 0.94)
const PANEL_POP_SCALE_OUT := Vector2(0.96, 0.96)


static func replace(owner: Node, current_tween: Tween, on_finished: Callable = Callable()) -> Tween:
	cancel(current_tween)
	var tween := owner.create_tween()
	if on_finished.is_valid():
		tween.finished.connect(on_finished)
	return tween


static func cancel(current_tween: Tween) -> Tween:
	if current_tween != null:
		current_tween.kill()
	return null


static func cancel_many(tweens: Array[Tween]) -> void:
	for tween in tweens:
		if is_instance_valid(tween):
			tween.kill()


static func fade_color_alpha(tween: Tween, target: ColorRect, alpha: float, duration := DURATION_BACKDROP) -> void:
	tween.parallel().tween_property(target, "color:a", alpha, duration).set_trans(TRANS_STANDARD).set_ease(EASE_STANDARD)


static func fade_modulate_alpha(tween: Tween, target: CanvasItem, alpha: float, duration := DURATION_ENTER) -> void:
	tween.parallel().tween_property(target, "modulate:a", alpha, duration).set_trans(TRANS_STANDARD).set_ease(EASE_STANDARD)


static func panel_pop_in(tween: Tween, panel: Control, duration := DURATION_ENTER, offset_y := PANEL_POP_OFFSET, scale_from := PANEL_POP_SCALE_IN) -> void:
	panel.position.y = offset_y
	panel.scale = scale_from
	panel.modulate.a = 0.0
	fade_modulate_alpha(tween, panel, 1.0, duration * 0.9)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, duration).set_trans(TRANS_STANDARD).set_ease(EASE_STANDARD)
	tween.parallel().tween_property(panel, "position:y", 0.0, duration).set_trans(TRANS_STANDARD).set_ease(EASE_STANDARD)


static func panel_pop_out(tween: Tween, panel: Control, duration := DURATION_EXIT, scale_to := PANEL_POP_SCALE_OUT) -> void:
	fade_modulate_alpha(tween, panel, 0.0, duration * 0.85)
	tween.parallel().tween_property(panel, "scale", scale_to, duration).set_trans(TRANS_STANDARD).set_ease(EASE_STANDARD)