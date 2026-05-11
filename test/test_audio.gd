## MMAE — Audio System Validasyon Testleri
## ==========================================
## AudioManager autoload singleton'ının varlığını
## ve temel API metodlarını doğrular.
##
## Testler:
##   1. AudioManager autoload'ı var
##   2. play_bgm(), play_sfx(), stop_bgm() metodları var
## ==========================================

extends Node


# ---------------------------------------------------------------------------
# Test 1: AudioManager autoload'ının var olduğunu doğrula
# ---------------------------------------------------------------------------
func test_audio_manager_autoload_exists() -> String:
	"""AudioManager autoload singleton'ı var olmalı."""
	
	var audio_manager: Variant = Engine.get_singleton("AudioManager")
	
	if audio_manager == null:
		audio_manager = get_node_or_null("/root/AudioManager")
	
	if audio_manager == null:
		return "FAIL: AudioManager autoload singleton'i bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 2: play_bgm() metodu var (kaynak kod okuma)
# ---------------------------------------------------------------------------
func test_play_bgm_method_exists() -> String:
	"""AudioManager.play_bgm() metodu mevcut olmalı (kaynak kod)."""
	
	var file := FileAccess.open("res://scripts/audio_manager.gd", FileAccess.READ)
	if file == null:
		return "FAIL: audio_manager.gd kaynak dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "func play_bgm" in source_text:
		return "FAIL: audio_manager.gd'de 'func play_bgm' metodu bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 3: play_sfx() metodu var (kaynak kod okuma)
# ---------------------------------------------------------------------------
func test_play_sfx_method_exists() -> String:
	"""AudioManager.play_sfx() metodu mevcut olmalı (kaynak kod)."""
	
	var file := FileAccess.open("res://scripts/audio_manager.gd", FileAccess.READ)
	if file == null:
		return "FAIL: audio_manager.gd kaynak dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "func play_sfx" in source_text:
		return "FAIL: audio_manager.gd'de 'func play_sfx' metodu bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 4: stop_bgm() metodu var (kaynak kod okuma)
# ---------------------------------------------------------------------------
func test_stop_bgm_method_exists() -> String:
	"""AudioManager.stop_bgm() metodu mevcut olmalı (kaynak kod)."""
	
	var file := FileAccess.open("res://scripts/audio_manager.gd", FileAccess.READ)
	if file == null:
		return "FAIL: audio_manager.gd kaynak dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	if not "func stop_bgm" in source_text:
		return "FAIL: audio_manager.gd'de 'func stop_bgm' metodu bulunamadi"
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 5: AudioManager script'inin kendisini de doğrula (autoload yoksa)
# ---------------------------------------------------------------------------
func test_audio_manager_script_has_required_methods() -> String:
	"""AudioManager script dosyasında play_bgm, play_sfx, stop_bgm tanımlı olmalı."""
	
	var file := FileAccess.open("res://scripts/audio_manager.gd", FileAccess.READ)
	if file == null:
		return "FAIL: audio_manager.gd kaynak dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	var required_methods: Array[String] = ["func play_bgm", "func play_sfx", "func stop_bgm"]
	
	for method_name: String in required_methods:
		if not method_name in source_text:
			return "FAIL: audio_manager.gd'de '%s' metodu bulunamadi" % method_name
	
	return "OK"


# ---------------------------------------------------------------------------
# Test 6: AudioManager sinyalleri var (kaynak kod okuma)
# ---------------------------------------------------------------------------
func test_audio_manager_signals_exist() -> String:
	"""AudioManager'da beklenen sinyaller tanımlı olmalı."""
	
	var file := FileAccess.open("res://scripts/audio_manager.gd", FileAccess.READ)
	if file == null:
		return "FAIL: audio_manager.gd kaynak dosyasi acilamadi"
	
	var source_text: String = file.get_as_text()
	file.close()
	
	var expected_signals: Array[String] = [
		"signal bgm_started",
		"signal bgm_stopped",
		"signal sfx_played",
		"signal master_volume_changed",
		"signal bgm_volume_changed",
		"signal sfx_volume_changed",
	]
	
	for signal_name: String in expected_signals:
		if not signal_name in source_text:
			return "FAIL: audio_manager.gd'de '%s' sinyali bulunamadi" % signal_name
	
	return "OK"
