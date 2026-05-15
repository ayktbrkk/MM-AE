extends Node

# Yalnızca oyun durumu yönetimi
# orchestrator (world.gd) sinyallerle haberleşir

signal state_changed(key: String, value: Variant)

# ---------------------------------------------------------------------------
# P6: Tutorial State
# ---------------------------------------------------------------------------
var tutorial_active: bool:
	get:
		var save_manager := get_node_or_null("/root/SaveManager")
		if save_manager == null or not save_manager.has_method("is_tutorial_completed"):
			return false
		return not bool(save_manager.call("is_tutorial_completed"))

# === TEMEL STATE ===

# Karakter seçimi (world.gd'den taşındı: hero_key)
var selected_character: String = "arda" : set = _set_selected_character

# Bölüm/alan (world.gd'den taşındı: current_area)
var current_zone: String = "room" : set = _set_current_zone

# Aktif hedef (world.gd'den taşındı: active_goal_kind)
var current_goal_kind: String = "unit"
var current_goal_text: String = ""

# Koleksiyon item'ları (world.gd'den taşındı: collected_units, collected_ship_clues, vb.)
var collected_items: Dictionary = {}

# Zone bazlı toplam item sayıları (world.gd'den taşındı: total_units, total_ship_clues, vb.)
var total_items_in_zone: Dictionary = {}

# Liderlik puanı (world.gd'den taşındı: leadership_points)
var leadership_points: int = 3

# Kurulan destek sayısı (world.gd'den taşındı: built_supports)
var built_supports: int = 0

# Gerekli destek sayısı (world.gd'den taşındı: required_supports)
var required_supports: int = 2

# Dalga deneme sayısı (world.gd'den taşındı: wave_attempts)
var wave_attempts: int = 0

# ---------------------------------------------------------------------------
# P7: Journal / Tarih Defteri State
# ---------------------------------------------------------------------------
var collected_card_ids: Array[String] = [] : set = _set_collected_card_ids
var completed_chapters: Array[String] = [] : set = _set_completed_chapters
var journal_opened_count: int = 0 : set = _set_journal_opened_count

# === SETTER'LAR ===

func _set_selected_character(value: String) -> void:
	selected_character = value
	state_changed.emit("selected_character", value)

func _set_current_zone(value: String) -> void:
	current_zone = value
	state_changed.emit("current_zone", value)

func _set_collected_card_ids(value: Array[String]) -> void:
	collected_card_ids = value
	state_changed.emit("collected_card_ids", value)

func _set_completed_chapters(value: Array[String]) -> void:
	completed_chapters = value
	state_changed.emit("completed_chapters", value)

func _set_journal_opened_count(value: int) -> void:
	journal_opened_count = value
	state_changed.emit("journal_opened_count", value)

# === STATE FONKSİYONLARI ===

# Karakter seçimi (world.gd'deki _choose_hero mantığı)
func select_character(char_name: String) -> void:
	selected_character = char_name
	state_changed.emit("character_selected", char_name)

# Karakter seçildiğinde tetiklenir
func _on_character_selected(char_name: String) -> void:
	selected_character = char_name
	state_changed.emit("character_selected", char_name)

# Hedef/goal belirleme (world.gd'den taşındı: _set_goal)
func set_goal(kind: String, goal_text: String = "") -> void:
	current_goal_kind = kind
	current_goal_text = goal_text
	state_changed.emit("goal_updated", {"kind": kind, "text": goal_text})

# Item toplandı mı kontrolü
func is_item_collected(item_id: String) -> bool:
	return collected_items.get(item_id, false)

# Item toplama işareti (world.gd'den taşındı: _mark_marker_collected logic)
func mark_item_collected(item_id: String) -> void:
	collected_items[item_id] = true
	state_changed.emit("item_collected", item_id)

# Zone'a geçiş
func enter_zone(zone: String) -> void:
	current_zone = zone
	state_changed.emit("zone_entered", zone)

# Zone set/get (world_marker.gd icin)
func set_zone(zone: String) -> void:
	current_zone = zone

func get_zone() -> String:
	return current_zone

# Liderlik puanı ekle
func add_leadership(amount: int) -> void:
	leadership_points += amount
	state_changed.emit("leadership_changed", leadership_points)

# Destek kur
func place_support() -> void:
	built_supports += 1
	state_changed.emit("support_placed", built_supports)

# Dalga sayacı
func increment_wave_attempts() -> void:
	wave_attempts += 1
	state_changed.emit("wave_attempted", wave_attempts)

# Zone'daki toplam item sayısını ayarla
func set_zone_item_total(zone: String, total: int) -> void:
	total_items_in_zone[zone] = total

# Zone'daki toplam item sayısını al
func get_zone_item_total(zone: String) -> int:
	return total_items_in_zone.get(zone, 0)

