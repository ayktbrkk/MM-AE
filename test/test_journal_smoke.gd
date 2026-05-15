## MMAE — Journal Runtime Smoke Test
## ===================================
## Journal overlay'in runtime'da yüklenebildiğini,
## script'inin parse edilebildiğini ve kritik
## fonksiyonlarının çalıştığını doğrular.
##
## Kullanım:
##   .\Godot_v4.6.2-stable_win64_console.exe --path . --script res://test/test_journal_smoke.gd --quit
##
## Veya --check-only ile parse doğrulaması:
##   .\Godot_v4.6.2-stable_win64_console.exe --check-only res://test/test_journal_smoke.gd
##
## Kısıtlamalar:
##   - Statik typing zorunlu (var x: Type, func f() -> void:)
##   - Mevcut test_journal.gd'ye dokunulmaz

extends MainLoop


# ---------------------------------------------------------------------------
# TEST SABİTLERİ
# ---------------------------------------------------------------------------
const SCRIPT_PATH := "res://scripts/journal_overlay.gd"
const SCENE_PATH := "res://scenes/journal_overlay.tscn"
const QUESTIONS_PATH := "res://assets/data/questions.gd"

const EXPECTED_FUNCTIONS: Array[String] = [
	"func show_overlay",
	"func hide_overlay",
	"func _ready",
	"func _exit_tree",
	"func get_overlay_type",
	"func _populate_tabs",
	"func _populate_cards_tab",
	"func _populate_chapters_tab",
	"func _get_card_data",
	"func _get_chapter_data",
	"func _on_close_pressed",
	"func _play_show_animation",
	"func _play_hide_animation",
]

const EXPECTED_SIGNALS: Array[String] = [
	"signal journal_closed",
]

# questions.gd'de aranacak journal sabitleri.
# NOT: JOURNAL_CHAPTER_IDS henüz tanımlı değil (gelecek paketlerde eklenecek).
const EXPECTED_QUESTIONS_CONSTANTS: Array[String] = [
	"JOURNAL_CARD_IDS",
]


# ---------------------------------------------------------------------------
# STATE
# ---------------------------------------------------------------------------
var _passed: int = 0
var _failed: int = 0
var _errors: PackedStringArray = []


# ---------------------------------------------------------------------------
# INIT
# ---------------------------------------------------------------------------
func _initialize() -> void:
	"""Tüm smoke testlerini çalıştır ve sonucu bildir."""
	print(">>> Journal Runtime Smoke Test basladi")
	print("")
	_run_all_tests()
	_print_report()


# ---------------------------------------------------------------------------
# TEST RUNNER
# ---------------------------------------------------------------------------
func _run_all_tests() -> void:
	"""Her testi sırayla çalıştır."""
	_test_script_exists()
	_test_script_loads()
	_test_scene_exists()
	_test_scene_loads()
	_test_required_functions()
	_test_required_signals()
	_test_questions_constants()
	_test_overlay_type_enum()
	_test_world_state_journal_getters()
	_test_journal_card_data_mapping()


# ---------------------------------------------------------------------------
# TEST 1: Script dosyası var
# ---------------------------------------------------------------------------
func _test_script_exists() -> void:
	"""Script dosyasının varlığını ve class_name içerdiğini kontrol et."""
	var file: FileAccess = FileAccess.open(SCRIPT_PATH, FileAccess.READ)
	if file == null:
		_fail("Script dosyasi bulunamadi: " + SCRIPT_PATH)
		return

	var source_text: String = file.get_as_text()
	file.close()

	if not "class_name JournalOverlay" in source_text:
		_fail("Script 'class_name JournalOverlay' icermiyor")
		return

	_pass("Script dosyasi mevcut ve JournalOverlay class_name iceriyor")


# ---------------------------------------------------------------------------
# TEST 2: Script load()
# ---------------------------------------------------------------------------
func _test_script_loads() -> void:
	"""Script'in load() ile başarıyla yüklenebildiğini doğrula."""
	var script_res: Resource = load(SCRIPT_PATH)
	if script_res == null:
		_fail("Script load edilemedi: " + SCRIPT_PATH)
		return

	if not script_res is GDScript:
		_fail("Yuklenen kaynak GDScript degil, tur: " + str(typeof(script_res)))
		return

	_pass("Script basariyla load edildi (GDScript)")


# ---------------------------------------------------------------------------
# TEST 3: Scene dosyası var
# ---------------------------------------------------------------------------
func _test_scene_exists() -> void:
	"""Scene dosyasının varlığını kontrol et."""
	var file: FileAccess = FileAccess.open(SCENE_PATH, FileAccess.READ)
	if file == null:
		_fail("Scene dosyasi bulunamadi: " + SCENE_PATH)
		return

	file.close()
	_pass("Scene dosyasi mevcut")


