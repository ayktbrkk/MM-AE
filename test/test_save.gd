## MMAE — SaveManager Validasyon Testleri
## =========================================
## SaveManager autoload singleton'ının varlığını
## ve save_setting / load_setting API'lerini doğrular.
##
## Testler:
##   1. SaveManager autoload'ı var
##   2. save_setting() metodu var
##   3. load_setting() metodu var
##   4. save_game() / load_game() ana API'leri var
## =========================================

extends Node


# ---------------------------------------------------------------------------
# Test 1: SaveManager autoload'ının var olduğunu doğrula
# ---------------------------------------------------------------------------
func test_save_manager_autoload_exists() -> String:
	"""SaveManager autoload singleton'ı var olmalı."""
	
	var save_manager: Variant = Engine.get_singleton("SaveManager")
	
	if save_manager == null:
		save_manager = get_node_or_null("/root/SaveManager")
	
	if save_manager == null:
		return "FAIL: SaveManager autoload singleton'i bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 2: save_setting() metodu var (kaynak kod okuma)
# ---------------------------------------------------------------------------
func test_save_setting_method_exists() -> String:
	"""SaveManager.save_setting() metodu mevcut olmalı (kaynak kod)."""
	
	var file := FileAccess.open("res://scripts/save_manager.gd", FileAccess.READ)
	if file == null:
		return "FAIL: save_manager.gd kaynak dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "func save_setting" in source_text:
		return "FAIL: save_manager.gd'de 'func save_setting' metodu bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 3: load_setting() metodu var (kaynak kod okuma)
# ---------------------------------------------------------------------------
func test_load_setting_method_exists() -> String:
	"""SaveManager.load_setting() metodu mevcut olmalı (kaynak kod)."""
	
	var file := FileAccess.open("res://scripts/save_manager.gd", FileAccess.READ)
	if file == null:
		return "FAIL: save_manager.gd kaynak dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "func load_setting" in source_text:
		return "FAIL: save_manager.gd'de 'func load_setting' metodu bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 4: save_game() / load_game() ana API'leri var (kaynak kod okuma)
# ---------------------------------------------------------------------------
func test_save_game_api_exists() -> String:
	"""SaveManager.save_game() ve load_game() metodları mevcut olmalı (kaynak kod)."""
	
	var file := FileAccess.open("res://scripts/save_manager.gd", FileAccess.READ)
	if file == null:
		return "FAIL: save_manager.gd kaynak dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "func save_game" in source_text:
		return "FAIL: save_manager.gd'de 'func save_game' metodu bulunamadi"
	
	if not "func load_game" in source_text:
		return "FAIL: save_manager.gd'de 'func load_game' metodu bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 5: Script seviyesinde method validasyonu (kaynak kod okuma)
# ---------------------------------------------------------------------------
func test_save_manager_script_has_required_methods() -> String:
	"""SaveManager script dosyasında tüm gerekli metodlar tanımlı olmalı."""
	
	var file := FileAccess.open("res://scripts/save_manager.gd", FileAccess.READ)
	if file == null:
		return "FAIL: save_manager.gd kaynak dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	var required_methods: Array[String] = [
		"func save_setting",
		"func load_setting",
		"func save_game",
		"func load_game",
		"func has_save",
		"func delete_save",
	]
	
	for method_name: String in required_methods:
		if not method_name in source_text:
			return "FAIL: save_manager.gd'de '%s' metodu bulunamadi" % method_name
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 6: SaveManager sinyalleri var (kaynak kod okuma)
# ---------------------------------------------------------------------------
func test_save_manager_signals_exist() -> String:
	"""SaveManager'da beklenen sinyaller tanımlı olmalı."""
	
	var file := FileAccess.open("res://scripts/save_manager.gd", FileAccess.READ)
	if file == null:
		return "FAIL: save_manager.gd kaynak dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	var expected_signals: Array[String] = [
		"signal game_saved",
		"signal game_loaded",
		"signal save_deleted",
		"signal save_corrupted",
		"signal settings_changed",
	]
	
	for signal_name: String in expected_signals:
		if not signal_name in source_text:
			return "FAIL: save_manager.gd'de '%s' sinyali bulunamadi" % signal_name
	
	return "OK"