# Item sayacını artır (collected_units, collected_ship_clues vb. için)
func increment_item_count(item_key: String, amount: int = 1) -> void:
	collected_items[item_key] = collected_items.get(item_key, 0) + amount
	state_changed.emit("item_count_incremented", {"key": item_key, "count": collected_items[item_key]})

# Item sayacını al
func get_item_count(item_key: String) -> int:
	return collected_items.get(item_key, 0)

# Item sayacını sıfırla
func reset_item_count(item_key: String) -> void:
	collected_items[item_key] = 0
	state_changed.emit("item_count_reset", item_key)

# Gerekli destek sayısını ayarla
func set_required_supports(value: int) -> void:
	required_supports = value
	state_changed.emit("required_supports_changed", value)

# Liderlik puanını ayarla
func set_leadership(value: int) -> void:
	leadership_points = value
	state_changed.emit("leadership_set", value)

# Destek sayısını sıfırla
func reset_supports() -> void:
	built_supports = 0
	state_changed.emit("supports_reset", 0)

# Dalga sayacını sıfırla
func reset_wave_attempts() -> void:
	wave_attempts = 0
	state_changed.emit("wave_attempts_reset", 0)


# ---------------------------------------------------------------------------
# P7: Journal State Yönetimi
# ---------------------------------------------------------------------------

## Kartı toplanmış olarak işaretler.
func mark_card_collected(card_id: String) -> void:
	if card_id in collected_card_ids:
		return
	collected_card_ids.append(card_id)
	state_changed.emit("card_collected", card_id)


## Kart daha önce toplanmış mı?
func is_card_collected(card_id: String) -> bool:
	return card_id in collected_card_ids


## Bölümü tamamlanmış olarak işaretler.
func mark_chapter_completed(chapter_id: String) -> void:
	if chapter_id in completed_chapters:
		return
	completed_chapters.append(chapter_id)
	state_changed.emit("chapter_completed", chapter_id)


## Bölüm daha önce tamamlanmış mı?
func is_chapter_completed(chapter_id: String) -> bool:
	return chapter_id in completed_chapters


## Toplanan kart sayısını döndürür.
func get_collected_card_count() -> int:
	return collected_card_ids.size()


## Toplanan kart ID'lerini döndürür.
func get_collected_card_ids() -> Array[String]:
	return collected_card_ids.duplicate()


## Tamamlanan bölüm sayısını döndürür.
func get_completed_chapter_count() -> int:
	return completed_chapters.size()


## Tamamlanan bölüm ID'lerini döndürür.
func get_completed_chapters() -> Array[String]:
	return completed_chapters.duplicate()


## Journal açılma sayısını artırır.
func increment_journal_opened() -> void:
	journal_opened_count += 1
	state_changed.emit("journal_opened", journal_opened_count)


# ---------------------------------------------------------------------------
# P8: Save/Load serialize / deserialize
# ---------------------------------------------------------------------------
func to_dict() -> Dictionary:
	"""Mevcut state'i Dictionary olarak serialize eder."""
	return {
		"selected_character": selected_character,
		"current_zone": current_zone,
		"current_goal_kind": current_goal_kind,
		"current_goal_text": current_goal_text,
		"collected_items": collected_items.duplicate(),
		"total_items_in_zone": total_items_in_zone.duplicate(),
		"leadership_points": leadership_points,
		"built_supports": built_supports,
		"required_supports": required_supports,
		"wave_attempts": wave_attempts,
		"collected_card_ids": collected_card_ids.duplicate(),
		"completed_chapters": completed_chapters.duplicate(),
		"journal_opened_count": journal_opened_count,
	}


func from_dict(data: Dictionary) -> void:
	"""Dictionary'den state'i geri yukler."""
	if data.is_empty():
		return

	if data.has("selected_character"):
		selected_character = data["selected_character"]
	if data.has("current_zone"):
		current_zone = data["current_zone"]
	if data.has("current_goal_kind"):
		current_goal_kind = data["current_goal_kind"]
	if data.has("current_goal_text"):
		current_goal_text = data["current_goal_text"]
	if data.has("collected_items"):
		var merged_collected := collected_items.duplicate()
		merged_collected.merge(data["collected_items"], true)
		collected_items = merged_collected
	if data.has("total_items_in_zone"):
		var merged_totals := total_items_in_zone.duplicate()
		merged_totals.merge(data["total_items_in_zone"], true)
		total_items_in_zone = merged_totals
	if data.has("leadership_points"):
		leadership_points = data["leadership_points"]
	if data.has("built_supports"):
		built_supports = data["built_supports"]
	if data.has("required_supports"):
		required_supports = data["required_supports"]
	if data.has("wave_attempts"):
		wave_attempts = data["wave_attempts"]
	if data.has("collected_card_ids"):
		collected_card_ids = data["collected_card_ids"].duplicate()
	if data.has("completed_chapters"):
		completed_chapters = data["completed_chapters"].duplicate()
	if data.has("journal_opened_count"):
		journal_opened_count = data["journal_opened_count"]
