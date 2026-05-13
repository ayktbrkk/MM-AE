extends Node

# Marker sistemi — etkilesim noktalari, item toplama
# Orkestratordeki Markers node'una child ekleyerek calisir

# -----------------------------------------------------------------------------
# Texture sabitleri (marker iconlari icin) — procedural olusturulur
# Kenney placeholder'lari yerine 32x32 renkli daire texture'lari
# -----------------------------------------------------------------------------

static func _make_icon(color: Color) -> Texture2D:
	"""32x32'lik renkli daire icon texture'i olusturur."""
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var center := Vector2i(16, 16)
	for y in 32:
		for x in 32:
			if center.distance_squared_to(Vector2i(x, y)) <= 196:  # radius=14
				image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)

static var NOTE_ICON := _make_icon(Color(0.92, 0.78, 0.48))
static var TALK_ICON := _make_icon(Color(0.48, 0.72, 0.92))
static var PORTAL_ICON := _make_icon(Color(0.72, 0.48, 0.92))
static var DECISION_ICON := _make_icon(Color(0.92, 0.48, 0.58))
static var RESOURCE_ICON := _make_icon(Color(0.48, 0.88, 0.62))
static var SUPPORT_ICON := _make_icon(Color(0.92, 0.68, 0.42))
static var WAVE_ICON := _make_icon(Color(0.42, 0.68, 0.92))
static var BADGE_ICON := _make_icon(Color(0.98, 0.82, 0.38))

# -----------------------------------------------------------------------------
# Renk sistemi
# -----------------------------------------------------------------------------
@onready var _colors := preload("res://scripts/colors.gd")

# Renk kisaltmalari (okunabilirlik icin)
var POP_GOLD: Color:
	get: return _colors.POP_GOLD
var POP_TURQUOISE: Color:
	get: return _colors.POP_TURQUOISE
var POP_CRIMSON: Color:
	get: return _colors.POP_CRIMSON
var RIFT_BLUE: Color:
	get: return _colors.RIFT_BLUE
var DESIGN_CREAM_PAPER: Color:
	get: return _colors.DESIGN_CREAM_PAPER
var CEL_OUTLINE: Color:
	get: return _colors.CEL_OUTLINE

# -----------------------------------------------------------------------------
# Sinyaller
# -----------------------------------------------------------------------------
signal marker_activated(marker_id: String)
signal marker_collected(marker_id: String)
signal support_requested(support_type: String)
signal markers_spawned(area_key: String)

# -----------------------------------------------------------------------------
# Public API — orkestrator tarafindan cagrilir
# -----------------------------------------------------------------------------

func spawn_markers(area_key: String, world_root: Node) -> void:
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
	_add_marker("ship_clue", "Üniforma", Vector2(520, 650), "Üniforma {hero}'ya tam olur. Bu rüya, tarihsel sorumlulukları anlaması için kurulmuş gibidir.", world_root)
	_add_marker("ship_clue", "Harita Masası", Vector2(850, 1260), "Haritada Samsun, Havza, Amasya ve Ankara işaretlidir. Yolculuk bir ünite sırasına dönüşür.", world_root)
	_add_marker("npc", "Güvertedeki Öğrenci", Vector2(1070, 1160), "Limana yaklaşırken herkes heyecanlı. Önce ne yapılacağına karar vermeden çevreyi iyi okumak gerekir.", world_root)
	_add_marker("decision", "Samsun Kararı", Vector2(1160, 1470), "Samsun'a çıkınca ilk karar verilecek.", world_root)


