extends SceneTree

const DEFAULT_OUTPUT := "res://artifacts/renders/opening/opening_render.png"
const DEFAULT_SCENE := "res://scenes/world.tscn"
const DEFAULT_SIZE := Vector2i(923, 1287)

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var output_path := DEFAULT_OUTPUT
	var scene_path := DEFAULT_SCENE
	var viewport_size := DEFAULT_SIZE
	var world_only := false
	var hide_hud := false
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
			"--world-only":
				world_only = true
			"--hide-hud":
				hide_hud = true
			"--hero":
				if index + 1 < args.size():
					hero = args[index + 1]
	call_deferred("_capture", scene_path, output_path, viewport_size, world_only, hide_hud, hero)

func _capture(scene_path: String, output_path: String, viewport_size: Vector2i, world_only: bool, hide_hud: bool, hero: String) -> void:
	root.size = viewport_size
	var packed_scene := load(scene_path)
	if packed_scene == null:
		push_error("Could not load scene: %s" % scene_path)
		quit(1)
		return
	var scene: Node = packed_scene.instantiate()
	root.add_child(scene)
	if hero != "" and scene.has_method("_choose_hero"):
		scene.call("_choose_hero", hero)
	if world_only:
		var canvas := scene.get_node_or_null("CanvasLayer")
		if canvas != null:
			canvas.visible = false
	elif hide_hud:
		var hud := scene.get_node_or_null("CanvasLayer/HUD")
		if hud != null:
			hud.visible = false
	for frame in range(12):
		await process_frame
	RenderingServer.force_draw()
	await process_frame
	var image := root.get_texture().get_image()
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
