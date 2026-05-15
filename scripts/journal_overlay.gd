## MMAE - Tarih Defteri (Journal) Overlay
## =========================================
## Oyuncunun topladığı bilgi kartlarını ve tamamladığı bölümleri
## görüntülemesini sağlayan CanvasLayer tabanlı overlay.
##
## İki sekme: "Kartlar" (toplanan bilgi kartları) ve "Bölümler" (tamamlanan bölümler)
##
## Kullanım:
##   show_overlay({"tab": "cards"})    # Kartlar sekmesini aç
##   show_overlay({"tab": "chapters"}) # Bölümler sekmesini aç
##   hide_overlay()                    # Kapat

class_name JournalOverlay
extends Control


# ---------------------------------------------------------------------------
# SİNYALLER
# ---------------------------------------------------------------------------
signal journal_closed


# ---------------------------------------------------------------------------
# SABİTLER
# ---------------------------------------------------------------------------
const CARD_GRID_COLS := 3
const CARD_THUMB_SIZE := Vector2(180, 140)
const CARD_SPACING := 12


# ---------------------------------------------------------------------------
# DIŞ KAYNAKLAR
# ---------------------------------------------------------------------------
const _colors := preload("res://scripts/colors.gd")
const _ui_text := preload("res://scripts/ui_text.gd")
const _ui_tokens := preload("res://scripts/ui_tokens.gd")
const _overlay_tween_helper := preload("res://scripts/overlay_tween_helper.gd")
const _gui_frame := preload("res://scripts/gui_frame.gd")


# ---------------------------------------------------------------------------
# @ONREADY NODE REFERANSLARI
# ---------------------------------------------------------------------------
@onready var backdrop: ColorRect = $Backdrop
@onready var panel: PanelContainer = $Panel
@onready var panel_margin: MarginContainer = $Panel/PanelMargin
@onready var panel_vbox: VBoxContainer = $Panel/PanelMargin/PanelVBox
@onready var tab_container: TabContainer = $Panel/PanelMargin/PanelVBox/TabContainer
@onready var cards_tab: Control = $Panel/PanelMargin/PanelVBox/TabContainer/CardsTab
@onready var cards_grid: GridContainer = $Panel/PanelMargin/PanelVBox/TabContainer/CardsTab/Scroll/Grid
@onready var cards_empty_label: Label = $Panel/PanelMargin/PanelVBox/TabContainer/CardsTab/EmptyLabel
@onready var chapters_tab: Control = $Panel/PanelMargin/PanelVBox/TabContainer/ChaptersTab
@onready var chapters_list: VBoxContainer = $Panel/PanelMargin/PanelVBox/TabContainer/ChaptersTab/Scroll/List
@onready var chapters_empty_label: Label = $Panel/PanelMargin/PanelVBox/TabContainer/ChaptersTab/EmptyLabel
@onready var close_button: Button = $Panel/PanelMargin/PanelVBox/CloseRow/CloseButton
@onready var stats_label: Label = $Panel/PanelMargin/PanelVBox/StatsRow/StatsLabel


# ---------------------------------------------------------------------------
# STATE
# ---------------------------------------------------------------------------
var _world_state: Node = null
var _card_buttons: Array[Button] = []
# Main menu'den gelen override verileri (world_state yokken kullanılır)
var _card_ids_override: Array[String] = []
var _chapter_ids_override: Array[String] = []


# ---------------------------------------------------------------------------
# OVERLAY API
# ---------------------------------------------------------------------------

func get_overlay_type() -> int:
	return OverlayManager.OverlayType.JOURNAL


func show_overlay(config: Dictionary = {}) -> void:
	"""Journal overlay'ini göster.
	
	Config parametreleri:
	  - tab: "cards" veya "chapters" (hangi sekme açılsın)
	  - card_ids: Array[String] — world_state yokken kullanılacak kart ID'leri
	  - chapter_ids: Array[String] — world_state yokken kullanılacak bölüm ID'leri
	"""
	# Override verilerini config'den al
	_card_ids_override = []
	_chapter_ids_override = []
	if config.has("card_ids"):
		_card_ids_override = config.get("card_ids", []) as Array[String]
	if config.has("chapter_ids"):
		_chapter_ids_override = config.get("chapter_ids", []) as Array[String]
	
	visible = true
	_refresh_world_state()
	_populate_tabs()
	_select_tab(String(config.get("tab", "cards")))
	_play_show_animation()


func hide_overlay() -> void:
	"""Journal overlay'ini gizle."""
	visible = false
	_card_buttons.clear()


# ---------------------------------------------------------------------------
# INIT
# ---------------------------------------------------------------------------

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	tab_container.tab_changed.connect(_on_tab_changed)
	_sync_layout()
	get_viewport().size_changed.connect(_sync_layout)
	visible = false


func _exit_tree() -> void:
	if get_viewport().size_changed.is_connected(_sync_layout):
		get_viewport().size_changed.disconnect(_sync_layout)


