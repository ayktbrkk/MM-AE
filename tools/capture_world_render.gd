extends SceneTree

const DEFAULT_OUTPUT := "res://artifacts/renders/opening/opening_render.png"
const DEFAULT_SCENE := "res://scenes/world.tscn"
const DEFAULT_SIZE := Vector2i(923, 1287)
const DEFAULT_ZONE := ""
const READY_FRAME_LIMIT := 240
const DEFAULT_CAMERA_ZOOM := Vector2.ZERO

## --show-journal parametresi için varsayılan kart ID'leri (virgülle ayrılmış).
const DEFAULT_JOURNAL_CARDS_STR := "samsun_first_decision"
const DEFAULT_JOURNAL_CHAPTERS_STR := "samsun_cards"

var _show_journal := false
var _journal_cards: PackedStringArray = []
var _journal_chapters: PackedStringArray = []
var _show_accessibility := false
var _show_tutorial_arrow := false
var _show_portrait_slide := false
var _show_marker_collect := false

## P12B: Karakter seçimini otomatik yapmak için --auto-select-hero=<arda|eda>
var _auto_select_hero: String = ""

## P12B: Karakter seçimini tamamen atlamak için --skip-character-select
var _skip_character_select: bool = false

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var output_path := DEFAULT_OUTPUT
	var scene_path := DEFAULT_SCENE
	var viewport_size := DEFAULT_SIZE
	var zone := DEFAULT_ZONE
	var camera_zoom := DEFAULT_CAMERA_ZOOM
	var world_only := false
	var hide_hud := false
	var hide_overlays := false
	var hide_markers := false
	var hide_actors := false
	var hide_world_guides := false
	var clean_export := false
	var hero := ""
	for index in range(args.size()):
		match args[index]:
			"--output":
				if index + 1 < args.size():
					output_path = args[index + 1]
			"--scene":
				if index + 1 < args.size():
					scene_path = args[index + 1]
			"--size":
				if index + 1 < args.size():
					var parts := args[index + 1].split("x")
					if parts.size() == 2:
						viewport_size = Vector2i(parts[0].to_int(), parts[1].to_int())
			"--zone":
				if index + 1 < args.size():
					zone = args[index + 1]
			"--zoom":
				if index + 1 < args.size():
					var zoom_parts := args[index + 1].split(",")
					if zoom_parts.size() == 2:
						camera_zoom = Vector2(zoom_parts[0].to_float(), zoom_parts[1].to_float())
					else:
						var uniform_zoom := args[index + 1].to_float()
						if uniform_zoom > 0.0:
							camera_zoom = Vector2(uniform_zoom, uniform_zoom)
			"--world-only":
				world_only = true
			"--hide-hud":
				hide_hud = true
			"--hide-overlays":
				hide_overlays = true
			"--hide-markers":
				hide_markers = true
			"--hide-actors":
				hide_actors = true
			"--hide-world-guides":
				hide_world_guides = true
			"--clean-export":
				clean_export = true
				hide_hud = true
				hide_markers = true
				hide_actors = true
				hide_world_guides = true
			"--hero":
				if index + 1 < args.size():
					hero = args[index + 1]
			"--show-journal":
				_show_journal = true
			"--journal-cards":
				if index + 1 < args.size():
					_journal_cards = PackedStringArray(args[index + 1].split(","))
			"--journal-chapters":
				if index + 1 < args.size():
					_journal_chapters = PackedStringArray(args[index + 1].split(","))
			"--show-accessibility":
				_show_accessibility = true
			"--show-tutorial-arrow":
				_show_tutorial_arrow = true
			"--show-portrait-slide":
				_show_portrait_slide = true
			"--show-marker-collect":
				_show_marker_collect = true
			"--skip-character-select":
				_skip_character_select = true
		# P12B: --auto-select-hero=<value> formatını kontrol et (tek argüman)
		var current_arg: String = args[index]
		if current_arg.begins_with("--auto-select-hero="):
			_auto_select_hero = current_arg.trim_prefix("--auto-select-hero=")
	# P12B: call_deferred for döngüsü DIŞINA taşındı — her argümanda değil, bir kere çağrılır.
	call_deferred("_capture", scene_path, output_path, viewport_size, zone, camera_zoom, world_only, hide_hud, hide_overlays, hide_markers, hide_actors, hide_world_guides, clean_export, hero)
