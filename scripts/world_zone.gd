## MMAE - Zone ve Chapter Yönetimi Modülü
## =========================================
## R5 refactoring: world.gd'den ayrıştırıldı.
## Zone geçişleri, etkileşim routing, koleksiyon mantığı, karar yönetimi.
##
## Kullanım: world.gd tarafından preload edilip initialize() ile kurulur.

class_name WorldZone
extends Node

var _world: Node2D

# Texture/colors sabitleri (merkezi dosyalardan)
const _textures := preload("res://scripts/textures.gd")
const _colors := preload("res://scripts/colors.gd")
const _questions := preload("res://assets/data/questions.gd")

# ---------------------------------------------------------------------------
# EVENT CHAIN SABİTLERİ
# ---------------------------------------------------------------------------
# Bölüm bazlı event zincirleri — questions.gd EVENTS dizisine referans
# Her zone için sıralı event index'leri tanımlar.
const CHAPTER_EVENT_CHAINS := {
	"room": [0, 1, 2],
	"bandirma": [3, 4],
	"samsun_rift": [5, 6],
	"havza": [7, 8, 9],
	"amasya": [10, 11, 12, 13],
	"kongreler": [14, 15, 16, 17, 18, 19],
	"ankara": [20, 21, 22, 23],
	"sakarya": [24, 25, 26, 27],
	"final": [28, 29, 30],
}

