## test_samsun_svg_properties.gd
## Samsun SVG dosyaları için ek property kontrolleri.
## Validates: Requirements 1.3, 1.5, 1.6, 13.4, 15.1, 15.2, 15.3, 15.4, 15.5

extends RefCounted

const SVG_DIR := "res://assets/art/world/samsun/"
const MAX_FILE_SIZE_BYTES := 50 * 1024

const SVG_FILES: Array[String] = [
	"paper_sky_samsun.svg",
	"paper_sky_life.svg",
	"paper_distant_town.svg",
	"paper_skyline_depth.svg",
	"paper_harbor_water.svg",
	"paper_coast_details.svg",
	"paper_harbor_dock_props.svg",
	"paper_coastal_life.svg",
	"paper_terrain_island.svg",
	"paper_side_paths.svg",
	"paper_main_path.svg",
	"paper_route_beads.svg",
	"paper_safe_clearings.svg",
	"paper_civic_cluster.svg",
	"paper_discovery_props.svg",
	"paper_harbor_boats.svg",
	"paper_signal_ridge.svg",
	"paper_vista_flags.svg",
	"paper_harbor_landmark.svg",
	"paper_telegraph_landmark.svg",
	"paper_people_plaza.svg",
	"paper_rift_core.svg",
	"paper_wave_gate.svg",
	"paper_map_compass.svg",
	"paper_foreground_frame.svg",
]

const RELATIVE_PATH_COMMANDS: Array[String] = ["m", "l", "c", "q", "a"]
const FORBIDDEN_ELEMENTS: Array[String] = ["<defs", "<text", "<image", "<use", "<symbol"]
const FORBIDDEN_ATTRIBUTES: Array[String] = [" style=", "\tstyle="]
const COLOR_EXEMPT_FILES := {
	"paper_rift_core.svg": true,
	"paper_vista_flags.svg": true,
}


func run_tests() -> Dictionary:
	print("=".repeat(60))
	print("Samsun SVG Property Testleri")
	print("=".repeat(60))

	var passed: int = 0
	var failed: int = 0

	for file_name in SVG_FILES:
		var result: Dictionary = _test_svg_file(file_name)
		if result["ok"]:
			passed += 1
			print("  PASS  %s" % file_name)
		else:
			failed += 1
			print("  FAIL  %s" % file_name)
			for error in result["errors"]:
				print("        - %s" % error)

	var total: int = passed + failed
	print("=".repeat(60))
	print("Sonuç: %d / %d geçti  (%d başarısız)" % [passed, total, failed])
	print("=".repeat(60))
	return {"passed": passed, "failed": failed, "total": total}


func _test_svg_file(file_name: String) -> Dictionary:
	var errors: Array[String] = []
	var path: String = SVG_DIR + file_name
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("Dosya açılamadı: %s (hata kodu: %d)" % [path, FileAccess.get_open_error()])
		return {"ok": false, "errors": errors}

	var content: String = file.get_as_text()
	var file_size: int = file.get_length()
	file.close()

	if not content.contains('xmlns="http://www.w3.org/2000/svg"'):
		errors.append('xmlns="http://www.w3.org/2000/svg" bildirimi eksik')

	var path_count: int = _count_path_elements(content)
	if file_name == "paper_rift_core.svg":
		if path_count != 4:
			errors.append("paper_rift_core.svg için <path> sayısı 4 olmalı, bulundu: %d" % path_count)
	elif path_count < 2 or path_count > 5:
		errors.append("<path> sayısı 2-5 arasında olmalı, bulundu: %d" % path_count)

	if not COLOR_EXEMPT_FILES.has(file_name):
		var unique_colors: int = _extract_unique_colors(content).size()
		if unique_colors > 5:
			errors.append("Benzersiz renk sayısı 5'i geçiyor: %d" % unique_colors)

	if file_size >= MAX_FILE_SIZE_BYTES:
		errors.append("Dosya boyutu 50 KB altında olmalı, bulundu: %d byte" % file_size)

	for elem in FORBIDDEN_ELEMENTS:
		if content.contains(elem):
			errors.append('Yasak element bulundu: "%s"' % elem)

	for attr in FORBIDDEN_ATTRIBUTES:
		if content.contains(attr):
			errors.append('"style" attribute bulundu - yasak')
			break
	if _contains_style_attribute(content):
		var style_reported: bool = false
		for error in errors:
			if '"style" attribute' in error:
				style_reported = true
				break
		if not style_reported:
			errors.append('"style" attribute bulundu - yasak')

	var relative_found: Array[String] = _find_relative_commands_in_paths(content)
	if not relative_found.is_empty():
		errors.append("Küçük harf path komutu bulundu: %s" % ", ".join(relative_found))

	return {"ok": errors.is_empty(), "errors": errors}


