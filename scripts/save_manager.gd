extends Node

# ---------------------------------------------------------------------------
# save_manager.gd — P7: Save/Load sistemi
# Autoload singleton. JSON tabanli save/load mekanizmasi.
# ---------------------
# Autoload singleton. JSON tabanli save/load mekanizmasi.
# Kayitlar user://savegame.json dosyasina yazilir.
#
# Kullanim:
#   SaveManager.save_game(state_dict)
#   SaveManager.load_game() -> Dictionary (veya null)
#   SaveManager.has_save() -> bool
#   SaveManager.delete_save()
# ---------------------------------------------------------------------------

const SAVE_PATH := "user://savegame.json"
const SETTINGS_PATH := "user://settings.json"
const SAVE_VERSION := 1

signal game_saved(path: String)
signal game_loaded(path: String)
signal save_deleted()
signal save_corrupted(path: String, error_message: String)
signal settings_changed(key: String, value: Variant)


func save_game(data: Dictionary) -> bool:
	"""Verilen Dictionary'yi JSON'a serialize ederek kaydeder.
	data icinde en az 'version' ve 'timestamp' alanlari bulunmalidir."""
	var save_dict := data.duplicate()
	save_dict["version"] = SAVE_VERSION
	save_dict["timestamp"] = Time.get_unix_time_from_system()

	var json_string := JSON.stringify(save_dict, "\t")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("[SaveManager] Dosya acilamadi: %s" % SAVE_PATH)
		return false

	file.store_string(json_string)
	file.close()
	print("[SaveManager] Oyun kaydedildi: %s (%.1f KB)" % [SAVE_PATH, float(json_string.length()) / 1024.0])
	game_saved.emit(SAVE_PATH)
	return true


func load_game() -> Dictionary:
	"""Kayit dosyasini okur ve Dictionary olarak dondurur.
	Hata durumunda bos Dictionary dondurur."""
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveManager] Kayit dosyasi bulunamadi: %s" % SAVE_PATH)
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("[SaveManager] Kayit dosyasi okunamadi: %s" % SAVE_PATH)
		return {}

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		var error_msg := "JSON parse hatasi: %s (line %d)" % [json.get_error_message(), json.get_error_line()]
		push_error("[SaveManager] %s" % error_msg)
		save_corrupted.emit(SAVE_PATH, error_msg)
		return {}

	var data: Dictionary = json.data
	if not data.has("version"):
		push_error("[SaveManager] Kayit dosyasi gecersiz: version alani eksik")
		save_corrupted.emit(SAVE_PATH, "version alani eksik")
		return {}

	print("[SaveManager] Oyun yuklendi: %s (version %d)" % [SAVE_PATH, data.get("version", 0)])
	game_loaded.emit(SAVE_PATH)
	return data


func has_save() -> bool:
	"""Kayit dosyasi var mi?"""
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:
	"""Kayit dosyasini siler."""
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var dir := DirAccess.open("user://")
	if dir:
		dir.remove("savegame.json")
		print("[SaveManager] Kayit silindi: %s" % SAVE_PATH)
		save_deleted.emit()


func get_save_timestamp() -> String:
	"""Kayit dosyasindaki timestamp'i okur (goruntuleme icin)."""
	var data := load_game()
	if data.is_empty():
		return ""
	var ts: float = data.get("timestamp", 0.0)
	if ts <= 0.0:
		return ""
	return Time.get_datetime_string_from_unix_time(int(ts))


func get_save_version() -> int:
	"""Kayit dosyasinin versiyonunu dondurur."""
	var data := load_game()
	if data.is_empty():
		return 0
	return data.get("version", 0)


# ---------------------------------------------------------------------------
# Settings API
# ---------------------------------------------------------------------------
func save_setting(key: String, value: Variant) -> void:
	"""Tek bir ayar degerini user://settings.json dosyasina kaydeder."""
	var settings: Dictionary = load_settings()
	settings[key] = value
	_write_settings(settings)
	settings_changed.emit(key, value)


func load_setting(key: String, default_value: Variant = null) -> Variant:
	"""Belirtilen ayar degerini dondurur, yoksa default_value."""
	var settings: Dictionary = load_settings()
	if settings.has(key):
		return settings[key]
	return default_value


func load_settings() -> Dictionary:
	"""Tum ayarlari Dictionary olarak dondurur."""
	if not FileAccess.file_exists(SETTINGS_PATH):
		return {}

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return {}

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		return {}
	return json.data


func _write_settings(settings: Dictionary) -> void:
	"""settings.json dosyasina yazar."""
	var json_string := JSON.stringify(settings, "\t")
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if not file:
		push_error("[SaveManager] Ayarlar dosyasi acilamadi")
		return
	file.store_string(json_string)
	file.close()
