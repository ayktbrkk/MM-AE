## test_bandirma_svg_validity.gd
## Bandirma asset kit SVG dosyalarinin XML gecerliligini dogrular.

extends RefCounted

const SVG_DIR := "res://assets/art/world/bandirma/"

const SVG_FILES: Array[String] = [
	"paper_sky_bandirma.svg",
	"paper_fog_bands.svg",
	"paper_distant_coast.svg",
	"paper_cabin_wall.svg",
	"paper_sea_window.svg",
	"paper_terrain_harbor.svg",
	"paper_main_path.svg",
	"paper_bandirma_ship.svg",
	"paper_map_table.svg",
	"paper_uniform_stand.svg",
	"paper_compass.svg",
	"paper_telegraph_props.svg",
	"paper_foreground_frame.svg",
]

const EXPECTED_VIEWBOXES: Dictionary = {
	"paper_sky_bandirma.svg": "0 0 1800 900",
	"paper_fog_bands.svg": "0 0 1800 520",
	"paper_distant_coast.svg": "0 0 1600 420",
	"paper_cabin_wall.svg": "0 0 1500 900",
	"paper_sea_window.svg": "0 0 640 760",
	"paper_terrain_harbor.svg": "0 0 1400 900",
	"paper_main_path.svg": "0 0 900 900",
	"paper_bandirma_ship.svg": "0 0 1200 760",
	"paper_map_table.svg": "0 0 700 420",
	"paper_uniform_stand.svg": "0 0 420 620",
	"paper_compass.svg": "0 0 320 320",
	"paper_telegraph_props.svg": "0 0 560 360",
	"paper_foreground_frame.svg": "0 0 1800 780",
}

const REQUIRED_SLOT_METADATA: Dictionary = {
	"paper_bandirma_ship.svg": "ship.bandirma_hero",
	"paper_map_table.svg": "ship.map_table",
	"paper_uniform_stand.svg": "ship.uniform_stand",
	"paper_compass.svg": "ship.compass",
}

const RELATIVE_PATH_COMMANDS: Array[String] = ["m", "l", "c", "q", "a"]
const FORBIDDEN_ELEMENTS: Array[String] = ["<defs", "<text", "<image", "<use", "<symbol", "<tspan"]
const FORBIDDEN_SHAPE_ELEMENTS: Array[String] = ["<rect", "<circle", "<ellipse", "<g", "<line", "<polyline", "<polygon"]
const FORBIDDEN_ATTRIBUTES: Array[String] = [" style=", "\tstyle="]


func run_tests() -> Dictionary:
	print("=".repeat(60))
	print("Bandirma SVG Gecerlilik Testleri")
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
	print("Sonuc: %d / %d gecti  (%d basarisiz)" % [passed, total, failed])
	print("=".repeat(60))
	return {"passed": passed, "failed": failed, "total": total}


func _test_svg_file(file_name: String) -> Dictionary:
	var errors: Array[String] = []
	var path: String = SVG_DIR + file_name
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("Dosya acilamadi: %s (hata kodu: %d)" % [path, FileAccess.get_open_error()])
		return {"ok": false, "errors": errors}

	var content: String = file.get_as_text()
	var file_size: int = file.get_length()
	file.close()

	if not content.contains('xmlns="http://www.w3.org/2000/svg"'):
		errors.append('xmlns="http://www.w3.org/2000/svg" bildirimi eksik')

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

	for elem in FORBIDDEN_ELEMENTS:
		if content.contains(elem):
			errors.append('Yasak element bulundu: "%s"' % elem)

	for elem in FORBIDDEN_SHAPE_ELEMENTS:
		if content.contains(elem):
			errors.append('Yasak sekil elementi bulundu: "%s"' % elem)

	var relative_found: Array[String] = _find_relative_commands_in_paths(content)
	if not relative_found.is_empty():
		errors.append("Kucuk harf path komutu bulundu: %s" % ", ".join(relative_found))

	var path_count: int = _count_path_elements(content)
	if path_count < 2 or path_count > 5:
		errors.append("<path> sayisi 2-5 arasinda olmali, bulundu: %d" % path_count)

	var expected_viewbox: String = EXPECTED_VIEWBOXES[file_name]
	var actual_viewbox: String = _extract_attribute(content, "viewBox")
	if actual_viewbox.is_empty():
		errors.append('viewBox attribute bulunamadi (beklenen: "%s")' % expected_viewbox)
	elif actual_viewbox != expected_viewbox:
		errors.append('viewBox eslesmiyor - beklenen: "%s", bulunan: "%s"' % [expected_viewbox, actual_viewbox])

	if file_size >= 50 * 1024:
		errors.append("Dosya boyutu 50 KB altinda olmali, bulundu: %d byte" % file_size)

	if REQUIRED_SLOT_METADATA.has(file_name):
		var slot_id: String = REQUIRED_SLOT_METADATA[file_name]
		if not content.contains("<metadata><slot_id>%s</slot_id></metadata>" % slot_id):
			errors.append("Slot metadata eksik: %s" % slot_id)

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


func _extract_attribute(content: String, attribute_name: String) -> String:
	var prefix: String = '%s="' % attribute_name
	var start_idx: int = content.find(prefix)
	if start_idx == -1:
		return ""
	var value_start: int = start_idx + prefix.length()
	var value_end: int = content.find('"', value_start)
	if value_end == -1:
		return ""
	return content.substr(value_start, value_end - value_start)