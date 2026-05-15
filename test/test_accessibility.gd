## MMAE — P10: Accessibility Testleri
## =====================================
## SaveManager accessibility ayarlarini, UI text sabitlerini,
## AccessibilityPanel varligini ve overlay entegrasyonunu test eder.
##
## Kullanim:
##   Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://test/test_runner.gd --quit

extends Node


func _get_sm() -> Node:
	"""SaveManager singleton'ina guvenli erisim."""
	return Engine.get_singleton("SaveManager") as Node


# ---------------------------------------------------------------------------
# Test 1: SaveManager accessibility degiskenleri mevcut mu?
# ---------------------------------------------------------------------------
func test_accessibility_settings_exist() -> String:
	var sm := _get_sm()
	if sm == null:
		return "FAIL: SaveManager singleton'i bulunamadi"

	if sm.get("text_speed") == null:
		return "FAIL: SaveManager.text_speed tanimli degil"
	if sm.get("large_text") == null:
		return "FAIL: SaveManager.large_text tanimli degil"
	if sm.get("high_contrast") == null:
		return "FAIL: SaveManager.high_contrast tanimli degil"

	return "OK"


# ---------------------------------------------------------------------------
# Test 2: SaveManager accessibility_changed sinyali mevcut mu?
# ---------------------------------------------------------------------------
func test_accessibility_signal_exists() -> String:
	var sm := _get_sm()
	if sm == null:
		return "FAIL: SaveManager singleton'i bulunamadi"

	if not sm.has_signal("accessibility_changed"):
		return "FAIL: SaveManager.accessibility_changed sinyali tanimli degil"
	return "OK"


# ---------------------------------------------------------------------------
# Test 3: SaveManager.load_accessibility_settings() metodu mevcut mu?
# ---------------------------------------------------------------------------
func test_load_accessibility_settings_method() -> String:
	var sm := _get_sm()
	if sm == null:
		return "FAIL: SaveManager singleton'i bulunamadi"

	if not sm.has_method("load_accessibility_settings"):
		return "FAIL: SaveManager.load_accessibility_settings() metodu yok"
	return "OK"


# ---------------------------------------------------------------------------
# Test 4: UIText accessibility sabitleri mevcut mu?
# ---------------------------------------------------------------------------
func test_ui_text_accessibility_constants() -> String:
	var expected: Dictionary = {
		"ACCESSIBILITY_TITLE": "ui.accessibility.title",
		"ACCESSIBILITY_TEXT_SPEED": "ui.accessibility.text_speed",
		"ACCESSIBILITY_TEXT_SPEED_SLOW": "ui.accessibility.text_speed.slow",
		"ACCESSIBILITY_TEXT_SPEED_NORMAL": "ui.accessibility.text_speed.normal",
		"ACCESSIBILITY_TEXT_SPEED_FAST": "ui.accessibility.text_speed.fast",
		"ACCESSIBILITY_LARGE_TEXT": "ui.accessibility.large_text",
		"ACCESSIBILITY_HIGH_CONTRAST": "ui.accessibility.high_contrast",
	}
	var ui_instance := UIText.new()
	for const_name: String in expected.keys():
		var value: Variant = ui_instance.get(const_name)
		if value == null:
			return "FAIL: UIText.%s tanimli degil" % const_name
		if value != expected[const_name]:
			return "FAIL: UIText.%s beklenen '%s' degil, '%s' geldi" % [const_name, expected[const_name], str(value)]
	return "OK"


# ---------------------------------------------------------------------------
# Test 5: AccessibilityPanel scripti class_name olarak tanimli mi?
# ---------------------------------------------------------------------------
func test_accessibility_panel_class() -> String:
	if not ClassDB.class_exists("AccessibilityPanel"):
		return "FAIL: AccessibilityPanel class_name olarak tanimli degil"
	return "OK"


# ---------------------------------------------------------------------------
# Test 6: accessibility_panel.tscn sahnesi mevcut mu?
# ---------------------------------------------------------------------------
func test_accessibility_panel_scene_exists() -> String:
	var path := "res://scenes/accessibility_panel.tscn"
	if not ResourceLoader.exists(path):
		return "FAIL: accessibility_panel.tscn bulunamadi"
	var scene: PackedScene = load(path)
	if scene == null:
		return "FAIL: accessibility_panel.tscn yuklenemedi"
	return "OK"


