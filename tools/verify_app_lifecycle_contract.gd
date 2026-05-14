extends SceneTree

var _failed := false
var _save_signal_count := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var save_manager := _save_manager()
	if save_manager != null and not save_manager.game_saved.is_connected(_on_game_saved):
		save_manager.game_saved.connect(_on_game_saved)
	await _verify_world_pause_resume()
	await _verify_main_menu_pause_resume()
	await _verify_main_menu_dream_intro_pause_resume()
	await _verify_main_menu_cancel_during_transition()
	await _verify_loading_overlay_cancellation()
	if _failed:
		quit(1)
		return
	print("APP_LIFECYCLE_CONTRACT_OK")
	quit(0)


func _verify_world_pause_resume() -> void:
	var world: Node = load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	await process_frame
	await process_frame
	var world_ui: Node = world.get_node("WorldUI")
	world_ui.call("show_exit_confirm")
	await process_frame
	_assert_true(bool(world_ui.call("is_exit_confirm_visible")), "World pause precondition: exit confirm gorunur olmali.")
	var save_count_before := _save_signal_count
	world.call("_handle_application_pause")
	await process_frame
	_assert_true(_save_signal_count > save_count_before, "World pause lifecycle autosave tetiklemeli.")
	_assert_true(not bool(world_ui.call("is_exit_confirm_visible")), "World pause lifecycle exit confirm overlay'ini gizlemeli.")
	_assert_true(bool(_audio_manager().call("is_app_paused")), "World pause lifecycle AudioManager'i paused duruma almali.")
	world.call("_handle_application_resume")
	await process_frame
	_assert_true(not bool(_audio_manager().call("is_app_paused")), "World resume lifecycle AudioManager'i aktif duruma getirmeli.")
	world.queue_free()
	await process_frame


func _verify_main_menu_pause_resume() -> void:
	var menu: Control = load("res://scenes/main_menu.tscn").instantiate()
	root.add_child(menu)
	await process_frame
	menu.call("_on_settings_pressed")
	menu.call("_on_exit_pressed")
	await process_frame
	var settings_overlay: Control = menu.get("settings_overlay")
	var exit_dialog: CanvasLayer = menu.get("_exit_dialog")
	_assert_true(settings_overlay.visible, "Menu pause precondition: settings overlay gorunur olmali.")
	_assert_true(exit_dialog.visible, "Menu pause precondition: exit confirm gorunur olmali.")
	menu.call("_handle_application_pause")
	await process_frame
	_assert_true(not settings_overlay.visible, "Menu pause lifecycle settings overlay'ini gizlemeli.")
	_assert_true(not exit_dialog.visible, "Menu pause lifecycle exit confirm overlay'ini gizlemeli.")
	_assert_true(bool(_audio_manager().call("is_app_paused")), "Menu pause lifecycle AudioManager'i paused duruma almali.")
	menu.call("_handle_application_resume")
	await process_frame
	_assert_true(not bool(_audio_manager().call("is_app_paused")), "Menu resume lifecycle AudioManager'i aktif duruma getirmeli.")
	var save_manager := _save_manager()
	var expected_continue_disabled := save_manager == null or not bool(save_manager.call("has_save"))
	var continue_button: Button = menu.get("continue_button")
	_assert_true(continue_button.disabled == expected_continue_disabled, "Menu resume lifecycle continue button durumunu save varligina gore yenilemeli.")
	menu.queue_free()
	await process_frame


func _verify_main_menu_dream_intro_pause_resume() -> void:
	var menu: Control = load("res://scenes/main_menu.tscn").instantiate()
	root.add_child(menu)
	await process_frame
	menu.call("_on_start_pressed")
	await process_frame
	var dream_intro: Control = menu.get("dream_intro_overlay")
	_assert_true(dream_intro.visible, "Dream intro lifecycle precondition: intro gorunur olmali.")
	_assert_true(bool(menu.get("is_transitioning")), "Dream intro lifecycle precondition: menu transitioning durumda olmali.")
	menu.call("_handle_application_pause")
	await process_frame
	_assert_true(not dream_intro.visible, "Menu pause lifecycle dream intro overlay'ini iptal etmeli.")
	_assert_true(not bool(menu.get("is_transitioning")), "Menu pause lifecycle pending world transition durumunu temizlemeli.")
	var start_button: Button = menu.get("start_button")
	_assert_true(not start_button.disabled, "Menu pause lifecycle iptal sonrasi menu butonlarini tekrar acmali.")
	menu.call("_handle_application_resume")
	await process_frame
	_assert_true(not bool(_audio_manager().call("is_app_paused")), "Dream intro resume sonrasi AudioManager aktif olmali.")
	menu.queue_free()
	await process_frame


func _verify_main_menu_cancel_during_transition() -> void:
	var menu: Control = load("res://scenes/main_menu.tscn").instantiate()
	root.add_child(menu)
	await process_frame
	menu.call("_on_start_pressed")
	await process_frame
	var cancel_event := InputEventAction.new()
	cancel_event.action = "ui_cancel"
	cancel_event.pressed = true
	menu.call("_input", cancel_event)
	await process_frame
	var dream_intro: Control = menu.get("dream_intro_overlay")
	var exit_dialog: CanvasLayer = menu.get("_exit_dialog")
	_assert_true(not bool(menu.get("is_transitioning")), "Menu cancel lifecycle dream-intro sirasinda pending transition'i temizlemeli.")
	_assert_true(not dream_intro.visible, "Menu cancel lifecycle dream-intro overlay'ini kapatmali.")
	_assert_true(not exit_dialog.visible, "Menu cancel lifecycle gecis sirasinda exit dialog acmamali.")
	var start_button: Button = menu.get("start_button")
	_assert_true(not start_button.disabled, "Menu cancel lifecycle iptal sonrasi menu butonlarini tekrar acmali.")
	menu.queue_free()
	await process_frame


func _verify_loading_overlay_cancellation() -> void:
	var overlay: CanvasLayer = load("res://scenes/loading_overlay.tscn").instantiate()
	root.add_child(overlay)
	await process_frame
	overlay.call("show_overlay", {
		"target_scene": "res://scenes/world.tscn",
		"entry_action": "start",
		"title": "Bandirma Yolculugu",
		"hint_text": "Hazirlaniyor",
	})
	await process_frame
	await process_frame
	_assert_true(bool(overlay.call("has_active_request")), "Loading lifecycle precondition: request aktif olmali.")
	overlay.call("cancel_pending_request")
	await process_frame
	for _index in range(90):
		if not bool(overlay.call("has_background_drain")):
			break
		await process_frame
	_assert_true(not bool(overlay.call("has_active_request")), "Loading lifecycle cancel pending request durumunu temizlemeli.")
	_assert_true(not bool(overlay.call("has_background_drain")), "Loading lifecycle iptal sonrasi threaded request drain edilmeli.")
	_assert_true(not overlay.visible, "Loading lifecycle cancel overlay'i gizlemeli.")
	overlay.queue_free()
	await process_frame


func _on_game_saved(_path: String) -> void:
	_save_signal_count += 1


func _assert_true(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)


func _save_manager() -> Node:
	return root.get_node_or_null("SaveManager")


func _audio_manager() -> Node:
	return root.get_node_or_null("AudioManager")