# Builder'ı olan ve marker sistemi çalışan bölgeler
const BUILT_ZONES := [
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


func initialize(world: Node2D) -> void:
	"""World referansını kur."""
	_world = world


# ---------------------------------------------------------------------------
# EVENT CHAIN STATE
# ---------------------------------------------------------------------------
# Event zinciri ilerleme durumu
var _current_event_index: int = 0
var _is_event_chain_active: bool = false
var _last_decision_event_index: int = 0


# ---------------------------------------------------------------------------
# EVENT CHAIN TRIGGER
# ---------------------------------------------------------------------------

func trigger_event_chain() -> void:
	"""Event zincirini başlat veya sonraki event'e geç.
	
	Eğer mevcut zone BUILT_ZONES içindeyse (marker sistemi var):
	- Story event'leri otomatik oynat
	- Decision event'leri marker sisteme bırak (atla)
	
	Eğer zone henüz inşa edilmemişse (ankara, sakarya, final):
	- Feature flag kontrolü: sadece BUILT_ZONES'dekileri işle
	- İnşa edilmemiş zone'lar için event'leri pas geç
	"""
	var state: Node = _get_state()
	if state == null:
		return
	
	var zone: String = state.current_zone
	if not _is_zone_built(zone):
		# İnşa edilmemiş zone — event'leri atla, bölüm sonu
		_on_chapter_end()
		return
	
	var chain: Array = CHAPTER_EVENT_CHAINS.get(zone, [])
	if _current_event_index >= chain.size():
		_on_chapter_end()
		return
	
	_is_event_chain_active = true
	var event_idx: int = chain[_current_event_index] as int
	_handle_event(event_idx)
	_current_event_index += 1


func _handle_event(event_index: int) -> void:
	"""Event index'e göre içerik tipini belirle ve uygun overlay'i göster.
	
	Mevcut marker-tetiklemeli event'ler (index 3-6) bu fonksiyondan
	geçmez — onlar doğrudan _show_samsun_decision() vb. ile yönetilir.
	Bu fonksiyon sadece chain üzerinden gelen event'ler için çalışır.
	"""
	var event_data: Dictionary = _questions.EVENTS[event_index]
	var ui_mod: Node = _get_ui_mod()
	if ui_mod == null:
		return
	
	match event_data.get("kind", "story"):
		"story":
			var speaker: String = event_data.get("speaker", "Anlatıcı")
			var text: String = event_data.get("story", "")
			var player_mod: Node = _get_player_mod()
			if player_mod != null and "{hero}" in text:
				text = text.replace("{hero}", player_mod.hero_name)
			if "{hero}" in speaker:
				speaker = speaker.replace("{hero}", player_mod.hero_name if player_mod != null else "Arda")
			# Story event — dialogue göster, callback ile zinciri devam ettir
			ui_mod.show_dialogue(speaker, text, Callable(self, "_on_event_dialogue_closed"))
		
		"decision":
			# Decision event — karar overlay'ini göster
			# context olarak zone adını kullan
			_last_decision_event_index = event_index
			var state: Node = _get_state()
			var zone: String = state.current_zone if state != null else ""
			ui_mod.show_decision(event_index, zone)


func _on_event_dialogue_closed() -> void:
	"""Event zinciri dialogue'u kapatılınca sonraki event'i tetikle."""
	trigger_event_chain()


func _is_zone_built(zone: String) -> bool:
	"""Feature flag: Bu zone için builder/ marker sistemi var mı?
	
	Tüm zone'lar artık BUILT_ZONES içinde yer alır.
	"""
	return zone in BUILT_ZONES


func _on_chapter_end() -> void:
	"""Bölüm sonu — event zinciri tamamlandı.
	
	İleride burada strateji geçişi, otomatik kaydetme veya
	bölüm özeti gösterilebilir. Şu an için sadece zinciri kapatır.
	"""
	_is_event_chain_active = false
	_current_event_index = 0


# ---------------------------------------------------------------------------
# GOAL MANAGEMENT
# ---------------------------------------------------------------------------

func set_goal(kind: String, text: String) -> void:
	"""Hedefi state'e yaz ve UI'ı güncelle."""
	var state: Node = _world.get_node("WorldState")
	var ui_mod: Node = _get_ui_mod()
	state.set_goal(kind, text)
	if ui_mod != null:
		ui_mod.update_objective(text)
		ui_mod.refresh_minimap_markers()


func _get_player_mod() -> Node:
	"""Player modül referansını döndür."""
	if _world.has_node("WorldPlayer"):
		return _world.get_node("WorldPlayer")
	return null


func _get_ui_mod() -> Node:
	"""UI modül referansını döndür."""
	if _world.has_node("WorldUI"):
		return _world.get_node("WorldUI")
	return null


func _get_state() -> Node:
	return _world.get_node("WorldState")


func _get_builder() -> Node:
	return _world.get_node("WorldBuilder")


func _get_marker() -> Node:
	return _world.get_node("WorldMarker")


func _get_wave() -> Node:
	return _world.get_node("WorldWave")


# ---------------------------------------------------------------------------
# INTERACTION ROUTING
# ---------------------------------------------------------------------------

func interact() -> void:
	"""Yakındaki marker ile etkileşime geç."""
	var player_mod: Node = _get_player_mod()
	if player_mod == null:
		return

	var nearby_marker: Node2D = player_mod.nearby_marker
	if nearby_marker == null:
		return

	var kind := String(nearby_marker.get_meta("kind"))
	match kind:
		"unit":
			_collect_unit(nearby_marker)
		"ship_clue":
			_collect_ship_clue(nearby_marker)
		"havza_clue":
			_collect_havza_clue(nearby_marker)
		"npc":
			var ui_mod: Node = _get_ui_mod()
			if ui_mod != null:
				var marker_node: Node = _get_marker()
				ui_mod.show_dialogue(
					String(nearby_marker.get_meta("title")),
					marker_node.format_marker_text(String(nearby_marker.get_meta("text")), player_mod.hero_name),
					Callable()
				)
		"portal":
			_handle_portal_interaction(nearby_marker, player_mod)
		"decision":
			_handle_samsun_decision_check(nearby_marker, player_mod)
		"havza_decision":
			_handle_havza_decision_check(nearby_marker, player_mod)
		"amasya_decision":
			_handle_amasya_decision_check(nearby_marker, player_mod)
		"kongre_decision":
			_handle_kongre_decision_check(nearby_marker, player_mod)
		"amasya_clue":
			_collect_amasya_clue(nearby_marker)
		"kongre_clue":
			_collect_kongre_clue(nearby_marker)
		"resource":
			_collect_leadership_resource(nearby_marker)
		"build_spot":
			var wave: Node = _get_wave()
			wave.show_support_panel(nearby_marker)
		"wave_start":
			var wave: Node = _get_wave()
			wave.start_confusion_wave()
		"havza_wave":
			var wave: Node = _get_wave()
			wave.start_havza_wave()
		"amasya_wave":
			var wave: Node = _get_wave()
			wave.start_amasya_wave()
		"kongre_wave":
			var wave: Node = _get_wave()
			wave.start_kongre_wave()


func _handle_portal_interaction(marker: Node2D, player_mod: Node) -> void:
	"""Portal (oda çıkışı) etkileşimini yönet."""
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var marker_node: Node = _get_marker()
	if ui_mod == null:
		return

	if state.get_item_count("units") >= state.get_zone_item_total("units"):
		ui_mod.show_dialogue(
			String(marker.get_meta("title")),
			marker_node.format_marker_text(String(marker.get_meta("text")), player_mod.hero_name),
			Callable(self, "_enter_bandirma")
		)
	else:
		ui_mod.show_dialogue(
			"Kitap Henüz Açılmadı",
			"Bandırma Vapuru'na geçmeden önce üç ünite notunu da toplamalısın.",
			Callable()
		)


func _handle_samsun_decision_check(marker: Node2D, player_mod: Node) -> void:
	"""Samsun karar kontrolü — tüm ipuçları toplanmış mı?"""
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	if ui_mod == null:
		return

	if state.get_item_count("ship_clues") >= state.get_zone_item_total("ship_clues"):
		_show_samsun_decision()
	else:
		ui_mod.show_dialogue(
			"Karar İçin Hazır Değilsin",
			"Önce kamaradaki üniformayı ve harita masasını incele.",
			Callable()
		)


func _handle_havza_decision_check(marker: Node2D, player_mod: Node) -> void:
	"""Havza karar kontrolü."""
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	if ui_mod == null:
		return

	if state.get_item_count("havza_clues") >= state.get_zone_item_total("havza_clues"):
		_show_havza_decision()
	else:
		ui_mod.show_dialogue(
			"Çağrı İçin Hazır Değilsin",
			"Önce genelge metnini ve telgraf defterini incele.",
			Callable()
		)


func _handle_amasya_decision_check(marker: Node2D, player_mod: Node) -> void:
	"""Amasya karar kontrolü."""
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	if ui_mod == null:
		return

	if state.get_item_count("amasya_clues") >= state.get_zone_item_total("amasya_clues"):
		_show_amasya_decision()
	else:
		ui_mod.show_dialogue(
			"Bildiri İçin Hazır Değilsin",
			"Önce toplantı notunu ve bildiri taslağını incele.",
			Callable()
		)


func _handle_kongre_decision_check(marker: Node2D, player_mod: Node) -> void:
	"""Kongre karar kontrolü."""
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	if ui_mod == null:
		return

	if state.get_item_count("kongre_clues") >= state.get_zone_item_total("kongre_clues"):
		_show_kongre_decision()
	else:
		ui_mod.show_dialogue(
			"Kongre İçin Hazır Değilsin",
			"Önce temsil listesini ve ortak karar taslağını incele.",
			Callable()
		)


# ---------------------------------------------------------------------------
# COLLECTION FUNCTIONS
# ---------------------------------------------------------------------------

func _collect_unit(marker: Node2D) -> void:
	"""Ünite notu toplama."""
	if bool(marker.get_meta("collected")):
		return

	var marker_node: Node = _get_marker()
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()

	marker_node.mark_collected(marker)
	state.increment_item_count("units")
	ui_mod.spawn_reward_burst(marker.position, Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.92), "reward.unit")
	marker_node.hide_nearby_collection_visuals(marker.position, true, _world.get_node("Props"), _world.get_node("ForegroundProps"))
	ui_mod.update_progress()
	ui_mod.refresh_minimap_markers()
	ui_mod.show_info_card(
		String(marker.get_meta("title")),
		marker_node.format_marker_text(String(marker.get_meta("text")), player_mod.hero_name),
		"Yeni tarih notu bulundu",
		Callable(),
		"unit"
	)

	if state.get_item_count("units") >= state.get_zone_item_total("units"):
		set_goal("portal", "Tüm üniteler toplandı. Çalışma masasındaki Tarih Kitabı'na git.")


func _collect_ship_clue(marker: Node2D) -> void:
	"""Gemi ipucu toplama."""
	if bool(marker.get_meta("collected")):
		return

	var marker_node: Node = _get_marker()
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()

	marker_node.mark_collected(marker)
	state.increment_item_count("ship_clues")
	ui_mod.spawn_reward_burst(marker.position, Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.86), "reward.ship")
	marker_node.hide_nearby_collection_visuals(marker.position, true, _world.get_node("Props"), _world.get_node("ForegroundProps"))
	ui_mod.update_progress()
	ui_mod.refresh_minimap_markers()
	ui_mod.show_info_card(
		String(marker.get_meta("title")),
		marker_node.format_marker_text(String(marker.get_meta("text")), player_mod.hero_name),
		"Yeni gemi ipucu bulundu",
		Callable(),
		"ship"
	)

	if state.get_item_count("ship_clues") >= state.get_zone_item_total("ship_clues"):
		set_goal("decision", "Gemi ipuçları tamamlandı. Güvertedeki Samsun Kararı işaretine git.")


