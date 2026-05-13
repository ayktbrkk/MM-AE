extends SceneTree

const DEFAULT_SIZE := Vector2i(923, 1287)
const DEFAULT_OUTPUT_DIR := "res://artifacts/renders/character_ui"
const PSEUDO_EXPANSION_RATIO := 1.35
const PSEUDO_PREFIX := "[[ "
const PSEUDO_SUFFIX := " ]]"

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var surface := "menu"
	var output_path := ""
	var viewport_size := DEFAULT_SIZE
	var pseudo_locale := "--pseudo" in args
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
		var variant_suffix := "_pseudo" if pseudo_locale else ""
		output_path = "%s/%s%s.png" % [DEFAULT_OUTPUT_DIR, surface, variant_suffix]
	call_deferred("_capture_surface", surface, output_path, viewport_size, pseudo_locale)


func _capture_surface(surface: String, output_path: String, viewport_size: Vector2i, pseudo_locale: bool) -> void:
	_configure_pseudolocalization(pseudo_locale)
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

	_finalize_surface(surface, scene, pseudo_locale)
	if scene.has_method("_freeze_for_capture"):
		scene.call("_freeze_for_capture")

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


func _configure_pseudolocalization(enabled: bool) -> void:
	TranslationServer.pseudolocalization_enabled = enabled
	ProjectSettings.set_setting("internationalization/pseudolocalization/replace_with_accents", enabled)
	ProjectSettings.set_setting("internationalization/pseudolocalization/double_vowels", enabled)
	ProjectSettings.set_setting("internationalization/pseudolocalization/override", enabled)
	ProjectSettings.set_setting("internationalization/pseudolocalization/skip_placeholders", true)
	ProjectSettings.set_setting("internationalization/pseudolocalization/prefix", PSEUDO_PREFIX if enabled else "")
	ProjectSettings.set_setting("internationalization/pseudolocalization/suffix", PSEUDO_SUFFIX if enabled else "")
	ProjectSettings.set_setting("internationalization/pseudolocalization/expansion_ratio", PSEUDO_EXPANSION_RATIO if enabled else 1.0)
	TranslationServer.reload_pseudolocalization()


func _variant_text(value: String, pseudo_locale: bool) -> String:
	if not pseudo_locale:
		return value
	return TranslationServer.pseudolocalize(value)


func _set_node_text(node: Object, value: String, pseudo_locale: bool) -> void:
	if node == null:
		return
	node.set("text", _variant_text(value, pseudo_locale))


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
		"completion":
			return load("res://scenes/world.tscn").instantiate()
		_:
			return null