func _sync_layout() -> void:
	"""Viewport değişikliklerinde panel boyutlarını güncelle."""
	var viewport_size := get_viewport_rect().size
	var safe_rect := _gui_frame.safe_area_rect(viewport_size)

	# Panel boyutları — portrait 9:16, max 1080x1920
	var panel_w := clampf(safe_rect.size.x * 0.88, 520.0, 960.0)
	var panel_h := clampf(safe_rect.size.y * 0.82, 600.0, 1600.0)
	panel.custom_minimum_size = Vector2(panel_w, panel_h)

	# Pozisyon: ortala
	panel.position = Vector2(
		(viewport_size.x - panel.size.x) * 0.5,
		(viewport_size.y - panel.size.y) * 0.5
	)


# ---------------------------------------------------------------------------
# WORLD STATE BAĞLANTISI
# ---------------------------------------------------------------------------

func _refresh_world_state() -> void:
	"""WorldState referansını güncelle."""
	if _world_state == null or not is_instance_valid(_world_state):
		_world_state = _find_world_state()


func _find_world_state() -> Node:
	"""WorldState düğümünü bul (world sahnesinden veya başka yerden)."""
	var state := get_node_or_null("/root/World/WorldState")
	if state != null:
		return state
	# Alternatif: WorldState'i herhangi bir yerde ara
	var candidates := get_tree().get_nodes_in_group("world_state")
	if candidates.size() > 0:
		return candidates[0]
	return null


# ---------------------------------------------------------------------------
# TAB DOLDURMA
# ---------------------------------------------------------------------------

func _populate_tabs() -> void:
	"""Her iki sekmeyi de güncel state ile doldur."""
	_populate_cards_tab()
	_populate_chapters_tab()
	_update_stats()


# ---------------------------------------------------------------------------
# KARTLAR SEKMESİ
# ---------------------------------------------------------------------------

func _populate_cards_tab() -> void:
	"""Toplanan bilgi kartlarını grid'de göster."""
	# Mevcut kartları temizle
	for child in cards_grid.get_children():
		child.queue_free()
	_card_buttons.clear()

	var card_ids: Array[String] = []
	# Önce config override'ını dene, yoksa world_state'ten oku
	if not _card_ids_override.is_empty():
		card_ids = _card_ids_override
	elif _world_state != null and _world_state.has_method("get_collected_card_ids"):
		card_ids = _world_state.get_collected_card_ids() as Array[String]

	if card_ids.is_empty():
		cards_grid.visible = false
		cards_empty_label.visible = true
		cards_empty_label.text = _ui_text.text(_ui_text.JOURNAL_CARDS_EMPTY, "Henüz hiç tarih kartı toplamadın.\nKeşfe devam et!")
		return

	cards_grid.visible = true
	cards_empty_label.visible = false

	for card_id in card_ids:
		var thumb := _create_card_thumbnail(card_id)
		cards_grid.add_child(thumb)
		_card_buttons.append(thumb)


func _create_card_thumbnail(card_id: String) -> Button:
	"""Her kart için tıklanabilir bir thumbnail butonu oluştur."""
	var btn := Button.new()
	btn.custom_minimum_size = CARD_THUMB_SIZE
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.mouse_filter = Control.MOUSE_FILTER_STOP

	# Kart verilerini al
	var card_data: Dictionary = _get_card_data(card_id)
	var title: String = card_data.get("title", card_id) as String
	var tag: String = card_data.get("tag", "") as String

	# İç düzen: Vertical layout
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)

	var tag_label := Label.new()
	tag_label.text = tag
	tag_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag_label.add_theme_font_size_override("font_size", 14)
	tag_label.add_theme_color_override("font_color", _colors.DESIGN_STORY_INK)
	vbox.add_child(tag_label)

	var title_label := Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", _colors.DESIGN_HEADLINE)
	title_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(title_label)

	btn.add_child(vbox)
	btn.pressed.connect(_on_card_thumbnail_pressed.bind(card_id))
	return btn


func _on_card_thumbnail_pressed(card_id: String) -> void:
	"""Kart thumbnail'ine tıklandığında info card overlay'ini aç."""
	# Henüz info_card'ı yeniden gösterme mekaniği yok
	# İleride info_card_overlay'ın kart verilerini cache'leyip tekrar göstermesi sağlanabilir
	pass


# ---------------------------------------------------------------------------
# BÖLÜMLER SEKMESİ
# ---------------------------------------------------------------------------

func _populate_chapters_tab() -> void:
	"""Tamamlanan bölümleri listede göster."""
	# Mevcut listeyi temizle
	for child in chapters_list.get_children():
		child.queue_free()

	var chapter_ids: Array[String] = []
	# Önce config override'ını dene, yoksa world_state'ten oku
	if not _chapter_ids_override.is_empty():
		chapter_ids = _chapter_ids_override
	elif _world_state != null and _world_state.has_method("get_completed_chapters"):
		chapter_ids = _world_state.get_completed_chapters() as Array[String]

	if chapter_ids.is_empty():
		chapters_list.visible = false
		chapters_empty_label.visible = true
		chapters_empty_label.text = _ui_text.text(_ui_text.JOURNAL_CHAPTERS_EMPTY, "Henüz hiç bölüm tamamlamadın.\nYolculuğuna devam et!")
		return

	chapters_list.visible = true
	chapters_empty_label.visible = false

	for chapter_id in chapter_ids:
		var row := _create_chapter_row(chapter_id)
		chapters_list.add_child(row)