func _spawn_samsun_rift_markers(world_root: Node) -> void:
	var state: Node = world_root.get_node("WorldState")
	state.set_zone("samsun_rift")
	_add_marker("resource", "Liderlik Notu", Vector2(360, 620), "Küçük bir not buldun: önce gözlem, sonra güvenilir bağlantı. Liderlik puanı +1.", world_root)
	_add_marker("resource", "Cesaret Çiçeği", Vector2(1210, 1550), "Rüyada parlayan bir çiçek buldun. Zorlanırsan yeniden denemek için liderlik puanı +1.", world_root)
	_add_marker("build_spot", "Liman Destek Noktası", Vector2(360, 820), "Liman tarafını güçlendirmek için buraya bir destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Telgraf Destek Noktası", Vector2(1190, 820), "Haberleşmeyi güçlendirmek için buraya bir destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Halk Destek Noktası", Vector2(530, 1500), "Halkın bilinçli katılımı için buraya bir destek kurabilirsin.", world_root)
	_add_marker("wave_start", "Kararsızlık Dalgası", Vector2(820, 1500), "Hazır olduğunda kararsızlık dalgasını başlat.", world_root)


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
	_add_marker("npc", "Ankara Rehberi", Vector2(800, 760), "Burada doğru iş, Meclis'i yalnızca bina olarak değil, milletin ortak iradesi olarak kurmaktır.", world_root)
	_add_marker("ankara_decision", "Merkez Kararı", Vector2(800, 1000), "Hazır olduğunda Meclis'in merkez gücünü nasıl kuracağına karar ver.", world_root)
	_add_marker("build_spot", "Meclis Destek Noktası", Vector2(360, 820), "Meclis çevresindeki düzeni güçlendirmek için buraya destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Telgraf Destek Noktası", Vector2(1190, 820), "Haberleşmeyi güvenceye almak için buraya destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Halk Destek Noktası", Vector2(530, 1500), "Millet iradesini bir araya getirmek için buraya destek kurabilirsin.", world_root)
	_add_marker("ankara_wave", "İrade Dalgası", Vector2(820, 1500), "Hazır olduğunda İrade Dalgası'nı başlat.", world_root)


func _spawn_sakarya_markers(world_root: Node) -> void:
	var state: Node = world_root.get_node("WorldState")
	state.set_zone("sakarya")
	_add_marker("sakarya_clue", "Karargah Notu", Vector2(360, 620), "Karargah notu, savunmanın tek çizgide değil tüm vatana yayılan bir direnç olduğunu anlatır.", world_root)
	_add_marker("sakarya_clue", "Cephe Telgrafı", Vector2(1210, 1550), "Cepheden gelen telgraflar, sabır ve düzenli savunmanın zaferi hazırladığını gösterir.", world_root)
	_add_marker("npc", "Cephe Rehberi", Vector2(800, 760), "Sakarya'da doğru iş, geri çekilmeden çok topyekun savunma ruhunu canlı tutmaktır.", world_root)
	_add_marker("sakarya_decision", "Savunma Kararı", Vector2(800, 1000), "Hazır olduğunda savunma stratejisini belirle.", world_root)
	_add_marker("build_spot", "Karargah Destek Noktası", Vector2(360, 820), "Karargah düzenini güçlendirmek için buraya destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Telgraf Destek Noktası", Vector2(1190, 820), "Cephe haberlerini güvenli taşımak için buraya destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Cephe Destek Noktası", Vector2(530, 1500), "Savunma hattını güçlendirmek için buraya destek kurabilirsin.", world_root)
	_add_marker("sakarya_wave", "Taarruz Dalgası", Vector2(820, 1500), "Hazır olduğunda Taarruz Dalgası'nı başlat.", world_root)


func _spawn_final_markers(world_root: Node) -> void:
	var state: Node = world_root.get_node("WorldState")
	state.set_zone("final")
	_add_marker("final_clue", "Cumhuriyet Notu", Vector2(360, 620), "Cumhuriyet, egemenliğin kayıtsız şartsız millete ait olduğunu ilan eder.", world_root)
	_add_marker("final_clue", "Gelecek Defteri", Vector2(1210, 1550), "Yeni devletin geleceği, bilime, eğitime ve ortak yurttaşlık bilincine dayanacaktır.", world_root)
	_add_marker("npc", "Cumhuriyet Rehberi", Vector2(800, 760), "Buradaki son adım, kazanılan bağımsızlığı geleceğe taşıyacak vizyonu anlamaktır.", world_root)
	_add_marker("final_decision", "Gelecek Kararı", Vector2(800, 1000), "Hazır olduğunda Cumhuriyet'in geleceğini nasıl koruyacağına karar ver.", world_root)
	_add_marker("build_spot", "Meclis Destek Noktası", Vector2(360, 820), "Cumhuriyet kurumlarını güçlendirmek için buraya destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Zafer Destek Noktası", Vector2(1190, 820), "Kazanımları görünür kılmak için buraya destek kurabilirsin.", world_root)
	_add_marker("build_spot", "Gelecek Destek Noktası", Vector2(530, 1500), "Cumhuriyet'i geleceğe taşımak için buraya destek kurabilirsin.", world_root)
	_add_marker("final_wave", "Cumhuriyet Dalgası", Vector2(820, 1500), "Hazır olduğunda Cumhuriyet Dalgası'nı başlat.", world_root)


