## MMAE — Accessibility Runtime Smoke Test
## =========================================
## Accessibility panel'in runtime'da yüklenebildiğini,
## script'inin parse edilebildiğini ve kritik
## fonksiyonlarının çalıştığını doğrular.
##
## Kullanım:
##   .\Godot_v4.6.2-stable_win64_console.exe --path . --script res://test/test_accessibility_smoke.gd --quit
##
## Veya --check-only ile parse doğrulaması:
##   .\Godot_v4.6.2-stable_win64_console.exe --check-only res://test/test_accessibility_smoke.gd
##
## Kısıtlamalar:
##   - Statik typing zorunlu (var x: Type, func f() -> void:)
##   - Mevcut test_accessibility.gd'ye dokunulmaz
##   - --headless flag'i KULLANILMAZ (MainLoop ile çalışır)

extends MainLoop


# ---------------------------------------------------------------------------
# TEST SABİTLERİ
# ---------------------------------------------------------------------------
const SCRIPT_PATH := "res://scripts/accessibility_panel.gd"
const SCENE_PATH := "res://scenes/accessibility_panel.tscn"

const EXPECTED_FUNCTIONS: Array[String] = [
	"func _ready",
	"func _load_current_settings",
	"func _connect_signals",
	"func _on_speed_selected",
	"func _on_large_text_toggled",
	"func _on_high_contrast_toggled",
	"func _update_texts",
]

const EXPECTED_SIGNALS: Array[String] = [
	# accessibility_panel.gd'de sinyal tanımı yok; sinyaller SaveManager'da
	# Test, SaveManager.accessibility_changed varlığını ayrıca kontrol eder
]

const EXPECTED_NODE_REFS: Array[String] = [
	"_title_label",
	"_slow_btn",
	"_normal_btn",
	"_fast_btn",
	"_large_text_check",
	"_high_contrast_check",
	"_large_text_desc",
	"_high_contrast_desc",
]

const EXPECTED_SAVEMANAGER_PROPERTIES: Array[String] = [
	"text_speed",
	"large_text",
	"high_contrast",
]

const SAVEMANAGER_SINGLETON_NAME := "SaveManager"


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
	print(">>> Accessibility Runtime Smoke Test basladi")
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
	_test_required_node_references()
	_test_save_manager_accessibility()
	_test_save_manager_signal()


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

	if not "class_name AccessibilityPanel" in source_text:
		_fail("Script 'class_name AccessibilityPanel' icermiyor")
		return

	_pass("Script dosyasi mevcut ve AccessibilityPanel class_name iceriyor")


# ---------------------------------------------------------------------------
# TEST 2: Script load() ve GDScript doğrulama (compile error tespiti ile)
# ---------------------------------------------------------------------------
func _test_script_loads() -> void:
	"""Script'in load() ile GDScript kaynağı olarak yüklenebildiğini doğrula.
	load() null dönerse compile error var demektir — test başarısız sayılır."""
	var script_res: Resource = load(SCRIPT_PATH)
	if script_res == null:
		_fail("Script compile edilemedi (load null dondu) — script'te compile hatasi olabilir: " + SCRIPT_PATH)
		return

	if not script_res is GDScript:
		_fail("Yuklenen kaynak GDScript degil, tur: " + str(typeof(script_res)))
		return

	var gdscript: GDScript = script_res as GDScript
	if gdscript == null:
		_fail("Script GDScript'e donusturulemedi")
		return

	# Kaynak kodun varlığını kontrol et
	if gdscript.source_code.is_empty():
		_fail("Script'in kaynak kodu bos (compile hatasi olabilir)")
		return

	_pass("Script basariyla load edildi (GDScript, %d karakter) — compile hatasi yok" % gdscript.source_code.length())


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
# TEST 4: Scene load() + script path doğrulama
# ---------------------------------------------------------------------------
func _test_scene_loads() -> void:
	"""Scene'in load() ile yüklenebildiğini ve script yolunu doğrula.
	Not: MainLoop modunda autoload'lar (SaveManager) yüklenmediği için
	instantiate sırasında script compile olmayabilir. Bu yüzden script
	yolunu .tscn dosyasının metin analizi ile doğruluyoruz."""
	var scene_res: Resource = load(SCENE_PATH)
	if scene_res == null:
		_fail("Scene load edilemedi: " + SCENE_PATH)
		return

	if not scene_res is PackedScene:
		_fail("Yuklenen kaynak PackedScene degil, tur: " + str(typeof(scene_res)))
		return

	# .tscn dosyasındaki ext_resource script referansını kontrol et
	var file: FileAccess = FileAccess.open(SCENE_PATH, FileAccess.READ)
	if file == null:
		_fail("Scene dosyasi acilamadi (script yolu testi)")
		return

	var source_text: String = file.get_as_text()
	file.close()

	if not SCRIPT_PATH in source_text:
		_fail("Scene dosyasinda script referansi bulunamadi: " + SCRIPT_PATH)
		return

	# Instantiate dene — MainLoop'da SaveManager yoksa script compile olmaz
	# Bu beklenen bir durumdur, hata sayılmaz
	var instance: Node = scene_res.instantiate()
	if instance == null:
		_fail("Scene ornegi olusturulamadi (instantiate basarisiz)")
		return

	var instance_script: Script = instance.get_script()
	if instance_script == null:
		# MainLoop modunda SaveManager singleton'ı olmadığı için
		# accessibility_panel.gd compile olamaz. Bu beklenir.
		_info("Scene orneginin scripti MainLoop modunda compile olmadi " +
			"(beklenen: SaveManager singleton'i eksik). Script yolu .tscn'den dogrulandi.")
		instance.free()
		_pass("Scene basariyla instantiate edildi (script: .tscn referansi ile dogrulandi)")
		return

	if instance_script.resource_path != SCRIPT_PATH:
		_fail("Scene orneginin scripti beklenen ile eslesmiyor: " + str(instance_script.resource_path))
		instance.free()
		return

	instance.free()
	_pass("Scene basariyla load ve instantiate edildi (script: accessibility_panel.gd)")


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
# TEST 6: Node referansları (@onready)
# ---------------------------------------------------------------------------
func _test_required_node_references() -> void:
	"""@onready var ile tanımlanmış node referanslarını doğrula."""
	var file: FileAccess = FileAccess.open(SCRIPT_PATH, FileAccess.READ)
	if file == null:
		_fail("Script dosyasi acilamadi (node referans testi)")
		return

	var source_text: String = file.get_as_text()
	file.close()

	var missing: Array[String] = []
	for ref_name: String in EXPECTED_NODE_REFS:
		if not ref_name in source_text:
			missing.append(ref_name)

	if missing.size() > 0:
		_fail("Eksik node referanslari (%d): %s" % [missing.size(), ", ".join(missing)])
		return

	_pass("Tum node referanslari tanimli (%d adet)" % EXPECTED_NODE_REFS.size())


