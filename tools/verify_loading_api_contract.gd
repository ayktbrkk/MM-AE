extends SceneTree

var _failed := false


func _initialize() -> void:
	var save_manager: Node = root.get_node_or_null("SaveManager")
	_assert_true(save_manager != null, "SaveManager autoload should be available during loading contract verification")
	if save_manager == null:
		quit(1)
		return
	var overlay: CanvasLayer = load("res://scenes/loading_overlay.tscn").instantiate()
	root.add_child(overlay)
	await process_frame

	var request := {
		"target_scene": "res://scenes/world.tscn",
		"entry_action": "continue",
		"title": "Test Yukleme",
		"hint_text": "Ipuclari hazirlaniyor...",
	}
	_assert_true(overlay.stage_request(request), "Loading overlay should accept a valid staged request")
	var staged_request: Dictionary = overlay.get_loading_request()
	_assert_equal(staged_request.get("target_scene", ""), "res://scenes/world.tscn", "Loading request target_scene mismatch")
	_assert_equal(staged_request.get("entry_action", ""), "continue", "Loading request entry_action mismatch")
	_assert_equal(staged_request.get("title", ""), "Test Yukleme", "Loading request title mismatch")
	_assert_equal(staged_request.get("hint_text", ""), "Ipuclari hazirlaniyor...", "Loading request hint_text mismatch")
	overlay.call("_apply_entry_context")
	_assert_equal(String(save_manager.get("pending_entry_action")), "continue", "Loading overlay should forward entry_action into SaveManager")
	save_manager.set("pending_entry_action", "")
	await _validate_threaded_preload(overlay)
	_assert_true(not overlay.stage_request({}), "Loading overlay should reject an empty request")

	await _dispose_node(overlay)
	if _failed:
		quit(1)
		return
	print("LOADING_CONTRACT_EXIT=0")
	quit()


func _validate_threaded_preload(overlay: CanvasLayer) -> void:
	var threaded_request := {
		"target_scene": "res://scenes/exit_confirm_overlay.tscn",
		"title": "Threaded Test",
		"hint_text": "Threaded preload deneniyor...",
	}
	_assert_true(overlay.stage_request(threaded_request), "Loading overlay should stage a threaded preload request")
	_assert_true(overlay.call("_begin_threaded_load_request"), "Loading overlay should start a threaded preload request")
	var status := ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	for _attempt in range(180):
		var snapshot: Dictionary = overlay.call("_read_threaded_load_snapshot")
		status = int(snapshot.get("status", ResourceLoader.THREAD_LOAD_INVALID_RESOURCE))
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			break
		if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			break
		await process_frame
	_assert_equal(status, ResourceLoader.THREAD_LOAD_LOADED, "Loading overlay should finish threaded preloading for a valid scene")
	var loaded_scene: PackedScene = overlay.call("_consume_loaded_scene")
	_assert_true(loaded_scene != null, "Loading overlay should expose the loaded PackedScene after threaded preloading")
	loaded_scene = null
	overlay.call("_clear_request_state")


func _wait_frames(count: int) -> void:
	for _step in range(count):
		await process_frame


func _dispose_node(node: Node) -> void:
	if node == null:
		return
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	node.queue_free()
	await _wait_frames(3)


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failed = true
		push_error(message)


func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failed = true
		push_error("%s\nExpected: %s\nActual: %s" % [message, str(expected), str(actual)])