# -----------------------------------------------------------------------------
# Core marker creation
# -----------------------------------------------------------------------------

func _add_marker(kind: String, marker_name: String, marker_position: Vector2, text: String, world_root: Node) -> void:
	var markers: Node = world_root.get_node("Markers")
	var state: Node = world_root.get_node("WorldState")

	var marker := Node2D.new()
	marker.name = marker_name
	marker.position = marker_position
	marker.set_meta("kind", kind)
	marker.set_meta("title", marker_name)
	marker.set_meta("text", text)
	marker.set_meta("collected", false)
	markers.add_child(marker)

	# Golge
	var shadow := Polygon2D.new()
	shadow.position = Vector2(0, 52)
	shadow.color = Color(0.03, 0.05, 0.08, 0.24)
	shadow.polygon = PackedVector2Array([
		Vector2(-44, -10),
		Vector2(44, -10),
		Vector2(58, 0),
		Vector2(44, 10),
		Vector2(-44, 10),
		Vector2(-58, 0),
	])
	marker.add_child(shadow)

	# Kaide
	var pedestal := Polygon2D.new()
	pedestal.position = Vector2(0, 26)
	pedestal.color = Color(0.96, 0.92, 0.82, 0.92)
	pedestal.polygon = PackedVector2Array([
		Vector2(-26, -8),
		Vector2(26, -8),
		Vector2(34, 12),
		Vector2(-34, 12),
	])
	marker.add_child(pedestal)

	# Halo (renkli arkaplan)
	var halo := Polygon2D.new()
	halo.color = _marker_color(kind)
	halo.polygon = PackedVector2Array([
		Vector2(-48, -38),
		Vector2(48, -38),
		Vector2(58, 0),
		Vector2(48, 38),
		Vector2(-48, 38),
		Vector2(-58, 0),
	])
	marker.add_child(halo)
	marker.set_meta("halo_node", halo)

	# Aktif isaret (parlama alani)
	var active_beacon := Polygon2D.new()
	active_beacon.color = Color(1, 1, 1, 0.0)
	active_beacon.polygon = PackedVector2Array([
		Vector2(-72, -56),
		Vector2(72, -56),
		Vector2(88, 0),
		Vector2(72, 56),
		Vector2(-72, 56),
		Vector2(-88, 0),
	])
	marker.add_child(active_beacon)
	marker.move_child(active_beacon, 0)
	marker.set_meta("active_beacon_node", active_beacon)

	# Dis cerceve (cel outline)
	var ring := Polygon2D.new()
	ring.color = Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.28)
	ring.polygon = PackedVector2Array([
		Vector2(-56, -44),
		Vector2(56, -44),
		Vector2(66, 0),
		Vector2(56, 44),
		Vector2(-56, 44),
		Vector2(-66, 0),
	])
	marker.add_child(ring)
	marker.move_child(ring, marker.get_child_count() - 2)
	marker.set_meta("ring_node", ring)

	# Isilti halkasi
	var shine_ring := Polygon2D.new()
	shine_ring.color = Color(1, 1, 1, 0.18)
	shine_ring.polygon = PackedVector2Array([
		Vector2(-48, -36),
		Vector2(48, -36),
		Vector2(56, 0),
		Vector2(48, 36),
		Vector2(-48, 36),
		Vector2(-56, 0),
	])
	marker.add_child(shine_ring)
	marker.set_meta("shine_node", shine_ring)

	# Icon
	var icon := Sprite2D.new()
	icon.texture = _marker_icon(kind)
	icon.scale = Vector2(0.42, 0.42) if kind != "resource" else Vector2(0.34, 0.34)
	icon.position = Vector2(0, -2)
	marker.add_child(icon)
	marker.set_meta("icon_node", icon)

	# Sol isilti
	var sparkle_left := Polygon2D.new()
	sparkle_left.position = Vector2(-40, -28)
	sparkle_left.color = Color(1, 1, 1, 0.22)
	sparkle_left.polygon = PackedVector2Array([
		Vector2(0, -8),
		Vector2(4, -2),
		Vector2(10, 0),
		Vector2(4, 2),
		Vector2(0, 8),
		Vector2(-4, 2),
		Vector2(-10, 0),
		Vector2(-4, -2),
	])
	marker.add_child(sparkle_left)

	# Sag isilti
	var sparkle_right := Polygon2D.new()
	sparkle_right.position = Vector2(42, -22)
	sparkle_right.color = Color(1, 1, 1, 0.18)
	sparkle_right.polygon = sparkle_left.polygon
	marker.add_child(sparkle_right)

	# Etiket dis cercevesi
	var label_outline := Polygon2D.new()
	label_outline.position = Vector2(-174, 36)
	label_outline.color = Color(0.16, 0.14, 0.12, 0.34)
	label_outline.polygon = _rounded_rect_points(Vector2(348, 104), 18.0)
	marker.add_child(label_outline)
	marker.set_meta("label_outline_node", label_outline)
	marker.set_meta("tooltip_base_pos", label_outline.position)

	# Etiket zemini
	var label_plate := Polygon2D.new()
	label_plate.position = Vector2(-170, 40)
	label_plate.color = Color(DESIGN_CREAM_PAPER.r, DESIGN_CREAM_PAPER.g, DESIGN_CREAM_PAPER.b, 0.96)
	label_plate.polygon = _rounded_rect_points(Vector2(340, 96), 16.0)
	marker.add_child(label_plate)
	marker.set_meta("label_plate_node", label_plate)

	# Etiket icon dairesi
	var label_icon_circle := Polygon2D.new()
	label_icon_circle.position = Vector2(-128, 88)
	label_icon_circle.color = Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.90)
	label_icon_circle.polygon = _ellipse_points(Vector2(24, 24), 20)
	marker.add_child(label_icon_circle)
	marker.set_meta("label_icon_circle_node", label_icon_circle)

	# Etiket icon metni
	var label_icon := Label.new()
	label_icon.position = Vector2(-152, 64)
	label_icon.custom_minimum_size = Vector2(48, 48)
	label_icon.text = _tooltip_icon_text(kind)
	label_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_icon.add_theme_font_size_override("font_size", 26)
	label_icon.add_theme_color_override("font_color", Color(0.12, 0.10, 0.08, 0.96))
	marker.add_child(label_icon)
	marker.set_meta("label_icon_node", label_icon)

	# Marker isim etiketi
	var label := Label.new()
	label.position = Vector2(-88, 54)
	label.custom_minimum_size = Vector2(232, 70)
	label.text = marker_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", Color(0.12, 0.13, 0.17))
	marker.add_child(label)
	marker.set_meta("label_node", label)

	# Durum etiketi
	var status_label := Label.new()
	status_label.position = Vector2(-70, 138)
	status_label.custom_minimum_size = Vector2(140, 28)
	status_label.text = ""
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color(0.98, 0.94, 0.78, 0.92))
	marker.add_child(status_label)
	marker.set_meta("status_label_node", status_label)

	# Zone'a ozel setpiece
	_add_marker_setpiece(marker, kind, marker_name, state)

	# Zone stil uygulamalari
	var current_zone: String = state.get_zone()
	if current_zone == "room":
		_apply_opening_marker_style(marker, kind)
	if current_zone == "samsun_rift":
		_apply_samsun_marker_style(marker, kind)


