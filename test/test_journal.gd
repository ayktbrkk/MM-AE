## MMAE — Journal / Tarih Defteri Validasyon Testleri
## ====================================================
## Package 7: Journal overlay, world_state entegrasyonu,
## info_card tracking ve UI metinlerinin varlığını doğrular.
##
## Testler:
##   1. journal_overlay.gd scripts dosyası var ve class_name içeriyor
##   2. scenes/journal_overlay.tscn sahne dosyası var
##   3. show_overlay(config) API'si var
##   4. hide_overlay() API'si var
##   5. get_overlay_type() API'si var
##   6. journal_closed sinyali var
##   7. OverlayType.JOURNAL overlay_manager.gd'de tanımlı
##   8. world_state.gd mark_card_collected() metodu var
##   9. world_state.gd get_collected_card_ids() metodu var
##  10. world_state.gd completed_chapters API'leri var
##  11. info_card_overlay.gd card_viewed sinyali var
##  12. ui_text.gd journal sabitleri tanımlı
##  13. translations/ui_texts.csv journal anahtarları var
##  14. HUD sahnesinde JournalButton düğümü var
##  15. world_ui.gd journal entegrasyon metodları var
## ====================================================

extends Node


# ---------------------------------------------------------------------------
# Test 1: journal_overlay.gd scripts dosyası var
# ---------------------------------------------------------------------------
func test_journal_script_exists() -> String:
	"""journal_overlay.gd dosyası mevcut ve class_name içermeli."""
	
	var file := FileAccess.open("res://scripts/journal_overlay.gd", FileAccess.READ)
	if file == null:
		return "FAIL: scripts/journal_overlay.gd dosyasi bulunamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "class_name JournalOverlay" in source_text:
		return "FAIL: journal_overlay.gd 'class_name JournalOverlay' icermiyor"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 2: scenes/journal_overlay.tscn sahne dosyası var
# ---------------------------------------------------------------------------
func test_journal_scene_exists() -> String:
	"""scenes/journal_overlay.tscn sahne dosyası mevcut olmalı."""
	
	var file := FileAccess.open("res://scenes/journal_overlay.tscn", FileAccess.READ)
	if file == null:
		return "FAIL: scenes/journal_overlay.tscn dosyasi bulunamadi"
	
	file.close()
	return "OK"


# ---------------------------------------------------------------------------
# Test 3: show_overlay(config) API'si var
# ---------------------------------------------------------------------------
func test_show_overlay_api_exists() -> String:
	"""JournalOverlay.show_overlay() metodu mevcut olmalı."""
	
	var file := FileAccess.open("res://scripts/journal_overlay.gd", FileAccess.READ)
	if file == null:
		return "FAIL: scripts/journal_overlay.gd dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "func show_overlay" in source_text:
		return "FAIL: journal_overlay.gd'de 'func show_overlay' metodu bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 4: hide_overlay() API'si var
# ---------------------------------------------------------------------------
func test_hide_overlay_api_exists() -> String:
	"""JournalOverlay.hide_overlay() metodu mevcut olmalı."""
	
	var file := FileAccess.open("res://scripts/journal_overlay.gd", FileAccess.READ)
	if file == null:
		return "FAIL: scripts/journal_overlay.gd dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "func hide_overlay" in source_text:
		return "FAIL: journal_overlay.gd'de 'func hide_overlay' metodu bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 5: get_overlay_type() API'si var
# ---------------------------------------------------------------------------
func test_get_overlay_type_api_exists() -> String:
	"""JournalOverlay.get_overlay_type() metodu mevcut olmalı."""
	
	var file := FileAccess.open("res://scripts/journal_overlay.gd", FileAccess.READ)
	if file == null:
		return "FAIL: scripts/journal_overlay.gd dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "func get_overlay_type" in source_text:
		return "FAIL: journal_overlay.gd'de 'func get_overlay_type' metodu bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 6: journal_closed sinyali var
# ---------------------------------------------------------------------------
func test_journal_closed_signal_exists() -> String:
	"""JournalOverlay'de journal_closed sinyali tanımlı olmalı."""
	
	var file := FileAccess.open("res://scripts/journal_overlay.gd", FileAccess.READ)
	if file == null:
		return "FAIL: scripts/journal_overlay.gd dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "signal journal_closed" in source_text:
		return "FAIL: journal_overlay.gd'de 'signal journal_closed' bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 7: OverlayType.JOURNAL overlay_manager.gd'de tanımlı
# ---------------------------------------------------------------------------
func test_journal_overlay_type_exists() -> String:
	"""overlay_manager.gd'de OverlayType.JOURNAL tanımlı olmalı."""
	
	var file := FileAccess.open("res://scripts/overlay_manager.gd", FileAccess.READ)
	if file == null:
		return "FAIL: scripts/overlay_manager.gd dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "JOURNAL" in source_text:
		return "FAIL: overlay_manager.gd'de 'JOURNAL' enum degeri bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 8: world_state.gd mark_card_collected() metodu var
# ---------------------------------------------------------------------------
func test_world_state_mark_card_collected() -> String:
	"""world_state.gd'de mark_card_collected() metodu mevcut olmalı."""
	
	var file := FileAccess.open("res://scripts/world_state.gd", FileAccess.READ)
	if file == null:
		return "FAIL: scripts/world_state.gd dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "func mark_card_collected" in source_text:
		return "FAIL: world_state.gd'de 'func mark_card_collected' metodu bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 9: world_state.gd get_collected_card_ids() metodu var
