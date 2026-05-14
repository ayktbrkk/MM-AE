extends SceneTree

const MAX_MARKER_TEXT_LENGTH := 96
const MAX_GOAL_TEXT_LENGTH := 86

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var world_scene: PackedScene = load("res://scenes/world.tscn")
	var world := world_scene.instantiate()
	root.add_child(world)
	await _wait_frames(6)

	var zone_mod: Node = world.get_node("WorldZone")
	var state: Node = world.get_node("WorldState")
	var markers: Node = world.get_node("Markers")
	var ui_mod: Node = world.get_node("WorldUI")

	zone_mod.call("_setup_bandirma")
	await _wait_frames(100)
	_hide_all_overlays(ui_mod)
	await _wait_frames(2)

	_assert_true(String(state.get("current_goal_text")).length() <= MAX_GOAL_TEXT_LENGTH, "Bandırma opening goal should stay short enough for mobile HUD.")

	for marker in markers.get_children():
		if not marker is Node2D:
			continue
		var kind := String(marker.get_meta("kind", ""))
		if kind not in ["ship_clue", "npc", "decision"]:
			continue
		var marker_text := String(marker.get_meta("text", ""))
		_assert_true(marker_text.length() <= MAX_MARKER_TEXT_LENGTH, "Bandırma marker text is too long: %s" % String(marker.get_meta("title", "")))

	world.queue_free()
	await _wait_frames(2)

	if _failures.is_empty():
		print("BANDIRMA_COPY_CONTRACT_OK")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _hide_all_overlays(ui_mod: Node) -> void:
	var overlay_manager = ui_mod.get("_overlay_manager")
	if overlay_manager != null and overlay_manager.has_method("hide_all"):
		overlay_manager.call("hide_all")


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _wait_frames(count: int) -> void:
	for _index in range(count):
		await process_frame