func _collect_havza_clue(marker: Node2D) -> void:
	"""Havza ipucu toplama."""
	if bool(marker.get_meta("collected")):
		return

	var marker_node: Node = _get_marker()
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()

	marker_node.mark_collected(marker)
	state.increment_item_count("havza_clues")
	ui_mod.spawn_reward_burst(marker.position, Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.86), "reward.havza")
	marker_node.hide_nearby_collection_visuals(marker.position, true, _world.get_node("Props"), _world.get_node("ForegroundProps"))
	ui_mod.update_progress()
	ui_mod.refresh_minimap_markers()
	ui_mod.show_info_card(
		String(marker.get_meta("title")),
		marker_node.format_marker_text(String(marker.get_meta("text")), player_mod.hero_name),
		"Yeni genelge ipucu bulundu",
		Callable(),
		"havza"
	)

	if state.get_item_count("havza_clues") >= state.get_zone_item_total("havza_clues"):
		set_goal("havza_decision", "Havza ipuçları tamamlandı. Şimdi Havza Çağrısı noktasına git.")


func _collect_amasya_clue(marker: Node2D) -> void:
	"""Amasya ipucu toplama."""
	if bool(marker.get_meta("collected")):
		return

	var marker_node: Node = _get_marker()
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()

	marker_node.mark_collected(marker)
	state.increment_item_count("amasya_clues")
	ui_mod.spawn_reward_burst(marker.position, Color(1.0, 0.74, 0.34, 0.86), "reward.amasya")
	marker_node.hide_nearby_collection_visuals(marker.position, true, _world.get_node("Props"), _world.get_node("ForegroundProps"))
	ui_mod.update_progress()
	ui_mod.refresh_minimap_markers()
	ui_mod.show_info_card(
		String(marker.get_meta("title")),
		marker_node.format_marker_text(String(marker.get_meta("text")), player_mod.hero_name),
		"Yeni bildiri ipucu bulundu",
		Callable(),
		"amasya"
	)

	if state.get_item_count("amasya_clues") >= state.get_zone_item_total("amasya_clues"):
		set_goal("amasya_decision", "Amasya ipuçları tamamlandı. Şimdi Amasya Kararı noktasına git.")


func _collect_kongre_clue(marker: Node2D) -> void:
	"""Kongre ipucu toplama."""
	if bool(marker.get_meta("collected")):
		return

	var marker_node: Node = _get_marker()
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()

	marker_node.mark_collected(marker)
	state.increment_item_count("kongre_clues")
	ui_mod.spawn_reward_burst(marker.position, Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.76), "reward.kongre")
	marker_node.hide_nearby_collection_visuals(marker.position, true, _world.get_node("Props"), _world.get_node("ForegroundProps"))
	ui_mod.update_progress()
	ui_mod.refresh_minimap_markers()
	ui_mod.show_info_card(
		String(marker.get_meta("title")),
		marker_node.format_marker_text(String(marker.get_meta("text")), player_mod.hero_name),
		"Yeni kongre ipucu bulundu",
		Callable(),
		"kongre"
	)

	if state.get_item_count("kongre_clues") >= state.get_zone_item_total("kongre_clues"):
		set_goal("kongre_decision", "Kongre ipuçları tamamlandı. Şimdi Kongre Kararı noktasına git.")


func _collect_leadership_resource(marker: Node2D) -> void:
	"""Liderlik kaynağı toplama."""
	if bool(marker.get_meta("collected")):
		return

	var marker_node: Node = _get_marker()
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()

	marker_node.mark_collected(marker)
	state.add_leadership(1)
	ui_mod.spawn_reward_burst(marker.position, Color(0.70, 1.0, 0.48, 0.86), "reward.resource")
	marker_node.hide_nearby_collection_visuals(marker.position, true, _world.get_node("Props"), _world.get_node("ForegroundProps"))
	ui_mod.update_progress()
	ui_mod.refresh_minimap_markers()
	ui_mod.show_info_card(
		String(marker.get_meta("title")),
		marker_node.format_marker_text(String(marker.get_meta("text")), player_mod.hero_name),
		"Liderlik puani +1",
		Callable(),
		"support"
	)


# ---------------------------------------------------------------------------
# ZONE TRANSITIONS
# ---------------------------------------------------------------------------

func clear_world() -> void:
	"""Dünyayı temizle ve UI state'leri sıfırla."""
	var builder: Node = _get_builder()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()
	builder.clear_world(_world)
	if player_mod != null:
		player_mod.companion_reaction_spots.clear()
	player_mod.active_companion_reaction = ""
	if player_mod.companion_reaction_label != null:
		player_mod.companion_reaction_label.visible = false
	if ui_mod != null:
		ui_mod.samsun_goal_visuals.clear()
		ui_mod.clear_minimap_markers()


func transition_to(zone: String) -> void:
	"""Belirtilen zone'a geçiş yap. Geçiş animasyonu + setup."""
	var ui_mod: Node = _get_ui_mod()
	if ui_mod == null:
		return
	
	# Event chain'i sıfırla — yeni zone için hazırla
	_current_event_index = 0
	_is_event_chain_active = false

	match zone:
		"bandirma":
			ui_mod.play_dream_transition(Callable(self, "_setup_bandirma"))
		"samsun_rift":
			ui_mod.play_dream_transition(Callable(self, "_setup_samsun_rift"))
		"havza":
			ui_mod.play_dream_transition(Callable(self, "_setup_havza"))
		"amasya":
			ui_mod.play_dream_transition(Callable(self, "_setup_amasya"))
		"kongreler":
			ui_mod.play_dream_transition(Callable(self, "_setup_kongreler"))
		"ankara":
			ui_mod.play_dream_transition(Callable(self, "_setup_ankara"))
		"sakarya":
			ui_mod.play_dream_transition(Callable(self, "_setup_sakarya"))
		"final":
			ui_mod.play_dream_transition(Callable(self, "_setup_final"))


