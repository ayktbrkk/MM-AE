extends SceneTree

const CAPTURE_WORLD_RENDER := preload("res://tools/capture_world_render.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var world_scene: PackedScene = load("res://scenes/world.tscn")
	var world := world_scene.instantiate()
	root.add_child(world)
	await _wait_frames(6)

	var ui_mod: Node = world.get_node("WorldUI")
	ui_mod.show_chapter_transition("Bandırma Vapuru", "Gece yolculugu basliyor")
	await _wait_frames(2)

	var transition_node: Node = CAPTURE_WORLD_RENDER.find_chapter_transition_overlay(world)
	_assert_true(transition_node != null, "Capture helper should find the active chapter transition overlay through OverlayManager.")
	if transition_node != null and transition_node is CanvasItem:
		_assert_true((transition_node as CanvasItem).visible, "Capture helper should return the visible chapter transition node.")

	world.queue_free()
	await _wait_frames(2)

	if _failures.is_empty():
		print("CAPTURE_WORLD_RENDER_CONTRACT_OK")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _wait_frames(count: int) -> void:
	for _index in range(count):
		await process_frame
