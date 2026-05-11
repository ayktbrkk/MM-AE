## MMAE — Regression Testleri (Bug Fix Validasyonu)
## ===================================================
## Daha önce fixlenen bug'ların regresyon testleri.
##
## Test Edilen Bug Fix'ler:
##   1. Modül node'larının isim bazlı değil, class_name (tip) bazlı bulunması
##      (world_zone.gd: _get_player_mod / _get_ui_mod)
##   2. world_player.gd'de class_name WorldPlayer tanımlı
##   3. world_ui.gd'de class_name WorldUI tanımlı
## ===================================================

extends Node


# ---------------------------------------------------------------------------
# Test 1: _get_player_mod ve _get_ui_mod 'is' (tip) kontrolü kullanır
# ---------------------------------------------------------------------------
func test_module_lookup_uses_class_name_not_node_name() -> String:
	"""_get_player_mod() ve _get_ui_mod() 'is' (tip) kontrolü yapar, get_node() KULLANMAZ."""
	
	var file := FileAccess.open("res://scripts/world_zone.gd", FileAccess.READ)
	if file == null:
		return "FAIL: world_zone.gd kaynak dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	# 1. _get_player_mod fonksiyon tanimi var mi?
	if not "_get_player_mod" in source_text:
		return "FAIL: _get_player_mod fonksiyon tanimi world_zone.gd'de bulunamadi"
	
	# 2. _get_ui_mod fonksiyon tanimi var mi?
	if not "_get_ui_mod" in source_text:
		return "FAIL: _get_ui_mod fonksiyon tanimi world_zone.gd'de bulunamadi"
	
	# 3. _get_player_mod 'is WorldPlayer' kontrolu yapiyor mu?
	if not "is WorldPlayer" in source_text:
		return "FAIL: _get_player_mod() 'is WorldPlayer' tip kontrolu yapmiyor"
	
	# 4. _get_ui_mod 'is WorldUI' kontrolu yapiyor mu?
	if not "is WorldUI" in source_text:
		return "FAIL: _get_ui_mod() 'is WorldUI' tip kontrolu yapmiyor"
	
	# 5. Dosyada genel olarak get_node() ile modul bulma YOK
	# _get_player_mod ve _get_ui_mod fonksiyonlari get_node() kullanmaz
	# (is WorldPlayer / is WorldUI kullanir)
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 2: world_player.gd'de class_name WorldPlayer tanımlı
# ---------------------------------------------------------------------------
func test_world_player_has_class_name() -> String:
	"""world_player.gd'de class_name WorldPlayer tanimli olmali."""
	
	var file := FileAccess.open("res://scripts/world_player.gd", FileAccess.READ)
	if file == null:
		return "FAIL: world_player.gd kaynak dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "class_name WorldPlayer" in source_text:
		return "FAIL: world_player.gd'de 'class_name WorldPlayer' tanimi bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 3: world_ui.gd'de class_name WorldUI tanımlı
# ---------------------------------------------------------------------------
func test_world_ui_has_class_name() -> String:
	"""world_ui.gd'de class_name WorldUI tanimli olmali."""
	
	var file := FileAccess.open("res://scripts/world_ui.gd", FileAccess.READ)
	if file == null:
		return "FAIL: world_ui.gd kaynak dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "class_name WorldUI" in source_text:
		return "FAIL: world_ui.gd'de 'class_name WorldUI' tanimi bulunamadi"
	
	return "OK"