func _setup_bandirma() -> void:
	"""Bandırma Vapuru sahnesini kur."""
	var builder: Node = _get_builder()
	var marker_node: Node = _get_marker()
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()

	builder.clear_world(_world)
	builder.build_world("ship", _world)
	marker_node.spawn_markers("ship", _world)
	state.reset_item_count("ship_clues")

	player_mod.target_position = _setup_player_position(Vector2(520, 760), Vector2(660, 820))

	set_goal("ship_clue", "Bandırma Vapuru'nda uyan. Üniformayı ve harita masasını incele.")
	ui_mod.update_progress()
	ui_mod.show_chapter_transition("Bandırma Vapuru", "Gece yolculugu basliyor")
	ui_mod.show_dialogue(
		"Bandırma Vapuru",
		"%s gözlerini açtığında küçük bir kamaradadır. Başucunda ona uygun bir üniforma vardır. Güverteye çıkmadan önce kamaradaki ipuçlarını incele." % player_mod.hero_name,
		Callable()
	)


func _setup_samsun_rift() -> void:
	"""Samsun Rüyası sahnesini kur."""
	var builder: Node = _get_builder()
	var marker_node: Node = _get_marker()
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()

	builder.clear_world(_world)
	builder.build_world("samsun_rift", _world)
	_setup_samsun_rift_after_build()
	marker_node.spawn_markers("samsun_rift", _world)
	state.set_leadership(3)
	state.set_required_supports(2)
	state.reset_supports()
	state.reset_wave_attempts()

	player_mod.target_position = _setup_player_position(Vector2(800, 1070), Vector2(930, 1160))

	ui_mod.start_samsun_open_world_overview()
	set_goal("resource", _samsun_intro_goal_text())
	ui_mod.update_progress()
	ui_mod.show_chapter_transition("Samsun Ruyasi", "Kararlarini stratejiyle destekle")
	ui_mod.show_dialogue(
		"Samsun Rüyası",
		"Ekranın kenarları bulutlanır. %s Samsun kıyısında küçük bir rüya haritasına iner. Liman, Telgraf ve Halk noktaları parlıyor: önce izleri oku, sonra iki destek kur." % player_mod.hero_name,
		Callable()
	)


func _setup_havza() -> void:
	"""Havza sahnesini kur."""
	var builder: Node = _get_builder()
	var marker_node: Node = _get_marker()
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()

	builder.clear_world(_world)
	builder.build_world("havza", _world)
	marker_node.spawn_markers("havza", _world)
	state.reset_item_count("havza_clues")
	state.set_leadership(2)
	state.set_required_supports(2)
	state.reset_supports()
	state.reset_wave_attempts()

	player_mod.target_position = _setup_player_position(Vector2(760, 1180), Vector2(900, 1260))

	set_goal("havza_clue", "Havza açıldı. İpuçlarını topla, doğru çağrıyı seç ve sessizlik dalgasını aş.")
	ui_mod.update_progress()
	ui_mod.show_chapter_transition("Havza Genelgesi", "Halkin ortak sesini bul")
	ui_mod.show_dialogue(
		"Havza Genelgesi",
		"%s bu kez sakin ama gergin bir kasaba meydanında belirir. İnsanlar ne yapacaklarını bilmiyor gibidir. Onları ortak ve bilinçli tepkiye hazırlamak gerekir." % player_mod.hero_name,
		Callable()
	)


func _setup_amasya() -> void:
	"""Amasya sahnesini kur."""
	var builder: Node = _get_builder()
	var marker_node: Node = _get_marker()
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()

	builder.clear_world(_world)
	builder.build_world("amasya", _world)
	marker_node.spawn_markers("amasya", _world)
	state.reset_item_count("amasya_clues")
	state.set_leadership(2)
	state.set_required_supports(2)
	state.reset_supports()
	state.reset_wave_attempts()

	player_mod.target_position = _setup_player_position(Vector2(780, 1220), Vector2(920, 1300))

	set_goal("amasya_clue", "Amasya açıldı. İpuçlarını topla, doğru bildiriyi seç ve tereddüt çemberini aş.")
	ui_mod.update_progress()
	ui_mod.show_chapter_transition("Amasya Genelgesi", "Milletin kararini cümleye dönüştür")
	ui_mod.show_dialogue(
		"Amasya Genelgesi",
		"%s şimdi loş bir toplantı evindedir. Fikirler havada asılı gibidir. Burada doğru iş, ortak iradeyi açık ve cesur bir bildiride birleştirmektir." % player_mod.hero_name,
		Callable()
	)


func _setup_kongreler() -> void:
	"""Kongreler sahnesini kur."""
	var builder: Node = _get_builder()
	var marker_node: Node = _get_marker()
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()

	builder.clear_world(_world)
	builder.build_world("kongreler", _world)
	marker_node.spawn_markers("kongreler", _world)
	state.reset_item_count("kongre_clues")
	state.set_leadership(2)
	state.set_required_supports(2)
	state.reset_supports()
	state.reset_wave_attempts()

	player_mod.target_position = _setup_player_position(Vector2(780, 1220), Vector2(920, 1300))

	set_goal("kongre_clue", "Kongreler açıldı. İpuçlarını topla, doğru birleşimi seç ve dağınıklık dalgasını aş.")
	ui_mod.update_progress()
	ui_mod.show_chapter_transition("Kongreler", "Farklı sesleri ortak hedefte buluştur")
	ui_mod.show_dialogue(
		"Kongreler",
		"%s şimdi büyük bir kongre salonundadır. Herkesin sesi farklıdır ama doğru iş, bu sesleri tek bir amaçta buluşturmaktır." % player_mod.hero_name,
		Callable()
	)


func _setup_ankara() -> void:
	"""Ankara / Meclis sahnesini kur."""
	var builder: Node = _get_builder()
	var marker_node: Node = _get_marker()
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()

	builder.clear_world(_world)
	builder.build_world("ankara", _world)
	_setup_ankara_after_build()
	marker_node.spawn_markers("ankara", _world)
	state.reset_item_count("ankara_clues")
	state.set_leadership(2)
	state.set_required_supports(2)
	state.reset_supports()
	state.reset_wave_attempts()

	player_mod.target_position = _setup_player_position(Vector2(780, 1220), Vector2(920, 1300))

	set_goal("ankara_clue", "Ankara açıldı. İpuçlarını topla, doğru kararı ver ve Meclis'in iradesini kur.")
	ui_mod.update_progress()
	ui_mod.show_chapter_transition("Ankara: Meclis ve İrade", "Iradenin gücünü Meclis'te bul")
	ui_mod.show_dialogue(
		"Ankara: Meclis ve İrade",
		"%s şimdi sıcak bir bozkırın ortasında, yeni kurulmakta olan bir meclisin eşiğindedir. Burada doğru iş, milletin iradesini tek bir çatı altında toplamak ve tarihe yön vermektir." % player_mod.hero_name,
		Callable()
	)