# ---------------------------------------------------------------------------
# TEST 4: Scene load() + instantiate
# ---------------------------------------------------------------------------
func _test_scene_loads() -> void:
	"""Scene'in load() ile yüklenip örnek oluşturulabildiğini doğrula."""
	var scene_res: Resource = load(SCENE_PATH)
	if scene_res == null:
		_fail("Scene load edilemedi: " + SCENE_PATH)
		return

	if not scene_res is PackedScene:
		_fail("Yuklenen kaynak PackedScene degil, tur: " + str(typeof(scene_res)))
		return

	var instance: Node = scene_res.instantiate()
	if instance == null:
		_fail("Scene ornegi olusturulamadi (instantiate basarisiz)")
		return

	# Script'in journal_overlay.gd olduğunu doğrula
	var instance_script: Script = instance.get_script()
	if instance_script == null:
		_fail("Scene orneginin scripti bulunamadi")
		instance.free()
		return

	if instance_script.resource_path != SCRIPT_PATH:
		_fail("Scene orneginin scripti beklenen ile eslesmiyor: " + str(instance_script.resource_path))
		instance.free()
		return

	instance.free()
	_pass("Scene basariyla load ve instantiate edildi (script: journal_overlay.gd)")


# ---------------------------------------------------------------------------
# TEST 5: Gerekli fonksiyonlar
# ---------------------------------------------------------------------------
func _test_required_functions() -> void:
	"""Script içindeki kritik fonksiyonların varlığını doğrula."""
	var file: FileAccess = FileAccess.open(SCRIPT_PATH, FileAccess.READ)
	if file == null:
		_fail("Script dosyasi acilamadi (fonksiyon testi)")
		return

	var source_text: String = file.get_as_text()
	file.close()

	var missing: Array[String] = []
	for func_name: String in EXPECTED_FUNCTIONS:
		if not func_name in source_text:
			missing.append(func_name)

	if missing.size() > 0:
		_fail("Eksik fonksiyonlar (%d): %s" % [missing.size(), ", ".join(missing)])
		return

	_pass("Tum kritik fonksiyonlar tanimli (%d adet)" % EXPECTED_FUNCTIONS.size())


# ---------------------------------------------------------------------------
# TEST 6: Gerekli sinyaller
# ---------------------------------------------------------------------------
func _test_required_signals() -> void:
	"""Script içindeki sinyallerin varlığını doğrula."""
	var file: FileAccess = FileAccess.open(SCRIPT_PATH, FileAccess.READ)
	if file == null:
		_fail("Script dosyasi acilamadi (sinyal testi)")
		return

	var source_text: String = file.get_as_text()
	file.close()

	var missing: Array[String] = []
	for signal_name: String in EXPECTED_SIGNALS:
		if not signal_name in source_text:
			missing.append(signal_name)

	if missing.size() > 0:
		_fail("Eksik sinyaller (%d): %s" % [missing.size(), ", ".join(missing)])
		return

	_pass("Tum kritik sinyaller tanimli (%d adet)" % EXPECTED_SIGNALS.size())


# ---------------------------------------------------------------------------
# TEST 7: questions.gd constants
# ---------------------------------------------------------------------------
func _test_questions_constants() -> void:
	"""questions.gd içinde journal sabitlerini doğrula."""
	var file: FileAccess = FileAccess.open(QUESTIONS_PATH, FileAccess.READ)
	if file == null:
		_fail("questions.gd dosyasi bulunamadi: " + QUESTIONS_PATH)
		return

	var source_text: String = file.get_as_text()
	file.close()

	var missing: Array[String] = []
	for const_name: String in EXPECTED_QUESTIONS_CONSTANTS:
		if not const_name in source_text:
			missing.append(const_name)

	if missing.size() > 0:
		_fail("questions.gd'de eksik sabitler (%d): %s" % [missing.size(), ", ".join(missing)])
		return

	_pass("questions.gd'de tum journal sabitleri tanimli (%d adet)" % EXPECTED_QUESTIONS_CONSTANTS.size())


# ---------------------------------------------------------------------------
# TEST 8: OverlayType.JOURNAL
# ---------------------------------------------------------------------------
func _test_overlay_type_enum() -> void:
	"""overlay_manager.gd içinde OverlayType.JOURNAL enum değerini doğrula."""
	var overlay_mgr_path := "res://scripts/overlay_manager.gd"
	var file: FileAccess = FileAccess.open(overlay_mgr_path, FileAccess.READ)
	if file == null:
		_info("overlay_manager.gd bulunamadi (opsiyonel kontrol)")
		_pass("overlay_manager.gd henuz olusturulmamis (opsiyonel)")
		return

	var source_text: String = file.get_as_text()
	file.close()

	if not "JOURNAL" in source_text:
		_fail("overlay_manager.gd'de OverlayType enum'unda JOURNAL degeri bulunamadi")
		return

	_pass("OverlayType.JOURNAL enum'unda tanimli")


