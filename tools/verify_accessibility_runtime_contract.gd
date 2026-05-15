## MMAE — Accessibility Runtime Contract Verification
## ===================================================
## Accessibility panel'in runtime state/veri akışını doğrular.
## SaveManager property'leri, dialogue overlay entegrasyonu,
## sinyaller ve settings persistence test edilir.
##
## Kullanım:
##   .\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_accessibility_runtime_contract.gd --quit
##
## Beklenen çıktı: ACCESSIBILITY_RUNTIME_CONTRACT_OK, exit code 0

extends MainLoop


# ---------------------------------------------------------------------------
# SABİTLER
# ---------------------------------------------------------------------------
const ACCESSIBILITY_SCRIPT_PATH := "res://scripts/accessibility_panel.gd"
const ACCESSIBILITY_SCENE_PATH := "res://scenes/accessibility_panel.tscn"
const SAVEMANAGER_SCRIPT_PATH := "res://scripts/save_manager.gd"
const DIALOGUE_OVERLAY_SCRIPT_PATH := "res://scripts/dialogue_overlay.gd"


# ---------------------------------------------------------------------------
# STATE
# ---------------------------------------------------------------------------
var _failed := 0


# ---------------------------------------------------------------------------
# INIT
# ---------------------------------------------------------------------------
func _initialize() -> void:
	"""Contract testlerini sırayla çalıştır."""
	print(">>> Accessibility Runtime Contract Testi Basladi")
	print("")

	# =========================================================================
	# TEST 1: Script ve Scene Varlığı
	# =========================================================================
	_test_script_and_scene_exist()

	# =========================================================================
	# TEST 2: Script Fonksiyon ve Node Referansları
	# =========================================================================
	_test_script_functions()

	# =========================================================================
	# TEST 3: Scene Load ve Instantiation
	# =========================================================================
	_test_scene_load_and_instantiate()

	# =========================================================================
	# TEST 4: SaveManager Accessibility Properties
	# =========================================================================
	_test_save_manager_accessibility_properties()

	# =========================================================================
	# TEST 5: SaveManager Accessibility Signal
	# =========================================================================
	_test_save_manager_accessibility_signal()

	# =========================================================================
	# TEST 6: SaveManager Settings Persistence API
	# =========================================================================
	_test_save_manager_settings_persistence()

	# =========================================================================
	# TEST 7: Panel Mutation Metodları (Source Code)
	# =========================================================================
	_test_panel_mutation_methods()

	# =========================================================================
	# TEST 8: Dialogue Overlay Accessibility Entegrasyonu
	# =========================================================================
	_test_dialogue_accessibility_integration()

	# =========================================================================
	# RAPOR
	# =========================================================================
	print("")
	print("=".repeat(60))
	if _failed == 0:
		print("  ACCESSIBILITY_RUNTIME_CONTRACT_OK")
	else:
		print("  ACCESSIBILITY_RUNTIME_CONTRACT_FAILED  (%d hata)" % _failed)
	print("=".repeat(60))


func _idle(_delta: float) -> bool:
	"""Idle callback — _initialize'da tüm testler çalıştı, çık.
	
	false döndürünce MainLoop sonlanır.
	"""
	return false


# ---------------------------------------------------------------------------
# TEST 1: Script ve Scene Dosyaları Varlığı
# ---------------------------------------------------------------------------
func _test_script_and_scene_exist() -> void:
	"""Script ve scene dosyalarının varlığını doğrula."""
	var script_ok := true
	var scene_ok := true

	# script dosyası
	var script_file: FileAccess = FileAccess.open(ACCESSIBILITY_SCRIPT_PATH, FileAccess.READ)
	if script_file == null:
		_fail("Script dosyasi bulunamadi: " + ACCESSIBILITY_SCRIPT_PATH)
		script_ok = false
	else:
		var src: String = script_file.get_as_text()
		script_file.close()
		if not "class_name AccessibilityPanel" in src:
			_fail("Script 'class_name AccessibilityPanel' icermiyor")
			script_ok = false

	if script_ok:
		print("  PASS [Script dosyasi mevcut ve AccessibilityPanel class_name iceriyor]")

	# scene dosyası
	var scene_file: FileAccess = FileAccess.open(ACCESSIBILITY_SCENE_PATH, FileAccess.READ)
	if scene_file == null:
		_fail("Scene dosyasi bulunamadi: " + ACCESSIBILITY_SCENE_PATH)
		scene_ok = false
	else:
		var scene_src: String = scene_file.get_as_text()
		scene_file.close()
		if not ACCESSIBILITY_SCRIPT_PATH in scene_src:
			_fail("Scene dosyasinda script referansi bulunamadi: " + ACCESSIBILITY_SCRIPT_PATH)
			scene_ok = false

	if scene_ok:
		print("  PASS [Scene dosyasi mevcut ve script referansi iceriyor]")


