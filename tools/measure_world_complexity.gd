extends SceneTree

# ==============================================================================
# Package 9: Performance Observation and Node Count Gate
# Zone bazında node karmaşıklığını ölçen headless script.
# Kullanım: godot --headless --path . --script res://tools/measure_world_complexity.gd
# ==============================================================================

# Zone listesi — world_builder.gd ile senkron
const ZONES: Array[String] = [
	"room", "ship", "samsun_rift", "havza",
	"amasya", "kongreler", "ankara", "sakarya", "final"
]

# Threshold uyarı eşikleri (WARNING seviyesi, FAILURE değil)
const THRESHOLDS: Dictionary = {
	"total_nodes": 2000,
	"node2d": 500,
	"canvas_item": 1000,
	"sprite2d": 300,
	"polygon2d": 200,
	"markers": 30
}

const SCENE_PATH := "res://scenes/world.tscn"
const READY_FRAME_LIMIT := 240

# Ölçüm sonuçları: Array[Dictionary]
var _results: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("_run_all_measurements")


func _run_all_measurements() -> void:
	print("#".repeat(70))
	print("#  P11 — WORLD COMPLEXITY MEASUREMENT")
	print("#  Timestamp: %s" % Time.get_datetime_string_from_system())
	print("#".repeat(70))
	print("")
	print("zone,total_nodes,node2d,canvas_item,sprite2d,polygon2d,markers,threshold_warnings")
	print("")

	var packed_scene: PackedScene = load(SCENE_PATH)
	if packed_scene == null:
		push_error("Could not load scene: %s" % SCENE_PATH)
		quit(1)
		return

	for zone in ZONES:
		_measure_zone(zone, packed_scene)

	# Özet tablosu
	_print_summary()
	quit()


func _measure_zone(zone: String, packed_scene: PackedScene) -> void:
	var viewport := SubViewport.new()
	viewport.name = "MeasureViewport_%s" % zone
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	viewport.size = Vector2i(1, 1)  # minimum boyut, render gerekmez
	root.add_child(viewport)

	var scene: Node = packed_scene.instantiate()
	viewport.add_child(scene)

	# Scene'in hazır olmasını bekle
	for frame in range(READY_FRAME_LIMIT):
		await process_frame
		if not scene.is_inside_tree():
			break
		var dream_overlay := scene.get_node_or_null("CanvasLayer/DreamOverlay")
		if dream_overlay != null and dream_overlay.visible:
			continue
		var chapter_transition := _find_chapter_transition(scene)
		if chapter_transition != null and chapter_transition.visible:
			continue
		# Zone geçişi yap
		_switch_zone(scene, zone)
		# Biraz daha bekle, geçiş tamamlansın
		for settle in range(24):
			await process_frame
		break

	# Ölçüm
	var counts := _count_nodes(scene)
	var total_nodes: int = counts["total"]
	var node2d_count: int = counts["node2d"]
	var canvas_item_count: int = counts["canvas_item"]
	var sprite2d_count: int = counts["sprite2d"]
	var polygon2d_count: int = counts["polygon2d"]
	var marker_count: int = _count_visible_markers(scene)

	# Threshold kontrolü
	var warnings: Array[String] = []
	if total_nodes > THRESHOLDS["total_nodes"]:
		warnings.append("total_nodes=%d > %d" % [total_nodes, THRESHOLDS["total_nodes"]])
	if node2d_count > THRESHOLDS["node2d"]:
		warnings.append("node2d=%d > %d" % [node2d_count, THRESHOLDS["node2d"]])
	if canvas_item_count > THRESHOLDS["canvas_item"]:
		warnings.append("canvas_item=%d > %d" % [canvas_item_count, THRESHOLDS["canvas_item"]])
	if sprite2d_count > THRESHOLDS["sprite2d"]:
		warnings.append("sprite2d=%d > %d" % [sprite2d_count, THRESHOLDS["sprite2d"]])
	if polygon2d_count > THRESHOLDS["polygon2d"]:
		warnings.append("polygon2d=%d > %d" % [polygon2d_count, THRESHOLDS["polygon2d"]])
	if marker_count > THRESHOLDS["markers"]:
		warnings.append("markers=%d > %d" % [marker_count, THRESHOLDS["markers"]])

	var warning_text := ";".join(warnings) if warnings.size() > 0 else ""

	# CSV satırı
	var csv_line := "%s,%d,%d,%d,%d,%d,%d,%s" % [
		zone, total_nodes, node2d_count, canvas_item_count,
		sprite2d_count, polygon2d_count, marker_count, warning_text
	]
	print(csv_line)

	# Sonuçları kaydet
	_results.append({
		"zone": zone,
		"total_nodes": total_nodes,
		"node2d": node2d_count,
		"canvas_item": canvas_item_count,
		"sprite2d": sprite2d_count,
		"polygon2d": polygon2d_count,
		"markers": marker_count,
		"warnings": warnings
	})

	# Temizlik
	viewport.remove_child(scene)
	scene.queue_free()
	root.remove_child(viewport)
	viewport.queue_free()
	await process_frame