# -----------------------------------------------------------------------------
# Setpiece dekorasyonu — zone'a gore marker goruntusu
# -----------------------------------------------------------------------------

func _add_marker_setpiece(marker: Node2D, kind: String, marker_name: String, state: Node) -> void:
	var current_zone: String = state.get_zone()
	if current_zone == "room":
		if kind == "portal":
			_add_marker_quad(marker, Vector2(-52, 4), Vector2(44, 54), Color(0.94, 0.89, 0.72, 0.88))
			_add_marker_quad(marker, Vector2(8, 4), Vector2(44, 54), Color(0.98, 0.93, 0.76, 0.88))
			_add_marker_quad(marker, Vector2(-8, -2), Vector2(16, 60), Color(0.72, 0.56, 0.34, 0.92))
		elif kind == "unit":
			_add_marker_quad(marker, Vector2(-34, 2), Vector2(68, 52), Color(0.96, 0.92, 0.80, 0.86))
			_add_marker_quad(marker, Vector2(-24, -8), Vector2(48, 8), Color(0.85, 0.66, 0.28, 0.90))
	elif current_zone == "ship":
		if marker_name == "Üniforma":
			_add_marker_quad(marker, Vector2(-6, -26), Vector2(12, 62), Color(0.48, 0.34, 0.22, 0.92))
			_add_marker_quad(marker, Vector2(-36, 8), Vector2(72, 44), Color(0.24, 0.34, 0.46, 0.92))
		elif marker_name == "Harita Masası":
			_add_marker_quad(marker, Vector2(-54, 4), Vector2(108, 46), Color(0.58, 0.44, 0.30, 0.92))
			_add_marker_quad(marker, Vector2(-36, -12), Vector2(72, 26), Color(0.92, 0.84, 0.60, 0.92))
		elif kind == "decision":
			_add_marker_quad(marker, Vector2(-8, -32), Vector2(12, 74), Color(0.42, 0.30, 0.20, 0.94))
			_add_marker_triangle(marker, Vector2(12, -26), Vector2(58, 20), Color(0.95, 0.58, 0.28, 0.92))
	elif current_zone == "havza":
		if marker_name == "Genelge Metni":
			_add_marker_quad(marker, Vector2(-12, -26), Vector2(18, 70), Color(0.50, 0.38, 0.24, 0.92))
			_add_marker_quad(marker, Vector2(-42, -18), Vector2(84, 56), Color(0.92, 0.88, 0.74, 0.92))
		elif marker_name == "Telgraf Defteri":
			_add_marker_quad(marker, Vector2(-48, 8), Vector2(96, 28), Color(0.48, 0.36, 0.24, 0.94))
			_add_marker_quad(marker, Vector2(-26, -10), Vector2(52, 26), Color(0.94, 0.90, 0.80, 0.90))
		elif kind == "havza_decision":
			_add_marker_quad(marker, Vector2(-22, -12), Vector2(44, 54), Color(0.60, 0.46, 0.30, 0.94))
			_add_marker_triangle(marker, Vector2(0, -34), Vector2(76, 30), Color(0.95, 0.80, 0.26, 0.92))
		elif kind == "build_spot":
			_add_marker_quad(marker, Vector2(-42, 18), Vector2(84, 16), Color(0.62, 0.48, 0.28, 0.88))
			_add_marker_quad(marker, Vector2(-28, -14), Vector2(12, 44), Color(0.60, 0.46, 0.28, 0.82))
			_add_marker_quad(marker, Vector2(16, -14), Vector2(12, 44), Color(0.60, 0.46, 0.28, 0.82))
	elif current_zone == "amasya":
		if marker_name == "Toplanti Notu":
			_add_marker_quad(marker, Vector2(-36, -12), Vector2(72, 46), Color(0.95, 0.90, 0.80, 0.92))
			_add_marker_quad(marker, Vector2(-24, -22), Vector2(48, 10), Color(0.72, 0.54, 0.30, 0.90))
		elif marker_name == "Bildiri Taslağı":
			_add_marker_quad(marker, Vector2(-44, 6), Vector2(88, 34), Color(0.56, 0.42, 0.28, 0.90))
			_add_marker_quad(marker, Vector2(-28, -14), Vector2(56, 26), Color(0.96, 0.93, 0.84, 0.92))
		elif kind == "amasya_decision":
			_add_marker_quad(marker, Vector2(-20, -16), Vector2(40, 52), Color(0.64, 0.48, 0.30, 0.92))
			_add_marker_triangle(marker, Vector2(0, -34), Vector2(80, 32), Color(0.93, 0.72, 0.36, 0.90))
		elif kind == "build_spot":
			_add_marker_quad(marker, Vector2(-38, 18), Vector2(76, 14), Color(0.68, 0.52, 0.32, 0.90))
			_add_marker_quad(marker, Vector2(-8, -18), Vector2(16, 46), Color(0.62, 0.46, 0.28, 0.84))
	elif current_zone == "kongreler":
		if marker_name == "Temsil Listesi":
			_add_marker_quad(marker, Vector2(-34, -12), Vector2(68, 46), Color(0.96, 0.92, 0.82, 0.92))
			_add_marker_quad(marker, Vector2(-22, -22), Vector2(44, 10), Color(0.74, 0.56, 0.34, 0.90))
		elif marker_name == "Ortak Karar Taslağı":
			_add_marker_quad(marker, Vector2(-42, 6), Vector2(84, 34), Color(0.58, 0.44, 0.28, 0.92))
			_add_marker_quad(marker, Vector2(-26, -14), Vector2(52, 24), Color(0.96, 0.93, 0.84, 0.92))
		elif kind == "kongre_decision":
			_add_marker_quad(marker, Vector2(-20, -16), Vector2(40, 52), Color(0.62, 0.46, 0.28, 0.92))
			_add_marker_triangle(marker, Vector2(0, -34), Vector2(84, 32), Color(0.95, 0.68, 0.32, 0.90))
		elif kind == "build_spot":
			_add_marker_quad(marker, Vector2(-40, 18), Vector2(80, 14), Color(0.68, 0.52, 0.32, 0.90))
			_add_marker_quad(marker, Vector2(-8, -18), Vector2(16, 46), Color(0.62, 0.46, 0.28, 0.84))
	elif current_zone == "samsun_rift":
		if kind == "build_spot":
			_add_marker_quad(marker, Vector2(-18, -12), Vector2(36, 48), Color(0.46, 0.58, 0.72, 0.86))
			_add_marker_triangle(marker, Vector2(0, -34), Vector2(54, 32), Color(0.70, 0.84, 0.95, 0.82))
		elif kind == "wave_start":
			_add_marker_triangle(marker, Vector2(0, -24), Vector2(92, 54), Color(0.74, 0.42, 0.90, 0.28))


