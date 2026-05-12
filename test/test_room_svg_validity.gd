## test_room_svg_validity.gd
## Room asset kit SVG dosyalarının XML geçerliliğini doğrular.
## Validates: Requirements 1.3, 1.6, 3.1, 3.2, 3.3, 3.4, 16.1, 16.4, 16.5
##
## Kullanım: run_tests() fonksiyonunu çağır.
## Godot editöründe veya GDScript test runner ile çalıştırılabilir.

extends RefCounted

const SVG_DIR := "res://assets/art/world/room/"

const SVG_FILES: Array[String] = [
	"paper_wall_window.svg",
	"paper_wall_story.svg",
	"paper_terrain_room.svg",
	"paper_shelf.svg",
	"paper_desk_clutter.svg",
	"paper_study_nook.svg",
	"paper_bed.svg",
	"paper_floor_rug.svg",
	"paper_book_portal.svg",
	"paper_foreground_frame.svg",
]

## Beklenen viewBox değerleri
const EXPECTED_VIEWBOXES: Dictionary = {
	"paper_wall_window.svg":      "0 0 1500 780",
	"paper_wall_story.svg":       "0 0 900 420",
	"paper_terrain_room.svg":     "0 0 800 600",
	"paper_shelf.svg":            "0 0 520 760",
	"paper_desk_clutter.svg":     "0 0 520 300",
	"paper_study_nook.svg":       "0 0 720 520",
	"paper_bed.svg":              "0 0 720 520",
	"paper_floor_rug.svg":        "0 0 980 560",
	"paper_book_portal.svg":      "0 0 420 340",
	"paper_foreground_frame.svg": "0 0 1600 780",
}

## Küçük harf (göreli koordinat) path komutları — bunlar bulunmamalı
const RELATIVE_PATH_COMMANDS: Array[String] = ["m", "l", "c", "q", "a"]

## Yasak elementler
const FORBIDDEN_ELEMENTS: Array[String] = ["<defs", "<text", "<image", "<use", "<symbol"]

## Yasak şekil elementleri
const FORBIDDEN_SHAPE_ELEMENTS: Array[String] = ["<rect", "<circle", "<ellipse", "<g"]

## Yasak attribute
const FORBIDDEN_ATTRIBUTES: Array[String] = [" style=", "\tstyle="]


## Ana test giriş noktası.
## Tüm 10 SVG dosyasını test eder ve özet yazdırır.
## Döndürür: { "passed": int, "failed": int, "total": int }
func run_tests() -> Dictionary:
	print("=".repeat(60))
	print("Room SVG Geçerlilik Testleri")
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


## Tek bir SVG dosyasını tüm kurallara göre test eder.
## Döndürür: { "ok": bool, "errors": Array[String] }
func _test_svg_file(file_name: String) -> Dictionary:
	var errors: Array[String] = []
	var path: String = SVG_DIR + file_name

	# Dosyayı oku
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("Dosya açılamadı: %s (hata kodu: %d)" % [path, FileAccess.get_open_error()])
		return {"ok": false, "errors": errors}

	var content: String = file.get_as_text()
	file.close()

	if content.is_empty():
		errors.append("Dosya boş: %s" % path)
		return {"ok": false, "errors": errors}

	# --- Kural 1: xmlns bildirimi mevcut olmalı (Gereksinim 1.6, 16.1) ---
	if not content.contains('xmlns="http://www.w3.org/2000/svg"'):
		errors.append('xmlns="http://www.w3.org/2000/svg" bildirimi eksik')

	# --- Kural 2: style attribute bulunmamalı (Gereksinim 3.2) ---
	for attr in FORBIDDEN_ATTRIBUTES:
		if content.contains(attr):
			errors.append('"style" attribute bulundu — yasak')
			break
	# Ayrıca style= genel olarak kontrol et (tırnak türünden bağımsız)
	if _contains_style_attribute(content):
		# Zaten yukarıda yakalanmış olabilir; tekrar ekleme
		var already_reported: bool = false
		for e in errors:
			if '"style" attribute' in e:
				already_reported = true
				break
		if not already_reported:
			errors.append('"style" attribute bulundu — yasak')

	# --- Kural 3: Yasak elementler bulunmamalı (Gereksinim 3.3, 16.4) ---
	for elem in FORBIDDEN_ELEMENTS:
		if content.contains(elem):
			errors.append('Yasak element bulundu: "%s"' % elem)

	# --- Kural 4: Yasak şekil elementleri bulunmamalı (Gereksinim 3.4, 16.5) ---
	for elem in FORBIDDEN_SHAPE_ELEMENTS:
		if content.contains(elem):
			errors.append('Yasak şekil elementi bulundu: "%s"' % elem)

	# --- Kural 5: Göreli koordinat komutları bulunmamalı (Gereksinim 3.1) ---
	var relative_found: Array[String] = _find_relative_commands_in_paths(content)
	if not relative_found.is_empty():
		errors.append('Göreli (küçük harf) path komutları bulundu: %s' % ", ".join(relative_found))

	# --- Kural 6: <path> sayısı 2–5 arasında olmalı (Gereksinim 1.3) ---
	var path_count: int = _count_path_elements(content)
	if path_count < 2 or path_count > 5:
		errors.append('<path> sayısı 2–5 arasında olmalı, bulundu: %d' % path_count)

	# --- Kural 7: viewBox beklenen değerle eşleşmeli (Gereksinim 16.1, 16.4) ---
	if EXPECTED_VIEWBOXES.has(file_name):
		var expected_viewbox: String = EXPECTED_VIEWBOXES[file_name]
		var actual_viewbox: String = _extract_viewbox(content)
		if actual_viewbox.is_empty():
			errors.append('viewBox attribute bulunamadı (beklenen: "%s")' % expected_viewbox)
		elif actual_viewbox != expected_viewbox:
			errors.append('viewBox eşleşmiyor — beklenen: "%s", bulunan: "%s"' % [expected_viewbox, actual_viewbox])

	return {"ok": errors.is_empty(), "errors": errors}