func _contains_style_attribute(content: String) -> bool:
	var patterns: Array[String] = [" style=", "\tstyle=", "\nstyle=", ">style="]
	for pattern in patterns:
		if content.contains(pattern):
			return true
	return false


func _find_relative_commands_in_paths(content: String) -> Array[String]:
	var found: Array[String] = []
	for d_value in _extract_d_attributes(content):
		for cmd in RELATIVE_PATH_COMMANDS:
			if not found.has(cmd) and _path_contains_command(d_value, cmd):
				found.append(cmd)
	return found


func _path_contains_command(d_value: String, cmd: String) -> bool:
	var i: int = 0
	while i < d_value.length():
		var ch: String = d_value[i]
		if ch == cmd:
			var prev_is_alnum: bool = false
			if i > 0:
				var prev: String = d_value[i - 1]
				prev_is_alnum = (prev >= "a" and prev <= "z") or (prev >= "A" and prev <= "Z") or (prev >= "0" and prev <= "9")
			if not prev_is_alnum:
				return true
		i += 1
	return false


func _extract_d_attributes(content: String) -> Array[String]:
	var results: Array[String] = []
	var search_from: int = 0
	while true:
		var idx_double: int = content.find(' d="', search_from)
		var idx_single: int = content.find(" d='", search_from)
		var idx: int = -1
		var quote_char: String = '"'
		if idx_double == -1 and idx_single == -1:
			break
		elif idx_double == -1:
			idx = idx_single
			quote_char = "'"
		elif idx_single == -1:
			idx = idx_double
			quote_char = '"'
		elif idx_double < idx_single:
			idx = idx_double
			quote_char = '"'
		else:
			idx = idx_single
			quote_char = "'"
		var value_start: int = idx + 4
		var value_end: int = content.find(quote_char, value_start)
		if value_end == -1:
			break
		results.append(content.substr(value_start, value_end - value_start))
		search_from = value_end + 1
	return results


func _count_path_elements(content: String) -> int:
	var count: int = 0
	var search_from: int = 0
	while true:
		var idx: int = content.find("<path", search_from)
		if idx == -1:
			break
		var next_char_idx: int = idx + 5
		if next_char_idx < content.length():
			var next_char: String = content[next_char_idx]
			if next_char == " " or next_char == ">" or next_char == "/" or next_char == "\t" or next_char == "\n":
				count += 1
		search_from = idx + 1
	return count


func _extract_unique_colors(content: String) -> Array[String]:
	var colors: Dictionary = {}
	var prefixes: Array[String] = ['fill="', 'stroke="']
	for prefix in prefixes:
		var search_from: int = 0
		while true:
			var idx: int = content.find(prefix, search_from)
			if idx == -1:
				break
			var value_start: int = idx + prefix.length()
			var value_end: int = content.find('"', value_start)
			if value_end == -1:
				break
			var color_value: String = content.substr(value_start, value_end - value_start).to_lower()
			if color_value != "none":
				colors[color_value] = true
			search_from = value_end + 1
	return colors.keys()