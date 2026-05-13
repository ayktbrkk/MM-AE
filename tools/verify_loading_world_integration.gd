extends SceneTree

var _failed := false


class DummyOverlay:
	extends Control

	func show_overlay(_config: Dictionary = {}) -> void:
		visible = true

	func hide_overlay() -> void:
		visible = false


class DummyWorldUI:
	extends WorldUI

	var objective_text := ""
	var info_card_payload := {}
	var completion_callback: Callable
	var loading_request := {}

	func update_objective(text: String) -> void:
		objective_text = text

	func show_info_card(title: String, text: String, reward_text: String, callback: Callable, card_kind := "resource") -> void:
		info_card_payload = {
			"title": title,
			"text": text,
			"reward_text": reward_text,
			"card_kind": card_kind,
		}
		completion_callback = callback

	func show_loading_request(request: Dictionary) -> bool:
		loading_request = request.duplicate(true)
		return true


func _initialize() -> void:
	var save_manager: Node = root.get_node_or_null("SaveManager")
	_assert_true(save_manager != null, "SaveManager autoload should be available during world integration verification")
	if save_manager == null:
		quit(1)
		return
	await _validate_world_ui_loading_registration()
	await _validate_world_completion_transition(save_manager)
	if _failed:
		quit(1)
		return
	print("LOADING_WORLD_INTEGRATION_EXIT=0")
	quit()


func _validate_world_ui_loading_registration() -> void:
	var harness := _build_world_ui_harness()
	var world: Node2D = harness.get("world")
	var world_ui: WorldUI = harness.get("world_ui")
	_assert_true(world != null, "WorldUI harness world should be created")
	_assert_true(world_ui != null, "WorldUI harness should be created")
	if world == null or world_ui == null:
		return
	root.add_child(world)
	await _wait_frames(1)
	world_ui.initialize(world)
	await _wait_frames(2)
	var loading_overlay: Node = world_ui.get_loading_overlay()
	_assert_true(loading_overlay != null, "WorldUI should register a loading overlay with OverlayManager")
	if loading_overlay != null:
		var request := {
			"target_scene": "res://scenes/main_menu.tscn",
			"entry_action": "",
			"title": "Dunya Donusu",
			"hint_text": "Ana menu hazirlaniyor...",
		}
		_assert_true(world_ui.stage_loading_request(request), "WorldUI should expose the shared loading request contract")
		var staged_request: Dictionary = loading_overlay.call("get_loading_request")
		_assert_equal(staged_request.get("target_scene", ""), "res://scenes/main_menu.tscn", "WorldUI loading overlay target_scene mismatch")
	await _dispose_node(world)


func _validate_world_completion_transition(save_manager: Node) -> void:
	if bool(save_manager.call("has_save")):
		save_manager.call("delete_save")
	save_manager.call("save_game", {"selected_character": "arda", "current_zone": "final"})
	save_manager.set("pending_entry_action", "continue")
	var world := Node2D.new()
	world.name = "WorldZoneHarness"
	var world_ui := DummyWorldUI.new()
	world_ui.name = "WorldUI"
	world.add_child(world_ui)
	var zone_script: Script = load("res://scripts/world_zone.gd")
	var zone: Node = zone_script.new()
	zone.name = "WorldZone"
	world.add_child(zone)
	root.add_child(world)
	zone.call("initialize", world)
	zone.call("finish_prototype")
	_assert_equal(world_ui.objective_text, "Yolculuk tamamlandı: Cumhuriyet ilan edildi ve tarih akışı başarıyla korundu.", "Prototype completion should update the world objective")
	_assert_equal(String(world_ui.info_card_payload.get("reward_text", "")), "Ana menüye dön", "Prototype completion should present a return-to-menu info card")
	_assert_true(world_ui.completion_callback.is_valid(), "Prototype completion should provide a callback for returning to the main menu")
	if world_ui.completion_callback.is_valid():
		world_ui.completion_callback.call()
		_assert_equal(String(world_ui.loading_request.get("target_scene", "")), "res://scenes/main_menu.tscn", "Prototype completion should route back to the main menu through the shared loading request API")
		_assert_true(not bool(save_manager.call("has_save")), "Prototype completion should clear the active save before returning to the main menu")
	await _dispose_node(world)


func _build_world_ui_harness() -> Dictionary:
	var world := Node2D.new()
	world.name = "WorldHarness"
	var canvas := CanvasLayer.new()
	canvas.name = "CanvasLayer"
	world.add_child(canvas)
	var hud := Control.new()
	hud.name = "HUD"
	canvas.add_child(hud)
	var hud_bar := Control.new()
	hud_bar.name = "HudBar"
	hud.add_child(hud_bar)
	hud.add_child(_make_button("InteractButton"))
	hud.add_child(_make_character_panel())
	hud.add_child(_make_dialogue_panel())
	hud.add_child(_make_dummy_overlay("DialogueOverlay"))
	hud.add_child(_make_dummy_overlay("DecisionOverlay"))
	hud.add_child(_make_dummy_overlay("InfoCardOverlay"))
	hud.add_child(_make_dummy_overlay("ChapterTransitionOverlay"))
	var world_ui_script: Script = load("res://scripts/world_ui.gd")
	var world_ui: Node = world_ui_script.new()
	world_ui.name = "WorldUI"
	world.add_child(world_ui)
	return {
		"world": world,
		"world_ui": world_ui,
	}


func _make_character_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "CharacterPanel"
	var margin := MarginContainer.new()
	margin.name = "CharacterMargin"
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.name = "CharacterContent"
	margin.add_child(content)
	content.add_child(_make_label("CharacterTitle"))
	content.add_child(_make_label("CharacterText"))
	content.add_child(_make_button("ArdaButton"))
	content.add_child(_make_button("EdaButton"))
	return panel


func _make_dialogue_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "DialoguePanel"
	var margin := MarginContainer.new()
	margin.name = "DialogueMargin"
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.name = "DialogueContent"
	margin.add_child(content)
	content.add_child(_make_button("DialogueContinue"))
	return panel


func _make_dummy_overlay(name: String) -> Control:
	var overlay := DummyOverlay.new()
	overlay.name = name
	overlay.visible = false
	return overlay


func _make_button(name: String) -> Button:
	var button := Button.new()
	button.name = name
	return button


func _make_label(name: String) -> Label:
	var label := Label.new()
	label.name = name
	return label


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