# ---------------------------------------------------------------------------
func test_world_state_get_collected_card_ids() -> String:
	"""world_state.gd'de get_collected_card_ids() metodu mevcut olmalı."""
	
	var file := FileAccess.open("res://scripts/world_state.gd", FileAccess.READ)
	if file == null:
		return "FAIL: scripts/world_state.gd dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "func get_collected_card_ids" in source_text:
		return "FAIL: world_state.gd'de 'func get_collected_card_ids' metodu bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 10: world_state.gd completed_chapters API'leri var
# ---------------------------------------------------------------------------
func test_world_state_completed_chapters_api() -> String:
	"""world_state.gd'de completed_chapters ile ilgili metodlar mevcut olmalı."""
	
	var file := FileAccess.open("res://scripts/world_state.gd", FileAccess.READ)
	if file == null:
		return "FAIL: scripts/world_state.gd dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "func get_completed_chapters" in source_text:
		return "FAIL: world_state.gd'de 'func get_completed_chapters' metodu bulunamadi"
	
	if not "func mark_chapter_completed" in source_text:
		return "FAIL: world_state.gd'de 'func mark_chapter_completed' metodu bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 11: info_card_overlay.gd card_viewed sinyali var
# ---------------------------------------------------------------------------
func test_info_card_viewed_signal() -> String:
	"""info_card_overlay.gd'de card_viewed sinyali tanımlı olmalı."""
	
	var file := FileAccess.open("res://scripts/info_card_overlay.gd", FileAccess.READ)
	if file == null:
		return "FAIL: scripts/info_card_overlay.gd dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "signal card_viewed" in source_text:
		return "FAIL: info_card_overlay.gd'de 'signal card_viewed' bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 12: ui_text.gd journal sabitleri tanımlı
# ---------------------------------------------------------------------------
func test_ui_text_journal_constants() -> String:
	"""ui_text.gd'de journal ile ilgili sabitler tanımlı olmalı."""
	
	var file := FileAccess.open("res://scripts/ui_text.gd", FileAccess.READ)
	if file == null:
		return "FAIL: scripts/ui_text.gd dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	var required_constants := [
		"JOURNAL_TITLE",
		"JOURNAL_TAB_CARDS",
		"JOURNAL_TAB_CHAPTERS",
		"JOURNAL_CLOSE",
		"JOURNAL_BUTTON",
		"JOURNAL_MENU_BUTTON",
	]
	
	for const_name: String in required_constants:
		if not const_name in source_text:
			return "FAIL: ui_text.gd'de '%s' sabiti bulunamadi" % const_name
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 13: translations/ui_texts.csv journal anahtarları var
# ---------------------------------------------------------------------------
func test_csv_journal_keys() -> String:
	"""ui_texts.csv dosyasında journal ile ilgili anahtarlar olmalı."""
	
	var file := FileAccess.open("res://translations/ui_texts.csv", FileAccess.READ)
	if file == null:
		return "FAIL: translations/ui_texts.csv dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	var required_keys := [
		"ui.journal.title",
		"ui.journal.tab.cards",
		"ui.journal.tab.chapters",
		"ui.journal.close",
		"ui.journal.button",
		"ui.journal.menu.button",
	]
	
	for key: String in required_keys:
		if not key in source_text:
			return "FAIL: ui_texts.csv'de '%s' anahtari bulunamadi" % key
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 14: HUD sahnesinde JournalButton düğümü var
# ---------------------------------------------------------------------------
func test_hud_journal_button_exists() -> String:
	"""hud_bar.tscn sahnesinde JournalButton düğümü olmalı."""
	
	var file := FileAccess.open("res://scenes/hud_bar.tscn", FileAccess.READ)
	if file == null:
		return "FAIL: scenes/hud_bar.tscn dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "JournalButton" in source_text:
		return "FAIL: hud_bar.tscn'de 'JournalButton' dugumu bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 15: world_ui.gd journal entegrasyon metodları var
# ---------------------------------------------------------------------------
func test_world_ui_journal_methods() -> String:
	"""world_ui.gd'de journal entegrasyonu için gerekli metodlar olmalı."""
	
	var file := FileAccess.open("res://scripts/world_ui.gd", FileAccess.READ)
	if file == null:
		return "FAIL: scripts/world_ui.gd dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	var required_methods := [
		"func show_journal",
		"func hide_journal",
		"func _on_journal_pressed",
		"func show_journal_button",
		"func hide_journal_button",
		"func _on_info_card_viewed",
	]
	
	for method_name: String in required_methods:
		if not method_name in source_text:
			return "FAIL: world_ui.gd'de '%s' metodu bulunamadi" % method_name
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 16: main_menu.gd'de journal butonu ve journal metodu var
# ---------------------------------------------------------------------------
func test_main_menu_journal_integration() -> String:
	"""main_menu.gd'de journal entegrasyonu için gerekli metodlar olmalı."""
	
	var file := FileAccess.open("res://scripts/main_menu.gd", FileAccess.READ)
	if file == null:
		return "FAIL: scripts/main_menu.gd dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	var required_items := [
		"JOURNAL_OVERLAY_SCENE",
		"func _on_menu_journal_pressed",
		"func _on_menu_journal_closed",
	]
	
	for item: String in required_items:
		if not item in source_text:
			return "FAIL: main_menu.gd'de '%s' bulunamadi" % item
	
	return "OK"