func _capture(scene_path: String, output_path: String, viewport_size: Vector2i, zone: String, camera_zoom: Vector2, world_only: bool, hide_hud: bool, hide_overlays: bool, hide_markers: bool, hide_actors: bool, hide_world_guides: bool, clean_export: bool, hero: String) -> void:
	var packed_scene := load(scene_path)
	if packed_scene == null:
		push_error("Could not load scene: %s" % scene_path)
		quit(1)
		return
	var viewport := SubViewport.new()
	viewport.name = "CaptureViewport"
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = false
	viewport.size = viewport_size
	root.add_child(viewport)
	var scene: Node = packed_scene.instantiate()
	viewport.add_child(scene)
	await process_frame

	# P12B: Karakter seçimini yönet
	var hero_choice: String = hero
	if hero_choice == "" and _auto_select_hero != "":
		hero_choice = _auto_select_hero
	if _skip_character_select or hero_choice != "":
		await _perform_hero_selection(scene, hero_choice, _skip_character_select)

	if zone != "":
		await _configure_world_zone(scene, zone)
	_apply_camera_zoom(scene, camera_zoom)
	await _await_capture_ready(scene, zone)
	if clean_export:
		_apply_clean_export(scene)
	if hide_overlays:
		_hide_overlays(scene)
	if world_only:
		var canvas := scene.get_node_or_null("CanvasLayer")
		if canvas != null:
			canvas.visible = false
	elif hide_hud:
		var hud := scene.get_node_or_null("CanvasLayer/HUD")
		if hud != null:
			hud.visible = false
	if hide_markers:
		var markers := scene.get_node_or_null("Markers")
		if markers != null:
			markers.visible = false
	if hide_world_guides:
		_hide_world_guides(scene)
	if hide_actors:
		_hide_actor_visuals(scene)
	if _show_journal:
		_show_journal_overlay(scene)
		for frame in range(24):
			await process_frame
	if _show_accessibility:
		_show_accessibility_panel(scene)
		for frame in range(24):
			await process_frame
	if _show_tutorial_arrow:
		_show_tutorial_arrow_overlay(scene)
		for frame in range(24):
			await process_frame
	if _show_portrait_slide:
		_show_portrait_slide_overlay(scene)
		for frame in range(24):
			await process_frame
	if _show_marker_collect:
		_show_marker_collect_animation(scene)
		for frame in range(24):
			await process_frame
	for frame in range(12):
		await process_frame
	RenderingServer.force_draw()
	await process_frame
	var image := viewport.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Could not capture viewport image.")
		quit(1)
		return
	var absolute_output := ProjectSettings.globalize_path(output_path)
	var directory := absolute_output.get_base_dir()
	if not DirAccess.dir_exists_absolute(directory):
		DirAccess.make_dir_recursive_absolute(directory)
	var error := image.save_png(absolute_output)
	if error != OK:
		push_error("Could not save render: %s" % output_path)
		quit(1)
		return
	print("Saved render: %s" % absolute_output)
	quit()


func _apply_camera_zoom(scene: Node, camera_zoom: Vector2) -> void:
	if camera_zoom == Vector2.ZERO:
		return
	var camera: Camera2D = scene.get_node_or_null("Player/Camera2D")
	if camera != null:
		camera.zoom = camera_zoom


func _select_hero(scene: Node, hero: String) -> void:
	"""Karakter seçimi: WorldPlayer üzerinden choose_hero() çağırır."""
	if hero == "":
		return
	var player_mod := scene.get_node_or_null("WorldPlayer")
	if player_mod != null and player_mod.has_method("choose_hero"):
		player_mod.call("choose_hero", hero)