# -----------------------------------------------------------------------------
# Zone stil uygulayicilari
# -----------------------------------------------------------------------------

func _apply_opening_marker_style(marker: Node2D, kind: String) -> void:
	var halo: Polygon2D = marker.get_meta("halo_node", null)
	if halo != null:
		halo.polygon = _ellipse_points(Vector2(34, 24), 20)
		halo.color = Color(_marker_color(kind).r, _marker_color(kind).g, _marker_color(kind).b, 0.22)

	var beacon: Polygon2D = marker.get_meta("active_beacon_node", null)
	if beacon != null:
		beacon.polygon = _ellipse_points(Vector2(70, 46), 22)

	var ring: Polygon2D = marker.get_meta("ring_node", null)
	if ring != null:
		ring.polygon = _ellipse_points(Vector2(42, 30), 20)
		ring.color = Color(0.10, 0.12, 0.12, 0.12)

	var shine: Polygon2D = marker.get_meta("shine_node", null)
	if shine != null:
		shine.polygon = _ellipse_points(Vector2(28, 20), 18)
		shine.color = Color(1, 1, 1, 0.08)

	var icon: Sprite2D = marker.get_meta("icon_node", null)
	if icon != null:
		icon.visible = false

	var shadow := marker.get_child(0) as Polygon2D
	if shadow != null:
		shadow.position = Vector2(0, 34)
		shadow.polygon = _ellipse_points(Vector2(48, 16), 18)
		shadow.color = Color(0.03, 0.05, 0.08, 0.10)

	for child in marker.get_children():
		if child.has_meta("marker_setpiece"):
			child.visible = false


