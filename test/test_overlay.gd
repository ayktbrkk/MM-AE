## MMAE — Overlay Sistemi Validasyon Testleri
## ==============================================
## overlay_manager.gd içindeki OverlayType enum'ı ve
## layer mapping'in doğruluğunu test eder.
##
## Testler:
##   1. OverlayType enum'ı tüm tipleri içerir
##   2. LAYER_BASE ve layer mapping doğru
##   3. Public API metodları mevcut
## ==============================================

extends Node

var _om_constants: Dictionary


func _init() -> void:
	var om_script: GDScript = load("res://scripts/overlay_manager.gd")
	_om_constants = om_script.get_script_constant_map()


# ---------------------------------------------------------------------------
# Test 1: OverlayType enum'ı tüm tipleri içerir
# ---------------------------------------------------------------------------
func test_overlay_type_enum_has_all_types() -> String:
	"""OverlayType enum'ında tanımlı tüm overlay tipleri mevcut olmalı."""
	
	if not _om_constants.has("OverlayType"):
		return "FAIL: OverlayType enum'i overlay_manager.gd'de bulunamadi"
	
	var overlay_type: Dictionary = _om_constants["OverlayType"] as Dictionary
	
	var expected_types: Dictionary = {
		"DIALOGUE": 0,
		"DECISION": 1,
		"INFO_CARD": 2,
		"CHAPTER_TRANSITION": 3,
		"DREAM_INTRO": 4,
		"EXIT_CONFIRM": 5,
		"LOADING": 6,
	}
	
	for type_name: String in expected_types:
		if not overlay_type.has(type_name):
			return "FAIL: OverlayType enum'inda '%s' eksik" % type_name
		
		var expected_value: int = expected_types[type_name]
		var actual_value: int = overlay_type[type_name]
		if actual_value != expected_value:
			return "FAIL: OverlayType.%s = %d, beklenen %d" % [type_name, actual_value, expected_value]
	
	if overlay_type.size() != expected_types.size():
		return "FAIL: OverlayType enum'i %d deger iceriyor, beklenen %d" % [overlay_type.size(), expected_types.size()]
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 2: LAYER_BASE ve layer mapping doğru
# ---------------------------------------------------------------------------
func test_layer_base_and_mapping() -> String:
	"""LAYER_BASE = 50 ve her overlay kendi layer'ında olmalı."""
	
	if not _om_constants.has("LAYER_BASE"):
		return "FAIL: LAYER_BASE sabiti overlay_manager.gd'de bulunamadi"
	
	if not _om_constants.has("OverlayType"):
		return "FAIL: OverlayType enum'i bulunamadi"
	
	var layer_base: int = _om_constants["LAYER_BASE"] as int
	var overlay_type: Dictionary = _om_constants["OverlayType"] as Dictionary
	
	if layer_base != 50:
		return "FAIL: LAYER_BASE = %d, beklenen 50" % layer_base
	
	var expected_layers: Dictionary = {
		"DIALOGUE": 50,
		"DECISION": 60,
		"INFO_CARD": 70,
		"CHAPTER_TRANSITION": 80,
		"DREAM_INTRO": 90,
		"EXIT_CONFIRM": 100,
		"LOADING": 110,
	}
	
	for type_name: String in expected_layers:
		if not overlay_type.has(type_name):
			continue
		
		var enum_value: int = overlay_type[type_name]
		var expected_layer: int = expected_layers[type_name]
		var calculated_layer: int = layer_base + enum_value * 10
		
		if calculated_layer != expected_layer:
			return "FAIL: %s layer = layer_base(%d) + enum(%d) * 10 = %d, beklenen %d" % [
				type_name, layer_base, enum_value, calculated_layer, expected_layer
			]
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 3: OverlayManager public API metodları mevcut (kaynak kod okuma)
# ---------------------------------------------------------------------------
func test_overlay_manager_public_api_exists() -> String:
	"""OverlayManager'in public API metodları mevcut olmalı."""
	
	var file := FileAccess.open("res://scripts/overlay_manager.gd", FileAccess.READ)
	if file == null:
		return "FAIL: overlay_manager.gd kaynak dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	var expected_methods: Array[String] = [
		"func register_overlay",
		"func show",
		"func hide",
		"func hide_all",
		"func get_active",
		"func is_visible",
		"func get_overlay_node",
		"func get_canvas_layer",
	]
	
	for method_name: String in expected_methods:
		if not method_name in source_text:
			return "FAIL: overlay_manager.gd'de '%s' metodu bulunamadi" % method_name
	
	return "OK"
