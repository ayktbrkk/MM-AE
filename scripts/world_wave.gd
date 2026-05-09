extends Node

# Dalga/Strateji mekaniği — Support node yerleştirme ve dalga atlatma
# ================================================================
# Orkestratör (world.gd) tarafından _wave.show_support_panel() ve
# _wave.start_*_wave() çağrılarıyla kullanılır.
# Bağımlılıklar: _state (child node), _world (setup ile atanan parent ref)

@onready var _colors := preload("res://scripts/colors.gd")
@onready var _state: Node = $"../WorldState"

signal wave_started(wave_id: String)
signal wave_completed(wave_id: String)
signal support_node_placed(node_type: String, position: Vector2)

var _world: Node = null


func setup(world_ref: Node) -> void:
	"""Orkestratör referansını ata (world.gd _ready içinde çağrılır)."""
	_world = world_ref


# ---------------------------------------------------------------------------
# PUBLIC API — Support panel
# ---------------------------------------------------------------------------

func show_support_panel(marker: Node2D) -> void:
	"""build_spot marker'ına tıklandığında support kurma panelini göster."""
	if _world == null:
		return

	if bool(marker.get_meta("built", false)):
		_world._show_dialogue(
			"Destek Hazır",
			"Bu noktaya zaten bir destek kuruldu. Başka bir noktayı güçlendirebilirsin.",
			Callable()
		)
		return

	_world.selected_build_marker = marker
	_world.panel_mode = "support"
	_world.character_title.text = String(marker.get_meta("title"))

	var zone: String = _state.current_zone
	var lp: int = _state.leadership_points

	if zone == "havza":
		_world.character_text.text = "Halkı düzenli ve bilinçli tepkiye hazırlamak için destek kur. Liderlik puanı: %d" % lp
		_world.arda_button.text = "Miting Noktası kur (1)"
		_world.eda_button.text = "Telgraf Ağı kur (1)"
	elif zone == "amasya":
		_world.character_text.text = "Ortak bildiriyi güçlendirmek için destek kur. Liderlik puanı: %d" % lp
		_world.arda_button.text = "Yazım Masası kur (1)"
		_world.eda_button.text = "Temsilci Halkası kur (1)"
	elif zone == "kongreler":
		_world.character_text.text = "Dağınık yapıları ortak hedefte toplamak için destek kur. Liderlik puanı: %d" % lp
		_world.arda_button.text = "Delegasyon Masası kur (1)"
		_world.eda_button.text = "Ortak Hedef Kürsüsü kur (1)"
	else:
		_world.character_text.text = "Destekleri önceden belirlenmiş noktalara kurarsın. Liderlik puanı: %d" % lp
		_world.arda_button.text = "Gözlem Noktası kur (1)"
		_world.eda_button.text = "Telgraf Ağı kur (1)"

	_world.character_panel.visible = true
	_world.interact_button.visible = false


