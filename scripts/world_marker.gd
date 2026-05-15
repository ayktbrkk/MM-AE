extends Node

# Marker sistemi — etkilesim noktalari, item toplama
# Orkestratordeki Markers node'una child ekleyerek calisir

# Visual inşa helper'ları için referans
const _MarkerVisuals := preload("res://scripts/world_marker_visuals.gd")

# -----------------------------------------------------------------------------
# Sinyaller
# -----------------------------------------------------------------------------
signal markers_spawned(area_key: String)

# -----------------------------------------------------------------------------
# Public API — orkestrator tarafindan cagrilir
# -----------------------------------------------------------------------------

func spawn_markers(area_key: String, world_root: Node) -> void:
	# RESOURCE-DRIVEN PATH: Önce ZoneDefinition Resource dosyasını dene
	var zone_def: ZoneDefinition = ZoneLoader.load_zone(area_key)
	if zone_def and zone_def.markers.size() > 0:
		for marker_def in zone_def.markers:
			_create_marker_from_def(marker_def, world_root)
		markers_spawned.emit(area_key)
		return
	# FALLBACK: Hardcoded zone spawners (mevcut mantık)
	match area_key:
		"room":
			_spawn_room_markers(world_root)
		"ship":
			_spawn_ship_markers(world_root)
		"samsun_rift":
			_spawn_samsun_rift_markers(world_root)
		"havza":
			_spawn_havza_markers(world_root)
		"amasya":
			_spawn_amasya_markers(world_root)
		"kongreler":
			_spawn_kongreler_markers(world_root)
		"ankara":
			_spawn_ankara_markers(world_root)
		"sakarya":
			_spawn_sakarya_markers(world_root)
		"final":
			_spawn_final_markers(world_root)
		_:
			push_warning("world_marker: bilinmeyen area_key: ", area_key)
	markers_spawned.emit(area_key)


# -----------------------------------------------------------------------------
# Zone marker spawners
# -----------------------------------------------------------------------------

func _spawn_room_markers(world_root: Node) -> void:
	var state: Node = world_root.get_node("WorldState")
	state.set_zone("room")
	_add_marker("unit", "Samsun'a Çıkış", Vector2(1080, 1265), "Kitapta ilk ünite parlıyor: Samsun'a çıkış, Milli Mücadele'nin başlangıç adımıdır.", world_root)
	_add_marker("unit", "Amasya Genelgesi", Vector2(360, 1510), "Kağıt patikadaki notta şu cümle parlar: Milletin bağımsızlığını yine milletin azmi ve kararı kurtaracaktır.", world_root)
	_add_marker("unit", "Kongreler", Vector2(660, 1360), "Ada üzerindeki kartta Erzurum ve Sivas kongreleri yazıyor. Dağınık fikirler ortak hedefte birleşmelidir.", world_root)
	_add_marker("npc", "Eda'nın İpucu", Vector2(520, 1205), "Üç ünite notunu bulunca kitabın içindeki yol açılacak. Acele etme, parlayan işaretleri takip et.", world_root)
	_add_marker("portal", "Bandırma'ya Geç", Vector2(1230, 1440), "Kitap sayfaları dalga sesi gibi hışırdar. Gözlerin kapanır ve Bandırma Vapuru'nun kamarasında uyanırsın.", world_root)


func _spawn_ship_markers(world_root: Node) -> void:
	var state: Node = world_root.get_node("WorldState")
	state.set_zone("ship")
	_add_marker("ship_clue", "Üniforma", Vector2(520, 650), "Üniforma {hero}'ya tam olur. Bu yolculuk sorumlulukla başlar.", world_root)
	_add_marker("ship_clue", "Harita Masası", Vector2(850, 1260), "Haritada Samsun parlıyor. İlk adım orada atılacak.", world_root)
	_add_marker("npc", "Güvertedeki Öğrenci", Vector2(1070, 1160), "Limana yaklaşırken önce çevreyi oku, sonra karar ver.", world_root)
	_add_marker("decision", "Samsun Kararı", Vector2(1160, 1470), "Hazırsan Samsun'daki ilk adımı seç.", world_root)