# ---------------------------------------------------------------------------
# TEST 9: WorldState journal getter'ları
# ---------------------------------------------------------------------------
func _test_world_state_journal_getters() -> void:
	"""Journal overlay'in world_state'ten okuyacağı getter'ları doğrula."""
	var state_script: Resource = load("res://scripts/world_state.gd")
	if state_script == null or not state_script is GDScript:
		_fail("world_state.gd load edilemedi")
		return

	var state: Node = (state_script as GDScript).new()
	state.mark_card_collected("samsun_first_decision")
	state.mark_chapter_completed("samsun_cards")

	if not state.has_method("get_collected_card_ids") or not state.has_method("get_completed_chapters"):
		_fail("WorldState journal getter'lari eksik")
		state.free()
		return

	var card_ids: Array[String] = state.get_collected_card_ids()
	var chapter_ids: Array[String] = state.get_completed_chapters()
	if card_ids != ["samsun_first_decision"] or chapter_ids != ["samsun_cards"]:
		_fail("WorldState journal getter'lari beklenen ID'leri dondurmedi")
		state.free()
		return

	state.free()
	_pass("WorldState journal getter'lari runtime ID'lerini donduruyor")


# ---------------------------------------------------------------------------
# TEST 10: Journal kart veri eşlemesi
# ---------------------------------------------------------------------------
func _test_journal_card_data_mapping() -> void:
	"""JournalOverlay kart ID'sinden anlamlı başlık ve tag üretebiliyor."""
	var scene_res: Resource = load(SCENE_PATH)
	if scene_res == null or not scene_res is PackedScene:
		_fail("Journal scene veri esleme testi icin yuklenemedi")
		return

	var instance: Node = (scene_res as PackedScene).instantiate()
	var card_data: Dictionary = instance.call("_get_card_data", "samsun_first_decision")
	instance.free()

	if String(card_data.get("title", "")).is_empty() or String(card_data.get("tag", "")).is_empty():
		_fail("Journal kart veri eslemesi bos title/tag uretti")
		return
	if String(card_data.get("title", "")) == "First Decision":
		_fail("Journal kart veri eslemesi fallback baslikta kaldi")
		return

	_pass("Journal kart ID'leri questions.gd verisine esleniyor")


# ---------------------------------------------------------------------------
# YARDIMCILAR
# ---------------------------------------------------------------------------
func _info(message: String) -> void:
	"""Bilgilendirme mesajı (test sayılmaz)."""
	print("  [INFO] " + message)


func _pass(message: String) -> void:
	"""Test geçti olarak işaretle."""
	_passed += 1
	print("  [OK] " + message)


func _fail(message: String) -> void:
	"""Test başarısız olarak işaretle."""
	_failed += 1
	_errors.append(message)
	print("  [FAIL] " + message)


# ---------------------------------------------------------------------------
# RAPOR
# ---------------------------------------------------------------------------
func _print_report() -> void:
	"""Test raporunu konsola yazdır."""
	print("")
	print("=".repeat(60))
	print("  JOURNAL SMOKE TEST RAPORU")
	print("=".repeat(60))
	print("  Gecen:     %d" % _passed)
	print("  Basarisiz: %d" % _failed)
	print("  Toplam:    %d" % (_passed + _failed))
	if _errors.size() > 0:
		print("")
		print("  Hatalar:")
		for err: String in _errors:
			print("    - " + err)
	print("=".repeat(60))

	var result_str: String = "BASARILI" if _failed == 0 else "BASARISIZ"
	print("  SONUC: [%s]" % result_str)
	print("=".repeat(60))

	# Test sonucunu belirgin şekilde bildir
	# MainLoop'ta exit_code ayarlanamadığı için shell'de grep ile kontrol edilecek
	if _failed == 0:
		print("  EXIT_CODE: 0")
	else:
		print("  EXIT_CODE: 1")


# ---------------------------------------------------------------------------
# MAIN LOOP CALLBACKS
# ---------------------------------------------------------------------------
func _idle(_delta: float) -> bool:
	"""Idle callback — _initialize'da tüm testler çalıştı, çık."""
	return false  # false = MainLoop sonlanır


func _input_event(_event: InputEvent) -> void:
	"""Input event callback (kullanılmıyor)."""
	pass


func _input_text(_text: String) -> void:
	"""Input text callback (kullanılmıyor)."""
	pass


func _finalize() -> void:
	"""Cleanup."""
	pass