# ---------------------------------------------------------------------------
# P12B: Karakter Seçimini Yönet
# ---------------------------------------------------------------------------
func _perform_hero_selection(scene: Node, hero_choice: String, skip_select: bool) -> void:
	"""Karakter seçim akışını yönetir.

	--skip-character-select: hero_choice varsayılan olarak "arda" kullanılır,
	karakter seçim paneli atlanır ve doğrudan oyun dünyasına geçilir.

	--auto-select-hero=arda|eda: normal choose_hero akışı çalıştırılır,
	karakter seçilir, diyalog/tutorial başlatılır.
	"""
	if skip_select:
		# Skip modu: karakteri doğrudan uygula, paneli gizle
		var final_hero: String = hero_choice if hero_choice != "" else "arda"
		var player_mod := scene.get_node_or_null("WorldPlayer")
		if player_mod != null and player_mod.has_method("apply_hero_selection"):
			player_mod.call("apply_hero_selection", final_hero)
			# Karakter panelini gizle
			var char_panel := scene.get_node_or_null("CanvasLayer/HUD/CharacterPanel")
			if char_panel != null:
				char_panel.visible = false
			# Identity row'u da gizle
			if player_mod.has_method("_set_character_choice_visible"):
				player_mod.call("_set_character_choice_visible", false)
			print("  Character select skipped, hero set to: %s" % final_hero)
		else:
			push_error("skip_character_select: WorldPlayer not found or missing apply_hero_selection")
		# Skip modunda kısa bekleme
		for frame in range(16):
			await process_frame
		return

	# Normal auto-select: choose_hero akışını çalıştır
	_select_hero(scene, hero_choice)
	# Karakter seçimi sonrası diyalog/tutorial başlayana kadar bekle
	await _wait_for_hero_selection(scene)
	print("  Hero selection complete: %s" % hero_choice)


func _wait_for_hero_selection(scene: Node) -> void:
	"""Karakter seçimi sonrası dünyanın yerleşmesini bekler.

	Karakter panelinin kaybolmasını ve diyalog/tutorial başlamasını
	bekler. Maksimum 120 frame (~2 saniye).
	"""
	var max_frames: int = 120
	for frame in range(max_frames):
		await process_frame
		# Karakter paneli kayboldu mu kontrol et
		var char_panel := scene.get_node_or_null("CanvasLayer/HUD/CharacterPanel")
		if char_panel == null or not char_panel.visible:
			# Panel kayboldu — karakter seçimi tamamlanmış
			break
	# Ek stabilizasyon frame'leri
	for frame in range(24):
		await process_frame


func _configure_world_zone(scene: Node, zone: String) -> void:
	var zone_node := scene.get_node_or_null("WorldZone")
	if zone_node == null or not zone_node.has_method("transition_to"):
		push_error("Could not configure zone '%s': WorldZone missing." % zone)
		quit(1)
		return
	zone_node.call("transition_to", zone)
	for frame in range(16):
		await process_frame


func _await_capture_ready(scene: Node, zone: String) -> void:
	for frame in range(READY_FRAME_LIMIT):
		await process_frame
		if _is_scene_ready(scene, zone):
			for settle_frame in range(8):
				await process_frame
			return


func _is_scene_ready(scene: Node, zone: String) -> bool:
	# main_menu.tscn icin: zone="" ise ve WorldState yoksa hemen hazir
	if zone == "" and scene.get_node_or_null("WorldState") == null:
		return true
	var dream_overlay := scene.get_node_or_null("CanvasLayer/DreamOverlay")
	if dream_overlay != null and dream_overlay.visible:
		return false
	var chapter_transition := find_chapter_transition_overlay(scene)
	if chapter_transition != null and chapter_transition.visible:
		return false
	if zone == "":
		return true
	var state := scene.get_node_or_null("WorldState")
	if state == null:
		return false
	var expected_zone := "ship" if zone == "bandirma" else zone
	return String(state.get("current_zone")) == expected_zone


static func find_chapter_transition_overlay(scene: Node) -> Node:
	var world_ui := scene.get_node_or_null("WorldUI")
	if world_ui != null:
		var overlay_manager = world_ui.get("_overlay_manager")
		if overlay_manager != null and overlay_manager.has_method("get_overlay_node"):
			var overlay_node = overlay_manager.call("get_overlay_node", OverlayManager.OverlayType.CHAPTER_TRANSITION)
			if overlay_node != null:
				return overlay_node as Node
	return scene.find_child("ChapterTransitionOverlay", true, false)