func _apply_samsun_marker_style(marker: Node2D, kind: String) -> void:
	marker.set_meta("samsun_marker", true)

	var ground_glow := Polygon2D.new()
	ground_glow.name = "SamsunMarkerGroundGlow"
	ground_glow.position = Vector2(0, 54)
	ground_glow.color = Color(0.96, 0.91, 0.83, 0.14)
	ground_glow.polygon = _ellipse_points(Vector2(88, 30), 24)
	marker.add_child(ground_glow)
	marker.move_child(ground_glow, 0)
	marker.set_meta("samsun_ground_glow_node", ground_glow)

	var halo: Polygon2D = marker.get_meta("halo_node", null)
	if halo != null:
		halo.polygon = _ellipse_points(Vector2(42, 34), 24)
		halo.color = Color(_marker_color(kind).r, _marker_color(kind).g, _marker_color(kind).b, 0.24)

	var beacon: Polygon2D = marker.get_meta("active_beacon_node", null)
	if beacon != null:
		beacon.polygon = _ellipse_points(Vector2(108, 64), 28)

	var ring: Polygon2D = marker.get_meta("ring_node", null)
	if ring != null:
		ring.polygon = _ellipse_points(Vector2(52, 40), 24)
		ring.color = Color(0.10, 0.15, 0.18, 0.16)

	var shine: Polygon2D = marker.get_meta("shine_node", null)
	if shine != null:
		shine.polygon = _ellipse_points(Vector2(44, 32), 20)
		shine.color = Color(1, 1, 1, 0.10)

	var label_outline: Polygon2D = marker.get_meta("label_outline_node", null)
	if label_outline != null:
		label_outline.position = Vector2(-154, 38)
		label_outline.polygon = _rounded_rect_points(Vector2(308, 96), 18.0)

	var label_plate: Polygon2D = marker.get_meta("label_plate_node", null)
	if label_plate != null:
		label_plate.position = Vector2(-150, 42)
		label_plate.polygon = _rounded_rect_points(Vector2(300, 88), 16.0)

	var label_icon_circle: Polygon2D = marker.get_meta("label_icon_circle_node", null)
	if label_icon_circle != null:
		label_icon_circle.position = Vector2(-112, 86)
		label_icon_circle.polygon = _ellipse_points(Vector2(22, 22), 18)

	var label_icon: Label = marker.get_meta("label_icon_node", null)
	if label_icon != null:
		label_icon.position = Vector2(-134, 64)
		label_icon.custom_minimum_size = Vector2(44, 44)
		label_icon.add_theme_font_size_override("font_size", 24)

	var label: Label = marker.get_meta("label_node", null)
	if label != null:
		label.position = Vector2(-72, 54)
		label.custom_minimum_size = Vector2(198, 66)
		label.add_theme_font_size_override("font_size", 24)

	var icon: Sprite2D = marker.get_meta("icon_node", null)
	if icon != null:
		icon.scale = Vector2(0.34, 0.34) if kind == "resource" else Vector2(0.38, 0.38)