func _spawn_samsun_rift_markers(world_root: Node) -> void:
	var state: Node = world_root.get_node("WorldState")
	state.set_zone("samsun_rift")
	_add_marker("resource", "Liderlik Notu", Vector2(360, 620), "Küçük bir not buldun: önce gözlem, sonra güvenilir bağlantı. Liderlik puanı +1.", world_root)
	_add_marker("resource", "Cesaret Çiçeği", Vector2(1210, 1550), "Rüyada parlayan bir çiçek buldun. Zorlanırsan yeniden denemek için liderlik puanı +1.", world_root)
	_add_marker("build_spot", "Liman Destek Noktası", Vector2(360, 820), "Liman tarafını güçlendirmek için buraya bir destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Telgraf Destek Noktası", Vector2(1190, 820), "Haberleşmeyi güçlendirmek için buraya bir destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Halk Destek Noktası", Vector2(430, 1560), "Halkın bilinçli katılımı için buraya bir destek kurabilirsin.", world_root)
	_add_marker("wave_start", "Kararsızlık Dalgası", Vector2(930, 1490), "Hazır olduğunda kararsızlık dalgasını başlat.", world_root)


func _spawn_havza_markers(world_root: Node) -> void:
	var state: Node = world_root.get_node("WorldState")
	state.set_zone("havza")
	_add_marker("havza_clue", "Genelge Metni", Vector2(1030, 650), "Havza Genelgesi halkı sessiz kalmamaya değil, düzenli ve bilinçli tepkiye çağırır.", world_root)
	_add_marker("havza_clue", "Telgraf Defteri", Vector2(430, 1560), "Telgraflar ortak sesi büyütür. Tepki dağınık değil, birleşik olmalıdır.", world_root)
	_add_marker("resource", "Birlik Rozeti", Vector2(620, 980), "Birlik rozeti buldun. İnsanları ortak hedefte toplamak için liderlik puanı +1.", world_root)
	_add_marker("resource", "Cesaret Rozeti", Vector2(1180, 1220), "Cesaret rozeti buldun. Halkı korkutmadan cesaretlendirmek için liderlik puanı +1.", world_root)
	_add_marker("npc", "Öğretmen Rehber", Vector2(700, 780), "Doğru liderlik sadece cesaret değil, insanları aynı amaç etrafında toplama becerisidir.", world_root)
	_add_marker("havza_decision", "Havza Çağrısı", Vector2(1080, 860), "Hazır olduğunda halka nasıl çağrı yapılacağına karar ver.", world_root)
	_add_marker("build_spot", "Meydan Destek Noktası", Vector2(700, 1120), "Toplanma alanını düzenlemek için buraya bir destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Bildiri Destek Noktası", Vector2(970, 980), "Genelgeyi yaymak için buraya bir destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Telgraf Destek Noktası", Vector2(520, 1400), "Haberleşmeyi güçlendirmek için buraya bir destek kurabilirsin.", world_root)
	_add_marker("havza_wave", "Sessizlik Dalgası", Vector2(1160, 1480), "Hazır olduğunda sessizlik dalgasını başlat.", world_root)