func _switch_zone(scene: Node, zone: String) -> void:
	var zone_node := scene.get_node_or_null("WorldZone")
	if zone_node != null and zone_node.has_method("transition_to"):
		zone_node.call("transition_to", zone)

	# state.set_zone()'u da dene
	var state := scene.get_node_or_null("WorldState")
	if state != null and state.has_method("set_zone"):
		state.call("set_zone", zone)


func _count_nodes(node: Node) -> Dictionary:
	var total := 0
	var node2d := 0
	var canvas_item := 0
	var sprite2d := 0
	var polygon2d := 0

	var stack: Array[Node] = [node]
	while stack.size() > 0:
		var current: Node = stack.pop_back()
		if current == null:
			continue
		total += 1

		if current is Node2D:
			node2d += 1
		if current is CanvasItem:
			canvas_item += 1
		if current is Sprite2D:
			sprite2d += 1
		if current is Polygon2D:
			polygon2d += 1

		for child in current.get_children():
			stack.append(child as Node)

	return {
		"total": total,
		"node2d": node2d,
		"canvas_item": canvas_item,
		"sprite2d": sprite2d,
		"polygon2d": polygon2d
	}


func _count_visible_markers(scene: Node) -> int:
	var markers_node := scene.get_node_or_null("Markers")
	if markers_node == null:
		return 0

	var count := 0
	for child in markers_node.get_children():
		if child is CanvasItem and child.visible:
			count += 1
	return count


static func _find_chapter_transition(scene: Node) -> Node:
	var world_ui := scene.get_node_or_null("WorldUI")
	if world_ui != null:
		var overlay_manager = world_ui.get("_overlay_manager")
		if overlay_manager != null and overlay_manager.has_method("get_overlay_node"):
			var overlay_node = overlay_manager.call("get_overlay_node", 5)  # OverlayType.CHAPTER_TRANSITION
			if overlay_node != null:
				return overlay_node as Node
	return scene.find_child("ChapterTransitionOverlay", true, false)


func _print_summary() -> void:
	print("")
	print("#".repeat(70))
	print("#  P11 — SUMMARY")
	print("#".repeat(70))
	print("")
	print("%-20s %10s %8s %8s %8s %8s %8s" % [
		"ZONE", "TOTAL", "NODE2D", "CANVAS", "SPRITE", "POLY", "MARKERS"
	])
	print("-".repeat(70))

	var sorted: Array[Dictionary] = _results.duplicate()
	sorted.sort_custom(_sort_by_total)

	for r in sorted:
		var flag := " ⚠" if r["warnings"].size() > 0 else "  "
		print("%-20s %6d %8d %8d %8d %8d %8d%s" % [
			r["zone"], r["total_nodes"], r["node2d"], r["canvas_item"],
			r["sprite2d"], r["polygon2d"], r["markers"], flag
		])

	print("-".repeat(70))

	# En yüksek node sayılı zone
	if sorted.size() > 0:
		var worst := sorted[0]
		print("")
		print(">>> High node-count zone: '%s' (%d nodes) — profiling priority" % [worst["zone"], worst["total_nodes"]])

	# Threshold aşımları
	var total_warnings: int = 0
	for r in _results:
		total_warnings += r["warnings"].size()

	if total_warnings > 0:
		print(">>> Threshold warnings: %d" % total_warnings)
		for r in _results:
			if r["warnings"].size() > 0:
				for w in r["warnings"]:
					print("    %s: %s" % [r["zone"], w])
	else:
		print(">>> No threshold warnings — all zones within limits.")

	print("")
	print("#".repeat(70))
	print("#  P11_MEASUREMENT_COMPLETE")
	print("#".repeat(70))


static func _sort_by_total(a: Dictionary, b: Dictionary) -> bool:
	return a["total_nodes"] > b["total_nodes"]
