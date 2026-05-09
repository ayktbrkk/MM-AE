extends Node

# Yalnızca oyun durumu yönetimi
# orchestrator (world.gd) sinyallerle haberleşir

@onready var _colors := preload("res://scripts/colors.gd")
@onready var _questions := preload("res://assets/data/questions.gd")

signal state_changed(key: String, value: Variant)

# === TEMEL STATE ===

# Karakter seçimi (world.gd'den taşındı: hero_key)
var selected_character: String = "arda" : set = _set_selected_character

# Bölüm/alan (world.gd'den taşındı: current_area)
var current_zone: String = "room" : set = _set_current_zone

# Aktif hedef (world.gd'den taşındı: active_goal_kind)
var current_goal_kind: String = "unit"

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

# === YENİ STATE DEĞİŞKENLERİ ===
var _active_markers: Dictionary = {}
var _zone_marker_count: Dictionary = {}
var _gathered_names: Array = []
var _unit_notes_collected: Array = []
var _item_discovered: Dictionary = {}
var _interacted_markers: Dictionary = {}
var _support_nodes: Dictionary = {}

# === SETTER'LAR ===

func _set_selected_character(value: String) -> void:
	selected_character = value
	state_changed.emit("selected_character", value)

func _set_current_zone(value: String) -> void:
	current_zone = value
	state_changed.emit("current_zone", value)

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
