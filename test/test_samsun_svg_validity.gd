## test_samsun_svg_validity.gd
## Samsun asset kit SVG dosyalarının XML geçerliliğini doğrular.
## Validates: Requirements 1.3, 1.6, 15.1, 15.2, 15.3, 15.4, 15.5
##
## Kullanım: run_tests() fonksiyonunu çağır.
## Godot editöründe veya GDScript test runner ile çalıştırılabilir.

extends RefCounted

const SVG_DIR := "res://assets/art/world/samsun/"

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

## Küçük harf (göreli koordinat) path komutları — bunlar bulunmamalı
const RELATIVE_PATH_COMMANDS: Array[String] = ["m", "l", "c", "q", "a"]

## Yasak elementler
const FORBIDDEN_ELEMENTS: Array[String] = ["<defs", "<text", "<image", "<use", "<symbol"]

## Yasak attribute
const FORBIDDEN_ATTRIBUTES: Array[String] = [" style=", "\tstyle="]


## Ana test giriş noktası.
## Tüm 25 SVG dosyasını test eder ve özet yazdırır.
## Döndürür: { "passed": int, "failed": int, "total": int }
func run_tests() -> Dictionary:
	print("=" .repeat(60))
	print("Samsun SVG Geçerlilik Testleri")
	print("=" .repeat(60))

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
	print("=" .repeat(60))
	print("Sonuç: %d / %d geçti  (%d başarısız)" % [passed, total, failed])
	print("=" .repeat(60))

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

	# --- Kural 1: xmlns bildirimi mevcut olmalı (Gereksinim 1.6, 15.1) ---
	if not content.contains('xmlns="http://www.w3.org/2000/svg"'):
		errors.append('xmlns="http://www.w3.org/2000/svg" bildirimi eksik')

	# --- Kural 2: style attribute bulunmamalı (Gereksinim 15.2) ---
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

	# --- Kural 3: Yasak elementler bulunmamalı (Gereksinim 15.2, 15.3, 15.5) ---
	for elem in FORBIDDEN_ELEMENTS:
		if content.contains(elem):
			errors.append('Yasak element bulundu: "%s"' % elem)

	# --- Kural 4: Göreli koordinat komutları bulunmamalı (Gereksinim 15.4) ---
	var relative_found: Array[String] = _find_relative_commands_in_paths(content)
	if not relative_found.is_empty():
		errors.append('Göreli (küçük harf) path komutları bulundu: %s' % ", ".join(relative_found))

	# --- Kural 5: <path> sayısı 2–5 arasında olmalı (Gereksinim 1.3) ---
	var path_count: int = _count_path_elements(content)
	if file_name == "paper_rift_core.svg":
		# paper_rift_core.svg tam 4 <path> içermeli (Gereksinim 10.1)
		if path_count != 4:
			errors.append('<path> sayısı tam 4 olmalı (paper_rift_core.svg), bulundu: %d' % path_count)
	else:
		if path_count < 2 or path_count > 5:
			errors.append('<path> sayısı 2–5 arasında olmalı, bulundu: %d' % path_count)

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