# -----------------------------------------------------------------------------
# Setpiece yardimci fonksiyonlari
# -----------------------------------------------------------------------------

func _add_marker_quad(marker: Node2D, pos: Vector2, size: Vector2, color: Color) -> void:
	var quad := Polygon2D.new()
	quad.set_meta("marker_setpiece", true)
	quad.position = pos
	quad.color = color
	quad.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0),
		size,
		Vector2(0, size.y),
	])
	marker.add_child(quad)


func _add_marker_triangle(marker: Node2D, center: Vector2, size: Vector2, color: Color) -> void:
	var tri := Polygon2D.new()
	tri.set_meta("marker_setpiece", true)
	tri.position = center
	tri.color = color
	tri.polygon = PackedVector2Array([
		Vector2(-size.x * 0.5, size.y * 0.5),
		Vector2(size.x * 0.5, size.y * 0.5),
		Vector2.ZERO + Vector2(0, -size.y * 0.5),
	])
	marker.add_child(tri)


# -----------------------------------------------------------------------------
# Geometri yardimcilari
# -----------------------------------------------------------------------------

func _rounded_rect_points(size: Vector2, radius: float, segments := 6) -> PackedVector2Array:
	var r: float = min(radius, min(size.x, size.y) * 0.5)
	var points := PackedVector2Array()
	var corners := [
		{"center": Vector2(r, r), "from": PI, "to": PI * 1.5},
		{"center": Vector2(size.x - r, r), "from": PI * 1.5, "to": TAU},
		{"center": Vector2(size.x - r, size.y - r), "from": 0.0, "to": PI * 0.5},
		{"center": Vector2(r, size.y - r), "from": PI * 0.5, "to": PI},
	]
	for corner in corners:
		for step in range(segments + 1):
			var t := float(step) / float(segments)
			var angle: float = lerp(float(corner["from"]), float(corner["to"]), t)
			var center: Vector2 = corner["center"]
			points.append(center + Vector2(cos(angle), sin(angle)) * r)
	return points


