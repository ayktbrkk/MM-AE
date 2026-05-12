## test_samsun_builder_properties.gd
## Samsun builder için property kontrolleri.
## Validates: Requirements 6.5, 13.3, 14.1

extends RefCounted

const WORLD_BUILDER_SCENE := preload("res://scripts/world_builder.gd")
const WORLD_BUILDER_SOURCE := "res://scripts/world_builder.gd"


func run_tests() -> Dictionary:
	print("=".repeat(60))
	print("Samsun Builder Property Testleri")
	print("=".repeat(60))

	var results: Array[Dictionary] = [
		_test_runtime_builder_properties(),
		_test_signal_order_property(),
	]

	var passed: int = 0
	var failed: int = 0
	for result in results:
		if result["ok"]:
			passed += 1
			print("  PASS  %s" % result["name"])
		else:
			failed += 1
			print("  FAIL  %s" % result["name"])
			for error in result["errors"]:
				print("        - %s" % error)

	var total: int = passed + failed
	print("=".repeat(60))
	print("Sonuç: %d / %d geçti  (%d başarısız)" % [passed, total, failed])
	print("=".repeat(60))
	return {"passed": passed, "failed": failed, "total": total}


func _test_runtime_builder_properties() -> Dictionary:
	var errors: Array[String] = []
	var harness: Node = Node.new()
	harness.name = "Harness"

	var world_state: Node = Node.new()
	world_state.name = "WorldState"
	harness.add_child(world_state)

	var builder: Node = WORLD_BUILDER_SCENE.new()
	harness.add_child(builder)

	var world_root: Node2D = Node2D.new()
	world_root.name = "WorldRoot"
	var props: Node2D = Node2D.new()
	props.name = "Props"
	var foreground: Node2D = Node2D.new()
	foreground.name = "ForegroundProps"
	var markers: Node2D = Node2D.new()
	markers.name = "Markers"
	var player: Node2D = Node2D.new()
	player.name = "Player"
	var companion: Node2D = Node2D.new()
	companion.name = "Companion"
	world_root.add_child(props)
	world_root.add_child(foreground)
	world_root.add_child(markers)
	world_root.add_child(player)
	world_root.add_child(companion)
	harness.add_child(world_root)

	builder.build_world("samsun_rift", world_root)

	var render_node_count: int = _count_render_nodes(world_root)
	if render_node_count >= 60:
		errors.append("Sprite2D + Polygon2D sayısı 60'ın altında olmalı, bulundu: %d" % render_node_count)

	for node in _collect_samsun_asset_nodes(world_root):
		if node is Node2D:
			var node_2d: Node2D = node
			if node_2d.position.x < -100.0 or node_2d.position.x > 1700.0:
				errors.append("Asset x sınır dışında: %s -> %.2f" % [node.name, node_2d.position.x])
			if node_2d.position.y < -100.0 or node_2d.position.y > 2300.0:
				errors.append("Asset y sınır dışında: %s -> %.2f" % [node.name, node_2d.position.y])

	harness.free()
	return {"name": "runtime_builder_properties", "ok": errors.is_empty(), "errors": errors}


func _test_signal_order_property() -> Dictionary:
	var errors: Array[String] = []
	var file: FileAccess = FileAccess.open(WORLD_BUILDER_SOURCE, FileAccess.READ)
	if file == null:
		errors.append("world_builder.gd açılamadı")
		return {"name": "signal_order_property", "ok": false, "errors": errors}

	var content: String = file.get_as_text()
	file.close()
	var function_body: String = _extract_function_body(content, "_build_samsun_rift")
	if function_body.is_empty():
		errors.append("_build_samsun_rift() gövdesi bulunamadı")
	else:
		var decorate_idx: int = function_body.find("_decorate_samsun_rift(world_root)")
		var signal_idx: int = function_body.find("emit_signal(\"world_built\", \"samsun_rift\")")
		if decorate_idx == -1:
			errors.append("_decorate_samsun_rift(world_root) çağrısı bulunamadı")
		if signal_idx == -1:
			errors.append("emit_signal(\"world_built\", \"samsun_rift\") çağrısı bulunamadı")
		elif decorate_idx != -1 and signal_idx < decorate_idx:
			errors.append("world_built sinyali dekorasyondan önce yayılıyor")

	return {"name": "signal_order_property", "ok": errors.is_empty(), "errors": errors}


func _count_render_nodes(node: Node) -> int:
	var count: int = 0
	if node is Sprite2D or node is Polygon2D:
		count += 1
	for child in node.get_children():
		count += _count_render_nodes(child)
	return count


func _collect_samsun_asset_nodes(world_root: Node) -> Array[Node]:
	var results: Array[Node] = []
	_collect_nodes_recursive(world_root, results)
	return results


func _collect_nodes_recursive(node: Node, results: Array[Node]) -> void:
	if node.has_meta("asset_slot"):
		var slot_value: Variant = node.get_meta("asset_slot")
		if slot_value is String and String(slot_value).begins_with("paperworld.samsun_"):
			results.append(node)
	for child in node.get_children():
		_collect_nodes_recursive(child, results)


func _extract_function_body(content: String, function_name: String) -> String:
	var signature: String = "func %s(" % function_name
	var start_idx: int = content.find(signature)
	if start_idx == -1:
		return ""
	var next_func_idx: int = content.find("\nfunc ", start_idx + signature.length())
	if next_func_idx == -1:
		return content.substr(start_idx)
	return content.substr(start_idx, next_func_idx - start_idx)