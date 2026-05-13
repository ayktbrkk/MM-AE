extends SceneTree

const DEFAULT_SIZE := Vector2i(923, 1287)
const DEFAULT_OUTPUT_DIR := "res://artifacts/renders/character_ui"

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var surface := "menu"
	var output_path := ""
	var viewport_size := DEFAULT_SIZE
	for index in range(args.size()):
		match args[index]:
			"--surface":
				if index + 1 < args.size():
					surface = args[index + 1]
			"--output":
				if index + 1 < args.size():
					output_path = args[index + 1]
			"--size":
				if index + 1 < args.size():
					var parts := args[index + 1].split("x")
					if parts.size() == 2:
						viewport_size = Vector2i(parts[0].to_int(), parts[1].to_int())
	if output_path == "":
		output_path = "%s/%s.png" % [DEFAULT_OUTPUT_DIR, surface]
	call_deferred("_capture_surface", surface, output_path, viewport_size)


func _capture_surface(surface: String, output_path: String, viewport_size: Vector2i) -> void:
	var viewport := SubViewport.new()
	viewport.name = "CharacterUICaptureViewport"
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = false
	viewport.size = viewport_size
	root.add_child(viewport)

	var scene := _build_surface(surface)
	if scene == null:
		push_error("Unknown or failed UI surface: %s" % surface)
		quit(1)
		return
	viewport.add_child(scene)

	for frame in range(24):
		await process_frame

	_finalize_surface(surface, scene)

	for frame in range(24):
		await process_frame

	RenderingServer.force_draw()
	await process_frame
	var image := viewport.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Could not capture UI surface image: %s" % surface)
		quit(1)
		return
	var absolute_output := ProjectSettings.globalize_path(output_path)
	var directory := absolute_output.get_base_dir()
	if not DirAccess.dir_exists_absolute(directory):
		DirAccess.make_dir_recursive_absolute(directory)
	var error := image.save_png(absolute_output)
	if error != OK:
		push_error("Could not save UI capture: %s" % output_path)
		quit(1)
		return
	print("Saved UI capture: %s" % absolute_output)
	quit()


func _build_surface(surface: String) -> Node:
	match surface:
		"menu":
			return load("res://scenes/main_menu.tscn").instantiate()
		"hud":
			return load("res://scenes/hud_bar.tscn").instantiate()
		"dialogue":
			var dialogue: Node = load("res://scenes/dialogue_overlay.tscn").instantiate()
			return dialogue
		"info_card":
			var info_card: Node = load("res://scenes/info_card_overlay.tscn").instantiate()
			return info_card
		"decision":
			var decision: Node = load("res://scenes/decision_overlay.tscn").instantiate()
			return decision
		"chapter_transition":
			var chapter_transition: Node = load("res://scenes/chapter_transition_overlay.tscn").instantiate()
			return chapter_transition
		"choice":
			return load("res://scenes/world.tscn").instantiate()
		_:
			return null


func _finalize_surface(surface: String, scene: Node) -> void:
	match surface:
		"menu":
			return
		"hud":
			if scene.has_method("apply_theme"):
				scene.call("apply_theme", Color(0.90, 0.97, 1.0), Color(0.04, 0.42, 0.56), Color(0.08, 0.48, 0.62), Color(0.04, 0.22, 0.32), Color(0.08, 0.48, 0.62))
			if scene.has_method("set_title"):
				scene.call("set_title", "Zaman Yolculari: Samsun Ruyasi")
			if scene.has_method("set_chip"):
				scene.call("set_chip", "Samsun Ruyasi")
			if scene.has_method("set_objective"):
				scene.call("set_objective", "Telgrafhaneye ulas ve ilk ipuclarini topla.")
			if scene.has_method("set_progress"):
				scene.call("set_progress", "Liderlik: 3 | Destek: 2/3 | Dalga: 1")
			if scene.has_method("set_star_count"):
				scene.call("set_star_count", 0)
				await process_frame
				scene.call("set_star_count", 4)
		"dialogue":
			if scene.has_method("present"):
				scene.call("present", {
					"chapter": "Bandirma 1919",
					"speaker": "Arda",
					"text": "Bandirma'ya geldik. Hazir misin?",
					"speaker_side": "left",
					"expression": "thinking"
				})
				await process_frame
				var body_label := scene.get_node_or_null("BottomArea/DialoguePanel/DialogueMargin/DialogueContent/BodyText")
				if body_label != null:
					body_label.visible_ratio = 1.0
		"info_card":
			if scene.has_method("present"):
				scene.call("present", {
					"tag_text": "Dogru Karar",
					"title": "Karar Notu",
					"text": "Bilgi karti artik gorunur bir kapat aksiyonu ve daha net mobil aksiyon satiri ile aciliyor.",
					"reward_text": "Yoluna devam et",
					"accent_color": Color(0.34, 0.63, 0.95, 0.18)
				})
		"decision":
			if scene.has_method("present"):
				scene.call("present", {
					"context": "visual_check",
					"chapter": "Karar Ani",
					"title": "Ilk adimi kim atsın?",
					"prompt": "Bandirma'daki ilk ipucunu incelemek icin hangi ogrenci one cikmali?",
					"option_a": "Arda hemen ilerlesin",
					"option_b": "Eda once gozlem yapsin",
					"arda_hint": "Merakli ve hizli",
					"eda_hint": "Sakin ve planli"
				})
		"chapter_transition":
			if scene.has_method("present"):
				scene.call("present", "Ankara", "Meclis iradesi toplaniyor", "Sahne hazirlaniyor...")
		"choice":
			var dream_overlay := scene.get_node_or_null("CanvasLayer/DreamOverlay")
			if dream_overlay != null and dream_overlay is CanvasItem:
				(dream_overlay as CanvasItem).visible = false
			var world_ui := scene.get_node_or_null("WorldUI")
			if world_ui != null:
				var overlay_manager = world_ui.get("_overlay_manager")
				if overlay_manager != null and overlay_manager.has_method("hide_all"):
					overlay_manager.call("hide_all")
			var player_mod := scene.get_node_or_null("WorldPlayer")
			if player_mod != null and player_mod.has_method("set_character_choice_visible"):
				player_mod.call("set_character_choice_visible", true)
			for path in ["Props", "Markers", "ForegroundProps", "Player", "Companion"]:
				var node := scene.get_node_or_null(path)
				if node != null and node is CanvasItem:
					(node as CanvasItem).visible = false
			var dialogue_panel := scene.get_node_or_null("CanvasLayer/HUD/DialoguePanel")
			if dialogue_panel != null and dialogue_panel is CanvasItem:
				(dialogue_panel as CanvasItem).visible = false
			var interact_button := scene.get_node_or_null("CanvasLayer/HUD/InteractButton")
			if interact_button != null and interact_button is CanvasItem:
				(interact_button as CanvasItem).visible = false
			var progress_panel := scene.get_node_or_null("CanvasLayer/HUD/ProgressPanel")
			if progress_panel != null and progress_panel is CanvasItem:
				(progress_panel as CanvasItem).visible = false
			var route_panel := scene.get_node_or_null("CanvasLayer/HUD/RoutePanel")
			if route_panel != null and route_panel is CanvasItem:
				(route_panel as CanvasItem).visible = false