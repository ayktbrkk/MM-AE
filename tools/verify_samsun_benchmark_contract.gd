extends SceneTree

const MAX_SAMSUN_GOAL_CHARS := 64
const PEOPLE_MARKER_POS := Vector2(430, 1560)
const WAVE_MARKER_POS := Vector2(930, 1490)
const ASSET_ALIGNMENT_TOLERANCE := 60.0

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
	var ui_mod: Node = world.get_node("WorldUI")
	var markers: Node = world.get_node("Markers")

	zone_mod.call("_setup_samsun_rift")
	await _wait_frames(120)

	var goal_text := String(state.get("current_goal_text"))
	_assert_true(goal_text.length() <= MAX_SAMSUN_GOAL_CHARS, "Samsun intro goal should stay short enough for HUD + objective hint.")
	_assert_true(not goal_text.contains("açıldı"), "Samsun intro goal should describe the next action, not announce the mode.")
	_assert_true(not bool(ui_mod.call("is_objective_hint_visible")), "Samsun benchmark should not duplicate the same goal in the objective hint.")
	_assert_true(not _has_visible_location_sign(world), "Samsun benchmark should not stack the location sign under the HUD objective.")

	var people_marker := _find_marker(markers, "Halk Destek Noktası")
	var wave_marker := _find_marker(markers, "Kararsızlık Dalgası")
	_assert_near(people_marker, PEOPLE_MARKER_POS, "Halk Destek Noktası marker should stay in the separated lower-left band.")
	_assert_near(wave_marker, WAVE_MARKER_POS, "Kararsızlık Dalgası marker should stay in the separated lower-right band.")

	var people_asset := _find_asset_slot(world, "paperworld.samsun_people_plaza")
	var wave_asset := _find_asset_slot(world, "paperworld.samsun_wave_gate")
	_assert_near(people_asset, PEOPLE_MARKER_POS, "Samsun people paper asset should align with the Halk marker.")
	_assert_near(wave_asset, WAVE_MARKER_POS, "Samsun wave gate paper asset should align with the Dalga marker.")

	world.queue_free()
	await _wait_frames(2)

	if _failures.is_empty():
		print("SAMSUN_BENCHMARK_CONTRACT_OK")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _find_marker(markers: Node, label: String) -> Node2D:
	for marker in markers.get_children():
		if marker is Node2D and String(marker.get_meta("title", "")) == label:
			return marker as Node2D
	return null


func _find_asset_slot(node: Node, slot_id: String) -> Node2D:
	if node is Node2D and String(node.get_meta("asset_slot", "")) == slot_id:
		return node as Node2D
	for child in node.get_children():
		var found := _find_asset_slot(child, slot_id)
		if found != null:
			return found
	return null


func _has_visible_location_sign(node: Node) -> bool:
	if node is CanvasItem and node.has_meta("asset_slot") and String(node.get_meta("asset_slot", "")).contains("location_sign"):
		return bool((node as CanvasItem).visible)
	for child in node.get_children():
		if _has_visible_location_sign(child):
			return true
	return false


func _assert_near(node: Node2D, expected: Vector2, message: String) -> void:
	if node == null:
		_failures.append("%s Node bulunamadı." % message)
		return
	if node.global_position.distance_to(expected) > ASSET_ALIGNMENT_TOLERANCE:
		_failures.append("%s Beklenen=%s Gerçek=%s" % [message, expected, node.global_position])


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _wait_frames(count: int) -> void:
	for _index in range(count):
		await process_frame