func _spawn_amasya_markers(world_root: Node) -> void:
	var state: Node = world_root.get_node("WorldState")
	state.set_zone("amasya")
	_add_marker("amasya_clue", "Toplanti Notu", Vector2(620, 620), "Masadaki not, kararın tek kişiden değil ortak akıldan çıkması gerektiğini anlatır.", world_root)
	_add_marker("amasya_clue", "Bildiri Taslağı", Vector2(980, 1180), "Taslakta milletin geleceğini yine milletin azim ve kararı belirler fikri belirginleşir.", world_root)
	_add_marker("resource", "Dayanisma Rozeti", Vector2(430, 1320), "Dayanışma rozeti buldun. Farklı sesleri bir arada tutmak için liderlik puanı +1.", world_root)
	_add_marker("resource", "Temsil Rozeti", Vector2(1180, 980), "Temsil rozeti buldun. Ortak karar için herkesi duymak gerekir. Liderlik puanı +1.", world_root)
	_add_marker("npc", "Toplanti Rehberi", Vector2(820, 760), "Burada doğru karar, birkaç kişinin değil milletin ortak iradesini cümleye dönüştürmektir.", world_root)
	_add_marker("amasya_decision", "Amasya Kararı", Vector2(860, 980), "Hazır olduğunda bildirinin nasıl kurulacağına karar ver.", world_root)
	_add_marker("build_spot", "Yazim Masası", Vector2(620, 1500), "Bildiriyi netleştirmek için buraya bir destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Temsilci Halkası", Vector2(980, 1500), "Farklı sesleri bir araya getirmek için buraya bir destek kurabilirsin.", world_root)
	_add_marker("amasya_wave", "Tereddüt Çemberi", Vector2(1240, 1460), "Hazır olduğunda tereddüt çemberini başlat.", world_root)


func _spawn_kongreler_markers(world_root: Node) -> void:
	var state: Node = world_root.get_node("WorldState")
	state.set_zone("kongreler")
	_add_marker("kongre_clue", "Temsil Listesi", Vector2(620, 640), "Liste, farklı bölgelerden gelen temsilcilerin ortak hedefte buluşması gerektiğini anlatır.", world_root)
	_add_marker("kongre_clue", "Ortak Karar Taslağı", Vector2(980, 1180), "Taslakta dağınık cemiyetlerin tek ses olması gerektiği belirginleşir.", world_root)
	_add_marker("resource", "Birlik Rozeti", Vector2(440, 1320), "Birlik rozeti buldun. Ayrı sesleri ortak hedefte toplamak için liderlik puanı +1.", world_root)
	_add_marker("resource", "Dayanisma Rozeti", Vector2(1180, 980), "Dayanışma rozeti buldun. Temsilcileri aynı amaçta buluşturmak için liderlik puanı +1.", world_root)
	_add_marker("npc", "Kongre Rehberi", Vector2(820, 760), "Buradaki en güçlü adım, herkesin kendi yoluna gitmesi değil, ortak hedefte birleşmesidir.", world_root)
	_add_marker("kongre_decision", "Kongre Kararı", Vector2(860, 980), "Hazır olduğunda kongrelerde nasıl ilerleyeceğine karar ver.", world_root)
	_add_marker("build_spot", "Delegasyon Masası", Vector2(620, 1500), "Temsilcileri hizalamak için buraya bir destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Ortak Hedef Kürsüsü", Vector2(980, 1500), "Ortak kararı güçlendirmek için buraya bir destek kurabilirsin.", world_root)
	_add_marker("kongre_wave", "Dağınıklık Dalgası", Vector2(1240, 1460), "Hazır olduğunda dağınıklık dalgasını başlat.", world_root)


func _spawn_ankara_markers(world_root: Node) -> void:
	var state: Node = world_root.get_node("WorldState")
	state.set_zone("ankara")
	_add_marker("ankara_clue", "Meclis Notu", Vector2(360, 620), "Meclis'in açılışı, milletin iradesini tek çatı altında toplamanın en güçlü adımıdır.", world_root)
	_add_marker("ankara_clue", "Telgraf Defteri", Vector2(1210, 1550), "Telgraf kayıtları, kararların hızlı ve güvenli biçimde tüm Anadolu'ya ulaştığını gösterir.", world_root)
	_add_marker("npc", "Ankara Rehberi", Vector2(700, 990), "Burada doğru iş, Meclis'i yalnızca bina olarak değil, milletin ortak iradesi olarak kurmaktır.", world_root)
	_add_marker("ankara_decision", "Merkez Kararı", Vector2(960, 1120), "Hazır olduğunda Meclis'in merkez gücünü nasıl kuracağına karar ver.", world_root)
	_add_marker("build_spot", "Meclis Destek Noktası", Vector2(520, 1180), "Meclis çevresindeki düzeni güçlendirmek için buraya destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Telgraf Destek Noktası", Vector2(1030, 1180), "Haberleşmeyi güvenceye almak için buraya destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Halk Destek Noktası", Vector2(530, 1500), "Millet iradesini bir araya getirmek için buraya destek kurabilirsin.", world_root)
	_add_marker("ankara_wave", "İrade Dalgası", Vector2(820, 1500), "Hazır olduğunda İrade Dalgası'nı başlat.", world_root)


