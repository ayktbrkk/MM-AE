## MMAE — Event Chain Validasyon Testleri
## ==========================================
## CHAPTER_EVENT_CHAINS ve BUILT_ZONES sabitlerinin
## questions.gd EVENTS dizisi ile uyumluluğunu doğrular.
##
## Testler:
##   1. CHAPTER_EVENT_CHAINS tüm zone'ları içerir
##   2. Her zone'un event index'leri EVENTS dizisi sınırları içinde
##   3. BUILT_ZONES tüm zone'ları içerir
## ==========================================

extends Node

# Script sabitlerine get_script_constant_map() ile erisilir
var _zone_constants: Dictionary
var _questions_constants: Dictionary


func _init() -> void:
	var zone_script: GDScript = load("res://scripts/world_zone.gd")
	var questions_script: GDScript = load("res://assets/data/questions.gd")
	_zone_constants = zone_script.get_script_constant_map()
	_questions_constants = questions_script.get_script_constant_map()


# ---------------------------------------------------------------------------
# Test 1: CHAPTER_EVENT_CHAINS tüm zone'ları içerir
# ---------------------------------------------------------------------------
func test_chapter_event_chains_contains_all_zones() -> String:
	"""CHAPTER_EVENT_CHAINS tüm zone anahtarlarını içermeli."""
	
	if not _zone_constants.has("CHAPTER_EVENT_CHAINS"):
		return "FAIL: CHAPTER_EVENT_CHAINS sabiti world_zone.gd'de bulunamadi"
	
	var chains: Dictionary = _zone_constants["CHAPTER_EVENT_CHAINS"] as Dictionary
	
	var expected_zones: Array[String] = [
		"room",
		"bandirma",
		"samsun_rift",
		"havza",
		"amasya",
		"kongreler",
		"ankara",
		"sakarya",
		"final",
	]
	
	for zone: String in expected_zones:
		if not chains.has(zone):
			return "FAIL: CHAPTER_EVENT_CHAINS '%s' zone'unu icermiyor" % zone
	
	if chains.size() != expected_zones.size():
		return "FAIL: CHAPTER_EVENT_CHAINS %d zone iceriyor, beklenen %d" % [chains.size(), expected_zones.size()]
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 2: Her zone'un event index'leri EVENTS dizisi sınırları içinde
# ---------------------------------------------------------------------------
func test_all_event_indices_are_valid() -> String:
	"""Her zone'daki event index'leri EVENTS dizisi sınırları içinde olmalı."""
	
	if not _zone_constants.has("CHAPTER_EVENT_CHAINS"):
		return "FAIL: CHAPTER_EVENT_CHAINS sabiti bulunamadi"
	
	if not _questions_constants.has("EVENTS"):
		return "FAIL: EVENTS sabiti questions.gd'de bulunamadi"
	
	var chains: Dictionary = _zone_constants["CHAPTER_EVENT_CHAINS"] as Dictionary
	var events: Array = _questions_constants["EVENTS"] as Array
	var max_index: int = events.size() - 1
	
	for zone: Variant in chains:
		var indices: Array = chains[zone] as Array
		for idx: Variant in indices:
			var index: int = idx as int
			if index < 0 or index > max_index:
				return "FAIL: '%s' zone'unda gecersiz event index %d (EVENTS boyutu: %d, 0-%d)" % [zone, index, events.size(), max_index]
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 2b: Her event index'in EVENTS'te karşılığı var ve kind alanına sahip
# ---------------------------------------------------------------------------
func test_each_event_index_has_valid_kind() -> String:
	"""Her event index'inin EVENTS'te 'kind' alanı 'story' veya 'decision' olmalı."""
	
	if not _zone_constants.has("CHAPTER_EVENT_CHAINS"):
		return "FAIL: CHAPTER_EVENT_CHAINS sabiti bulunamadi"
	
	if not _questions_constants.has("EVENTS"):
		return "FAIL: EVENTS sabiti questions.gd'de bulunamadi"
	
	var chains: Dictionary = _zone_constants["CHAPTER_EVENT_CHAINS"] as Dictionary
	var events: Array = _questions_constants["EVENTS"] as Array
	
	for zone: Variant in chains:
		var indices: Array = chains[zone] as Array
		for idx: Variant in indices:
			var index: int = idx as int
			var event: Dictionary = events[index] as Dictionary
			var kind: String = event.get("kind", "")
			if kind != "story" and kind != "decision":
				return "FAIL: '%s' zone'unda index %d: gecersiz 'kind' = '%s' (story veya decision olmali)" % [zone, index, kind]
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 3: BUILT_ZONES tüm zone'ları içerir
# ---------------------------------------------------------------------------
func test_built_zones_contains_all_chapter_zones() -> String:
	"""BUILT_ZONES feature flag'i CHAPTER_EVENT_CHAINS'teki tüm zone'ları içermeli."""
	
	if not _zone_constants.has("BUILT_ZONES"):
		return "FAIL: BUILT_ZONES sabiti world_zone.gd'de bulunamadi"
	
	if not _zone_constants.has("CHAPTER_EVENT_CHAINS"):
		return "FAIL: CHAPTER_EVENT_CHAINS sabiti bulunamadi"
	
	var built_zones: Array = _zone_constants["BUILT_ZONES"] as Array
	var chains: Dictionary = _zone_constants["CHAPTER_EVENT_CHAINS"] as Dictionary
	
	for zone: Variant in chains:
		if zone is String:
			if not zone in built_zones:
				return "FAIL: '%s' zone'u BUILT_ZONES icinde yer almiyor" % zone
	
	for zone: Variant in built_zones:
		if zone is String:
			if not chains.has(zone):
				return "FAIL: BUILT_ZONES '%s' zone'u CHAPTER_EVENT_CHAINS'te tanimli degil" % zone
	
	return "OK"