func _setup_ankara_after_build() -> void:
	"""Builder sonrası Ankara özel kurulumları — landmark ve companion reaksiyonları."""
	var builder: Node = _get_builder()
	var player_mod: Node = _get_player_mod()
	if builder == null or player_mod == null:
		return

	builder.add_strategy_node(Vector2(800, 1000), "Milli İrade", _colors.POP_GOLD, "ankara.rift_core")
	builder.add_historical_landmark(Vector2(360, 820), "harbor", "Meclis", "ankara.meclis_node")
	builder.add_prop_cluster(Vector2(360, 820), "meeting", "ankara.meclis_landmark")
	builder.add_historical_landmark(Vector2(1190, 820), "telegraph", "Telgraf", "ankara.telegraph_node")
	builder.add_prop_cluster(Vector2(1190, 820), "telegraph", "ankara.telegraph_landmark")
	builder.add_historical_landmark(Vector2(530, 1500), "people", "Halk", "ankara.people_node")
	builder.add_prop_cluster(Vector2(530, 1500), "people", "ankara.people_landmark")

	builder.add_strategy_node(Vector2(360, 820), "Destek", _colors.POP_TURQUOISE, "interactables.strategy_node")
	builder.add_strategy_node(Vector2(1190, 820), "Haber", _colors.RIFT_BLUE, "interactables.strategy_node")
	builder.add_strategy_node(Vector2(530, 1500), "Birlik", _colors.POP_GOLD, "interactables.strategy_node")
	builder.add_strategy_node(Vector2(820, 1500), "Dalga", Color(0.68, 0.40, 1.0), "fx.rift_focus_ring")

	builder.add_prop_cluster(Vector2(360, 620), "discovery", "world_props.prop_cluster")
	builder.add_prop_cluster(Vector2(1210, 1550), "discovery", "world_props.prop_cluster")

	player_mod.add_companion_reaction_spot(Vector2(360, 620), 210.0, "Eda: Önce Meclis çevresindeki izleri okuyalım.", "interactables.companion_reaction_spot")
	player_mod.add_companion_reaction_spot(Vector2(1190, 820), 230.0, "Eda: Telgraf, Ankara'ya gelen haberleri güvenli taşımak için önemli.", "interactables.companion_reaction_spot")
	player_mod.add_companion_reaction_spot(Vector2(530, 1500), 230.0, "Arda: Halkın iradesini Meclis'te buluşturmak en güçlü yol.", "interactables.companion_reaction_spot")
	player_mod.add_companion_reaction_spot(Vector2(800, 1000), 240.0, "Eda: Gözlem ve birlik, Meclis'in temelidir.", "interactables.companion_reaction_spot")


func _setup_sakarya() -> void:
	"""Sakarya / Büyük Taarruz sahnesini kur."""
	var builder: Node = _get_builder()
	var marker_node: Node = _get_marker()
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()

	builder.clear_world(_world)
	builder.build_world("sakarya", _world)
	_setup_sakarya_after_build()
	marker_node.spawn_markers("sakarya", _world)
	state.reset_item_count("sakarya_clues")
	state.set_leadership(3)
	state.set_required_supports(3)
	state.reset_supports()
	state.reset_wave_attempts()

	player_mod.target_position = _setup_player_position(Vector2(780, 1220), Vector2(920, 1300))

	set_goal("sakarya_clue", "Sakarya açıldı. İpuçlarını topla, doğru kararı ver ve Büyük Taarruz'u başlat.")
	ui_mod.update_progress()
	ui_mod.show_chapter_transition("Sakarya ve Büyük Taarruz", "Vatan savunmasında son kale")
	ui_mod.show_dialogue(
		"Sakarya ve Büyük Taarruz",
		"%s şimdi savaşın tam ortasındadır. Düşman Ankara'ya doğru ilerlerken, herkes umudunu korumaya çalışmaktadır. Burada doğru iş, vatanın her karış toprağını savunmak ve zaferi getirecek kararları vermektir." % player_mod.hero_name,
		Callable()
	)


func _setup_sakarya_after_build() -> void:
	"""Builder sonrası Sakarya özel kurulumları — karargah ve companion reaksiyonları."""
	var builder: Node = _get_builder()
	var player_mod: Node = _get_player_mod()
	if builder == null or player_mod == null:
		return

	builder.add_strategy_node(Vector2(800, 1000), "Millî İrade", _colors.POP_GOLD, "sakarya.rift_core")
	builder.add_historical_landmark(Vector2(360, 820), "harbor", "Karargâh", "sakarya.hq_node")
	builder.add_prop_cluster(Vector2(360, 820), "meeting", "sakarya.hq_landmark")
	builder.add_historical_landmark(Vector2(1190, 820), "telegraph", "Telgraf", "sakarya.telegraph_node")
	builder.add_prop_cluster(Vector2(1190, 820), "telegraph", "sakarya.telegraph_landmark")
	builder.add_historical_landmark(Vector2(530, 1500), "people", "Cephe", "sakarya.front_node")
	builder.add_prop_cluster(Vector2(530, 1500), "people", "sakarya.front_landmark")

	builder.add_strategy_node(Vector2(360, 820), "Destek", _colors.POP_TURQUOISE, "interactables.strategy_node")
	builder.add_strategy_node(Vector2(1190, 820), "Haber", _colors.RIFT_BLUE, "interactables.strategy_node")
	builder.add_strategy_node(Vector2(530, 1500), "Birlik", _colors.POP_GOLD, "interactables.strategy_node")
	builder.add_strategy_node(Vector2(820, 1500), "Dalga", Color(0.68, 0.40, 1.0), "fx.rift_focus_ring")

	builder.add_prop_cluster(Vector2(360, 620), "discovery", "world_props.prop_cluster")
	builder.add_prop_cluster(Vector2(1210, 1550), "discovery", "world_props.prop_cluster")

	player_mod.add_companion_reaction_spot(Vector2(360, 620), 210.0, "Eda: Önce karargâh çevresindeki izleri okuyalım.", "interactables.companion_reaction_spot")
	player_mod.add_companion_reaction_spot(Vector2(1190, 820), 230.0, "Eda: Telgraf, cephe haberlerini güvenli taşımak için önemli.", "interactables.companion_reaction_spot")
	player_mod.add_companion_reaction_spot(Vector2(530, 1500), 230.0, "Arda: Cephedeki askerlerin moralini yüksek tutmak en önemli görev.", "interactables.companion_reaction_spot")
	player_mod.add_companion_reaction_spot(Vector2(800, 1000), 240.0, "Eda: Strateji ve birlik, zaferin anahtarıdır.", "interactables.companion_reaction_spot")


