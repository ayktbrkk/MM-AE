extends SceneTree

var _failed := false


class DummyOverlay:
	extends Control

	func show_overlay(_config: Dictionary = {}) -> void:
		visible = true

	func hide_overlay() -> void:
		visible = false


func _initialize() -> void:
	var manager := OverlayManager.new()
	root.add_child(manager)
	var overlays := {
		OverlayManager.OverlayType.DIALOGUE: _make_overlay(manager, OverlayManager.OverlayType.DIALOGUE),
		OverlayManager.OverlayType.DECISION: _make_overlay(manager, OverlayManager.OverlayType.DECISION),
		OverlayManager.OverlayType.INFO_CARD: _make_overlay(manager, OverlayManager.OverlayType.INFO_CARD),
		OverlayManager.OverlayType.CHAPTER_TRANSITION: _make_overlay(manager, OverlayManager.OverlayType.CHAPTER_TRANSITION),
		OverlayManager.OverlayType.EXIT_CONFIRM: _make_overlay(manager, OverlayManager.OverlayType.EXIT_CONFIRM),
		OverlayManager.OverlayType.LOADING: _make_overlay(manager, OverlayManager.OverlayType.LOADING),
	}
	await process_frame

	_assert_equal(overlays[OverlayManager.OverlayType.DIALOGUE].process_mode, Node.PROCESS_MODE_ALWAYS, "Dialogue process_mode contract mismatch")
	_assert_equal(overlays[OverlayManager.OverlayType.DECISION].process_mode, Node.PROCESS_MODE_ALWAYS, "Decision process_mode contract mismatch")
	_assert_equal(overlays[OverlayManager.OverlayType.CHAPTER_TRANSITION].process_mode, Node.PROCESS_MODE_ALWAYS, "Chapter transition process_mode contract mismatch")
	_assert_equal(overlays[OverlayManager.OverlayType.LOADING].process_mode, Node.PROCESS_MODE_ALWAYS, "Loading process_mode contract mismatch")

	manager.show(OverlayManager.OverlayType.DIALOGUE, {})
	_assert_true(manager.active_blocks_world_input(), "Dialogue should block world input")
	_assert_true(manager.has_closeable_active_overlay(), "Dialogue should be closeable on cancel")
	_assert_equal(manager.hide_active_closeable_overlay(), OverlayManager.OverlayType.DIALOGUE, "Dialogue should be hideable via the active closeable contract")
	_assert_true(not manager.active_blocks_world_input(), "No overlay should block input after hiding dialogue")

	manager.show(OverlayManager.OverlayType.DECISION, {})
	_assert_true(manager.active_blocks_world_input(), "Decision should block world input")
	_assert_true(not manager.has_closeable_active_overlay(), "Decision should not be closeable on cancel")
	manager.hide(OverlayManager.OverlayType.DECISION)

	manager.show(OverlayManager.OverlayType.CHAPTER_TRANSITION, {})
	_assert_true(manager.active_blocks_world_input(), "Chapter transition should block world input")
	_assert_true(not manager.has_closeable_active_overlay(), "Chapter transition should not be closeable on cancel")
	_assert_true(manager.is_effectively_visible(OverlayManager.OverlayType.CHAPTER_TRANSITION), "Chapter transition should be effectively visible when shown")
	overlays[OverlayManager.OverlayType.CHAPTER_TRANSITION].visible = false
	_assert_true(not manager.is_effectively_visible(OverlayManager.OverlayType.CHAPTER_TRANSITION), "Effective visibility should follow the overlay node visibility")
	manager.hide(OverlayManager.OverlayType.CHAPTER_TRANSITION)

	manager.show(OverlayManager.OverlayType.INFO_CARD, {})
	manager.show(OverlayManager.OverlayType.EXIT_CONFIRM, {})
	_assert_true(manager.active_blocks_world_input(), "Exit confirm should block world input while active")
	_assert_true(not manager.has_closeable_active_overlay(), "Exit confirm should stay outside the closeable-overlay contract")
	manager.hide(OverlayManager.OverlayType.EXIT_CONFIRM)
	_assert_true(manager.has_closeable_active_overlay(), "Hiding exit confirm should restore the stacked info card as the active closeable overlay")

	manager.hide_all()
	await process_frame
	if _failed:
		quit(1)
		return
	print("OVERLAY_CONTRACT_EXIT=0")
	quit()


func _make_overlay(manager: OverlayManager, overlay_type: int) -> Control:
	var overlay := DummyOverlay.new()
	overlay.name = "DummyOverlay%d" % overlay_type
	overlay.visible = false
	root.add_child(overlay)
	manager.register_overlay(overlay_type, overlay)
	return overlay


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failed = true
		push_error(message)


func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failed = true
		push_error("%s\nExpected: %s\nActual: %s" % [message, str(expected), str(actual)])