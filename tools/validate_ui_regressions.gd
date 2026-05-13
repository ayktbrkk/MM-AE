extends SceneTree

const READY_FRAMES := 8
const OVERLAY_DIALOGUE := 0
const OVERLAY_INFO_CARD := 2
const OVERLAY_EXIT_CONFIRM := 5


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var save_manager: Node = root.get_node_or_null("SaveManager")
	if save_manager != null and bool(save_manager.call("has_save")):
		save_manager.set("pending_entry_action", "continue")
	var world_scene: PackedScene = load("res://scenes/world.tscn") as PackedScene
	if world_scene == null:
		push_error("UI regression check: world.tscn yuklenemedi.")
		quit(1)
		return
	var world: Node = world_scene.instantiate()
	root.add_child(world)
	await _wait_frames(READY_FRAMES)

	var world_ui: Node = world.get_node_or_null("WorldUI")
	if world_ui == null:
		push_error("UI regression check: WorldUI bulunamadi.")
		quit(1)
		return

	var overlay_manager: Node = world_ui.call("get_overlay_manager")
	if overlay_manager == null:
		push_error("UI regression check: OverlayManager bulunamadi.")
		quit(1)
		return

	if not await _validate_back_button(world, overlay_manager):
		quit(1)
		return

	if not await _validate_overlay_stack(world_ui, overlay_manager):
		quit(1)
		return

	print("UI_REGRESSION_VALIDATION_OK")
	quit(0)


func _validate_back_button(world: Node, overlay_manager: Node) -> bool:
	var back_event := InputEventAction.new()
	back_event.action = "ui_cancel"
	back_event.pressed = true

	world.call("_unhandled_input", back_event)
	await _wait_frames(2)
	if not bool(overlay_manager.call("is_visible", OVERLAY_EXIT_CONFIRM)):
		push_error("UI regression check: geri tusu exit confirm overlay'ini acmadi.")
		return false

	world.call("_unhandled_input", back_event)
	await _wait_frames(2)
	if bool(overlay_manager.call("is_visible", OVERLAY_EXIT_CONFIRM)):
		push_error("UI regression check: ikinci geri tusu exit confirm overlay'ini kapatmadi.")
		return false

	return true


func _validate_overlay_stack(world_ui: Node, overlay_manager: Node) -> bool:
	world_ui.call("show_dialogue", "Test", "Overlay stack kontrolu", Callable())
	await _wait_frames(2)
	if int(overlay_manager.call("get_active")) != OVERLAY_DIALOGUE:
		push_error("UI regression check: diyalog overlay'i aktif olmadi.")
		return false

	world_ui.call("show_info_card", "Bilgi", "Stack geri donmeli", "Devam", Callable())
	await _wait_frames(2)
	if int(overlay_manager.call("get_active")) != OVERLAY_INFO_CARD:
		push_error("UI regression check: info card overlay'i aktif olmadi.")
		return false

	world_ui.call("close_dialogue")
	await _wait_frames(2)
	if int(overlay_manager.call("get_active")) != OVERLAY_DIALOGUE:
		push_error("UI regression check: info card kapatilinca diyalog overlay'i geri donmedi.")
		return false
	if not bool(overlay_manager.call("is_visible", OVERLAY_DIALOGUE)):
		push_error("UI regression check: geri donen diyalog overlay'i gorunur degil.")
		return false

	world_ui.call("close_dialogue")
	await _wait_frames(2)
	if bool(overlay_manager.call("is_visible", OVERLAY_DIALOGUE)):
		push_error("UI regression check: diyalog overlay'i kapanmadi.")
		return false

	return true


func _wait_frames(count: int) -> void:
	for _i in range(count):
		await process_frame