func _setup_final() -> void:
	"""Final / Cumhuriyet sahnesini kur."""
	var builder: Node = _get_builder()
	var marker_node: Node = _get_marker()
	var state: Node = _get_state()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()

	builder.clear_world(_world)
	builder.build_world("final", _world)
	_setup_final_after_build()
	marker_node.spawn_markers("final", _world)
	state.reset_item_count("final_clues")
	state.set_leadership(5)
	state.set_required_supports(2)
	state.reset_supports()
	state.reset_wave_attempts()

	player_mod.target_position = _setup_player_position(Vector2(780, 1220), Vector2(920, 1300))

	set_goal("final_clue", "Cumhuriyet açıldı. İpuçlarını topla, doğru kararı ver ve zaferi tamamla.")
	ui_mod.update_progress()
	ui_mod.show_chapter_transition("Final: Cumhuriyet", "29 Ekim 1923 — Milletin zaferi")
	ui_mod.show_dialogue(
		"Final: Cumhuriyet",
		"%s şimdi tarihin en önemli anlarından birindedir. 29 Ekim 1923'te Cumhuriyet ilan edilmiştir. Millet, bağımsızlığını kazanmış, yeni bir devletin temelleri atılmıştır. Şimdi sıra, bu mirası anlamak ve geleceğe taşımaktadır." % player_mod.hero_name,
		Callable()
	)


func _setup_final_after_build() -> void:
	"""Builder sonrası Final özel kurulumları — meclis ve companion reaksiyonları."""
	var builder: Node = _get_builder()
	var player_mod: Node = _get_player_mod()
	if builder == null or player_mod == null:
		return

	builder.add_strategy_node(Vector2(800, 1000), "Millî İrade", _colors.POP_GOLD, "final.rift_core")
	builder.add_historical_landmark(Vector2(360, 820), "harbor", "Meclis", "final.meclis_node")
	builder.add_prop_cluster(Vector2(360, 820), "meeting", "final.meclis_landmark")
	builder.add_historical_landmark(Vector2(1190, 820), "telegraph", "Zafer", "final.victory_node")
	builder.add_prop_cluster(Vector2(1190, 820), "telegraph", "final.victory_landmark")
	builder.add_historical_landmark(Vector2(530, 1500), "people", "Gelecek", "final.future_node")
	builder.add_prop_cluster(Vector2(530, 1500), "people", "final.future_landmark")

	builder.add_strategy_node(Vector2(360, 820), "Destek", _colors.POP_TURQUOISE, "interactables.strategy_node")
	builder.add_strategy_node(Vector2(1190, 820), "Haber", _colors.RIFT_BLUE, "interactables.strategy_node")
	builder.add_strategy_node(Vector2(530, 1500), "Birlik", _colors.POP_GOLD, "interactables.strategy_node")
	builder.add_strategy_node(Vector2(820, 1500), "Dalga", Color(0.90, 0.75, 0.30), "fx.rift_focus_ring")

	builder.add_prop_cluster(Vector2(360, 620), "discovery", "world_props.prop_cluster")
	builder.add_prop_cluster(Vector2(1210, 1550), "discovery", "world_props.prop_cluster")

	player_mod.add_companion_reaction_spot(Vector2(360, 620), 210.0, "Eda: Meclis binası... İşte burası, tarih burada yazıldı.", "interactables.companion_reaction_spot")
	player_mod.add_companion_reaction_spot(Vector2(1190, 820), 230.0, "Eda: Zafer, sadece savaşla değil, bilgiyle de kazanılır.", "interactables.companion_reaction_spot")
	player_mod.add_companion_reaction_spot(Vector2(530, 1500), 230.0, "Arda: Gelecek bizim... Bunu unutmamalıyız.", "interactables.companion_reaction_spot")
	player_mod.add_companion_reaction_spot(Vector2(800, 1000), 240.0, "Eda: Cumhuriyet, en büyük mirasımız. Onu korumak bizim görevimiz.", "interactables.companion_reaction_spot")


func _setup_player_position(player_pos: Vector2, companion_pos: Vector2) -> Vector2:
	"""Oyuncu ve companion pozisyonlarını kur, hedefi sıfırla."""
	var player_node: Node2D = _world.get_node("Player")
	var companion_node: Node2D = _world.get_node("Companion")
	player_node.position = player_pos
	companion_node.position = companion_pos
	return player_pos


func _samsun_intro_goal_text() -> String:
	return "Samsun Rüyası açıldı. Önce 2 liderlik izi topla, sonra Liman, Telgraf ve Halk çevresindeki 2 destek noktası kur."


func _setup_samsun_rift_after_build() -> void:
	"""Builder sonrası Samsun rift özel kurulumları — builder ve player modülü kullanır."""
	var builder: Node = _get_builder()
	var player_mod: Node = _get_player_mod()
	if builder == null or player_mod == null:
		return

	builder.add_strategy_node(Vector2(800, 1000), "Milli İrade", _colors.RIFT_BLUE, "samsun.rift_core")
	builder.add_historical_landmark(Vector2(360, 820), "harbor", "Liman", "samsun.harbor_node")
	builder.add_prop_cluster(Vector2(360, 820), "harbor", "samsun.harbor_landmark")
	builder.add_historical_landmark(Vector2(1190, 820), "telegraph", "Telgraf", "samsun.telegraph_node")
	builder.add_prop_cluster(Vector2(1190, 820), "telegraph", "samsun.telegraph_landmark")
	builder.add_historical_landmark(Vector2(530, 1500), "people", "Halk", "samsun.people_node")
	builder.add_prop_cluster(Vector2(530, 1500), "people", "samsun.people_landmark")

	builder.add_strategy_node(Vector2(360, 820), "Destek", _colors.POP_TURQUOISE, "interactables.strategy_node")
	builder.add_strategy_node(Vector2(1190, 820), "Haber", _colors.RIFT_BLUE, "interactables.strategy_node")
	builder.add_strategy_node(Vector2(530, 1500), "Birlik", _colors.POP_GOLD, "interactables.strategy_node")
	builder.add_strategy_node(Vector2(820, 1500), "Dalga", Color(0.68, 0.40, 1.0), "fx.rift_focus_ring")

	builder.add_prop_cluster(Vector2(360, 620), "discovery", "world_props.prop_cluster")
	builder.add_prop_cluster(Vector2(1210, 1550), "discovery", "world_props.prop_cluster")

	player_mod.add_companion_reaction_spot(Vector2(360, 620), 210.0, "Eda: Önce çevredeki izleri okuyalım.", "interactables.companion_reaction_spot")
	player_mod.add_companion_reaction_spot(Vector2(1190, 820), 230.0, "Eda: Telgraf, haberleri güvenli taşımak için önemli.", "interactables.companion_reaction_spot")
	player_mod.add_companion_reaction_spot(Vector2(530, 1500), 230.0, "Arda: İnsanları birlikte düşünmeye çağırmak daha güçlü.", "interactables.companion_reaction_spot")
	player_mod.add_companion_reaction_spot(Vector2(800, 1000), 240.0, "Eda: Gözlem ve bağlantı birlikte güç olur.", "interactables.companion_reaction_spot")