func _apply_clean_export(scene: Node) -> void:
	var world_ui := scene.get_node_or_null("WorldUI")
	if world_ui != null:
		var overlay_manager = world_ui.get("_overlay_manager")
		if overlay_manager != null and overlay_manager.has_method("hide_all"):
			overlay_manager.call("hide_all")
	var dialogue_panel := scene.get_node_or_null("CanvasLayer/HUD/DialoguePanel")
	if dialogue_panel != null:
		dialogue_panel.visible = false
	var character_panel := scene.get_node_or_null("CanvasLayer/HUD/CharacterPanel")
	if character_panel != null:
		character_panel.visible = false


func _show_accessibility_panel(scene: Node) -> void:
	"""main_menu.tscn icinde accessibility panel overlay'ini acar."""
	var main_menu := scene as Control
	if main_menu == null or not main_menu.has_method("_on_accessibility_pressed"):
		push_error("show_accessibility: main_menu not found or missing _on_accessibility_pressed")
		return
	main_menu.call("_on_accessibility_pressed")


func _show_journal_overlay(scene: Node) -> void:
	"""Journal overlay'ini test verileriyle açar.

	WorldUI node'unu bulur, overlay manager üzerinden JOURNAL overlay'ini
	gösterir. Eğer kullanıcı --journal-cards veya --journal-chapters
	belirtmemişse varsayılan test verilerini (DEFAULT_JOURNAL_CARDS,
	DEFAULT_JOURNAL_CHAPTERS) kullanır.
	"""
	var world_ui := scene.get_node_or_null("WorldUI")
	if world_ui == null:
		push_error("show_journal: WorldUI not found")
		return
	var overlay_manager = world_ui.get("_overlay_manager")
	if overlay_manager == null:
		push_error("show_journal: overlay_manager not found")
		return
	var cards := _journal_cards if not _journal_cards.is_empty() else PackedStringArray(DEFAULT_JOURNAL_CARDS_STR.split(","))
	var chapters := _journal_chapters if not _journal_chapters.is_empty() else PackedStringArray(DEFAULT_JOURNAL_CHAPTERS_STR.split(","))
	overlay_manager.call("show", OverlayManager.OverlayType.JOURNAL, {
		"tab": "cards",
		"card_ids": Array(cards),
		"chapter_ids": Array(chapters),
	})


func _hide_overlays(scene: Node) -> void:
	var world_ui := scene.get_node_or_null("WorldUI")
	if world_ui != null:
		var overlay_manager = world_ui.get("_overlay_manager")
		if overlay_manager != null and overlay_manager.has_method("hide_all"):
			overlay_manager.call("hide_all")
	for path in [
		"CanvasLayer/HUD/DialoguePanel",
		"CanvasLayer/HUD/CharacterPanel",
		"CanvasLayer/HUD/DialogueOverlay",
		"CanvasLayer/HUD/DecisionOverlay",
		"CanvasLayer/HUD/InfoCardOverlay",
		"CanvasLayer/HUD/ChapterTransitionOverlay",
	]:
		var node := scene.get_node_or_null(path)
		if node != null and node is CanvasItem:
			(node as CanvasItem).visible = false


func _hide_actor_visuals(scene: Node) -> void:
	var player := scene.get_node_or_null("Player")
	if player != null:
		_hide_canvas_items_except(player, ["Camera2D"])
	var companion := scene.get_node_or_null("Companion")
	if companion != null:
		_hide_canvas_items_except(companion, [])


func _hide_canvas_items_except(node: Node, keep_names: Array[String]) -> void:
	for child in node.get_children():
		if keep_names.has(String(child.name)):
			continue
		if child is CanvasItem:
			(child as CanvasItem).visible = false
		_hide_canvas_items_except(child, keep_names)