func _spawn_sakarya_markers(world_root: Node) -> void:
	var state: Node = world_root.get_node("WorldState")
	state.set_zone("sakarya")
	_add_marker("sakarya_clue", "Karargah Notu", Vector2(360, 620), "Karargah notu, savunmanın tek çizgide değil tüm vatana yayılan bir direnç olduğunu anlatır.", world_root)
	_add_marker("sakarya_clue", "Cephe Telgrafı", Vector2(1210, 1550), "Cepheden gelen telgraflar, sabır ve düzenli savunmanın zaferi hazırladığını gösterir.", world_root)
	_add_marker("npc", "Cephe Rehberi", Vector2(800, 760), "Sakarya'da doğru iş, geri çekilmeden çok topyekun savunma ruhunu canlı tutmaktır.", world_root)
	_add_marker("sakarya_decision", "Savunma Kararı", Vector2(800, 1000), "Hazır olduğunda savunma stratejisini belirle.", world_root)
	_add_marker("build_spot", "Karargah Destek Noktası", Vector2(470, 980), "Karargah düzenini güçlendirmek için buraya destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Telgraf Destek Noktası", Vector2(1080, 980), "Cephe haberlerini güvenli taşımak için buraya destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Cephe Destek Noktası", Vector2(530, 1500), "Savunma hattını güçlendirmek için buraya destek kurabilirsin.", world_root)
	_add_marker("sakarya_wave", "Taarruz Dalgası", Vector2(820, 1500), "Hazır olduğunda Taarruz Dalgası'nı başlat.", world_root)


func _spawn_final_markers(world_root: Node) -> void:
	var state: Node = world_root.get_node("WorldState")
	state.set_zone("final")
	_add_marker("final_clue", "Cumhuriyet Notu", Vector2(620, 900), "Cumhuriyet, egemenliğin kayıtsız şartsız millete ait olduğunu ilan eder.", world_root)
	_add_marker("final_clue", "Gelecek Defteri", Vector2(1080, 1490), "Yeni devletin geleceği, bilime, eğitime ve ortak yurttaşlık bilincine dayanacaktır.", world_root)
	_add_marker("npc", "Cumhuriyet Rehberi", Vector2(800, 760), "Buradaki son adım, kazanılan bağımsızlığı geleceğe taşıyacak vizyonu anlamaktır.", world_root)
	_add_marker("final_decision", "Gelecek Kararı", Vector2(800, 1000), "Hazır olduğunda Cumhuriyet'in geleceğini nasıl koruyacağına karar ver.", world_root)
	_add_marker("build_spot", "Meclis Destek Noktası", Vector2(470, 980), "Cumhuriyet kurumlarını güçlendirmek için buraya destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Zafer Destek Noktası", Vector2(1080, 980), "Kazanımları görünür kılmak için buraya destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Gelecek Destek Noktası", Vector2(530, 1500), "Cumhuriyet'i geleceğe taşımak için buraya destek kurabilirsin.", world_root)
	_add_marker("final_wave", "Cumhuriyet Dalgası", Vector2(820, 1500), "Hazır olduğunda Cumhuriyet Dalgası'nı başlat.", world_root)