## SVG içeriğinde style attribute varlığını kontrol eder.
## Hem style=" hem style=' biçimlerini yakalar.
func _contains_style_attribute(content: String) -> bool:
	# Boşluk veya tab ile başlayan style= attribute'unu ara
	var patterns: Array[String] = [" style=", "\tstyle=", "\nstyle=", ">style="]
	for pattern in patterns:
		if content.contains(pattern):
			return true
	return false


## SVG içeriğindeki <path d="..."> attribute'larında göreli komut arar.
## Döndürür: bulunan göreli komutların listesi (tekrarsız)
func _find_relative_commands_in_paths(content: String) -> Array[String]:
	var found: Array[String] = []

	# Tüm d="..." veya d='...' bloklarını bul ve içlerini tara
	var d_blocks: Array[String] = _extract_d_attributes(content)

	for block in d_blocks:
		for cmd in RELATIVE_PATH_COMMANDS:
			if not found.has(cmd):
				# Komutun path verisi içinde geçip geçmediğini kontrol et
				# Sayı içinde geçen 'e' (bilimsel notasyon) ile karışmaması için
				# komutun harf olarak (öncesinde harf olmayan) geçtiğini doğrula
				if _path_contains_command(block, cmd):
					found.append(cmd)

	return found


## Bir path d değerinde belirli bir komut harfinin geçip geçmediğini kontrol eder.
## Sayısal değerlerdeki harflerle (örn. bilimsel notasyondaki 'e') karışmaz.
func _path_contains_command(d_value: String, cmd: String) -> bool:
	var i: int = 0
	while i < d_value.length():
		var ch: String = d_value[i]
		if ch == cmd:
			# Önceki karakter harf veya rakam değilse bu bir komuttur
			var prev_is_alnum: bool = false
			if i > 0:
				var prev: String = d_value[i - 1]
				prev_is_alnum = (prev >= "a" and prev <= "z") or (prev >= "A" and prev <= "Z") or (prev >= "0" and prev <= "9")
			if not prev_is_alnum:
				return true
		i += 1
	return false


## SVG içeriğinden tüm d="..." attribute değerlerini çıkarır.
func _extract_d_attributes(content: String) -> Array[String]:
	var results: Array[String] = []
	var search_from: int = 0

	while true:
		# d=" veya d=' ile başlayan attribute'u bul
		var idx_double: int = content.find(' d="', search_from)
		var idx_single: int = content.find(" d='", search_from)

		# Hangisi önce geliyorsa onu işle
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

		# Attribute değerinin başlangıcını bul (d=" sonrası)
		var value_start: int = idx + 4  # ' d="' = 4 karakter
		var value_end: int = content.find(quote_char, value_start)

		if value_end == -1:
			break

		var d_value: String = content.substr(value_start, value_end - value_start)
		results.append(d_value)
		search_from = value_end + 1

	return results


## SVG içeriğindeki <path ... /> veya <path ...> element sayısını sayar.
func _count_path_elements(content: String) -> int:
	var count: int = 0
	var search_from: int = 0

	while true:
		var idx: int = content.find("<path", search_from)
		if idx == -1:
			break
		# <path ile başlayan ve ardından boşluk, > veya / gelen elementleri say
		# (örn. <pathfinder gibi başka elementlerle karışmasın)
		var next_char_idx: int = idx + 5
		if next_char_idx < content.length():
			var next_char: String = content[next_char_idx]
			if next_char == " " or next_char == ">" or next_char == "/" or next_char == "\t" or next_char == "\n":
				count += 1
		search_from = idx + 1

	return count


## SVG içeriğinden viewBox attribute değerini çıkarır.
## Döndürür: viewBox değeri (örn. "0 0 1500 780") veya boş string
func _extract_viewbox(content: String) -> String:
	# viewBox=" veya viewBox=' biçimlerini ara
	var idx_double: int = content.find('viewBox="')
	var idx_single: int = content.find("viewBox='")

	var idx: int = -1
	var quote_char: String = '"'
	var prefix_len: int = 9  # 'viewBox="' = 9 karakter

	if idx_double == -1 and idx_single == -1:
		return ""
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

	var value_start: int = idx + prefix_len
	var value_end: int = content.find(quote_char, value_start)

	if value_end == -1:
		return ""

	return content.substr(value_start, value_end - value_start)