func _create_chapter_row(chapter_id: String) -> PanelContainer:
	"""Her bölüm için bir satır oluştur."""
	var panel_container := PanelContainer.new()
	panel_container.custom_minimum_size = Vector2(0, 64)
	panel_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(32, 32)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	# Varsayılan ikon — ileride değiştirilebilir
	hbox.add_child(icon)

	var chapter_data: Dictionary = _get_chapter_data(chapter_id)
	var chapter_name: String = chapter_data.get("name", chapter_id) as String

	var label := Label.new()
	label.text = chapter_name
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", _colors.DESIGN_HEADLINE)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.mouse_filter = Control.MOUSE_FILTER_PASS
	hbox.add_child(label)

	panel_container.add_child(hbox)
	return panel_container


# ---------------------------------------------------------------------------
# VERİ YARDIMCILARI
# ---------------------------------------------------------------------------

func _get_card_data(card_id: String) -> Dictionary:
	"""Kart ID'sine göre görüntülenecek veriyi döndürür."""
	var questions := preload("res://assets/data/questions.gd")
	for event_index in range(questions.EVENTS.size()):
		var event: Dictionary = questions.localized_event(event_index)
		if String(event.get("card_id", "")) == card_id:
			return {
				"title": String(event.get("unit", card_id)),
				"tag": String(event.get("chapter", _ui_text.text(_ui_text.INFO_DEFAULT_TAG, "Tarih Kartı"))),
			}

	# Varsayılan: card_id'yi başlık olarak kullan
	var parts: PackedStringArray = card_id.split("_")
	return {
		"title": " ".join(parts.slice(1)).capitalize() if parts.size() > 1 else card_id.capitalize(),
		"tag": _ui_text.text(_ui_text.INFO_DEFAULT_TAG, "Tarih Kartı"),
	}


func _get_chapter_data(chapter_id: String) -> Dictionary:
	"""Bölüm ID'sine göre görüntülenecek veriyi döndürür."""
	var questions := preload("res://assets/data/questions.gd")
	for event_index in range(questions.EVENTS.size()):
		var event: Dictionary = questions.localized_event(event_index)
		if String(event.get("journal_entry", "")) == chapter_id:
			return {
				"name": String(event.get("chapter", chapter_id)),
			}
	return {
		"name": chapter_id.capitalize(),
	}


func _update_stats() -> void:
	"""Alt bilgi satırını güncelle: toplanan kart / tamamlanan bölüm."""
	var card_count := 0
	var chapter_count := 0
	if not _card_ids_override.is_empty() or not _chapter_ids_override.is_empty():
		card_count = _card_ids_override.size()
		chapter_count = _chapter_ids_override.size()
	elif _world_state != null:
		if _world_state.has_method("get_collected_card_count"):
			card_count = _world_state.get_collected_card_count()
		if _world_state.has_method("get_completed_chapter_count"):
			chapter_count = _world_state.get_completed_chapter_count()

	var card_text := _ui_text.text(_ui_text.JOURNAL_CARD_COUNT, "Kart: %d") % card_count
	var chapter_text := _ui_text.text(_ui_text.JOURNAL_CHAPTER_COUNT, "Bölüm: %d") % chapter_count
	stats_label.text = "%s  |  %s" % [card_text, chapter_text]


# ---------------------------------------------------------------------------
# SEKMELER
# ---------------------------------------------------------------------------

func _select_tab(tab_name: String) -> void:
	"""Verilen isimdeki sekmeyi seç."""
	if tab_name == "chapters":
		tab_container.current_tab = 1
	else:
		tab_container.current_tab = 0


func _on_tab_changed(tab_index: int) -> void:
	"""Sekme değiştiğinde — ileride analitik/log eklenebilir."""
	pass


# ---------------------------------------------------------------------------
# KAPATMA
# ---------------------------------------------------------------------------

func _on_close_pressed() -> void:
	_play_hide_animation()
	journal_closed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()


# ---------------------------------------------------------------------------
# ANİMASYONLAR
# ---------------------------------------------------------------------------

func _play_show_animation() -> void:
	"""Açılış animasyonu: fade-in + scale."""
	backdrop.color = Color(0.08, 0.10, 0.14, 0.0)
	panel.modulate = Color(1, 1, 1, 0.0)
	panel.scale = Vector2(0.92, 0.92)

	var tween := create_tween()
	_overlay_tween_helper.fade_color_alpha(tween, backdrop, 0.72, 0.18)
	_overlay_tween_helper.panel_pop_in(tween, panel)


func _play_hide_animation() -> void:
	"""Kapanış animasyonu: fade-out + scale."""
	var tween := create_tween()
	tween.tween_property(backdrop, "color:a", 0.0, 0.12)
	tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.10)
	tween.parallel().tween_property(panel, "scale", Vector2(0.94, 0.94), 0.10)
	tween.tween_callback(_finish_hide)


func _finish_hide() -> void:
	hide_overlay()
