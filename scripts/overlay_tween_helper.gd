class_name OverlayTweenHelper
extends RefCounted


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