# -----------------------------------------------------------------------------
# Resource-driven marker creation
# -----------------------------------------------------------------------------

func _create_marker_from_def(marker_def: ZoneMarkerDefinition, world_root: Node) -> void:
	"""ZoneMarkerDefinition Resource'undan marker oluşturur."""
	_add_marker(
		marker_def.kind,
		marker_def.title_key,
		marker_def.position,
		marker_def.text_key,
		world_root
	)


# -----------------------------------------------------------------------------
# Core marker creation
# -----------------------------------------------------------------------------

func _add_marker(kind: String, marker_name: String, marker_position: Vector2, text: String, world_root: Node) -> void:
	var markers: Node = world_root.get_node("Markers")
	var state: Node = world_root.get_node("WorldState")

	var marker := _create_marker_node(kind, marker_name, marker_position, state)
	marker.set_meta("kind", kind)
	marker.set_meta("title", marker_name)
	marker.set_meta("text", text)
	marker.set_meta("collected", false)
	markers.add_child(marker)


func _create_marker_node(kind: String, title: String, pos: Vector2, state: Node) -> Node2D:
	var zone_id: String = state.get_zone()
	return _MarkerVisuals.create_marker_visual(kind, title, pos, zone_id)




func animate_feedback(markers_node: Node, elapsed: float, nearby: Node, current_goal_kind: String) -> void:
	for marker in markers_node.get_children():
		if not marker.visible:
			continue
		var phase: float = (marker.position.x + marker.position.y) * 0.01
		var base_scale: float = 1.0 + (0.03 * sin(elapsed * 2.2 + phase))
		var marker_kind := String(marker.get_meta("kind"))
		var is_active_goal: bool = marker_kind == current_goal_kind
		var is_nearby := marker == nearby
		var is_samsun_marker := bool(marker.get_meta("samsun_marker", false))
		var goal_boost: float = 0.0
		if is_active_goal:
			goal_boost = 0.05 + (0.014 * sin(elapsed * 4.0 + phase)) if is_samsun_marker else 0.08 + (0.02 * sin(elapsed * 4.0 + phase))
		var nearby_boost: float = 0.08 if is_nearby and is_samsun_marker else 0.12 if is_nearby else 0.0
		var final_scale: float = base_scale + goal_boost + nearby_boost
		marker.scale = Vector2.ONE * final_scale
		var idle_alpha := 0.54 if is_samsun_marker else 0.72
		marker.modulate = Color(1, 1, 1, 1.0 if is_nearby else idle_alpha + min(goal_boost * 1.7, 0.22))

		var halo: Polygon2D = marker.get_meta("halo_node", null)
		if halo != null:
			var halo_color := _MarkerVisuals._marker_color(marker_kind)
			halo_color.a = 0.34 if is_active_goal and is_samsun_marker else 0.18 if is_samsun_marker else 0.52 if is_active_goal else 0.38
			if is_nearby:
				halo_color.a = 0.58 if is_samsun_marker else 0.74
			halo.color = halo_color

		var beacon: Polygon2D = marker.get_meta("active_beacon_node", null)
		if beacon != null:
			var beacon_color := _MarkerVisuals._marker_color(marker_kind)
			beacon_color.a = 0.11 + (0.035 * sin(elapsed * 3.2 + phase)) if is_active_goal and is_samsun_marker else 0.18 + (0.08 * sin(elapsed * 3.2 + phase)) if is_active_goal else 0.0
			if is_nearby:
				beacon_color.a = 0.18 + (0.045 * sin(elapsed * 4.8 + phase)) if is_samsun_marker else 0.30 + (0.08 * sin(elapsed * 4.8 + phase))
			beacon.color = beacon_color

		var shine: Polygon2D = marker.get_meta("shine_node", null)
		if shine != null:
			shine.color = Color(1, 1, 1, 0.18 if (is_active_goal or is_nearby) and is_samsun_marker else 0.08 if is_samsun_marker else 0.32 if is_active_goal or is_nearby else 0.14)