func _hide_world_guides(scene: Node) -> void:
	_hide_nodes_with_meta(scene.get_node_or_null("Props"), "world_guide")
	_hide_nodes_with_meta(scene.get_node_or_null("ForegroundProps"), "world_guide")
	var guidance_arrow := scene.get_node_or_null("Player/GuidanceArrow")
	if guidance_arrow != null and guidance_arrow is CanvasItem:
		(guidance_arrow as CanvasItem).visible = false
	var route_panel := scene.get_node_or_null("CanvasLayer/HUD/RoutePanel")
	if route_panel != null and route_panel is CanvasItem:
		(route_panel as CanvasItem).visible = false


func _hide_nodes_with_meta(root_node: Node, meta_key: String) -> void:
	if root_node == null:
		return
	if root_node.has_meta(meta_key) and root_node is CanvasItem:
		(root_node as CanvasItem).visible = false
	for child in root_node.get_children():
		_hide_nodes_with_meta(child, meta_key)


# ---------------------------------------------------------------------------
# P12A — Tutorial Arrow Capture
# ---------------------------------------------------------------------------
func _show_tutorial_arrow_overlay(scene: Node) -> void:
	"""world.tscn icinde tutorial callout arrow animasyonunu tetikler.

	TutorialController node'unu bulur (WorldUI altında, world_ui.gd
	_setup_tutorial() tarafından kurulur) ve _start_callout_arrow_animation()
	çağırarak animasyonlu oku gösterir.
	"""
	# P12B: TutorialController WorldUI altında yaşar (world_ui.gd _setup_tutorial)
	var tutorial := scene.get_node_or_null("WorldUI/TutorialController")
	if tutorial == null:
		tutorial = scene.find_child("TutorialController", true, false)
	if tutorial == null:
		push_error("show_tutorial_arrow: TutorialController not found (searched WorldUI/TutorialController, find_child)")
		return
	if tutorial.has_method("_start_callout_arrow_animation"):
		tutorial.call("_start_callout_arrow_animation")
		print("  Tutorial arrow animation started.")
	else:
		push_error("show_tutorial_arrow: _start_callout_arrow_animation not found")


# ---------------------------------------------------------------------------
# P12A — Portrait Slide Capture
# ---------------------------------------------------------------------------
func _show_portrait_slide_overlay(scene: Node) -> void:
	"""world.tscn icinde dialogue portrait slide-in animasyonunu tetikler.

	DialogueOverlay node'unu bulur ve present() fonksiyonu ile
	portrenin slide-in efektini gosterir.
	"""
	var dialogue := scene.get_node_or_null("CanvasLayer/HUD/DialogueOverlay")
	if dialogue == null:
		dialogue = scene.get_node_or_null("DialogueOverlay")
	if dialogue == null:
		dialogue = scene.find_child("DialogueOverlay", true, false)
	if dialogue == null:
		push_error("show_portrait_slide: DialogueOverlay not found")
		return
	if dialogue.has_method("present"):
		dialogue.call("present", {
			"portrait": "arda",
			"text": "Portre slide-in animasyonu testi...",
			"speaker": "Arda"
		})
		print("  Portrait slide animation triggered.")
	else:
		push_error("show_portrait_slide: present() not found on DialogueOverlay")


# ---------------------------------------------------------------------------
# P12A — Marker Collect Capture
# ---------------------------------------------------------------------------
func _show_marker_collect_animation(scene: Node) -> void:
	"""world.tscn icinde marker collect animasyonunu tetikler.

	WorldMarker node'unu bulur ve mark_collected() fonksiyonunu
	cagirarak ilk marker'in scale-down + fade-out efektini gosterir.
	"""
	var world_marker := scene.get_node_or_null("WorldMarker")
	if world_marker == null:
		push_error("show_marker_collect: WorldMarker node not found")
		return
	var markers := scene.get_node_or_null("Markers")
	if markers == null:
		push_error("show_marker_collect: Markers node not found")
		return
	var first_marker: Node = null
	for child in markers.get_children():
		if child is Node2D:
			first_marker = child
			break
	if first_marker == null:
		push_error("show_marker_collect: No marker child found under Markers")
		return
	# WorldMarker.mark_collected(marker) cagir
	if world_marker.has_method("mark_collected"):
		world_marker.call("mark_collected", first_marker)
		print("  Marker collect animation triggered on: %s" % first_marker.name)
	else:
		push_error("show_marker_collect: WorldMarker.mark_collected() not found")