# ---------------------------------------------------------------------------
# Test 7: main_menu.gd accessibility butonu ve overlay degiskenleri
# ---------------------------------------------------------------------------
func test_main_menu_accessibility_vars() -> String:
	var script_path := "res://scripts/main_menu.gd"
	var gdscript := load(script_path) as GDScript
	if gdscript == null:
		return "FAIL: main_menu.gd yuklenemedi"

	var source: String = gdscript.source_code
	var checks: Array[Dictionary] = [
		{"name": "accessibility_button", "label": "accessibility_button degiskeni"},
		{"name": "accessibility_overlay", "label": "accessibility_overlay degiskeni"},
		{"name": "accessibility_panel_instance", "label": "accessibility_panel_instance degiskeni"},
		{"name": "ACCESSIBILITY_PANEL_SCENE", "label": "ACCESSIBILITY_PANEL_SCENE sabiti"},
	]
	for check: Dictionary in checks:
		if not source.contains(check["name"]):
			return "FAIL: main_menu.gd -> %s tanimli degil" % check["label"]

	return "OK"


# ---------------------------------------------------------------------------
# Test 8: Translation CSV'de accessibility anahtarlari mevcut mu?
# ---------------------------------------------------------------------------
func test_translation_keys_exist() -> String:
	var expected_keys: Array[String] = [
		"ui.accessibility.title",
		"ui.accessibility.text_speed",
		"ui.accessibility.text_speed.slow",
		"ui.accessibility.text_speed.normal",
		"ui.accessibility.text_speed.fast",
		"ui.accessibility.large_text",
		"ui.accessibility.high_contrast",
		"ui.accessibility.large_text.desc",
		"ui.accessibility.high_contrast.desc",
	]
	for key: String in expected_keys:
		var translated := TranslationServer.translate(key)
		if translated.is_empty() or translated == key:
			return "FAIL: CSV'de '%s' anahtari eksik veya cevrilmemis" % key
	return "OK"


# ---------------------------------------------------------------------------
# Test 9: dialogue_overlay.gd typewriter_speed_multiplier degiskeni
# ---------------------------------------------------------------------------
func test_dialogue_typewriter_multiplier() -> String:
	var script_path := "res://scripts/dialogue_overlay.gd"
	var gdscript := load(script_path) as GDScript
	if gdscript == null:
		return "FAIL: dialogue_overlay.gd yuklenemedi"

	var source: String = gdscript.source_code
	if not source.contains("_typewriter_speed_multiplier"):
		return "FAIL: dialogue_overlay.gd -> _typewriter_speed_multiplier yok"
	if not source.contains("_apply_accessibility_settings"):
		return "FAIL: dialogue_overlay.gd -> _apply_accessibility_settings() yok"
	if not source.contains("SaveManager.accessibility_changed.connect"):
		return "FAIL: dialogue_overlay.gd -> accessibility_changed baglantisi yok"

	return "OK"


# ---------------------------------------------------------------------------
# Test 10: info_card_overlay.gd'de accessibility entegrasyonu
# ---------------------------------------------------------------------------
func test_info_card_accessibility() -> String:
	var script_path := "res://scripts/info_card_overlay.gd"
	var gdscript := load(script_path) as GDScript
	if gdscript == null:
		return "FAIL: info_card_overlay.gd yuklenemedi"

	var source: String = gdscript.source_code
	if not source.contains("_apply_accessibility_settings"):
		return "FAIL: info_card_overlay.gd -> _apply_accessibility_settings() yok"
	if not source.contains("SaveManager.accessibility_changed.connect"):
		return "FAIL: info_card_overlay.gd -> accessibility_changed baglantisi yok"

	return "OK"


# ---------------------------------------------------------------------------
# Test 11: decision_overlay.gd'de accessibility entegrasyonu
# ---------------------------------------------------------------------------
func test_decision_accessibility() -> String:
	var script_path := "res://scripts/decision_overlay.gd"
	var gdscript := load(script_path) as GDScript
	if gdscript == null:
		return "FAIL: decision_overlay.gd yuklenemedi"

	var source: String = gdscript.source_code
	if not source.contains("_apply_accessibility_settings"):
		return "FAIL: decision_overlay.gd -> _apply_accessibility_settings() yok"
	if not source.contains("SaveManager.accessibility_changed.connect"):
		return "FAIL: decision_overlay.gd -> accessibility_changed baglantisi yok"

	return "OK"
