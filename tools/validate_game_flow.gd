extends SceneTree

const TEXTURES := preload("res://scripts/textures.gd")

var _failures: Array[String] = []
var _save_manager: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_save_manager = root.get_node_or_null("SaveManager")
	if _save_manager == null:
		push_error("SaveManager autoload bulunamadı.")
		quit(1)
		return

	var had_original_save := bool(_save_manager.call("has_save"))
	var original_save: Dictionary = _save_manager.call("load_game") if had_original_save else {}

	if not await _validate_new_game_flow():
		_failures.append("Yeni oyun akışı doğrulanamadı.")
	if not await _validate_continue_flow():
		_failures.append("Devam et akışı doğrulanamadı.")

	if had_original_save:
		_save_manager.call("save_game", original_save)
	else:
		_save_manager.call("delete_save")
	_save_manager.set("pending_entry_action", "")

	if _failures.is_empty():
		print("FLOW_VALIDATION_OK")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _validate_new_game_flow() -> bool:
	_save_manager.set("pending_entry_action", "start")
	var world_scene: PackedScene = load("res://scenes/world.tscn")
	var world := world_scene.instantiate()
	root.add_child(world)
	await _wait_frames(6)

	var state: Node = world.get_node("WorldState")
	var character_panel: PanelContainer = world.get_node("CanvasLayer/HUD/CharacterPanel")
	var player_mod: Node = world.get_node("WorldPlayer")
	var player_sprite: Sprite2D = world.get_node("Player/PlayerSprite")
	var companion_sprite: Sprite2D = world.get_node("Companion/CompanionSprite")
	var dialogue_overlay := world.find_child("DialogueOverlay", true, false)

	var ok := true
	if String(state.get("current_zone")) != "room":
		_failures.append("Yeni oyun room zone'unda başlamadı.")
		ok = false
	if not character_panel.visible:
		_failures.append("Yeni oyunda karakter seçimi paneli görünür değil.")
		ok = false

	player_mod.call("choose_hero", "eda")
	await _wait_frames(6)

	if String(state.get("selected_character")) != "eda":
		_failures.append("Karakter seçimi state'e yazılmadı.")
		ok = false
	if character_panel.visible:
		_failures.append("Karakter seçimi sonrası panel kapanmadı.")
		ok = false
	if player_sprite.texture != TEXTURES.EDA_TEXTURE:
		_failures.append("Oyuncu sprite'ı seçilen Eda texture'ına bağlanmadı.")
		ok = false
	if companion_sprite.texture != TEXTURES.ARDA_TEXTURE:
		_failures.append("Companion sprite'ı Arda texture'ına bağlanmadı.")
		ok = false
	if dialogue_overlay == null or not dialogue_overlay.visible:
		_failures.append("Karakter seçimi sonrası yönlendirici diyalog açılmadı.")
		ok = false

	world.queue_free()
	await _wait_frames(2)
	return ok


func _validate_continue_flow() -> bool:
	var save_data := {
		"selected_character": "arda",
		"current_zone": "havza",
		"current_goal_kind": "havza_clue",
		"current_goal_text": "Havza ipuçlarını topla ve genelge kararını ver.",
		"collected_items": {"havza_clues": 1},
		"total_items_in_zone": {"units": 3, "ship_clues": 2, "havza_clues": 2, "amasya_clues": 2, "kongre_clues": 2},
		"leadership_points": 2,
		"built_supports": 0,
		"required_supports": 2,
		"wave_attempts": 0,
		"hero_name": "Arda",
		"current_chapter": "Havza Genelgesi",
		"player_position": {"x": 812.0, "y": 1194.0},
		"companion_position": {"x": 944.0, "y": 1276.0},
	}
	_save_manager.call("save_game", save_data)
	_save_manager.set("pending_entry_action", "continue")

	var world_scene: PackedScene = load("res://scenes/world.tscn")
	var world := world_scene.instantiate()
	root.add_child(world)
	await _wait_frames(10)

	var state: Node = world.get_node("WorldState")
	var character_panel: PanelContainer = world.get_node("CanvasLayer/HUD/CharacterPanel")
	var objective_label: Label = world.get_node("CanvasLayer/HUD/HudBar/TopPanel/TopMargin/TopContent/ObjectiveLabel")
	var player_sprite: Sprite2D = world.get_node("Player/PlayerSprite")
	var player_node: Node2D = world.get_node("Player")
	var companion_node: Node2D = world.get_node("Companion")
	var markers: Node = world.get_node("Markers")

	var ok := true
	if String(state.get("current_zone")) != "havza":
		_failures.append("Continue akışı Havza zone'unu restore etmedi.")
		ok = false
	if character_panel.visible:
		_failures.append("Continue akışında karakter paneli açık kaldı.")
		ok = false
	if player_sprite.texture != TEXTURES.ARDA_TEXTURE:
		_failures.append("Continue akışında Arda sprite'ı restore edilmedi.")
		ok = false
	if player_node.position.distance_to(Vector2(812.0, 1194.0)) > 1.0:
		_failures.append("Continue akışında oyuncu pozisyonu restore edilmedi.")
		ok = false
	if companion_node.position.distance_to(player_node.position) < 60.0:
		_failures.append("Continue akışında companion oyuncunun üstüne bindi.")
		ok = false
	if objective_label.text != "Havza ipuçlarını topla ve genelge kararını ver.":
		_failures.append("Continue akışında objective metni restore edilmedi.")
		ok = false
	if markers.get_child_count() == 0:
		_failures.append("Continue akışında zone marker'ları yeniden kurulmadı.")
		ok = false

	world.queue_free()
	await _wait_frames(2)
	return ok


func _wait_frames(count: int) -> void:
	for _index in range(count):
		await process_frame