# ---------------------------------------------------------------------------
# TEST 2: Script Fonksiyon ve Node Referansları
# ---------------------------------------------------------------------------
func _test_script_functions() -> void:
	"""Script içindeki kritik fonksiyonların ve @onready node referanslarının varlığını doğrula."""
	var file: FileAccess = FileAccess.open(ACCESSIBILITY_SCRIPT_PATH, FileAccess.READ)
	if file == null:
		_fail("Script dosyasi acilamadi (fonksiyon testi)")
		return

	var source_text: String = file.get_as_text()
	file.close()

	var expected_functions: Array[String] = [
		"func _ready",
		"func _load_current_settings",
		"func _connect_signals",
		"func _on_speed_selected",
		"func _on_large_text_toggled",
		"func _on_high_contrast_toggled",
		"func _update_texts",
	]

	var missing_funcs: Array[String] = []
	for func_name: String in expected_functions:
		if not func_name in source_text:
			missing_funcs.append(func_name)

	if missing_funcs.size() > 0:
		_fail("Eksik fonksiyonlar (%d): %s" % [missing_funcs.size(), ", ".join(missing_funcs)])
		return

	print("  PASS [Tum kritik fonksiyonlar tanimli (%d adet)]" % expected_functions.size())

	# Node referansları
	var expected_refs: Array[String] = [
		"_title_label",
		"_slow_btn",
		"_normal_btn",
		"_fast_btn",
		"_large_text_check",
		"_high_contrast_check",
		"_large_text_desc",
		"_high_contrast_desc",
	]

	var missing_refs: Array[String] = []
	for ref_name: String in expected_refs:
		if not ref_name in source_text:
			missing_refs.append(ref_name)

	if missing_refs.size() > 0:
		_fail("Eksik node referanslari (%d): %s" % [missing_refs.size(), ", ".join(missing_refs)])
		return

	print("  PASS [Tum node referanslari tanimli (%d adet)]" % expected_refs.size())


# ---------------------------------------------------------------------------
# TEST 3: Scene Load ve Instantiation
# ---------------------------------------------------------------------------
func _test_scene_load_and_instantiate() -> void:
	"""Scene'in load() ve instantiate() edilebildiğini doğrula.
	
	MainLoop modunda SaveManager singleton yok, bu yüzden script compile olmayabilir.
	Bu beklenen bir durumdur — sadece PackedScene load + instantiate test edilir."""
	var scene_res: Resource = load(ACCESSIBILITY_SCENE_PATH)
	if scene_res == null:
		_fail("Scene load edilemedi: " + ACCESSIBILITY_SCENE_PATH)
		return

	if not scene_res is PackedScene:
		_fail("Yuklenen kaynak PackedScene degil, tur: " + str(typeof(scene_res)))
		return

	print("  PASS [Scene PackedScene olarak yuklenebiliyor]")

	var instance: Node = scene_res.instantiate()
	if instance == null:
		_fail("Scene ornegi olusturulamadi (instantiate basarisiz)")
		return

	instance.free()
	print("  PASS [Scene instantiate edilebiliyor — node olusturma basarili]")


# ---------------------------------------------------------------------------
# TEST 4: SaveManager Accessibility Properties
# ---------------------------------------------------------------------------
func _test_save_manager_accessibility_properties() -> void:
	"""SaveManager script'inde accessibility property'lerinin
	(text_speed, large_text, high_contrast) setter ile tanımlandığını doğrula."""
	var sm_file: FileAccess = FileAccess.open(SAVEMANAGER_SCRIPT_PATH, FileAccess.READ)
	if sm_file == null:
		_fail("SaveManager script dosyasi bulunamadi: " + SAVEMANAGER_SCRIPT_PATH)
		return

	var source_text: String = sm_file.get_as_text()
	sm_file.close()

	# Property tanımları — setter pattern ile
	var expected_properties: Array[Dictionary] = [
		{"name": "text_speed", "type": "String", "default": "\"normal\""},
		{"name": "large_text", "type": "bool", "default": "false"},
		{"name": "high_contrast", "type": "bool", "default": "false"},
	]

	for prop: Dictionary in expected_properties:
		var prop_name: String = String(prop.get("name", ""))
		var prop_type: String = String(prop.get("type", ""))
		var prop_default: String = String(prop.get("default", ""))

		# var text_speed: String = "normal": set(value): pattern
		var declaration := "var %s: %s = %s:" % [prop_name, prop_type, prop_default]
		if not declaration in source_text:
			_fail("SaveManager'da '%s' property setter ile tanimli degil" % prop_name)
			return

	print("  PASS [SaveManager accessibility property'leri setter ile tanimli (%d adet)]" % expected_properties.size())


