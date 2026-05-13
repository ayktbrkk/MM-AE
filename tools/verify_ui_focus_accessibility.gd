extends SceneTree

var _failed := false


func _initialize() -> void:
	await _verify_main_menu()
	await _verify_decision_overlay()
	await _verify_info_card_overlay()
	await _verify_dialogue_overlay()
	if _failed:
		quit(1)
		return
	print("UI_FOCUS_EXIT=0")
	quit()


func _verify_main_menu() -> void:
	var menu: Control = load("res://scenes/main_menu.tscn").instantiate()
	root.add_child(menu)
	await process_frame
	await process_frame
	_assert_focus(menu.start_button, "Main menu should default focus the start button")
	_assert_path(menu.start_button.focus_neighbor_bottom, menu.continue_button.get_path(), "Main menu should wire start -> continue")
	menu.call("_on_settings_pressed")
	await process_frame
	_assert_focus(menu.bgm_slider, "Settings overlay should focus the BGM slider")
	_assert_path(menu.bgm_slider.focus_neighbor_bottom, menu.sfx_slider.get_path(), "Settings focus should move BGM -> SFX")
	menu.call("_hide_settings_overlay")
	await process_frame
	_assert_focus(menu.settings_button, "Closing settings should restore focus to settings")
	menu.queue_free()
	await process_frame


func _verify_decision_overlay() -> void:
	var decision: Control = load("res://scenes/decision_overlay.tscn").instantiate()
	root.add_child(decision)
	await process_frame
	decision.call("present", {
		"context": "verify",
		"chapter": "Karar",
		"title": "Secim",
		"prompt": "Hangisi once ilerlemeli?"
	})
	await process_frame
	var arda_button: Button = decision.get_node("Center/DecisionPanel/DecisionMargin/DecisionContent/ChoiceRow/ArdaButton")
	var eda_button: Button = decision.get_node("Center/DecisionPanel/DecisionMargin/DecisionContent/ChoiceRow/EdaButton")
	_assert_focus(arda_button, "Decision overlay should focus the first choice")
	_assert_path(arda_button.focus_neighbor_bottom, eda_button.get_path(), "Decision focus should move Arda -> Eda")
	decision.queue_free()
	await process_frame


func _verify_info_card_overlay() -> void:
	var info_card: Control = load("res://scenes/info_card_overlay.tscn").instantiate()
	root.add_child(info_card)
	await process_frame
	info_card.call("present", {
		"title": "Kart",
		"text": "Bilgi karti metni"
	})
	await process_frame
	var back_button: Button = info_card.get_node("Center/InfoCard/CardMargin/CardContent/ActionRow/BackButton")
	var continue_button: Button = info_card.get_node("Center/InfoCard/CardMargin/CardContent/ActionRow/ContinueButton")
	_assert_focus(continue_button, "Info card should focus the continue action")
	_assert_path(back_button.focus_neighbor_right, continue_button.get_path(), "Info card focus should move back -> continue")
	info_card.set_meta("closed_by_cancel", false)
	info_card.continue_pressed.connect(func() -> void:
		info_card.set_meta("closed_by_cancel", true)
	)
	var cancel_event := InputEventAction.new()
	cancel_event.action = &"ui_cancel"
	cancel_event.pressed = true
	info_card.call("_input", cancel_event)
	await process_frame
	_assert_true(bool(info_card.get_meta("closed_by_cancel", false)), "Info card should close on ui_cancel")
	info_card.queue_free()
	await process_frame


func _verify_dialogue_overlay() -> void:
	var dialogue: Control = load("res://scenes/dialogue_overlay.tscn").instantiate()
	root.add_child(dialogue)
	await process_frame
	dialogue.call("present", {
		"chapter": "Bolum",
		"speaker": "Arda",
		"text": "Uzun diyalog metni burada acilarak gelmeli.",
		"speaker_side": "left"
	})
	await process_frame
	var body_label: RichTextLabel = dialogue.get_node("BottomArea/DialoguePanel/DialogueMargin/DialogueContent/BodyText")
	_assert_true(body_label.visible_ratio < 0.98, "Dialogue should begin partially revealed")
	dialogue.set_meta("continued_from_accept", false)
	dialogue.continue_pressed.connect(func() -> void:
		dialogue.set_meta("continued_from_accept", true)
	)
	var accept_event := InputEventAction.new()
	accept_event.action = &"ui_accept"
	accept_event.pressed = true
	dialogue.call("_input", accept_event)
	await process_frame
	_assert_true(body_label.visible_ratio >= 0.98, "Dialogue should reveal fully on ui_accept")
	var confirm_event := InputEventAction.new()
	confirm_event.action = &"ui_accept"
	confirm_event.pressed = true
	dialogue.call("_input", confirm_event)
	await process_frame
	_assert_true(bool(dialogue.get_meta("continued_from_accept", false)), "Dialogue should continue on second ui_accept")
	dialogue.queue_free()
	await process_frame


func _assert_focus(expected: Control, message: String) -> void:
	var focus_owner := expected.get_viewport().gui_get_focus_owner()
	if focus_owner != expected:
		_fail("%s\nExpected: %s\nActual: %s" % [message, expected.name, "<none>" if focus_owner == null else focus_owner.name])


func _assert_path(actual: NodePath, expected: NodePath, message: String) -> void:
	if str(actual) != str(expected):
		_fail("%s\nExpected: %s\nActual: %s" % [message, str(expected), str(actual)])


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_fail(message)


func _fail(message: String) -> void:
	_failed = true
	push_error(message)