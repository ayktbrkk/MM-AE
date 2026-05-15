## MMAE — Journal Runtime Contract Verification
## =============================================
## Journal overlay'in runtime state/veri akışını doğrular.
##
## Kullanım:
##   .\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_journal_runtime_contract.gd --quit
##
## Beklenen çıktı: JOURNAL_RUNTIME_CONTRACT_OK, exit code 0

extends MainLoop


# ---------------------------------------------------------------------------
# SABİTLER
# ---------------------------------------------------------------------------
const JOURNAL_SCENE := preload("res://scenes/journal_overlay.tscn")
const WORLD_STATE_SCRIPT := preload("res://scripts/world_state.gd")


# ---------------------------------------------------------------------------
# STATE
# ---------------------------------------------------------------------------
var _failed := 0


# ---------------------------------------------------------------------------
# INIT
# ---------------------------------------------------------------------------
func _initialize() -> void:
	"""Contract testlerini sırayla çalıştır."""
	print(">>> Journal Runtime Contract Testi Basladi")
	print("")

	# =========================================================================
	# TEST 1: WorldState Contract
	# =========================================================================
	_test_world_state()

	# =========================================================================
	# TEST 2: JournalOverlay Node Yapısı
	# =========================================================================
	# SceneTree gerekmeden de nodes çözülebilir — @onready var'ları manuel ata
	var journal: Node = JOURNAL_SCENE.instantiate()
	_init_journal_nodes(journal)

	# show_overlay'i override verilerle çağır
	journal.show_overlay({
		"card_ids": ["samsun_first_decision"],
		"chapter_ids": ["samsun_cards"],
		"tab": "cards",
	})

	# Node referanslarını path ile çöz (güvenli erişim)
	var cards_grid: GridContainer = journal.get_node(
		"Panel/PanelMargin/PanelVBox/TabContainer/CardsTab/Scroll/Grid"
	) as GridContainer
	var chapters_list: VBoxContainer = journal.get_node(
		"Panel/PanelMargin/PanelVBox/TabContainer/ChaptersTab/Scroll/List"
	) as VBoxContainer
	var stats_label: Label = journal.get_node(
		"Panel/PanelMargin/PanelVBox/StatsRow/StatsLabel"
	) as Label

	# Kart grid'inde 1 buton olmalı
	if cards_grid != null:
		_assert_eq(cards_grid.get_child_count(), 1, "Cards grid child count = 1")
	else:
		_fail("cards_grid (GridContainer) cozulemedi — node path yanlis")

	# Bölüm listesinde 1 satır olmalı
	if chapters_list != null:
		_assert_eq(chapters_list.get_child_count(), 1, "Chapters list child count = 1")
	else:
		_fail("chapters_list (VBoxContainer) cozulemedi — node path yanlis")

	# Stats label "Kart: 1" ve "Bölüm: 1" içermeli
	if stats_label != null:
		var label_text: String = stats_label.text
		_assert_true("Kart: 1" in label_text, "Stats label 'Kart: 1' iceriyor")
		_assert_true("Bölüm: 1" in label_text, "Stats label 'Bolum: 1' iceriyor")
	else:
		_fail("stats_label (Label) cozulemedi — node path yanlis")

	journal.free()
	print("  [OK] JournalOverlay node yapisi dogrulandi")

	# =========================================================================
	# TEST 3: Veri Eşleme (_get_card_data / _get_chapter_data)
	# =========================================================================
	_test_data_mapping()

	# =========================================================================
	# RAPOR
	# =========================================================================
	print("")
	print("=".repeat(60))
	if _failed == 0:
		print("  JOURNAL_RUNTIME_CONTRACT_OK")
	else:
		print("  JOURNAL_RUNTIME_CONTRACT_FAILED  (%d hata)" % _failed)
	print("=".repeat(60))


func _idle(_delta: float) -> bool:
	"""Idle callback — _initialize'da tüm testler çalıştı, çık.
	
	false döndürünce MainLoop sonlanır.
	"""
	return false


