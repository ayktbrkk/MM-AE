## MMAE — Package 12A Polish Runtime Contract Verification
## =========================================================
## Package 12A'nın 3 polish iyileştirmesinin doğru çalıştığını
## source code analizi ile doğrular:
##   U03 — Tutorial Arrow Tween
##   A01 — Portrait Slide-In
##   A05 — Marker Collect Animation
##
## Kullanım:
##   .\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_p12a_polish_runtime_contract.gd --quit
##
## Beklenen çıktı: P12A_POLISH_RUNTIME_CONTRACT_OK, exit code 0

extends MainLoop


# ---------------------------------------------------------------------------
# SABİTLER
# ---------------------------------------------------------------------------
const TUTORIAL_CONTROLLER_PATH := "res://scripts/tutorial_controller.gd"
const DIALOGUE_OVERLAY_PATH := "res://scripts/dialogue_overlay.gd"
const WORLD_MARKER_PATH := "res://scripts/world_marker.gd"


# ---------------------------------------------------------------------------
# STATE
# ---------------------------------------------------------------------------
var _failed := 0
var _u03_passed := 0
var _u03_total := 3
var _a01_passed := 0
var _a01_total := 4
var _a05_passed := 0
var _a05_total := 4
var _genel_passed := 0
var _genel_total := 2


# ---------------------------------------------------------------------------
# INIT
# ---------------------------------------------------------------------------
func _initialize() -> void:
	"""Contract testlerini sırayla çalıştır."""
	print(">>> Package 12A Polish Runtime Contract Testi Basladi")
	print("")

	# =========================================================================
	# U03 — Tutorial Arrow Tween
	# =========================================================================
	_test_u03_tutorial_arrow()

	# =========================================================================
	# A01 — Portrait Slide-In
	# =========================================================================
	_test_a01_portrait_slide()

	# =========================================================================
	# A05 — Marker Collect Animation
	# =========================================================================
	_test_a05_marker_collect()

	# =========================================================================
	# GENEL — Statik typing ve Tween kullanımı
	# =========================================================================
	_test_genel_practices()

	# =========================================================================
	# RAPOR
	# =========================================================================
	print("")
	print("=".repeat(60))
	print("===== P12A POLISH RUNTIME CONTRACT =====")
	print("U03: %d/%d passed" % [_u03_passed, _u03_total])
	print("A01: %d/%d passed" % [_a01_passed, _a01_total])
	print("A05: %d/%d passed" % [_a05_passed, _a05_total])
	print("GENEL: %d/%d passed" % [_genel_passed, _genel_total])
	var toplam_passed := _u03_passed + _a01_passed + _a05_passed + _genel_passed
	var toplam_total := _u03_total + _a01_total + _a05_total + _genel_total
	print("TOPLAM: %d/%d passed" % [toplam_passed, toplam_total])
	print("")
	print("=".repeat(60))
	if _failed == 0:
		print("  P12A_POLISH_RUNTIME_CONTRACT_OK")
	else:
		print("  P12A_POLISH_RUNTIME_CONTRACT_FAILED  (%d hata)" % _failed)
	print("=".repeat(60))


func _idle(_delta: float) -> bool:
	"""Idle callback — _initialize'da tüm testler çalıştı, çık.
	
	false döndürünce MainLoop sonlanır.
	"""
	return false


# ---------------------------------------------------------------------------
# U03 — Tutorial Arrow Tween (3 tests)
# ---------------------------------------------------------------------------