func build_support(choice: String) -> void:
	"""Karakter panelinden seçilen support'u inşa et."""
	if _world == null:
		return

	_world.character_panel.visible = false
	_world.interact_button.visible = true
	_world.panel_mode = "character"

	if _world.selected_build_marker == null:
		return

	if _state.leadership_points <= 0:
		_world._show_dialogue(
			"Puan Yetmedi",
			"Bu prototip affedici: çevredeki Liderlik Notu veya Cesaret Rozeti gibi kaynakları toplayıp tekrar deneyebilirsin.",
			Callable()
		)
		return

	var marker: Node2D = _world.selected_build_marker
	var zone: String = _state.current_zone

	var support_name := "Gözlem Noktası" if choice == "a" else "Telgraf Ağı"
	if zone == "havza" and choice == "a":
		support_name = "Miting Noktası"
	elif zone == "amasya":
		support_name = "Yazım Masası" if choice == "a" else "Temsilci Halkası"
	elif zone == "kongreler":
		support_name = "Delegasyon Masası" if choice == "a" else "Ortak Hedef Kürsüsü"

	_state.add_leadership(-1)
	_state.place_support()
	marker.set_meta("built", true)
	marker.set_meta("title", "%s Hazır" % support_name)

	var zone_text: String
	if zone == "havza":
		zone_text = "%s kuruldu. Sessizlik dalgasına karşı halkın ortak sesini güçlendirdin." % support_name
	elif zone == "amasya":
		zone_text = "%s kuruldu. Bildirinin ortak iradesini güçlendirdin." % support_name
	elif zone == "kongreler":
		zone_text = "%s kuruldu. Dağınık yapıları ortak hedefte birleştirdin." % support_name
	else:
		zone_text = "%s kuruldu. Kararsızlık dalgasına karşı tarihsel akışı güçlendirdin." % support_name
	marker.set_meta("text", zone_text)
	marker.modulate = Color(0.70, 1.0, 0.70, 1.0)

	_add_built_support_visual(marker, support_name)
	_world._spawn_reward_burst(marker.position, Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.92), "reward.support")
	_world.selected_build_marker = null

	_world._update_progress()
	_world._refresh_minimap_markers()

	support_node_placed.emit(support_name, marker.position)

	if _state.built_supports >= _state.required_supports:
		var wave_kind := "wave_start"
		var wave_text := "Destekler hazır. Şimdi Kararsızlık Dalgası'nı başlat."
		if zone == "havza":
			wave_kind = "havza_wave"
			wave_text = "Destekler hazır. Şimdi Sessizlik Dalgası'nı başlat."
		elif zone == "amasya":
			wave_kind = "amasya_wave"
			wave_text = "Destekler hazır. Şimdi Tereddüt Çemberi'ni başlat."
		elif zone == "kongreler":
			wave_kind = "kongre_wave"
			wave_text = "Destekler hazır. Şimdi Dağınıklık Dalgası'nı başlat."
		_world._set_goal(wave_kind, wave_text)

	var dialogue_text: String
	if zone == "havza":
		dialogue_text = "%s hazır. En az %d destek kurunca sessizlik dalgasını daha güvenli aşarsın." % [support_name, _state.required_supports]
	elif zone == "amasya":
		dialogue_text = "%s hazır. En az %d destek kurunca ortak bildiriyi daha güvenli tamamlarsın." % [support_name, _state.required_supports]
	elif zone == "kongreler":
		dialogue_text = "%s hazır. En az %d destek kurunca ortak hedefi daha güvenli savunursun." % [support_name, _state.required_supports]
	else:
		dialogue_text = "%s hazır. En az %d destek kurunca kararsızlık dalgasını daha güvenli aşarsın." % [support_name, _state.required_supports]
	_world._show_dialogue("Destek Kuruldu", dialogue_text, Callable())


# ---------------------------------------------------------------------------
# PUBLIC API — Wave başlatma
# ---------------------------------------------------------------------------

func start_confusion_wave() -> void:
	"""Samsun Kararsızlık Dalgası'nı başlat."""
	_state.increment_wave_attempts()
	wave_started.emit("confusion")

	if _state.built_supports >= _state.required_supports:
		wave_completed.emit("confusion")
		_world._show_dialogue(
			"Dalga Aşıldı",
			"Gözlem ve haberleşme desteği sayesinde Samsun'daki ilk adımlar planlı ilerledi. Bu rüya senaryosu tamamlandı; sonraki sanal dünya Havza ve Amasya görevlerini açacak.",
			Callable(_world, "_enter_havza")
		)
	else:
		_state.add_leadership(1)
		_world._update_progress()
		_world._show_dialogue(
			"Dalga Çok Güçlü",
			"Kararsızlık dalgası Milli İrade Merkezi'ni zorladı. Oyun bitmedi: son dalgayı tekrar deneyeceksin ve +1 liderlik puanı aldın. En az %d destek kurmayı dene." % _state.required_supports,
			Callable()
		)


func start_havza_wave() -> void:
	"""Havza Sessizlik Dalgası'nı başlat."""
	_state.increment_wave_attempts()
	wave_started.emit("havza")

	if _state.built_supports >= _state.required_supports:
		wave_completed.emit("havza")
		_world._show_dialogue(
			"Sessizlik Aşıldı",
			"Meydan düzeni ve telgraf desteği sayesinde halk korkuya kapılmadan ortak ses çıkarabildi. Havza Genelgesi'nin örgütlü ruhu bu alanda hissedildi.",
			Callable(_world, "_enter_amasya")
		)
	else:
		_state.add_leadership(1)
		_world._update_progress()
		_world._show_dialogue(
			"Sessizlik Güçlü Kaldı",
			"Halkın sesi dağınık kaldı ama oyun bitmedi. +1 liderlik puanı aldın. Bir destek daha kurup sessizlik dalgasını yeniden dene.",
			Callable()
		)


func start_amasya_wave() -> void:
	"""Amasya Tereddüt Çemberi'ni başlat."""
	_state.increment_wave_attempts()
	wave_started.emit("amasya")

	if _state.built_supports >= _state.required_supports:
		wave_completed.emit("amasya")
		_world._show_dialogue(
			"Tereddüt Aşıldı",
			"Yazım masası ve temsilci halkası sayesinde ortak bildiri netleşti. Amasya'da milletin geleceğini yine milletin azim ve kararı belirler fikri güç kazandı.",
			Callable(_world, "_enter_kongreler")
		)
	else:
		_state.add_leadership(1)
		_world._update_progress()
		_world._show_dialogue(
			"Tereddüt Sürüyor",
			"Fikirler birleşmeye başladı ama ortak cümle henüz tam güçlenmedi. +1 liderlik puanı aldın. Bir destek daha kurup yeniden dene.",
			Callable()
		)


