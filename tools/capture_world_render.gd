extends SceneTree

const DEFAULT_OUTPUT := "res://artifacts/renders/opening/opening_render.png"
const DEFAULT_SCENE := "res://scenes/world.tscn"
const DEFAULT_SIZE := Vector2i(923, 1287)
const DEFAULT_ZONE := ""
const READY_FRAME_LIMIT := 240
const DEFAULT_CAMERA_ZOOM := Vector2.ZERO

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
	_select_hero(scene, hero)
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
	if hero == "":
		return
	var player_mod := scene.get_node_or_null("WorldPlayer")
	if player_mod != null and player_mod.has_method("choose_hero"):
		player_mod.call("choose_hero", hero)


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