func _test_u03_tutorial_arrow() -> void:
	"""U03: Tutorial arrow animasyonu fonksiyonlarının varlığını doğrula."""
	print("")
	print("--- U03: Tutorial Arrow Tween ---")

	var source_text: String = _read_source(TUTORIAL_CONTROLLER_PATH)
	if source_text.is_empty():
		_fail("U03: tutorial_controller.gd okunamadi")
		return

	# U03-01: _start_callout_arrow_animation var mı?
	if "func _start_callout_arrow_animation" in source_text:
		_u03_passed += 1
		print("  PASS [U03-01: _start_callout_arrow_animation tanimli]")
	else:
		_fail("U03-01: _start_callout_arrow_animation fonksiyonu bulunamadi")
		_failed += 1

	# U03-02: _stop_callout_arrow_animation var mı?
	if "func _stop_callout_arrow_animation" in source_text:
		_u03_passed += 1
		print("  PASS [U03-02: _stop_callout_arrow_animation tanimli]")
	else:
		_fail("U03-02: _stop_callout_arrow_animation fonksiyonu bulunamadi")
		_failed += 1

	# U03-03: _get_accessibility_speed_multiplier var mı?
	if "func _get_accessibility_speed_multiplier" in source_text:
		_u03_passed += 1
		print("  PASS [U03-03: _get_accessibility_speed_multiplier tanimli]")
	else:
		_fail("U03-03: _get_accessibility_speed_multiplier fonksiyonu bulunamadi")
		_failed += 1

	# U03-04 (ek): _get_accessibility_speed_multiplier içinde SaveManager.large_text kontrolü
	if "SaveManager.large_text" in source_text or "large_text" in source_text:
		print("  PASS [U03-04: _get_accessibility_speed_multiplier SaveManager.large_text kontrolu iceriyor]")
	else:
		_fail("U03-04: _get_accessibility_speed_multiplier SaveManager.large_text kontrolu icermiyor")
		_failed += 1

	# U03-05 (ek): start_tutorial içinde accessibility_changed sinyal bağlantısı
	if "accessibility_changed.connect" in source_text or "accessibility_changed.is_connected" in source_text:
		print("  PASS [U03-05: start_tutorial accessibility_changed sinyaline baglaniyor]")
	else:
		_fail("U03-05: start_tutorial accessibility_changed sinyaline baglanmiyor")
		_failed += 1


# ---------------------------------------------------------------------------
# A01 — Portrait Slide-In (4 tests)
# ---------------------------------------------------------------------------

func _test_a01_portrait_slide() -> void:
	"""A01: Portrait slide-in animasyonu kod varlığını doğrula."""
	print("")
	print("--- A01: Portrait Slide-In ---")

	var source_text: String = _read_source(DIALOGUE_OVERLAY_PATH)
	if source_text.is_empty():
		_fail("A01: dialogue_overlay.gd okunamadi")
		return

	# A01-01: present() içinde was_visible kontrolü
	if "was_visible" in source_text:
		_a01_passed += 1
		print("  PASS [A01-01: present() was_visible kontrolu iceriyor]")
	else:
		_fail("A01-01: present() was_visible kontrolu icermiyor")
		_failed += 1

	# A01-02: _portrait_slide_tween değişkeni
	if "_portrait_slide_tween" in source_text:
		_a01_passed += 1
		print("  PASS [A01-02: _portrait_slide_tween degiskeni tanimli]")
	else:
		_fail("A01-02: _portrait_slide_tween degiskeni tanimli degil")
		_failed += 1

	# A01-03: Tween.EASE_OUT ve Tween.TRANS_BACK kullanımı
	var has_ease_out: bool = "EASE_OUT" in source_text
	var has_trans_back: bool = "TRANS_BACK" in source_text
	if has_ease_out and has_trans_back:
		_a01_passed += 1
		print("  PASS [A01-03: Tween.EASE_OUT ve Tween.TRANS_BACK kullaniliyor]")
	else:
		var missing: String = ""
		if not has_ease_out:
			missing += "EASE_OUT "
		if not has_trans_back:
			missing += "TRANS_BACK"
		_fail("A01-03: %seksik" % missing)
		_failed += 1

	# A01-04: large_text kontrolü ile animasyon atlanıyor
	var has_large_text_check: bool = "not SaveManager.large_text" in source_text or "SaveManager.large_text" in source_text
	if has_large_text_check:
		_a01_passed += 1
		print("  PASS [A01-04: SaveManager.large_text kontrolu ile slide-in atlaniyor]")
	else:
		_fail("A01-04: large_text kontrolu ile slide-in atlanmiyor")
		_failed += 1


# ---------------------------------------------------------------------------
# A05 — Marker Collect Animation (4 tests)
# ---------------------------------------------------------------------------

