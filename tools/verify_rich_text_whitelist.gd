extends SceneTree

var _has_failed := false


func _initialize() -> void:
	var dialogue: Control = load("res://scenes/dialogue_overlay.tscn").instantiate()
	root.add_child(dialogue)
	var info_card: Control = load("res://scenes/info_card_overlay.tscn").instantiate()
	root.add_child(info_card)
	await process_frame

	dialogue.call("present", {
		"chapter": "Test",
		"speaker": "Arda",
		"text": "[b]Kalem[/b] [wave]yasak[/wave] [color=#3A7BD5]renk[/color]",
		"speaker_side": "left",
		"expression": "idle"
	})
	info_card.call("present", {
		"tag_text": "Test",
		"title": "Kart",
		"text": "[i]Bilgi[/i] [shake]yok[/shake] [color=#FFAA33]vurgu[/color]"
	})
	await process_frame

	var dialogue_body: RichTextLabel = dialogue.get_node("BottomArea/DialoguePanel/DialogueMargin/DialogueContent/BodyText")
	var info_body: RichTextLabel = info_card.get_node("Center/InfoCard/CardMargin/CardContent/BodyLabel")
	_assert_equal(
		dialogue_body.text,
		"[b]Kalem[/b] [lb]wave[rb]yasak[lb]/wave[rb] [color=#3A7BD5]renk[/color]",
		"Dialogue BBCode whitelist failed"
	)
	_assert_equal(
		dialogue_body.get_parsed_text(),
		"Kalem [wave]yasak[/wave] renk",
		"Dialogue parsed text mismatch"
	)
	_assert_equal(
		info_body.text,
		"[center][i]Bilgi[/i] [lb]shake[rb]yok[lb]/shake[rb] [color=#FFAA33]vurgu[/color][/center]",
		"Info card BBCode whitelist failed"
	)
	_assert_equal(
		info_body.get_parsed_text(),
		"Bilgi [shake]yok[/shake] vurgu",
		"Info card parsed text mismatch"
	)
	if _has_failed:
		quit(1)
		return
	print("RICH_TEXT_EXIT=0")
	quit()


func _assert_equal(actual: String, expected: String, message: String) -> void:
	if actual != expected:
		_has_failed = true
		push_error("%s\nExpected: %s\nActual: %s" % [message, expected, actual])