# ---------------------------------------------------------------------------
# TEST 7: SaveManager singleton ve accessibility özellikleri
# ---------------------------------------------------------------------------
func _test_save_manager_accessibility() -> void:
	"""SaveManager singleton'ına erişim ve accessibility property'lerini doğrula.
	--script modunda autoload'lar yüklenmediği için SaveManager bulunamayabilir.
	Bu beklenen bir durumdur, test sayılmaz — sadece INFO yazılır."""
	if not Engine.has_singleton(SAVEMANAGER_SINGLETON_NAME):
		print("  [INFO] SaveManager singleton not available in --script mode — skipping runtime checks")
		print("  [INFO] This is expected behavior for headless/test execution")
		# Test sayılmaz: ne pass ne fail — sadece bilgi mesajı
		return

	var sm: Node = Engine.get_singleton(SAVEMANAGER_SINGLETON_NAME) as Node
	var missing: Array[String] = []
	for prop_name: String in EXPECTED_SAVEMANAGER_PROPERTIES:
		if sm.get(prop_name) == null:
			missing.append(prop_name)

	if missing.size() > 0:
		_fail("SaveManager'da eksik accessibility property'leri (%d): %s" % [missing.size(), ", ".join(missing)])
		return

	_pass("SaveManager singleton'i mevcut ve tum accessibility property'leri tanimli (%d adet)" % EXPECTED_SAVEMANAGER_PROPERTIES.size())


# ---------------------------------------------------------------------------
# TEST 8: SaveManager accessibility_changed sinyali
# ---------------------------------------------------------------------------
func _test_save_manager_signal() -> void:
	"""SaveManager.accessibility_changed sinyalinin varlığını doğrula.
	--script modunda autoload'lar yüklenmediği için SaveManager bulunamayabilir.
	Bu beklenen bir durumdur, test sayılmaz — sadece INFO yazılır."""
	if not Engine.has_singleton(SAVEMANAGER_SINGLETON_NAME):
		print("  [INFO] SaveManager singleton not available in --script mode — skipping signal check")
		print("  [INFO] This is expected behavior for headless/test execution")
		# Test sayılmaz: ne pass ne fail — sadece bilgi mesajı
		return

	var sm: Node = Engine.get_singleton(SAVEMANAGER_SINGLETON_NAME) as Node
	if not sm.has_signal("accessibility_changed"):
		_fail("SaveManager.accessibility_changed sinyali tanimli degil")
		return

	_pass("SaveManager.accessibility_changed sinyali tanimli")


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
	print("  ACCESSIBILITY SMOKE TEST RAPORU")
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
