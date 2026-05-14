extends SceneTree

const MAX_GOAL_CHARS := 64
const ZONES := [
	{"zone": "ankara", "setup": "_setup_ankara"},
	{"zone": "sakarya", "setup": "_setup_sakarya"},
	{"zone": "final", "setup": "_setup_final"},
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for config in ZONES:
		await _validate_zone(String(config["zone"]), String(config["setup"]))

	if _failures.is_empty():
		print("P5_LATE_ZONE_BENCHMARK_CONTRACT_OK")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _validate_zone(zone: String, setup_method: String) -> void:
	var world_scene: PackedScene = load("res://scenes/world.tscn")
	var world := world_scene.instantiate()
	root.add_child(world)
	await _wait_frames(6)

	var zone_mod: Node = world.get_node("WorldZone")
	var state: Node = world.get_node("WorldState")
	var ui_mod: Node = world.get_node("WorldUI")

	zone_mod.call(setup_method)
	await _wait_frames(80)
	_hide_all_overlays(ui_mod)
	ui_mod.call("update_guidance_arrow")
	await _wait_frames(4)

	var goal_text := String(state.get("current_goal_text"))
	_assert_true(goal_text.length() <= MAX_GOAL_CHARS, "%s intro goal should stay short enough for the HUD." % zone)
	_assert_true(not goal_text.contains("açıldı"), "%s intro goal should describe the next action, not announce the mode." % zone)
	_assert_true(not bool(ui_mod.call("is_objective_hint_visible")), "%s should not duplicate the HUD objective in a hint panel." % zone)
	_assert_true(not _has_visible_location_sign(world), "%s should not stack a location sign under the HUD objective." % zone)
	_assert_guidance_label_hidden(world, "%s should keep guidance visual-only in benchmark captures." % zone)
	_assert_named_canvas_hidden(world, "RoutePanel", "%s route HUD should stay hidden in P5 benchmark captures." % zone)
	_assert_named_canvas_hidden(world, "MinimapPanel", "%s minimap should stay hidden in P5 benchmark captures." % zone)
	if zone == "final":
		var republic_note := _find_marker(world.get_node("Markers"), "Cumhuriyet Notu")
		_assert_true(republic_note != null and republic_note.position.x >= 560.0 and republic_note.position.y >= 820.0, "final Cumhuriyet Notu should stay below the HUD-safe gameplay band.")

	world.queue_free()
	await _wait_frames(2)


func _hide_all_overlays(ui_mod: Node) -> void:
	var overlay_manager = ui_mod.get("_overlay_manager")
	if overlay_manager != null and overlay_manager.has_method("hide_all"):
		overlay_manager.call("hide_all")


func _has_visible_location_sign(node: Node) -> bool:
	if node is CanvasItem and node.has_meta("asset_slot") and String(node.get_meta("asset_slot", "")).contains("location_sign"):
		return bool((node as CanvasItem).visible)
	for child in node.get_children():
		if _has_visible_location_sign(child):
			return true
	return false


func _find_marker(markers: Node, title: String) -> Node2D:
	for marker in markers.get_children():
		if marker is Node2D and String(marker.get_meta("title", "")) == title:
			return marker as Node2D
	return null


func _assert_named_canvas_hidden(root_node: Node, node_name: String, message: String) -> void:
	var found := root_node.find_child(node_name, true, false)
	if found == null:
		return
	if found is CanvasItem:
		_assert_true(not bool((found as CanvasItem).visible), message)


func _assert_guidance_label_hidden(world: Node, message: String) -> void:
	var label_panel := world.get_node_or_null("Player/GuidanceArrow/GuidanceLabelPanel")
	if label_panel == null:
		return
	if label_panel is CanvasItem:
		_assert_true(not bool((label_panel as CanvasItem).visible), message)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _wait_frames(count: int) -> void:
	for _index in range(count):
		await process_frame
