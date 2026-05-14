extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var world_scene: PackedScene = load("res://scenes/world.tscn")
	var world := world_scene.instantiate()
	root.add_child(world)
	await _wait_frames(6)

	var zone_mod: Node = world.get_node("WorldZone")
	var ui_mod: Node = world.get_node("WorldUI")
	var player: Node2D = world.get_node("Player")
	var markers: Node = world.get_node("Markers")

	zone_mod.call("_setup_bandirma")
	await _wait_frames(100)
	_hide_all_overlays(ui_mod)
	await _wait_frames(2)

	var decision_marker := _find_marker(markers, "decision")
	_assert_true(decision_marker != null, "Bandırma should expose a decision marker.")
	if decision_marker != null:
		player.global_position = decision_marker.global_position + Vector2(30, 0)
		zone_mod.call("set_goal", "decision", "Samsun Kararı işaretine git.")
		ui_mod.call("update_guidance_arrow")
		await _wait_frames(2)

		var guidance_arrow: Node2D = world.get_node("Player/GuidanceArrow")
		var label_panel := guidance_arrow.get_node_or_null("GuidanceLabelPanel")
		_assert_true(not guidance_arrow.visible, "Guidance arrow should hide when the target is already near.")
		_assert_true(label_panel != null and not bool(label_panel.get("visible")), "Guidance label panel should hide with the near-target arrow.")

	world.queue_free()
	await _wait_frames(2)

	if _failures.is_empty():
		print("BANDIRMA_GUIDANCE_CONTRACT_OK")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _find_marker(markers: Node, marker_kind: String) -> Node2D:
	for marker in markers.get_children():
		if marker is Node2D and String(marker.get_meta("kind", "")) == marker_kind:
			return marker as Node2D
	return null


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