func _setup_unbuilt_zone(zone: String) -> void:
	"""İnşa edilmemiş zone için geçici kurulum.
	
	Tüm zone'ların builder'ı mevcut olduğu için bu fonksiyon
	sadece legacy/fallback amaçlı kullanılır.
	Event chain üzerinden story/decision event'leri oynatılır,
	ardından bölüm sonu prototip mesajı gösterilir.
	"""
	var builder: Node = _get_builder()
	var ui_mod: Node = _get_ui_mod()
	var player_mod: Node = _get_player_mod()
	
	builder.clear_world(_world)
	# Henüz builder olmadığı için boş dünya — sadece arkaplan
	
	player_mod.target_position = _setup_player_position(Vector2(800, 1100), Vector2(900, 1200))
	
	ui_mod.update_progress()
	ui_mod.show_chapter_transition(
		_zone_display_name(zone),
		"Bu bolum henuz insa edilmedi"
	)
	
	# Event chain'i başlat — story/decision event'lerini sırayla oynat
	trigger_event_chain()


func _zone_display_name(zone: String) -> String:
	"""Zone slug'ından okunabilir bölüm adı döndür."""
	match zone:
		"ankara":
			return "Ankara: Meclis ve İrade"
		"sakarya":
			return "Sakarya ve Büyük Taarruz"
		"final":
			return "Final: Cumhuriyet"
		_:
			return zone.capitalize()


# ---------------------------------------------------------------------------
# DECISION ROUTING
# ---------------------------------------------------------------------------

func on_decision_overlay_choice(context: String, choice: String) -> void:
	"""Karar overlay'inden gelen seçimi ilgili cevaplayıcıya yönlendir."""
	match context:
		"havza":
			_answer_havza_decision(choice)
		"amasya":
			_answer_amasya_decision(choice)
		"kongreler":
			_answer_kongre_decision(choice)
		"ankara":
			_answer_ankara_decision(choice)
		"sakarya":
			_answer_sakarya_decision(choice)
		"final":
			_answer_final_decision(choice)
		_:
			_answer_samsun_decision(choice)


func _show_event_decision(event_index: int, context: String) -> void:
	"""Event index'e göre karar overlay'ini göster."""
	var ui_mod: Node = _get_ui_mod()
	if ui_mod != null:
		ui_mod.show_decision(event_index, context)


func _show_samsun_decision() -> void:
	_show_event_decision(3, "samsun")  # EVENT_DECISION_SAMSUN


func _show_havza_decision() -> void:
	_show_event_decision(4, "havza")  # EVENT_DECISION_HAVZA


func _show_amasya_decision() -> void:
	_show_event_decision(5, "amasya")  # EVENT_DECISION_AMASYA


func _show_kongre_decision() -> void:
	_show_event_decision(6, "kongreler")  # EVENT_DECISION_KONGRE


func _show_ankara_decision() -> void:
	"""Ankara karar overlay'ini göster (ilk karar: Merkez Seçimi - event 21)."""
	_show_event_decision(21, "ankara")  # EVENT_DECISION_MERKEZ


func _show_sakarya_decision() -> void:
	"""Sakarya karar overlay'ini göster (ilk karar: Savunma Stratejisi - event 25)."""
	_show_event_decision(25, "sakarya")  # EVENT_DECISION_SAVUNMA


func _show_final_decision() -> void:
	"""Final karar overlay'ini göster (Gelecek Vizyonu - event 29)."""
	_show_event_decision(29, "final")  # EVENT_DECISION_FINAL


func _answer_ankara_decision(choice: String) -> void:
	"""Ankara kararlarını değerlendir (event 21 veya 23)."""
	var questions := preload("res://assets/data/questions.gd")
	var event_index: int = _last_decision_event_index
	if event_index not in [21, 23]:
		event_index = 21  # fallback
	var event: Dictionary = questions.EVENTS[event_index]
	var ui_mod: Node = _get_ui_mod()
	if ui_mod == null:
		return

	var interact_btn: Button = _world.get_node("CanvasLayer/HUD/InteractButton")
	interact_btn.visible = true
	ui_mod.panel_mode = "character"

	if choice == event.get("correct", ""):
		var goal_text: String = ""
		var info_title: String = ""
		var badge_text: String = ""
		match event_index:
			21:
				goal_text = "Merkez seçimi doğru yapıldı. En az iki destek kur ve Meclis'in açılışını başlat."
				info_title = "Doğru Merkez"
				badge_text = "Stratejik merkez acildi"
			23:
				goal_text = "Meclis iradesi doğru kuruldu. En az iki destek kur ve İrade Dalgası'nı başlat."
				info_title = "Doğru İrade"
				badge_text = "Meclis guclendi"
		set_goal("build_spot", goal_text)
		ui_mod.show_info_card(
			info_title,
			event.get("info", ""),
			badge_text,
			Callable(),
			"decision"
		)
	else:
		ui_mod.show_dialogue(
			"Bir Daha Düşünelim",
			event.get("retry", ""),
			Callable()
		)


func _answer_sakarya_decision(choice: String) -> void:
	"""Sakarya kararlarını değerlendir (event 25 veya 27)."""
	var questions := preload("res://assets/data/questions.gd")
	var event_index: int = _last_decision_event_index
	if event_index not in [25, 27]:
		event_index = 25  # fallback
	var event: Dictionary = questions.EVENTS[event_index]
	var ui_mod: Node = _get_ui_mod()
	if ui_mod == null:
		return

	var interact_btn: Button = _world.get_node("CanvasLayer/HUD/InteractButton")
	interact_btn.visible = true
	ui_mod.panel_mode = "character"

	if choice == event.get("correct", ""):
		var goal_text: String = ""
		var info_title: String = ""
		var badge_text: String = ""
		match event_index:
			25:
				goal_text = "Savunma stratejisi doğru seçildi. En az iki destek kur ve Büyük Taarruz'u başlat."
				info_title = "Doğru Strateji"
				badge_text = "Savunma basarili"
			27:
				goal_text = "Zafer sonrası karar doğru verildi. En az iki destek kur ve Cumhuriyet Dalgası'nı başlat."
				info_title = "Doğru Karar"
				badge_text = "Zafer kazanildi"
		set_goal("build_spot", goal_text)
		ui_mod.show_info_card(
			info_title,
			event.get("info", ""),
			badge_text,
			Callable(),
			"decision"
		)
	else:
		ui_mod.show_dialogue(
			"Bir Daha Düşünelim",
			event.get("retry", ""),
			Callable()
		)