# ---------------------------------------------------------------------------
# @onready var'ları manuel çöz (SceneTree olmadan)
# ---------------------------------------------------------------------------
func _init_journal_nodes(journal: Node) -> void:
	"""Journal scene'in @onready var'larını manuel olarak ata.
	
	Normalde _ready() içinde SceneTree'den otomatik çözülür,
	ancak MainLoop'ta SceneTree olmadığı için manuel yapıyoruz.
	"""
	# @onready var backdrop: ColorRect = $Backdrop
	journal.set("backdrop", journal.get_node("Backdrop"))
	# @onready var panel: PanelContainer = $Panel
	journal.set("panel", journal.get_node("Panel"))
	# @onready var panel_margin: MarginContainer = $Panel/PanelMargin
	journal.set("panel_margin", journal.get_node("Panel/PanelMargin"))
	# @onready var panel_vbox: VBoxContainer = $Panel/PanelMargin/PanelVBox
	journal.set("panel_vbox", journal.get_node("Panel/PanelMargin/PanelVBox"))
	# @onready var tab_container: TabContainer = $Panel/PanelMargin/PanelVBox/TabContainer
	journal.set("tab_container", journal.get_node("Panel/PanelMargin/PanelVBox/TabContainer"))
	# @onready var cards_tab: Control = $Panel/PanelMargin/PanelVBox/TabContainer/CardsTab
	journal.set("cards_tab", journal.get_node("Panel/PanelMargin/PanelVBox/TabContainer/CardsTab"))
	# @onready var cards_grid: GridContainer = $Panel/PanelMargin/PanelVBox/TabContainer/CardsTab/Scroll/Grid
	journal.set("cards_grid", journal.get_node("Panel/PanelMargin/PanelVBox/TabContainer/CardsTab/Scroll/Grid"))
	# @onready var cards_empty_label: Label = $Panel/PanelMargin/PanelVBox/TabContainer/CardsTab/EmptyLabel
	journal.set("cards_empty_label", journal.get_node("Panel/PanelMargin/PanelVBox/TabContainer/CardsTab/EmptyLabel"))
	# @onready var chapters_tab: Control = $Panel/PanelMargin/PanelVBox/TabContainer/ChaptersTab
	journal.set("chapters_tab", journal.get_node("Panel/PanelMargin/PanelVBox/TabContainer/ChaptersTab"))
	# @onready var chapters_list: VBoxContainer = $Panel/PanelMargin/PanelVBox/TabContainer/ChaptersTab/Scroll/List
	journal.set("chapters_list", journal.get_node("Panel/PanelMargin/PanelVBox/TabContainer/ChaptersTab/Scroll/List"))
	# @onready var chapters_empty_label: Label = $Panel/PanelMargin/PanelVBox/TabContainer/ChaptersTab/EmptyLabel
	journal.set("chapters_empty_label", journal.get_node("Panel/PanelMargin/PanelVBox/TabContainer/ChaptersTab/EmptyLabel"))
	# @onready var close_button: Button = $Panel/PanelMargin/PanelVBox/CloseRow/CloseButton
	journal.set("close_button", journal.get_node("Panel/PanelMargin/PanelVBox/CloseRow/CloseButton"))
	# @onready var stats_label: Label = $Panel/PanelMargin/PanelVBox/StatsRow/StatsLabel
	journal.set("stats_label", journal.get_node("Panel/PanelMargin/PanelVBox/StatsRow/StatsLabel"))


# ---------------------------------------------------------------------------
# TEST 1: WorldState Contract
# ---------------------------------------------------------------------------
func _test_world_state() -> void:
	"""WorldState.mark_card_collected / mark_chapter_completed ve getter'ları doğrula."""
	var state: Node = WORLD_STATE_SCRIPT.new()

	# Boş state'te henüz hiçbir şey yok
	_assert_eq(state.get_collected_card_ids(), [], "WorldState baslangic card_ids bos")
	_assert_eq(state.get_completed_chapters(), [], "WorldState baslangic chapters bos")
	_assert_eq(state.get_collected_card_count(), 0, "WorldState baslangic card_count 0")
	_assert_eq(state.get_completed_chapter_count(), 0, "WorldState baslangic chapter_count 0")

	# Kart ve bölüm ekle
	state.mark_card_collected("samsun_first_decision")
	state.mark_chapter_completed("samsun_cards")

	# Doğrula
	_assert_eq(state.get_collected_card_ids(), ["samsun_first_decision"], "WorldState.get_collected_card_ids")
	_assert_eq(state.get_completed_chapters(), ["samsun_cards"], "WorldState.get_completed_chapters")
	_assert_eq(state.get_collected_card_count(), 1, "WorldState.get_collected_card_count -> 1")
	_assert_eq(state.get_completed_chapter_count(), 1, "WorldState.get_completed_chapter_count -> 1")

	# Deduplication test — aynı kartı/bölümü tekrar ekleme
	state.mark_card_collected("samsun_first_decision")
	state.mark_chapter_completed("samsun_cards")
	_assert_eq(state.get_collected_card_ids(), ["samsun_first_decision"], "WorldState dedup: card_ids ayni")
	_assert_eq(state.get_completed_chapters(), ["samsun_cards"], "WorldState dedup: chapters ayni")
	_assert_eq(state.get_collected_card_count(), 1, "WorldState dedup: card_count hala 1")
	_assert_eq(state.get_completed_chapter_count(), 1, "WorldState dedup: chapter_count hala 1")

	state.free()
	print("  [OK] WorldState contract testi gecti")