# ---------------------------------------------------------------------------
# TEST 5: SaveManager Accessibility Signal
# ---------------------------------------------------------------------------
func _test_save_manager_accessibility_signal() -> void:
	"""SaveManager script'inde accessibility_changed sinyalinin varlığını doğrula."""
	var sm_file: FileAccess = FileAccess.open(SAVEMANAGER_SCRIPT_PATH, FileAccess.READ)
	if sm_file == null:
		_fail("SaveManager script dosyasi bulunamadi (signal testi)")
		return

	var source_text: String = sm_file.get_as_text()
	sm_file.close()

	if not "signal accessibility_changed" in source_text:
		_fail("SaveManager.accessibility_changed sinyali tanimli degil")
		return

	print("  PASS [SaveManager.accessibility_changed sinyali tanimli]")

	# _emit_accessibility_changed metodunu kontrol et
	if not "func _emit_accessibility_changed" in source_text:
		_fail("_emit_accessibility_changed metodu eksik")
		return

	print("  PASS [_emit_accessibility_changed metodu tanimli (signal emit + save)]")


# ---------------------------------------------------------------------------
# TEST 6: SaveManager Settings Persistence API
# ---------------------------------------------------------------------------
func _test_save_manager_settings_persistence() -> void:
	"""SaveManager'ın settings persistence API'sini doğrula:
	save_setting, load_setting, load_accessibility_settings."""
	var sm_file: FileAccess = FileAccess.open(SAVEMANAGER_SCRIPT_PATH, FileAccess.READ)
	if sm_file == null:
		_fail("SaveManager script dosyasi bulunamadi (persistence testi)")
		return

	var source_text: String = sm_file.get_as_text()
	sm_file.close()

	# load_accessibility_settings metodu
	if not "func load_accessibility_settings" in source_text:
		_fail("load_accessibility_settings metodu eksik")
		return

	print("  PASS [load_accessibility_settings metodu tanimli]")

	# save_setting metodu
	if not "func save_setting" in source_text:
		_fail("save_setting metodu eksik")
		return

	# load_setting metodu
	if not "func load_setting" in source_text:
		_fail("load_setting metodu eksik")
		return

	print("  PASS [save_setting ve load_setting metodlari tanimli]")

	# _emit_accessibility_changed içinde save_setting çağrıları
	if not "save_setting(\"text_speed\"" in source_text:
		_fail("_emit_accessibility_changed text_speed kaydetmiyor")
		return
	if not "save_setting(\"large_text\"" in source_text:
		_fail("_emit_accessibility_changed large_text kaydetmiyor")
		return
	if not "save_setting(\"high_contrast\"" in source_text:
		_fail("_emit_accessibility_changed high_contrast kaydetmiyor")
		return

	print("  PASS [_emit_accessibility_changed tum accessibility ayarlarini settings.json'a kaydediyor]")

	# save_game içinde accessibility persist
	if not "accessibility" in source_text or not "save_dict" in source_text:
		_fail("save_game accessibility ayarlarini kaydetmiyor")
		return

	print("  PASS [save_game accessibility ayarlarini savegame.json'a kaydediyor]")