# -----------------------------------------------------------------------------
# Marker queries — orchestrator tarafindan cagrilir
# -----------------------------------------------------------------------------

func update_nearby(player_position: Vector2, markers_node: Node, interact_distance: float = 150.0) -> Node2D:
	"""En yakin etkilesim marker'ini bulur, yoksa null dondurur."""
	var nearest: Node2D = null
	var nearest_distance := INF
	for marker in markers_node.get_children():
		if not marker.visible:
			continue
		var distance := player_position.distance_to(marker.position)
		if distance < interact_distance and distance < nearest_distance:
			nearest = marker
			nearest_distance = distance
	return nearest


func get_guidance_marker(markers_node: Node, current_goal_kind: String) -> Node2D:
	"""Rehber oku icin hedef marker'i secer: once aktif goal kind, sonra ilk uygun."""
	var fallback: Node2D = null
	for marker in markers_node.get_children():
		if bool(marker.get_meta("collected", false)) or not marker.visible:
			continue
		var kind := String(marker.get_meta("kind", ""))
		if kind == current_goal_kind:
			return marker
		if fallback == null and kind != "npc":
			fallback = marker
	return fallback


func get_interact_text(marker: Node2D) -> String:
	"""Marker kind'ina gore etkilesim butonu metni dondurur."""
	var kind := String(marker.get_meta("kind", ""))
	match kind:
		"unit", "ship_clue", "havza_clue", "amasya_clue", "kongre_clue":
			return "Topla"
		"resource":
			return "Al"
		"build_spot":
			return "Kur"
		"portal":
			return "Aç"
		"decision", "havza_decision", "amasya_decision", "kongre_decision":
			return "Seç"
		"wave_start", "havza_wave", "amasya_wave", "kongre_wave":
			return "Başlat"
		"npc":
			return "Konuş"
		_:
			return "İncele"


func format_marker_text(text: String, hero_name: String) -> String:
	"""Marker metnindeki {hero} placeholder'ini karakter adiyla degistirir."""
	return text.replace("{hero}", hero_name)


func mark_collected(marker: Node2D) -> void:
	"""Marker'i toplanmis olarak isaretler ve gorunmez yapar."""
	marker.set_meta("collected", true)
	marker.visible = false
	hide_visual_tree(marker)


func hide_visual_tree(node: Node) -> void:
	"""Bir node ve tum child'larini CanvasItem olarak gizler."""
	for child in node.get_children():
		if child is CanvasItem:
			(child as CanvasItem).visible = false
		hide_visual_tree(child)


func hide_nearby_collection_visuals(center: Vector2, include_reward_fx: bool, props: Node, foreground_props: Node) -> void:
	"""Marker pozisyonu civarindaki koleksiyon gorsellerini gizler."""
	for layer in [props, foreground_props]:
		for child in layer.get_children():
			if not (child is CanvasItem):
				continue
			var slot_id := String(child.get_meta("asset_slot", ""))
			if not is_collectible_standalone_visual(slot_id, include_reward_fx):
				continue
			var child_position: Vector2 = visual_world_position(child)
			if child_position.distance_to(center) <= 150.0:
				(child as CanvasItem).visible = false


func is_collectible_standalone_visual(slot_id: String, include_reward_fx: bool) -> bool:
	"""Verilen slot_id'nin toplanabilir bagimsiz bir gorsel olup olmadigini kontrol eder."""
	if slot_id == "":
		return false
	if include_reward_fx and slot_id.begins_with("reward."):
		return true
	return slot_id.contains("breadcrumb") or slot_id.contains("badge")


func visual_world_position(node: Node) -> Vector2:
	"""Bir node'un dunya pozisyonunu dondurur (hem Node2D hem Control icin)."""
	if node is Node2D:
		return (node as Node2D).global_position
	if node is Control:
		return (node as Control).global_position
	return Vector2(1.0e20, 1.0e20)