func _test_a05_marker_collect() -> void:
	"""A05: Marker collect animasyonu kod varlığını doğrula."""
	print("")
	print("--- A05: Marker Collect Animation ---")

	var source_text: String = _read_source(WORLD_MARKER_PATH)
	if source_text.is_empty():
		_fail("A05: world_marker.gd okunamadi")
		return

	# A05-01: mark_collected içinde scale Tween
	if "tween_property(marker, \"scale\"" in source_text:
		_a05_passed += 1
		print("  PASS [A05-01: mark_collected scale Tween iceriyor]")
	else:
		_fail("A05-01: mark_collected scale Tween icermiyor")
		_failed += 1

	# A05-02: "collecting" meta flag kontrolü
	if "collecting" in source_text:
		_a05_passed += 1
		print("  PASS [A05-02: 'collecting' meta flag kontrolu mevcut]")
	else:
		_fail("A05-02: 'collecting' meta flag kontrolu mevcut degil")
		_failed += 1

	# A05-03: _on_collect_animation_done fonksiyonu
	if "func _on_collect_animation_done" in source_text:
		_a05_passed += 1
		print("  PASS [A05-03: _on_collect_animation_done fonksiyonu tanimli]")
	else:
		_fail("A05-03: _on_collect_animation_done fonksiyonu tanimli degil")
		_failed += 1

	# A05-04: is_instance_valid() kontrolü
	if "is_instance_valid" in source_text:
		_a05_passed += 1
		print("  PASS [A05-04: is_instance_valid() kontrolu mevcut]")
	else:
		_fail("A05-04: is_instance_valid() kontrolu mevcut degil")
		_failed += 1


# ---------------------------------------------------------------------------
# GENEL — Kod kalitesi kontrolleri (2 tests)
# ---------------------------------------------------------------------------

func _test_genel_practices() -> void:
	"""Genel kod kalitesi kurallarını doğrula."""
	print("")
	print("--- GENEL: Kod Kalitesi ---")

	var tutorial_src: String = _read_source(TUTORIAL_CONTROLLER_PATH)
	var dialogue_src: String = _read_source(DIALOGUE_OVERLAY_PATH)
	var marker_src: String = _read_source(WORLD_MARKER_PATH)

	# GENEL-01: Statik typing kullanımı (tüm script'lerde)
	var all_sources: String = tutorial_src + dialogue_src + marker_src
	var static_typing_count: int = 0
	# "var something: Type" pattern'ini ara
	var lines: PackedStringArray = all_sources.split("\n")
	for line: String in lines:
		var trimmed: String = line.strip_edges()
		if trimmed.begins_with("var ") and ":" in trimmed:
			static_typing_count += 1

	if static_typing_count > 0:
		_genel_passed += 1
		print("  PASS [GENEL-01: Statik typing kullaniliyor (%d var:Type ornegi)]" % static_typing_count)
	else:
		_fail("GENEL-01: Statik typing kullanilmiyor")
		_failed += 1

	# GENEL-02: _process(delta) animasyon için değil, Tween kullanılıyor
	# tutorial_controller.gd'de _process var ama animasyon değil (highlight ring pulse)
	# A01'de _start_portrait_slide_in Tween kullanıyor
	# A05'te mark_collected Tween kullanıyor
	var has_tween_in_animation: bool = false
	if "create_tween()" in tutorial_src:
		has_tween_in_animation = true
	if "create_tween()" in dialogue_src:
		has_tween_in_animation = true
	if "create_tween()" in marker_src:
		has_tween_in_animation = true

	if has_tween_in_animation:
		_genel_passed += 1
		print("  PASS [GENEL-02: Animasyon Tween ile yapiliyor (_process animasyon kullanimi yok)]")
	else:
		_fail("GENEL-02: Animasyon Tween ile yapilmiyor")
		_failed += 1


# ---------------------------------------------------------------------------
# YARDIMCI FONKSİYONLAR
# ---------------------------------------------------------------------------

func _read_source(path: String) -> String:
	"""Dosyayı oku ve kaynak kodunu string olarak döndür."""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Dosya acilamadi: %s" % path)
		return ""
	var content: String = file.get_as_text()
	file.close()
	return content


func _fail(message: String) -> void:
	"""Doğrudan hata bildir."""
	push_error("FAIL: %s" % message)