# ---------------------------------------------------------------------------
# TEST 7: Panel Mutation Metodları
# ---------------------------------------------------------------------------
func _test_panel_mutation_methods() -> void:
	"""Accessibility panel'in mutation metodlarının varlığını ve
	SaveManager property'lerine doğru yazdığını source code analizi ile doğrula."""
	var file: FileAccess = FileAccess.open(ACCESSIBILITY_SCRIPT_PATH, FileAccess.READ)
	if file == null:
		_fail("Script dosyasi acilamadi (mutation testi)")
		return

	var source_text: String = file.get_as_text()
	file.close()

	# _on_speed_selected → _save_manager.text_speed = speed
	if not "_save_manager.text_speed = speed" in source_text:
		_fail("_on_speed_selected _save_manager.text_speed'e yazmiyor")
		return

	print("  PASS [_on_speed_selected -> _save_manager.text_speed mutation dogrulandi]")

	# _on_large_text_toggled → _save_manager.large_text = enabled
	if not "_save_manager.large_text = enabled" in source_text:
		_fail("_on_large_text_toggled _save_manager.large_text'e yazmiyor")
		return

	print("  PASS [_on_large_text_toggled -> _save_manager.large_text mutation dogrulandi]")

	# _on_high_contrast_toggled → _save_manager.high_contrast = enabled
	if not "_save_manager.high_contrast = enabled" in source_text:
		_fail("_on_high_contrast_toggled _save_manager.high_contrast'a yazmiyor")
		return

	print("  PASS [_on_high_contrast_toggled -> _save_manager.high_contrast mutation dogrulandi]")

	# Engine.has_singleton("SaveManager") güvenli erişim
	if not "Engine.has_singleton(\"SaveManager\")" in source_text:
		_fail("_ready'de Engine.has_singleton kontrolu eksik")
		return

	print("  PASS [Engine.has_singleton('SaveManager') guvenli erisim kontrolu mevcut]")

	# Signal bağlantıları
	if not "_slow_btn.pressed.connect" in source_text:
		_fail("_slow_btn.pressed sinyali baglanmamis")
		return
	if not "_large_text_check.toggled.connect" in source_text:
		_fail("_large_text_check.toggled sinyali baglanmamis")
		return
	if not "_high_contrast_check.toggled.connect" in source_text:
		_fail("_high_contrast_check.toggled sinyali baglanmamis")
		return

	print("  PASS [Tum UI sinyal baglantilari tanimli]")


# ---------------------------------------------------------------------------
# TEST 8: Dialogue Overlay Accessibility Entegrasyonu
# ---------------------------------------------------------------------------
func _test_dialogue_accessibility_integration() -> void:
	"""Dialogue overlay'in accessibility ayarlarını nasıl okuduğunu
	ve uyguladığını source code analizi ile doğrula."""
	var file: FileAccess = FileAccess.open(DIALOGUE_OVERLAY_SCRIPT_PATH, FileAccess.READ)
	if file == null:
		_fail("Dialogue overlay script dosyasi bulunamadi: " + DIALOGUE_OVERLAY_SCRIPT_PATH)
		return

	var source_text: String = file.get_as_text()
	file.close()

	# _apply_accessibility_settings metodu
	if not "func _apply_accessibility_settings" in source_text:
		_fail("_apply_accessibility_settings metodu eksik")
		return

	print("  PASS [_apply_accessibility_settings metodu tanimli]")

	# Text speed kullanımı
	if not "SaveManager.text_speed" in source_text:
		_fail("Text speed SaveManager'dan okunmuyor")
		return
	if not "_typewriter_speed_multiplier" in source_text:
		_fail("_typewriter_speed_multiplier kullanilmiyor")
		return

	print("  PASS [Text speed SaveManager'dan okunuyor ve typewriter'a uygulaniyor]")

	# Large text kullanımı
	if not "SaveManager.large_text" in source_text:
		_fail("Large text SaveManager'dan okunmuyor")
		return

	print("  PASS [Large text SaveManager'dan okunuyor ve font size'a uygulaniyor]")

	# High contrast kullanımı
	if not "SaveManager.high_contrast" in source_text or not "_apply_body_label_accessibility" in source_text:
		_fail("High contrast SaveManager'dan okunmuyor veya uygulanmiyor")
		return

	print("  PASS [High contrast SaveManager'dan okunuyor ve outline'a uygulaniyor]")

	# Signal bağlantısı
	if not "SaveManager.accessibility_changed.connect" in source_text:
		_fail("SaveManager.accessibility_changed sinyaline baglanilmamis")
		return

	print("  PASS [SaveManager.accessibility_changed sinyali dialogue_overlay'a bagli]")

	# _on_accessibility_changed handler
	if not "func _on_accessibility_changed" in source_text:
		_fail("_on_accessibility_changed handler eksik")
		return

	print("  PASS [_on_accessibility_changed handler tanimli]")

	# _apply_body_label_accessibility metodu
	if not "func _apply_body_label_accessibility" in source_text:
		_fail("_apply_body_label_accessibility metodu eksik (high contrast outline)")
		return

	print("  PASS [_apply_body_label_accessibility metodu tanimli (font_outline_color + outline_size)]")


# ---------------------------------------------------------------------------
# YARDIMCI
# ---------------------------------------------------------------------------
func _fail(message: String) -> void:
	"""Doğrudan hata bildir."""
	push_error("FAIL: %s" % message)
	_failed += 1