func _answer_final_decision(choice: String) -> void:
	"""Final kararını değerlendir (Gelecek Vizyonu - event 29)."""
	var questions := preload("res://assets/data/questions.gd")
	var event_index: int = _last_decision_event_index
	if event_index not in [29]:
		event_index = 29  # fallback
	var event: Dictionary = questions.EVENTS[event_index]
	var ui_mod: Node = _get_ui_mod()
	if ui_mod == null:
		return

	var interact_btn: Button = _world.get_node("CanvasLayer/HUD/InteractButton")
	interact_btn.visible = true
	ui_mod.panel_mode = "character"

	if choice == event.get("correct", ""):
		var goal_text: String = ""
		var info_title: String = ""
		var badge_text: String = ""
		match event_index:
			29:
				goal_text = "Gelecek vizyonu doğru anlaşıldı. En az iki destek kur ve Cumhuriyet Dalgası'nı tamamla."
				info_title = "Doğru Vizyon"
				badge_text = "Cumhuriyet anlasildi"
		set_goal("build_spot", goal_text)
		ui_mod.show_info_card(
			info_title,
			event.get("info", ""),
			badge_text,
			Callable(),
			"decision"
		)
	else:
		ui_mod.show_dialogue(
			"Bir Daha Düşünelim",
			event.get("retry", ""),
			Callable()
		)


func _answer_samsun_decision(choice: String) -> void:
	"""Samsun kararını değerlendir."""
	var questions := preload("res://assets/data/questions.gd")
	var event: Dictionary = questions.EVENTS[3]  # EVENT_DECISION_SAMSUN
	var ui_mod: Node = _get_ui_mod()
	if ui_mod == null:
		return

	var interact_btn: Button = _world.get_node("CanvasLayer/HUD/InteractButton")
	interact_btn.visible = true
	ui_mod.panel_mode = "character"

	if choice == event.get("correct", ""):
		ui_mod.show_info_card(
			"Doğru Karar",
			event.get("info", ""),
			"Tarih yildizi kazandin",
			Callable(self, "_enter_samsun_rift"),
			"decision"
		)
	else:
		ui_mod.show_dialogue(
			"Bir Daha Düşünelim",
			event.get("retry", ""),
			Callable()
		)


func _answer_havza_decision(choice: String) -> void:
	"""Havza kararını değerlendir."""
	var questions := preload("res://assets/data/questions.gd")
	var event: Dictionary = questions.EVENTS[4]  # EVENT_DECISION_HAVZA
	var ui_mod: Node = _get_ui_mod()
	if ui_mod == null:
		return

	var interact_btn: Button = _world.get_node("CanvasLayer/HUD/InteractButton")
	interact_btn.visible = true
	ui_mod.panel_mode = "character"

	if choice == event.get("correct", ""):
		set_goal("build_spot", "Havza çağrısı doğru yapıldı. En az iki destek kur ve Sessizlik Dalgası'nı başlat.")
		ui_mod.show_info_card(
			"Doğru Çağrı",
			event.get("info", ""),
			"Halk destegi acildi",
			Callable(),
			"decision"
		)
	else:
		ui_mod.show_dialogue(
			"Bir Daha Düşünelim",
			event.get("retry", ""),
			Callable()
		)


func _answer_amasya_decision(choice: String) -> void:
	"""Amasya kararını değerlendir."""
	var questions := preload("res://assets/data/questions.gd")
	var event: Dictionary = questions.EVENTS[5]  # EVENT_DECISION_AMASYA
	var ui_mod: Node = _get_ui_mod()
	if ui_mod == null:
		return

	var interact_btn: Button = _world.get_node("CanvasLayer/HUD/InteractButton")
	interact_btn.visible = true
	ui_mod.panel_mode = "character"

	if choice == event.get("correct", ""):
		set_goal("build_spot", "Amasya kararı doğru kuruldu. En az iki destek kur ve Tereddüt Çemberi'ni başlat.")
		ui_mod.show_info_card(
			"Doğru Bildiri",
			event.get("info", ""),
			"Bildiri guclendi",
			Callable(),
			"decision"
		)
	else:
		ui_mod.show_dialogue(
			"Bir Daha Düşünelim",
			event.get("retry", ""),
			Callable()
		)


func _answer_kongre_decision(choice: String) -> void:
	"""Kongre kararını değerlendir."""
	var questions := preload("res://assets/data/questions.gd")
	var event: Dictionary = questions.EVENTS[6]  # EVENT_DECISION_KONGRE
	var ui_mod: Node = _get_ui_mod()
	if ui_mod == null:
		return

	var interact_btn: Button = _world.get_node("CanvasLayer/HUD/InteractButton")
	interact_btn.visible = true
	ui_mod.panel_mode = "character"

	if choice == event.get("correct", ""):
		set_goal("build_spot", "Kongre kararı doğru kuruldu. En az iki destek kur ve Dağınıklık Dalgası'nı başlat.")
		ui_mod.show_info_card(
			"Doğru Birleşim",
			event.get("info", ""),
			"Birlesik hedef acildi",
			Callable(),
			"decision"
		)
	else:
		ui_mod.show_dialogue(
			"Bir Daha Düşünelim",
			event.get("retry", ""),
			Callable()
		)


# ---------------------------------------------------------------------------
# ZONE ENTRY WRAPPERS (dream transition target callbacks)
# ---------------------------------------------------------------------------

func _enter_bandirma() -> void:
	transition_to("bandirma")


func _enter_samsun_rift() -> void:
	transition_to("samsun_rift")


func _enter_havza() -> void:
	transition_to("havza")


func _enter_amasya() -> void:
	transition_to("amasya")


func _enter_kongreler() -> void:
	transition_to("kongreler")


func _enter_final() -> void:
	transition_to("final")


# ---------------------------------------------------------------------------
# PROTOTYPE FINISH
# ---------------------------------------------------------------------------

func finish_prototype() -> void:
	"""Prototip sonlandırma mesajı."""
	var ui_mod: Node = _get_ui_mod()
	if ui_mod != null:
		ui_mod.update_objective("Prototip tamamlandı: sıradaki geliştirme Ankara ve Meclis dünyaları.")