# ---------------------------------------------------------------------------
# TEST 3: Veri Eşleme
# ---------------------------------------------------------------------------
func _test_data_mapping() -> void:
	"""Kart ID'sinden anlamlı başlık/tag, bölüm ID'sinden anlamlı isim alınabildiğini doğrula."""
	var journal: Node = JOURNAL_SCENE.instantiate()

	# _get_card_data("samsun_first_decision"):
	#   - questions.gd event 5: unit="İlk Karar", chapter="Bölüm 1: Samsun'a Çıkış"
	#   - Dönen: {"title": "İlk Karar", "tag": "Bölüm 1: Samsun'a Çıkış"}
	var card_data: Dictionary = journal.call("_get_card_data", "samsun_first_decision") as Dictionary
	var card_title: String = String(card_data.get("title", ""))
	var card_tag: String = String(card_data.get("tag", ""))

	_assert_false(card_title.is_empty(), "_get_card_data title bos degil")
	_assert_false(card_tag.is_empty(), "_get_card_data tag bos degil")

	# Fallback: card_id'yi başlık olarak KULLANMAMALI
	_assert_false(card_title == "samsun_first_decision",
		"_get_card_data fallback ID kullanmiyor (title != raw card_id)")

	# Gerçek veriden gelen başlık: questions.gd'de unit = "İlk Karar"
	_assert_true(card_title == "İlk Karar",
		"_get_card_data dogru title: '%s' (beklenen: 'İlk Karar')" % card_title)

	# _get_chapter_data("samsun_cards"):
	#   - questions.gd event 3: journal_entry="samsun_cards", chapter="Bölüm 1: Samsun'a Çıkış"
	#   - Dönen: {"name": "Bölüm 1: Samsun'a Çıkış"}
	var chapter_data: Dictionary = journal.call("_get_chapter_data", "samsun_cards") as Dictionary
	var chapter_name: String = String(chapter_data.get("name", ""))

	_assert_false(chapter_name.is_empty(), "_get_chapter_data name bos degil")
	_assert_false(chapter_name == "samsun_cards",
		"_get_chapter_data fallback ID kullanmiyor (name != raw chapter_id)")
	# "Bölüm 1: Samsun'a Çıkış" gibi anlamlı bir isim dönmeli
	_assert_true(chapter_name.length() > 5,
		"_get_chapter_data anlamli isim donduruyor: '%s'" % chapter_name)

	journal.free()
	print("  [OK] Veri esleme testi gecti")


# ---------------------------------------------------------------------------
# YARDIMCI ASSERT'LER
# ---------------------------------------------------------------------------
func _assert_eq(got: Variant, expected: Variant, label: String) -> void:
	"""İki değerin eşitliğini assert et."""
	if got != expected:
		push_error("FAIL [%s]: expected %s, got %s" % [label, str(expected), str(got)])
		_failed += 1
	else:
		print("  PASS [%s]" % label)


func _assert_true(condition: bool, label: String) -> void:
	"""Boolean koşulun true olduğunu assert et."""
	if not condition:
		push_error("FAIL [%s]: expected true" % label)
		_failed += 1
	else:
		print("  PASS [%s]" % label)


func _assert_false(condition: bool, label: String) -> void:
	"""Boolean koşulun false olduğunu assert et."""
	if condition:
		push_error("FAIL [%s]: expected false" % label)
		_failed += 1
	else:
		print("  PASS [%s]" % label)


func _fail(message: String) -> void:
	"""Doğrudan hata bildir (node cozulemedi vb.)."""
	push_error("FAIL: %s" % message)
	_failed += 1