func _finalize_surface(surface: String, scene: Node, pseudo_locale: bool) -> void:
	match surface:
		"menu":
			_set_node_text(scene.get("title_label"), "Zaman Yolculari", pseudo_locale)
			_set_node_text(scene.get("subtitle_label"), "Bandirma'dan baslayan tarih yolculugu", pseudo_locale)
			_set_node_text(scene.get("start_button"), "Oyuna Basla", pseudo_locale)
			_set_node_text(scene.get("continue_button"), "Devam Et", pseudo_locale)
			_set_node_text(scene.get("settings_button"), "Ayarlar", pseudo_locale)
			_set_node_text(scene.get("exit_button"), "Cikis", pseudo_locale)
			return
		"hud":
			if scene.has_method("apply_theme"):
				scene.call("apply_theme", Color(0.90, 0.97, 1.0), Color(0.04, 0.42, 0.56), Color(0.08, 0.48, 0.62), Color(0.04, 0.22, 0.32), Color(0.08, 0.48, 0.62))
			if scene.has_method("set_title"):
				scene.call("set_title", _variant_text("Zaman Yolculari: Samsun Ruyasi", pseudo_locale))
			if scene.has_method("set_chip"):
				scene.call("set_chip", _variant_text("Samsun Ruyasi", pseudo_locale))
			if scene.has_method("set_objective"):
				scene.call("set_objective", _variant_text("Telgrafhaneye ulas ve ilk ipuclarini topla.", pseudo_locale))
			if scene.has_method("set_progress"):
				scene.call("set_progress", _variant_text("Liderlik: 3 | Destek: 2/3 | Dalga: 1", pseudo_locale))
			if scene.has_method("set_star_count"):
				scene.call("set_star_count", 0)
				await process_frame
				scene.call("set_star_count", 4)
		"dialogue":
			if scene.has_method("present"):
				scene.call("present", {
					"chapter": _variant_text("Bandirma 1919", pseudo_locale),
					"speaker": _variant_text("Arda", pseudo_locale),
					"text": _variant_text("Bandirma'ya geldik. Hazir misin?", pseudo_locale),
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
					"tag_text": _variant_text("Dogru Karar", pseudo_locale),
					"title": _variant_text("Karar Notu", pseudo_locale),
					"text": _variant_text("Bilgi karti artik gorunur bir kapat aksiyonu ve daha net mobil aksiyon satiri ile aciliyor.", pseudo_locale),
					"reward_text": _variant_text("Yoluna devam et", pseudo_locale),
					"accent_color": Color(0.34, 0.63, 0.95, 0.18)
				})
		"decision":
			if scene.has_method("present"):
				scene.call("present", {
					"context": "visual_check",
					"chapter": _variant_text("Karar Ani", pseudo_locale),
					"title": _variant_text("Ilk adimi kim atsin?", pseudo_locale),
					"prompt": _variant_text("Bandirma'daki ilk ipucunu incelemek icin hangi ogrenci one cikmali?", pseudo_locale),
					"option_a": _variant_text("Arda hemen ilerlesin", pseudo_locale),
					"option_b": _variant_text("Eda once gozlem yapsin", pseudo_locale),
					"arda_hint": _variant_text("Merakli ve hizli", pseudo_locale),
					"eda_hint": _variant_text("Sakin ve planli", pseudo_locale)
				})
		"chapter_transition":
			if scene.has_method("present"):
				scene.call(
					"present",
					_variant_text("Ankara", pseudo_locale),
					_variant_text("Meclis iradesi toplaniyor", pseudo_locale),
					_variant_text("Sahne hazirlaniyor...", pseudo_locale)
				)
		"choice":
			_prepare_world_capture_scene(scene)
			var player_mod := scene.get_node_or_null("WorldPlayer")
			if player_mod != null and player_mod.has_method("set_character_choice_visible"):
				player_mod.call("set_character_choice_visible", true)
		"completion":
			_prepare_world_capture_scene(scene)
			var character_panel := scene.get_node_or_null("CanvasLayer/HUD/CharacterPanel")
			if character_panel != null and character_panel is CanvasItem:
				(character_panel as CanvasItem).visible = false
			var world_zone := scene.get_node_or_null("WorldZone")
			if world_zone != null and world_zone.has_method("finish_prototype"):
				world_zone.call("finish_prototype")


func _prepare_world_capture_scene(scene: Node) -> void:
	var dream_overlay := scene.get_node_or_null("CanvasLayer/DreamOverlay")
	if dream_overlay != null and dream_overlay is CanvasItem:
		(dream_overlay as CanvasItem).visible = false
	var world_ui := scene.get_node_or_null("WorldUI")
	if world_ui != null:
		var overlay_manager = world_ui.get("_overlay_manager")
		if overlay_manager != null and overlay_manager.has_method("hide_all"):
			overlay_manager.call("hide_all")
	for path in ["Props", "Markers", "ForegroundProps", "Player", "Companion"]:
		var node := scene.get_node_or_null(path)
		if node != null and node is CanvasItem:
			(node as CanvasItem).visible = false
	for path in ["CanvasLayer/HUD/DialoguePanel", "CanvasLayer/HUD/InteractButton", "CanvasLayer/HUD/ProgressPanel", "CanvasLayer/HUD/RoutePanel"]:
		var hud_node := scene.get_node_or_null(path)
		if hud_node != null and hud_node is CanvasItem:
			(hud_node as CanvasItem).visible = false