func _ellipse_points(radius: Vector2, segments := 24) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		points.append(Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return points


# -----------------------------------------------------------------------------
# Renk / Icon / Metin yardimcilari
# -----------------------------------------------------------------------------

func _tooltip_icon_text(kind: String) -> String:
	match kind:
		"unit", "ship_clue", "havza_clue", "amasya_clue", "kongre_clue", "resource":
			return "\u2605"  # ★
		_:
			return "\u279C"  # ➜


func _marker_color(kind: String) -> Color:
	match kind:
		"unit":
			return POP_GOLD
		"npc":
			return Color(POP_TURQUOISE.r, POP_TURQUOISE.g, POP_TURQUOISE.b, 1.0)
		"portal":
			return RIFT_BLUE
		"decision":
			return Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 1.0)
		"ship_clue":
			return Color(0.26, 0.72, 1.0)
		"havza_clue":
			return Color(0.96, 0.84, 0.30)
		"amasya_clue":
			return Color(1.0, 0.76, 0.32)
		"kongre_clue":
			return Color(0.96, 0.70, 0.34)
		"resource":
			return Color(0.70, 0.95, 0.42)
		"build_spot":
			return Color(1.0, 0.68, 0.22)
		"wave_start":
			return Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, 1.0)
		"havza_decision":
			return Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 1.0)
		"havza_wave":
			return RIFT_BLUE
		"amasya_decision":
			return Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 1.0)
		"amasya_wave":
			return RIFT_BLUE
		"kongre_decision":
			return Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 1.0)
		"kongre_wave":
			return RIFT_BLUE
		_:
			return Color.WHITE


func _marker_icon(kind: String) -> Texture2D:
	match kind:
		"unit", "ship_clue", "havza_clue", "amasya_clue", "kongre_clue":
			return NOTE_ICON
		"npc":
			return TALK_ICON
		"portal":
			return PORTAL_ICON
		"decision", "havza_decision", "amasya_decision", "kongre_decision":
			return DECISION_ICON
		"resource":
			return BADGE_ICON
		"build_spot":
			return SUPPORT_ICON
		"wave_start", "havza_wave", "amasya_wave", "kongre_wave":
			return WAVE_ICON
		_:
			return RESOURCE_ICON


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
			var halo_color := _marker_color(marker_kind)
			halo_color.a = 0.34 if is_active_goal and is_samsun_marker else 0.18 if is_samsun_marker else 0.52 if is_active_goal else 0.38
			if is_nearby:
				halo_color.a = 0.58 if is_samsun_marker else 0.74
			halo.color = halo_color

		var beacon: Polygon2D = marker.get_meta("active_beacon_node", null)
		if beacon != null:
			var beacon_color := _marker_color(marker_kind)
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