func start_kongre_wave() -> void:
	"""Kongre Dağınıklık Dalgası'nı başlat."""
	_state.increment_wave_attempts()
	wave_started.emit("kongre")

	if _state.built_supports >= _state.required_supports:
		wave_completed.emit("kongre")
		_world._show_dialogue(
			"Dağınıklık Aşıldı",
			"Delegasyon masası ve ortak hedef kürsüsü sayesinde farklı sesler tek amaçta birleşti. Kongrelerin birleştirici ruhu bu alanda güç kazandı.",
			Callable(_world, "_finish_prototype")
		)
	else:
		_state.add_leadership(1)
		_world._update_progress()
		_world._show_dialogue(
			"Dağınıklık Sürüyor",
			"Temsilciler aynı hedefe yaklaşsa da bağlar henüz tam güçlenmedi. +1 liderlik puanı aldın. Bir destek daha kurup yeniden dene.",
			Callable()
		)


# ---------------------------------------------------------------------------
# PRIVATE — Support görsel inşası
# ---------------------------------------------------------------------------

func _add_built_support_visual(marker: Node2D, support_name: String) -> void:
	"""Marker üzerine inşa edilen support'un görsel elemanlarını ekle."""
	for child in marker.get_children():
		if String(child.name).begins_with("BuiltSupport"):
			child.queue_free()

	var accent := Color(0.96, 0.82, 0.48, 0.86)
	if support_name.contains("Telgraf"):
		accent = Color(0.62, 0.83, 0.78, 0.88)
	elif support_name.contains("Gözlem") or support_name.contains("Miting"):
		accent = Color(0.95, 0.75, 0.39, 0.88)
	elif support_name.contains("Halk") or support_name.contains("Temsil"):
		accent = Color(0.74, 0.95, 0.38, 0.80)

	var glow := Polygon2D.new()
	glow.name = "BuiltSupportGlow"
	glow.position = Vector2(0, 54)
	glow.color = Color(accent.r, accent.g, accent.b, 0.20)
	glow.polygon = _world._ellipse_points(Vector2(104, 38), 24)
	marker.add_child(glow)
	marker.move_child(glow, 0)

	var shadow := Polygon2D.new()
	shadow.name = "BuiltSupportShadow"
	shadow.position = Vector2(0, 66)
	shadow.color = Color(0.04, 0.06, 0.07, 0.18)
	shadow.polygon = _world._ellipse_points(Vector2(78, 24), 20)
	marker.add_child(shadow)
	marker.move_child(shadow, 1)

	var base := Polygon2D.new()
	base.name = "BuiltSupportBase"
	base.position = Vector2(-34, 12)
	base.color = Color(0.24, 0.40, 0.34, 0.88)
	base.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(68, 0),
		Vector2(58, 36),
		Vector2(10, 36),
	])
	marker.add_child(base)

	var top := Polygon2D.new()
	top.name = "BuiltSupportTop"
	top.position = Vector2(0, -14)
	top.color = accent
	top.polygon = PackedVector2Array([
		Vector2(-48, 18),
		Vector2(0, -18),
		Vector2(48, 18),
	])
	marker.add_child(top)

	var pole := Polygon2D.new()
	pole.name = "BuiltSupportPole"
	pole.position = Vector2(4, -42)
	pole.color = Color(0.13, 0.16, 0.18, 0.64)
	pole.polygon = PackedVector2Array([
		Vector2(-4, 0),
		Vector2(4, 0),
		Vector2(4, 38),
		Vector2(-4, 38),
	])
	marker.add_child(pole)

	var flag := Polygon2D.new()
	flag.name = "BuiltSupportFlag"
	flag.position = Vector2(14, -38)
	flag.color = Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.72)
	flag.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(42, 8),
		Vector2(34, 28),
		Vector2(0, 22),
	])
	marker.add_child(flag)

	for index in range(2):
		var window := Polygon2D.new()
		window.name = "BuiltSupportWindow%02d" % index
		window.position = Vector2(-18 + (index * 28), 26)
		window.color = Color(0.96, 0.91, 0.83, 0.40)
		window.polygon = PackedVector2Array([
			Vector2(-7, -5),
			Vector2(7, -5),
			Vector2(6, 7),
			Vector2(-6, 7),
		])
		marker.add_child(window)
