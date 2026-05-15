# tools/verify_zone_definition_contract.gd
# Package 3: Zone Definition Resource Pilot — GUT doğrulama testi
# Pilot zone'lar: Bandırma (ship) ve Samsun Rift (samsun_rift)
# ============================================
# MMAE - Bandırma Yolculuğu
# Godot 4.6 · GDScript 2.0 · Static Typing
# ============================================
extends "res://addons/gut/test.gd"

## Pilot kapsamındaki zone_id'ler
const ZONE_IDS: Array[String] = ["ship", "samsun_rift"]


func test_zone_definitions_exist() -> void:
	"""Her zone_id için ZoneDefinition .tres dosyası var mı?"""
	for zone_id: String in ZONE_IDS:
		var has_def: bool = ZoneLoader.has_definition(zone_id)
		assert_true(has_def, "ZoneDefinition .tres dosyasi bulunamadi: " + zone_id)
		
		var def: ZoneDefinition = ZoneLoader.load_zone(zone_id)
		assert_not_null(def, "ZoneDefinition yuklenemedi: " + zone_id)
		assert_eq(def.zone_id, zone_id, "zone_id eslesmiyor -> beklene: %s, alinan: %s" % [zone_id, def.zone_id])


func test_ship_definition_values() -> void:
	"""Bandırma (ship) ZoneDefinition alan doğrulaması"""
	var def: ZoneDefinition = ZoneLoader.load_zone("ship")
	assert_not_null(def, "ship zone definition yuklenemedi")
	
	assert_eq(def.zone_id, "ship", "zone_id")
	assert_eq(def.goal_kind, "collect", "goal_kind")
	assert_eq(def.item_total, 5, "item_total (5 marker) = 5")
	assert_eq(def.required_supports, 2, "required_supports = 2")
	assert_eq(def.markers.size(), 2, "markers.size (2 note marker) = 2")
	assert_eq(def.wave_config_id, "ship_wave", "wave_config_id = ship_wave")
	
	# Marker detay kontrolü
	if def.markers.size() >= 1:
		var m0: ZoneMarkerDefinition = def.markers[0]
		assert_eq(m0.kind, "note", "marker[0].kind = note")
		assert_false(m0.collected, "marker[0].collected = false")
	
	if def.markers.size() >= 2:
		var m1: ZoneMarkerDefinition = def.markers[1]
		assert_eq(m1.kind, "note", "marker[1].kind = note")
		assert_false(m1.collected, "marker[1].collected = false")


func test_samsun_rift_definition_values() -> void:
	"""Samsun Rift (samsun_rift) ZoneDefinition alan doğrulaması"""
	var def: ZoneDefinition = ZoneLoader.load_zone("samsun_rift")
	assert_not_null(def, "samsun_rift zone definition yuklenemedi")
	
	assert_eq(def.zone_id, "samsun_rift", "zone_id")
	assert_eq(def.goal_kind, "support", "goal_kind (support-based zone)")
	assert_eq(def.item_total, 7, "item_total (7 marker) = 7")
	assert_eq(def.required_supports, 3, "required_supports = 3")
	assert_eq(def.markers.size(), 0, "markers.size (empty, hardcoded fallback) = 0")
	assert_eq(def.wave_config_id, "samsun_wave", "wave_config_id = samsun_wave")


func test_zone_loader_edge_cases() -> void:
	"""ZoneLoader kenar durumları"""
	# Var olmayan zone_id
	var missing_def: ZoneDefinition = ZoneLoader.load_zone("nonexistent_zone")
	assert_null(missing_def, "var olmayan zone_id -> null donmeli")
	
	var missing_has_def: bool = ZoneLoader.has_definition("nonexistent_zone")
	assert_false(missing_has_def, "var olmayan zone_id -> has_definition false donmeli")
	
	# Mevcut zone_id'lerin has_definition kontrolü
	for zone_id: String in ZONE_IDS:
		var has_def: bool = ZoneLoader.has_definition(zone_id)
		assert_true(has_def, "mevcut zone_id has_definition true donmeli: " + zone_id)
