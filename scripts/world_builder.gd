extends Node

# Dünya inşası — procedural Polygon2D/Sprite2D ile 6 bölge
# Tüm _build_*, _add_*, _decorate_* fonksiyonları world.gd'den buraya taşınıyor

@onready var _colors := preload("res://scripts/colors.gd")
@onready var _textures := preload("res://scripts/textures.gd")
@onready var _state: Node = $"../WorldState"

signal world_built(area_key: String)
signal world_cleared
signal companion_reaction_spot_registered(center: Vector2, radius: float, text: String, slot_id: String)
signal goal_visual_registered(slot_id: String, node: CanvasItem)

# Cached world_root — build_world() tarafından set edilir
var _cached_world_root: Node

# Dünya sabitleri
const WORLD_SIZE := Vector2(1600, 2200)

# ============================================================
# PUBLIC API
# ============================================================

# Ana giriş noktası — world.gd'den çağrılır
func build_world(area_key: String, world_root: Node) -> void:
	_cached_world_root = world_root
	match area_key:
		"room":
			_build_room(world_root)
		"ship":
			_build_ship(world_root)
		"samsun_rift":
			_build_samsun_rift(world_root)
		"havza":
			_build_havza_world(world_root)
		"amasya":
			_build_amasya_world(world_root)
		"kongreler":
			_build_kongreler_world(world_root)
		"ankara":
			_build_ankara_world(world_root)
		"sakarya":
			_build_sakarya_world(world_root)
		"final":
			_build_final_world(world_root)
		_:
			push_warning("world_builder: bilinmeyen area_key: ", area_key)
	world_built.emit(area_key)


# Dünyayı temizle — sadece Props, ForegroundProps, Markers içindeki çocukları siler
# companion_reaction_spots vb. world.gd'de temizlenir
func clear_world(world_root: Node) -> void:
	var props := world_root.get_node("Props")
	for child in props.get_children():
		child.queue_free()
	
	var foreground_props := world_root.get_node("ForegroundProps")
	for child in foreground_props.get_children():
		child.queue_free()
	
	for child in world_root.get_node("Markers").get_children():
		child.queue_free()
	
	# Gereksinim 13.5: "paperworld.samsun_" önekiyle set_meta("asset_slot", ...) ile
	# işaretlenmiş Samsun node'larını queue_free() ile serbest bırak.
	# Yukarıdaki döngüler tüm çocukları temizlediğinden bu node'lar zaten serbest
	# bırakılmaktadır. Aşağıdaki blok, bu gereksinimi açıkça karşılamak için
	# ek bir güvenlik katmanı olarak çalışır (örn. node'lar farklı bir parent
	# altında olsa bile).
	var samsun_containers: Array[Node] = [props, foreground_props, world_root.get_node("Markers")]
	for container in samsun_containers:
		for child in container.get_children():
			if child.has_meta("asset_slot"):
				var slot: String = child.get_meta("asset_slot")
				if slot.begins_with("paperworld.samsun_"):
					if not child.is_queued_for_deletion():
						child.queue_free()
	
	world_cleared.emit()


# ============================================================
# TEMEL İNŞA YARDIMCILARI
# ============================================================

func _get_props(world_root: Node) -> Node:
	return world_root.get_node("Props")

func _get_foreground(world_root: Node) -> Node:
	return world_root.get_node("ForegroundProps")

func _get_markers(world_root: Node) -> Node:
	return world_root.get_node("Markers")


# Dikdörtgen ekle — en temel yapı taşı
func _add_rect(world_root: Node, pos: Vector2, size: Vector2, color: Color, label_text := "") -> void:
	var props := _get_props(world_root)
	if color.a > 0.58 and size.x < WORLD_SIZE.x - 8.0 and size.y < WORLD_SIZE.y - 8.0:
		var outline := Polygon2D.new()
		outline.position = pos - Vector2(7, 7)
		outline.color = Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.24)
		outline.z_index = -5
		outline.polygon = PackedVector2Array([
			Vector2.ZERO,
			Vector2(size.x + 14, 0),
			size + Vector2(14, 14),
			Vector2(0, size.y + 14),
		])
		props.add_child(outline)

	var polygon := Polygon2D.new()
	polygon.position = pos
	polygon.color = color
	polygon.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0),
		size,
		Vector2(0, size.y),
	])
	props.add_child(polygon)

	if label_text != "":
		var label := Label.new()
		label.position = pos + Vector2(16, 14)
		label.text = label_text
		label.add_theme_font_size_override("font_size", 24)
		var label_alpha := 0.0 if _state.current_zone == "room" else 0.42
		label.add_theme_color_override("font_color", Color(1, 1, 1, label_alpha))
		props.add_child(label)


# Room polygon ekle
func _add_room_polygon(world_root: Node, pos: Vector2, points: PackedVector2Array, color: Color, z_index: int, slot_id := "") -> Polygon2D:
	var polygon := Polygon2D.new()
	polygon.position = pos
	polygon.color = color
	polygon.z_index = z_index
	polygon.polygon = points
	if slot_id != "":
		polygon.set_meta("asset_slot", slot_id)
	_get_props(world_root).add_child(polygon)
	return polygon


# Room rect ekle
func _add_room_rect(world_root: Node, pos: Vector2, size: Vector2, color: Color, z_index: int, slot_id := "") -> Polygon2D:
	return _add_room_polygon(world_root, pos, PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0),
		size,
		Vector2(0, size.y),
	]), color, z_index, slot_id)


# Room floor rect
func _add_room_floor_rect(world_root: Node, floor_top_y: float) -> void:
	var floor_height := WORLD_SIZE.y - floor_top_y
	_add_room_rect(world_root, Vector2(0, floor_top_y), Vector2(WORLD_SIZE.x, floor_height), _colors.DESIGN_ROOM_FLOOR, -9, "room.depth.floor")


# Yuvarlatılmış dikdörtgen 
func _add_room_bottom_rounded_rect(world_root: Node, pos: Vector2, size: Vector2, radius: float, color: Color, z_index: int, slot_id := "") -> Polygon2D:
	var r: float = min(radius, min(size.x, size.y) * 0.5)
	var w := size.x
	var h := size.y
	var points := PackedVector2Array([
		Vector2(0, 0),
		Vector2(w, 0),
		Vector2(w, h - r),
		Vector2(w - r, h),
		Vector2(r, h),
		Vector2(0, h - r),
	])
	return _add_room_polygon(world_root, pos, points, color, z_index, slot_id)


# Yumuşak ışıltı (blob) — atmosferik efekt
func _add_soft_blob(world_root: Node, center: Vector2, radius: Vector2, color: Color, point_count := 18, wobble := 0.08, to_foreground := false, z_index := -4) -> void:
	var blob := Polygon2D.new()
	blob.position = center
	blob.color = color
	blob.z_index = z_index
	var points := PackedVector2Array()
	for i in range(point_count):
		var angle := TAU * float(i) / float(point_count)
		var wave := 1.0 + (sin(float(i) * 1.73) * wobble) + (cos(float(i) * 0.91) * wobble * 0.55)
		points.append(Vector2(cos(angle) * radius.x, sin(angle) * radius.y) * wave)
	blob.polygon = points
	if to_foreground:
		_get_foreground(world_root).add_child(blob)
	else:
		_get_props(world_root).add_child(blob)


# Işık havuzu — soft blob wrapper
func _add_light_pool(world_root: Node, center: Vector2, radius: Vector2, color: Color, to_foreground := false) -> void:
	_add_soft_blob(world_root, center, radius, color, 20, 0.10, to_foreground, 4 if to_foreground else -1)


# Rift bulutu — dairesel yumuşak halka
func _add_rift_cloud(world_root: Node, center: Vector2, radius: float, color: Color) -> void:
	var ring := Polygon2D.new()
	ring.color = color
	var points := PackedVector2Array()
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		var wobble := 1.0 + (0.08 * sin(float(i) * 1.7))
		points.append(Vector2(cos(angle), sin(angle)) * radius * wobble)
	ring.position = center
	ring.polygon = points
	_get_props(world_root).add_child(ring)


# Lamba ışıltısı
func _add_room_lamp_glow(world_root: Node, center: Vector2) -> void:
	var glow_color := Color("#F5E0A0")
	_add_room_glow_ellipse(world_root, center, Vector2(120, 120), Color(glow_color.r, glow_color.g, glow_color.b, 0.08))
	_add_room_glow_ellipse(world_root, center, Vector2(80, 80), Color(glow_color.r, glow_color.g, glow_color.b, 0.20))


# Glow ellipse — BLEND_MODE_ADD ile parlak ışıltı
func _add_room_glow_ellipse(world_root: Node, center: Vector2, radius: Vector2, color: Color) -> void:
	var glow := Polygon2D.new()
	glow.position = center
	glow.color = color
	glow.z_index = 11
	var points := PackedVector2Array()
	for index in range(32):
		var angle := TAU * float(index) / 32.0
		points.append(Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	glow.polygon = points
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = material
	glow.set_meta("visual_fx", true)
	glow.set_meta("base_pos", center)
	glow.set_meta("base_alpha", color.a)
	glow.set_meta("drift", Vector2(0.0, 0.0))
	glow.set_meta("phase", 0.0)
	_get_props(world_root).add_child(glow)


# ============================================================
# ROOM DERİNLİK KATMANLARI
# ============================================================

func _get_room_floor_top_y() -> float:
	return 1580.0


func _add_room_depth_pass(world_root: Node) -> void:
	var floor_top_y := _get_room_floor_top_y()
	_add_room_rect(world_root, Vector2.ZERO, WORLD_SIZE, _colors.DESIGN_DEEP_NAVY, -10, "room.depth.wall")
	_add_room_floor_rect(world_root, floor_top_y)
	_add_room_rect(world_root, Vector2(980, 1200), Vector2(280, 120), _colors.DESIGN_WEATHERED_WALNUT, -8, "room.depth.desk_zone")
	_add_room_rect(world_root, Vector2(0, 0), Vector2(80, floor_top_y), _colors.DESIGN_ROOM_FOREGROUND, -7, "room.depth.bookshelf_silhouette")
	_add_room_bottom_rounded_rect(world_root, Vector2(WORLD_SIZE.x - 140, 270), Vector2(100, 200), 20.0, Color(_colors.DESIGN_ROOM_FOREGROUND.r, _colors.DESIGN_ROOM_FOREGROUND.g, _colors.DESIGN_ROOM_FOREGROUND.b, 0.60), -7, "room.depth.window_curtain")
	_add_room_lamp_glow(world_root, Vector2(860, 1278))


func _add_open_world_start_depth_pass(world_root: Node) -> void:
	_add_room_rect(world_root, Vector2(-220, -620), Vector2(WORLD_SIZE.x + 440, 650), Color("#ecdabe"), -21, "paperopening.depth.sky_overscan")
	_add_room_rect(world_root, Vector2(-220, WORLD_SIZE.y - 10), Vector2(WORLD_SIZE.x + 440, 640), Color("#F5E8D3"), -21, "paperopening.depth.paper_overscan")
	_add_room_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color("#ecdabe"), -20, "paperopening.depth.sky")
	_add_room_rect(world_root, Vector2(0, 660), Vector2(WORLD_SIZE.x, 400), Color("#d1b996"), -19, "paperopening.depth.distant_hills")
	_add_room_rect(world_root, Vector2(0, 980), Vector2(WORLD_SIZE.x, 320), Color("#9a875c"), -18, "paperopening.depth.mid_ground")
	_add_room_rect(world_root, Vector2(0, 1240), Vector2(WORLD_SIZE.x, 440), Color("#685934"), -17, "paperopening.depth.near_ground")
	_add_room_rect(world_root, Vector2(0, 1530), Vector2(WORLD_SIZE.x, 670), Color("#F5E8D3"), -17, "paperopening.depth.paper_base")
	_add_room_rect(world_root, Vector2(0, 950), Vector2(WORLD_SIZE.x, 8), Color("#F5E8D3"), -16, "paperopening.depth.horizon_cut_1")
	_add_room_rect(world_root, Vector2(0, 1050), Vector2(WORLD_SIZE.x, 8), Color("#F5E8D3"), -16, "paperopening.depth.horizon_cut_2")
	_add_room_rect(world_root, Vector2(0, 1150), Vector2(WORLD_SIZE.x, 8), Color("#ddd1be"), -16, "paperopening.depth.horizon_cut_3")
	_add_room_rect(world_root, Vector2(0, 1220), Vector2(WORLD_SIZE.x, 8), Color("#c5b59f"), -16, "paperopening.depth.horizon_cut_4")
	_add_room_rect(world_root, Vector2(0, 1370), Vector2(WORLD_SIZE.x, 8), Color("#b09c82"), -16, "paperopening.depth.horizon_cut_5")


# Paper cutout asset ekle — world.gd ile uyumlu meta key'ler
func _add_paper_cutout_asset(world_root: Node, texture: Texture2D, pos: Vector2, scale_value: Vector2, tint: Color, z_index: int, slot_id := "", drift := Vector2.ZERO, parallax_strength := 0.0) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = scale_value
	sprite.modulate = tint
	sprite.z_index = z_index
	sprite.set_meta("paperworld_asset", true)
	sprite.set_meta("ambient_bob", true)
	sprite.set_meta("base_pos", pos)
	sprite.set_meta("phase", fmod(pos.x * 0.011 + pos.y * 0.017, TAU))
	sprite.set_meta("bob_amount", 0.9)
	if drift != Vector2.ZERO:
		sprite.set_meta("paper_drift", drift)
	if parallax_strength != 0.0:
		sprite.set_meta("paper_parallax_strength", parallax_strength)
	if slot_id != "":
		sprite.set_meta("asset_slot", slot_id)
		sprite.set_meta("replacement_ready", true)
	_get_props(world_root).add_child(sprite)
	return sprite


func _add_open_world_start_asset_layer(world_root: Node) -> void:
	_add_paper_cutout_asset(world_root, _textures.OPENING_PAPER_BENCHMARK_TEXTURE, Vector2(800, 1130), Vector2(1.09, 1.09), Color(1, 1, 1, 0.96), -14, "paperopening.benchmark_world", Vector2.ZERO, -3.0)


func _add_room_paper_asset_layer(world_root: Node) -> void:
	# Duvar arka planı — en uzak katman
	_add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_WALL_TEXTURE,
		Vector2(800, 410), Vector2(1.0, 1.0), Color(1, 1, 1, 0.86), -6,
		"paperroom.wall_window", Vector2.ZERO, -2.0)
	# Duvar hikaye çerçeveleri
	_add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_WALL_STORY_TEXTURE,
		Vector2(460, 320), Vector2(0.90, 0.90), Color(1, 1, 1, 0.78), -5,
		"paperroom.wall_story", Vector2.ZERO, -1.8)
	# Zemin yüzeyi
	_add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_TERRAIN_TEXTURE,
		Vector2(800, 1580), Vector2(1.05, 1.05), Color(1, 1, 1, 0.88), -9,
		"paperroom.terrain", Vector2.ZERO, -3.0)
	# Kitaplık — sol kenar
	_add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_SHELF_TEXTURE,
		Vector2(60, 900), Vector2(0.82, 0.82), Color(1, 1, 1, 0.84), -7,
		"paperroom.shelf", Vector2.ZERO, -1.5)
	# Masa eşyaları
	_add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_DESK_CLUTTER_TEXTURE,
		Vector2(1100, 1260), Vector2(0.78, 0.78), Color(1, 1, 1, 0.82), -4,
		"paperroom.desk_clutter", Vector2.ZERO, -1.0)
	# Çalışma köşesi
	_add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_STUDY_NOOK_TEXTURE,
		Vector2(860, 1280), Vector2(0.80, 0.80), Color(1, 1, 1, 0.86), -3,
		"paperroom.study_nook", Vector2.ZERO, -0.8)
	# Yatak
	_add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_BED_TEXTURE,
		Vector2(340, 1380), Vector2(0.84, 0.84), Color(1, 1, 1, 0.88), -4,
		"paperroom.bed", Vector2.ZERO, -1.2)
	# Halı
	_add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_FLOOR_RUG_TEXTURE,
		Vector2(800, 1620), Vector2(0.92, 0.92), Color(1, 1, 1, 0.76), -8,
		"paperroom.floor_rug", Vector2.ZERO, -2.5)
	# Kitap portalı — zaman yolculuğu geçiş noktası
	_add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_BOOK_PORTAL_TEXTURE,
		Vector2(800, 1100), Vector2(0.72, 0.72), Color(1, 1, 1, 0.92), -2,
		"paperroom.book_portal", Vector2.ZERO, 0.5)
	# Ön plan çerçeve — en yakın katman
	_add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_FOREGROUND_FRAME_TEXTURE,
		Vector2(800, 1850), Vector2(1.10, 1.10), Color(1, 1, 1, 0.88), 4,
		"paperroom.foreground_frame", Vector2.ZERO, 2.0)


# ============================================================
# ROOM DEKORASYON
# ============================================================

func _decorate_room(world_root: Node) -> void:
	# Sıcak gün batımı ışığı - sahne 1.png referansı (%73 turuncu)
	_add_soft_blob(world_root, Vector2(700, 600), Vector2(600, 400), Color(1.0, 0.76, 0.42, 0.06), 24, 0.02, true, 5)
	_add_soft_blob(world_root, Vector2(1180, 1320), Vector2(240, 170), Color(1.0, 0.84, 0.46, 0.10), 24, 0.03, true, 5)
	_add_soft_blob(world_root, Vector2(360, 1470), Vector2(170, 110), Color(0.42, 0.58, 0.88, 0.08), 22, 0.03, true, 5)
	_add_soft_blob(world_root, Vector2(690, 1310), Vector2(190, 120), Color(1.0, 0.76, 0.38, 0.08), 22, 0.03, true, 5)
	# Sıcak ışık havuzu - merkez alan aydınlatması
	_add_light_pool(world_root, Vector2(800, 1100), Vector2(360, 180), Color(1.0, 0.78, 0.42, 0.08))
	# Altın tozu parçacıkları - rüya atmosferi
	_add_mote_cluster(Vector2(1180, 1320), Color(1.0, 0.84, 0.46, 0.13), 5)
	_add_mote_cluster(Vector2(720, 1300), Color(0.72, 0.92, 1.0, 0.10), 5)
	_add_mote_cluster(Vector2(500, 900), Color(1.0, 0.80, 0.50, 0.06), 8)
	_add_mote_cluster(Vector2(1100, 800), Color(0.92, 0.88, 0.70, 0.05), 6)
	# Yumuşak kenar ışığı - sıcak atmosfer katmanı
	_add_soft_blob(world_root, Vector2(400, 500), Vector2(250, 100), Color(0.92, 0.72, 0.50, 0.04), 24, 0.01, true, 4)
	_add_soft_blob(world_root, Vector2(1200, 500), Vector2(250, 100), Color(0.92, 0.72, 0.50, 0.04), 24, 0.01, true, 4)


# ============================================================
# ROOM BUILDER
# ============================================================

func _get_player(world_root: Node) -> Node:
	return world_root.get_node("Player")

func _get_companion(world_root: Node) -> Node:
	return world_root.get_node("Companion")


func _snap_room_characters_to_floor(world_root: Node) -> void:
	var player := _get_player(world_root)
	var companion := _get_companion(world_root)
	player.position = Vector2(540, 1480)
	companion.position = Vector2(660, 1540)


func _build_room(world_root: Node) -> void:
	_add_open_world_start_depth_pass(world_root)
	_add_open_world_start_asset_layer(world_root)
	_add_room_paper_asset_layer(world_root)
	_add_room_depth_pass(world_root)
	_snap_room_characters_to_floor(world_root)
	_decorate_room(world_root)


# ============================================================
# SHIP BUILDER (temel)
# ============================================================

func _add_ship_room_plates(world_root: Node) -> void:
	_add_room_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color("#20344F"), -18, "world_tiles.ship_deep_navy_back")
	_add_room_rect(world_root, Vector2(0, 1180), Vector2(WORLD_SIZE.x, 1020), Color("#355D78"), -17, "world_tiles.ship_ocean_slate_lower")
	_add_room_rect(world_root, Vector2(120, 260), Vector2(1360, 650), Color(0.31, 0.20, 0.14, 0.96), -16, "world_tiles.ship_cabin_wall")
	_add_room_rect(world_root, Vector2(120, 910), Vector2(1360, 5), Color("#7A5A42"), -15, "world_tiles.ship_cabin_wall_edge")
	_add_room_rect(world_root, Vector2(210, 1030), Vector2(1170, 610), Color(0.46, 0.29, 0.17, 0.96), -14, "world_tiles.ship_deck_floor")
	_add_room_rect(world_root, Vector2(210, 1030), Vector2(1170, 5), Color(0.63, 0.45, 0.28, 0.88), -13, "world_tiles.ship_deck_floor_edge")
	_add_room_rect(world_root, Vector2(1070, 980), Vector2(250, 640), Color(0.10, 0.36, 0.45, 0.76), -12, "world_tiles.ship_sea_window")
	_add_room_rect(world_root, Vector2(685, 1170), Vector2(330, 176), Color("#7A5A42"), -11, "world_tiles.ship_desk_zone")
	_add_room_rect(world_root, Vector2(0, 0), Vector2(88, WORLD_SIZE.y), Color("#1A2A3A"), 5, "world_props.ship_left_foreground_frame")
	_add_room_rect(world_root, Vector2(WORLD_SIZE.x - 88, 0), Vector2(88, WORLD_SIZE.y), Color("#1A2A3A"), 5, "world_props.ship_right_foreground_frame")
	_add_soft_blob(world_root, Vector2(850, 1250), Vector2(360, 170), Color(1.0, 0.78, 0.42, 0.11), 24, 0.04, false, -10)
	_add_soft_blob(world_root, Vector2(1170, 1310), Vector2(270, 430), Color(0.52, 0.86, 0.96, 0.10), 24, 0.04, false, -10)


func _build_ship(world_root: Node) -> void:
	_add_ship_room_plates(world_root)
	_decorate_ship(world_root)


# ============================================================
# SAMSUN RIFT BUILDER (temel)
# ============================================================

func _add_samsun_plate(world_root: Node, pos: Vector2, size: Vector2, fill: Color, edge: Color, z_index: int, slot_id := "") -> void:
	_add_room_rect(world_root, pos, size, fill, z_index, slot_id)
	_add_room_rect(world_root, pos, Vector2(size.x, 3.0), edge, z_index + 1, "%s.top_edge" % slot_id)


func _add_samsun_ground_plates(world_root: Node) -> void:
	_add_samsun_plate(world_root, Vector2.ZERO, Vector2(WORLD_SIZE.x, WORLD_SIZE.y * 0.40), Color("#355D78"), Color("#2B4A60"), -15, "world_tiles.samsun_plate_harbor")
	_add_samsun_plate(world_root, Vector2(WORLD_SIZE.x * 0.075, WORLD_SIZE.y * 0.32), Vector2(WORLD_SIZE.x * 0.85, WORLD_SIZE.y * 0.35), Color("#5D8F92"), Color("#4C777A"), -14, "world_tiles.samsun_plate_civic")
	_add_samsun_plate(world_root, Vector2(WORLD_SIZE.x * 0.15, WORLD_SIZE.y * 0.68), Vector2(WORLD_SIZE.x * 0.70, WORLD_SIZE.y * 0.25), Color("#E89863"), Color("#B96E4A"), -13, "world_tiles.samsun_plate_front")
	_add_samsun_harbor_wave_bands()
	_add_samsun_paper_cut_edges()


func _build_samsun_rift(world_root: Node) -> void:
	_add_rect(world_root, Vector2.ZERO, WORLD_SIZE, _colors.THEME_SAMSUN["bg"])
	_decorate_samsun_rift(world_root)
	emit_signal("world_built", "samsun_rift")


# ============================================================
# HAVZA BUILDER (temel)
# ============================================================

func _build_havza_world(world_root: Node) -> void:
	_add_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color(0.10, 0.17, 0.13))
	_add_rect(world_root, Vector2(90, 170), Vector2(1420, 1840), Color(0.20, 0.28, 0.18))
	_add_rect(world_root, Vector2(180, 320), Vector2(1240, 1460), Color(0.30, 0.40, 0.24))
	_add_rect(world_root, Vector2(310, 1490), Vector2(290, 230), Color(0.18, 0.30, 0.34))
	_add_rect(world_root, Vector2(1020, 1440), Vector2(270, 250), Color(0.35, 0.30, 0.20))
	_add_rift_cloud(world_root, Vector2(790, 1100), 760, Color(0.95, 0.80, 0.26, 0.12))
	_add_rift_cloud(world_root, Vector2(790, 1100), 900, Color(0.28, 0.50, 0.42, 0.12))
	_decorate_havza(world_root)


# ============================================================
# AMASYA BUILDER (temel)
# ============================================================

func _build_amasya_world(world_root: Node) -> void:
	_add_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color(0.12, 0.15, 0.20))
	_add_rect(world_root, Vector2(90, 170), Vector2(1420, 1840), Color(0.22, 0.24, 0.30))
	_add_rect(world_root, Vector2(180, 280), Vector2(1240, 1580), Color(0.32, 0.34, 0.40))
	_add_rect(world_root, Vector2(300, 440), Vector2(980, 340), Color(0.46, 0.36, 0.26), "Toplanti Evi")
	_add_rect(world_root, Vector2(360, 1010), Vector2(860, 540), Color(0.40, 0.32, 0.24), "Karar Salonu")
	_add_rect(world_root, Vector2(260, 1660), Vector2(1040, 120), Color(0.55, 0.48, 0.34), "Bildiri Yolu")
	_add_rift_cloud(world_root, Vector2(810, 1120), 780, Color(0.64, 0.70, 0.95, 0.12))
	_add_rift_cloud(world_root, Vector2(810, 1120), 920, Color(0.95, 0.82, 0.40, 0.10))
	_decorate_amasya(world_root)


# ============================================================
# KONGRELER BUILDER (temel)
# ============================================================

func _build_kongreler_world(world_root: Node) -> void:
	_add_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color(0.14, 0.14, 0.18))
	_add_rect(world_root, Vector2(80, 150), Vector2(1440, 1880), Color(0.24, 0.24, 0.30))
	_add_rect(world_root, Vector2(200, 300), Vector2(1200, 1500), Color(0.36, 0.34, 0.28))
	_add_rect(world_root, Vector2(300, 430), Vector2(1000, 300), Color(0.50, 0.40, 0.26), "Kongre Salonu")
	_add_rect(world_root, Vector2(260, 940), Vector2(1080, 540), Color(0.42, 0.32, 0.22), "Temsil Meydani")
	_add_rect(world_root, Vector2(340, 1620), Vector2(920, 120), Color(0.58, 0.50, 0.34), "Ortak Hedef Yolu")
	_add_rift_cloud(world_root, Vector2(800, 1080), 760, Color(0.95, 0.70, 0.42, 0.10))
	_add_rift_cloud(world_root, Vector2(800, 1080), 920, Color(0.70, 0.72, 0.92, 0.10))
	_decorate_kongreler(world_root)


# ============================================================
# ANKARA BUILDER
# ============================================================

func _build_ankara_world(world_root: Node) -> void:
	"""Ankara steppe / Meclis sahnesini paper cutout asset'lerle kur."""
	# Base background — warm steppe sky + terrain
	_add_ankara_paper_asset_layer(world_root)
	_add_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color(0.14, 0.16, 0.12))
	_add_rect(world_root, Vector2(80, 150), Vector2(1440, 1880), Color(0.24, 0.26, 0.20))
	_add_rect(world_root, Vector2(200, 300), Vector2(1200, 1500), Color(0.34, 0.32, 0.22))
	_add_rect(world_root, Vector2(300, 440), Vector2(1000, 340), Color(0.48, 0.38, 0.24), "Meclis Binasi")
	_add_rect(world_root, Vector2(260, 960), Vector2(1080, 500), Color(0.40, 0.30, 0.22), "Irade Alani")
	_add_rect(world_root, Vector2(340, 1620), Vector2(920, 120), Color(0.56, 0.48, 0.32), "Birlik Yolu")
	_add_rift_cloud(world_root, Vector2(800, 1080), 740, Color(0.95, 0.82, 0.40, 0.10))
	_add_rift_cloud(world_root, Vector2(800, 1080), 900, Color(0.72, 0.78, 0.92, 0.10))
	_decorate_ankara(world_root)


func _decorate_ankara(world_root: Node) -> void:
	"""Ankara dekorasyonu — steppe atmosferi, Meclis, yollar, landmarklar."""
	_add_ankara_toy_world_frame()
	_add_ankara_steppe_backdrop(world_root)
	_add_ankara_location_sign()
	_add_ankara_meclis_landmark()
	_add_ankara_path_ribbon()
	_add_ankara_light_pools(world_root)
	_add_ankara_steppe_props()
	_add_ankara_environment()


# ============================================================
# ANKARA YARDIMCI FONKSİYONLAR
# ============================================================

func _add_ankara_paper_asset_layer(world_root: Node) -> void:
	"""Ankara paper cutout asset'lerini diorama katmanına ekle."""
	# Sky — arkaplan overscan
	_add_paper_cutout_asset(
		world_root, _textures.ANKARA_PAPER_SKY_TEXTURE,
		Vector2(750, 360), Vector2(1.10, 1.10),
		Color(1, 1, 1, 0.92), -21, "ankara.depth.sky",
		Vector2.ZERO, -3.0
	)
	# Terrain — ana zemin katmanı
	_add_paper_cutout_asset(
		world_root, _textures.ANKARA_PAPER_TERRAIN_TEXTURE,
		Vector2(540, 1100), Vector2(0.82, 0.78),
		Color(1, 1, 1, 0.88), -14, "ankara.depth.terrain",
		Vector2.ZERO, -2.0
	)
	# Main path — soldan sağa kıvrılan patika
	_add_paper_cutout_asset(
		world_root, _textures.ANKARA_PAPER_MAIN_PATH_TEXTURE,
		Vector2(820, 980), Vector2(0.72, 0.72),
		Color(1, 1, 1, 0.86), -5, "ankara.path.main",
		Vector2.ZERO, -1.0
	)
	# Foreground frame — kenar süslemeleri
	_add_paper_cutout_asset(
		world_root, _textures.ANKARA_PAPER_FOREGROUND_FRAME_TEXTURE,
		Vector2(800, 1850), Vector2(1.04, 0.70),
		Color(1, 1, 1, 0.72), 1, "ankara.foreground.frame",
		Vector2.ZERO, 1.0
	)
	# Meclis landmark — TBMM binası
	_add_paper_cutout_asset(
		world_root, _textures.ANKARA_PAPER_MECLIS_LANDMARK_TEXTURE,
		Vector2(360, 820), Vector2(0.60, 0.60),
		Color(1, 1, 1, 0.94), -4, "ankara.landmark.meclis",
		Vector2.ZERO, -1.5
	)


func _add_ankara_toy_world_frame() -> void:
	"""Ankara toy world frame — warm steppe tonları."""
	_add_toy_world_frame(
		Color(0.42, 0.32, 0.20, 0.22),
		Color(0.96, 0.82, 0.42, 0.09)
	)


func _add_ankara_steppe_backdrop(world_root: Node) -> void:
	"""Ankara steppe arkaplanı — sıcak tepe silüetleri."""
	_add_backdrop_band(
		[_textures.BG_FLAT_HILLS_1_TEXTURE, _textures.BG_FLAT_MOUNTAIN_2_TEXTURE, _textures.BG_FLAT_HILLS_2_TEXTURE],
		460.0, Vector2(1.00, 1.00),
		Color(0.82, 0.74, 0.52, 0.16), "ankara.horizon"
	)
	_add_distant_town_band(
		600.0,
		Color(0.92, 0.86, 0.66, 0.14), "ankara.distant_town"
	)


func _add_ankara_location_sign() -> void:
	"""Ankara lokasyon tabelası."""
	_add_location_sign(
		"Ankara", "Meclis'e dogru",
		Vector2(556, 260), 480.0,
		Color(0.72, 0.58, 0.34, 0.82),
		"ankara.location_sign"
	)


func _add_ankara_meclis_landmark() -> void:
	"""Meclis landmark'ı etrafında atmosferik efektler."""
	var meclis_center := Vector2(360, 820)
	
	# Meclis ışıltısı
	_add_soft_blob(
		_cached_world_root, meclis_center + Vector2(0, 40),
		Vector2(200, 120), Color(0.96, 0.88, 0.66, 0.18),
		22, 0.08, false, -3
	)
	_add_soft_blob(
		_cached_world_root, meclis_center + Vector2(0, 20),
		Vector2(120, 80), Color(0.98, 0.92, 0.72, 0.12),
		18, 0.10, false, -2
	)
	
	# Bayrak ışıltısı — kırmızı vurgu
	_add_soft_blob(
		_cached_world_root, meclis_center + Vector2(0, -100),
		Vector2(60, 60), Color(0.78, 0.30, 0.24, 0.10),
		16, 0.12, false, -1
	)


func _add_ankara_path_ribbon() -> void:
	"""Ankara ana patika ribbon'ı — steppe rengi."""
	_add_path_ribbon(
		[
			Vector2(520, 1400),
			Vector2(680, 1120),
			Vector2(840, 980),
			Vector2(960, 860),
			Vector2(1080, 780),
		],
		32.0, Color(0.82, 0.64, 0.38, 0.24), -2
	)


func _add_ankara_light_pools(world_root: Node) -> void:
	"""Ankara ışık havuzları — Meclis çevresi aydınlatma."""
	_add_light_pool(
		world_root, Vector2(360, 820),
		Vector2(290, 180), Color(1.0, 0.86, 0.40, 0.11)
	)
	_add_light_pool(
		world_root, Vector2(800, 1120),
		Vector2(340, 200), Color(0.72, 0.78, 0.92, 0.09)
	)
	_add_light_pool(
		world_root, Vector2(600, 1420),
		Vector2(260, 160), Color(1.0, 0.78, 0.42, 0.08)
	)


func _add_ankara_steppe_props() -> void:
	"""Ankara steppe dekoratif prop'ları — kenney asset'leriyle."""
	# Meclis önü işaretleri
	_add_kenney_prop(
		_textures.BLOCK_MARKET_STALL_BLUE_TEXTURE, Vector2(710, 1086),
		Vector2(1.12, 1.12), Color(0.90, 1.0, 1.0, 0.82),
		true, "ankara.square_stall"
	)
	_add_kenney_prop(
		_textures.BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(1008, 724),
		Vector2(1.08, 1.08), Color(1.0, 0.88, 0.62, 0.70),
		true, "ankara.notice_board_legs"
	)
	_add_kenney_prop(
		_textures.BLOCK_TREE_GREEN_TEXTURE, Vector2(1160, 1190),
		Vector2(0.96, 0.96), Color(0.86, 1.0, 0.74, 0.70),
		true, "ankara.square_tree"
	)
	_add_kenney_prop(
		_textures.BLOCK_TREE_ORANGE_TEXTURE, Vector2(250, 1180),
		Vector2(0.84, 0.84), Color(1.0, 0.90, 0.56, 0.56),
		true, "ankara.warm_tree"
	)
	_add_kenney_prop(
		_textures.BLOCK_BUSH_LARGE_TEXTURE, Vector2(480, 1210),
		Vector2(1.00, 1.00), Color(0.82, 0.94, 0.62, 0.60),
		true, "ankara.bush_left"
	)
	_add_kenney_prop(
		_textures.BLOCK_BUSH_SMALL_TEXTURE, Vector2(920, 1160),
		Vector2(1.00, 1.00), Color(0.78, 0.90, 0.58, 0.56),
		true, "ankara.bush_right"
	)
	
	# NPC'ler
	_add_kenney_npc(
		_textures.BLOCK_CHARACTER_MAN_TEXTURE, Vector2(650, 1210),
		Vector2(0.82, 0.82), Color(0.96, 0.94, 0.86, 0.56),
		"ankara.citizen_a", "tartis"
	)
	_add_kenney_npc(
		_textures.BLOCK_CHARACTER_WOMAN_TEXTURE, Vector2(798, 1218),
		Vector2(0.82, 0.82), Color(0.96, 1.0, 0.94, 0.56),
		"ankara.citizen_b", "dinle"
	)
	_add_kenney_npc(
		_textures.BLOCK_CHARACTER_HORSE_TEXTURE, Vector2(470, 1280),
		Vector2(0.78, 0.78), Color(1.0, 0.92, 0.76, 0.42),
		"ankara.carrier_horse", ""
	)
	
	# Asset slot prop'ları
	_add_asset_slot_prop(
		"ankara.meclis_notice", Vector2(970, 622),
		Vector2(150, 118), Color(0.96, 0.88, 0.62, 0.86),
		Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.42),
		"Genelge", true
	)
	_add_asset_slot_prop(
		"ankara.telegraph_table", Vector2(370, 1470),
		Vector2(170, 98), Color(0.80, 0.62, 0.36, 0.86),
		Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.38),
		"Telgraf", true
	)
	_add_asset_slot_prop(
		"ankara.town_square", Vector2(625, 1048),
		Vector2(178, 104), Color(0.96, 0.82, 0.48, 0.62),
		Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.45),
		"Meydan", true
	)
	
	# Strateji kartları
	_add_strategy_card(
		_textures.BOARD_CARD_GREEN_TEXTURE, Vector2(860, 1040),
		Vector2(0.42, 0.42), Color(0.90, 1.0, 0.86, 0.76),
		"Irade", "ankara.voice_card"
	)
	_add_strategy_token(
		_textures.BOARD_CHIP_GREEN_TEXTURE, Vector2(990, 672),
		Vector2(0.42, 0.42), Color(0.86, 1.0, 0.76, 0.84),
		"ankara.notice_token"
	)
	
	# Yön okları
	_add_way_arrow(
		Vector2(900, 820), deg_to_rad(-52),
		Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.72),
		"meclis", "ankara.to_meclis_arrow"
	)
	_add_way_arrow(
		Vector2(575, 1415), deg_to_rad(154),
		Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.70),
		"telgraf", "ankara.to_telegraph_arrow"
	)
	
	# Keşif rozeti
	_add_discovery_badge(
		_textures.GAME_INFO_TEXTURE, Vector2(720, 940),
		Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.86),
		"meclis", "ankara.meclis_badge"
	)
	
	# Hikaye banner'ı
	_add_story_banner(
		Vector2(510, 420), Vector2(460, 128),
		Color(0.96, 0.92, 0.70, 0.86),
		Color(0.56, 0.48, 0.24, 0.80),
		"Meclis ve Irade"
	)


func _add_ankara_environment() -> void:
	"""Ankara çevresel detaylar — bulutlar, speckles, sketch strip."""
	_add_decorative_speckles(
		Rect2(Vector2(240, 520), Vector2(1120, 1100)),
		Color(1.0, 0.92, 0.54, 0.07), 22
	)
	_add_sprite_prop(
		_textures.CLOUD_TEXTURE, Vector2(310, 250),
		Vector2(0.98, 0.98), Color(1, 1, 1, 0.18)
	)
	_add_sprite_prop(
		_textures.CLOUD_TEXTURE_ALT, Vector2(1240, 280),
		Vector2(0.88, 0.88), Color(1, 1, 1, 0.14)
	)
	
	# Sketch strip — steppe grass
	_add_sketch_strip(
		_textures.SKETCH_GRASS_TEXTURE, Vector2(260, 360),
		8, Vector2(118, 0), Color(1, 1, 1, 0.70)
	)
	_add_sketch_strip(
		_textures.SKETCH_GRASS_TEXTURE, Vector2(320, 470),
		7, Vector2(118, 0), Color(1, 1, 1, 0.68)
	)
	_add_sketch_strip(
		_textures.SKETCH_GRASS_TEXTURE, Vector2(270, 1280),
		8, Vector2(118, 0), Color(1, 1, 1, 0.68)
	)
	_add_sketch_strip(
		_textures.SKETCH_GRASS_TEXTURE, Vector2(340, 1380),
		7, Vector2(118, 0), Color(1, 1, 1, 0.66)
	)
	
	# Sketch path tiles
	_add_sketch_tile(
		_textures.SKETCH_PATH_TEXTURE, Vector2(450, 1540),
		Color.WHITE, Vector2(0.74, 0.74)
	)
	_add_sketch_tile(
		_textures.SKETCH_PATH_TEXTURE, Vector2(920, 1040),
		Color.WHITE, Vector2(0.74, 0.74)
	)
	
	# Steppe ağaç binaları
	_add_havza_building(
		Vector2(790, 560), 4,
		_textures.SKETCH_BUILDING_DOOR_TEXTURE,
		_textures.SKETCH_BUILDING_WINDOWS_TEXTURE,
		_textures.SKETCH_BUILDING_CENTER_TEXTURE,
		Color(1, 1, 1, 0.92)
	)
	_add_havza_building(
		Vector2(300, 680), 3,
		_textures.SKETCH_BUILDING_WINDOW_TEXTURE,
		_textures.SKETCH_BUILDING_WINDOW_TEXTURE,
		_textures.SKETCH_BUILDING_CENTER_TEXTURE,
		Color(1, 1, 1, 0.78)
	)
	_add_kenney_building(
		Vector2(930, 620), Vector2(1.02, 1.02),
		_textures.BLOCK_BUILDING_ROOF_RED_TEXTURE,
		Color(1.0, 0.94, 0.78, 0.58)
	)
	_add_kenney_building(
		Vector2(310, 790), Vector2(0.88, 0.88),
		_textures.BLOCK_BUILDING_ROOF_BLUE_TEXTURE,
		Color(0.94, 1.0, 1.0, 0.48)
	)


# ============================================================
# SAKARYA BUILDER
# ============================================================

func _build_sakarya_world(world_root: Node) -> void:
	"""Sakarya savas / Buyuk Taarruz sahnesini paper cutout asset'lerle kur."""
	# Base background — dark war tones
	_add_sakarya_paper_asset_layer(world_root)
	_add_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color(0.08, 0.06, 0.05))
	_add_rect(world_root, Vector2(80, 150), Vector2(1440, 1880), Color(0.14, 0.12, 0.08))
	_add_rect(world_root, Vector2(200, 300), Vector2(1200, 1500), Color(0.22, 0.18, 0.12))
	_add_rect(world_root, Vector2(300, 440), Vector2(1000, 340), Color(0.32, 0.24, 0.16), "Karargah Alani")
	_add_rect(world_root, Vector2(260, 960), Vector2(1080, 500), Color(0.28, 0.20, 0.14), "Taarruz Alani")
	_add_rect(world_root, Vector2(340, 1620), Vector2(920, 120), Color(0.40, 0.32, 0.22), "Zafer Yolu")
	_add_rect(world_root, Vector2(300, 440), Vector2(1000, 4), Color(0.60, 0.18, 0.12, 0.30), "hat_1")
	_add_rect(world_root, Vector2(300, 780), Vector2(1000, 4), Color(0.60, 0.18, 0.12, 0.24), "hat_2")
	_add_rect(world_root, Vector2(300, 1120), Vector2(1000, 4), Color(0.60, 0.18, 0.12, 0.18), "hat_3")
	_add_rift_cloud(world_root, Vector2(800, 1080), 740, Color(0.60, 0.20, 0.12, 0.10))
	_add_rift_cloud(world_root, Vector2(800, 1080), 900, Color(0.40, 0.30, 0.20, 0.10))
	_decorate_sakarya(world_root)


func _decorate_sakarya(world_root: Node) -> void:
	"""Sakarya dekorasyonu — savas atmosferi, karargah, yol, landmarklar."""
	_add_sakarya_toy_world_frame()
	_add_sakarya_battle_backdrop(world_root)
	_add_sakarya_location_sign()
	_add_sakarya_hq_landmark()
	_add_sakarya_path_ribbon()
	_add_sakarya_light_pools(world_root)
	_add_sakarya_battle_props()
	_add_sakarya_environment()


# ============================================================
# SAKARYA YARDIMCI FONKSIYONLAR
# ============================================================

func _add_sakarya_paper_asset_layer(world_root: Node) -> void:
	"""Sakarya paper cutout asset'lerini diorama katmanina ekle."""
	# Sky — dramatic sunset/war sky
	_add_paper_cutout_asset(
		world_root, _textures.SAKARYA_PAPER_SKY_TEXTURE,
		Vector2(750, 360), Vector2(1.10, 1.10),
		Color(1, 1, 1, 0.92), -21, "sakarya.depth.sky",
		Vector2.ZERO, -3.0
	)
	# Terrain — battle-worn terrain
	_add_paper_cutout_asset(
		world_root, _textures.SAKARYA_PAPER_TERRAIN_TEXTURE,
		Vector2(540, 1100), Vector2(0.82, 0.78),
		Color(1, 1, 1, 0.88), -14, "sakarya.depth.terrain",
		Vector2.ZERO, -2.0
	)
	# Main path — soldan saga kivrilan taarruz yolu
	_add_paper_cutout_asset(
		world_root, _textures.SAKARYA_PAPER_MAIN_PATH_TEXTURE,
		Vector2(820, 980), Vector2(0.72, 0.72),
		Color(1, 1, 1, 0.86), -5, "sakarya.path.main",
		Vector2.ZERO, -1.0
	)
	# Foreground frame — war-themed edge ornaments
	_add_paper_cutout_asset(
		world_root, _textures.SAKARYA_PAPER_FOREGROUND_FRAME_TEXTURE,
		Vector2(800, 1850), Vector2(1.04, 0.70),
		Color(1, 1, 1, 0.72), 1, "sakarya.foreground.frame",
		Vector2.ZERO, 1.0
	)
	# HQ landmark — Mustafa Kemal's command tent
	_add_paper_cutout_asset(
		world_root, _textures.SAKARYA_PAPER_HQ_LANDMARK_TEXTURE,
		Vector2(360, 820), Vector2(0.60, 0.60),
		Color(1, 1, 1, 0.94), -4, "sakarya.landmark.hq",
		Vector2.ZERO, -1.5
	)
	# Victory marker — zafer sembolu
	_add_paper_cutout_asset(
		world_root, _textures.SAKARYA_PAPER_VICTORY_MARKER_TEXTURE,
		Vector2(1040, 680), Vector2(0.50, 0.50),
		Color(1, 1, 1, 0.90), -3, "sakarya.landmark.victory",
		Vector2.ZERO, -1.2
	)


func _add_sakarya_toy_world_frame() -> void:
	"""Sakarya toy world frame — koyu savas tonlari."""
	_add_toy_world_frame(
		Color(0.30, 0.18, 0.10, 0.25),
		Color(0.60, 0.20, 0.12, 0.08)
	)


func _add_sakarya_battle_backdrop(world_root: Node) -> void:
	"""Sakarya savas arkaplani — karanlik tepe siluetleri."""
	_add_backdrop_band(
		[_textures.BG_FLAT_MOUNTAIN_1_TEXTURE, _textures.BG_FLAT_POINTY_MOUNTAINS_TEXTURE, _textures.BG_FLAT_MOUNTAIN_2_TEXTURE],
		460.0, Vector2(1.00, 1.00),
		Color(0.30, 0.22, 0.16, 0.20), "sakarya.horizon"
	)
	_add_distant_town_band(
		600.0,
		Color(0.40, 0.30, 0.20, 0.12), "sakarya.distant_town"
	)


func _add_sakarya_location_sign() -> void:
	"""Sakarya lokasyon tabelasi."""
	_add_location_sign(
		"Sakarya", "Büyük Taarruz",
		Vector2(556, 260), 480.0,
		Color(0.50, 0.34, 0.20, 0.82),
		"sakarya.location_sign"
	)


func _add_sakarya_hq_landmark() -> void:
	"""Karargah landmark'i etrafinda atmosferik efektler."""
	var hq_center := Vector2(360, 820)

	# Karargah isiltisi
	_add_soft_blob(
		_cached_world_root, hq_center + Vector2(0, 40),
		Vector2(200, 120), Color(0.80, 0.60, 0.30, 0.18),
		22, 0.08, false, -3
	)
	_add_soft_blob(
		_cached_world_root, hq_center + Vector2(0, 20),
		Vector2(120, 80), Color(0.90, 0.70, 0.40, 0.12),
		18, 0.10, false, -2
	)

	# Bayrak isiltisi — kirmizi vurgu
	_add_soft_blob(
		_cached_world_root, hq_center + Vector2(0, -100),
		Vector2(60, 60), Color(0.78, 0.20, 0.14, 0.10),
		16, 0.12, false, -1
	)


func _add_sakarya_path_ribbon() -> void:
	"""Sakarya ana taarruz ribbon'i — koyu savas rengi."""
	_add_path_ribbon(
		[
			Vector2(520, 1400),
			Vector2(680, 1120),
			Vector2(840, 980),
			Vector2(960, 860),
			Vector2(1080, 780),
		],
		32.0, Color(0.50, 0.30, 0.16, 0.24), -2
	)


func _add_sakarya_light_pools(world_root: Node) -> void:
	"""Sakarya isik havuzlari — karargah cevresi aydinlatma."""
	_add_light_pool(
		world_root, Vector2(360, 820),
		Vector2(290, 180), Color(0.80, 0.50, 0.20, 0.11)
	)
	_add_light_pool(
		world_root, Vector2(800, 1120),
		Vector2(340, 200), Color(0.50, 0.30, 0.16, 0.09)
	)
	_add_light_pool(
		world_root, Vector2(600, 1420),
		Vector2(260, 160), Color(0.70, 0.30, 0.12, 0.08)
	)


func _add_sakarya_battle_props() -> void:
	"""Sakarya savas dekoratif prop'lari — kenney asset'leriyle."""
	# Karargah onu isaretleri
	_add_kenney_prop(
		_textures.BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(710, 1086),
		Vector2(1.12, 1.12), Color(0.70, 0.60, 0.50, 0.82),
		true, "sakarya.barrier_left"
	)
	_add_kenney_prop(
		_textures.BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(1008, 724),
		Vector2(1.08, 1.08), Color(0.70, 0.60, 0.50, 0.70),
		true, "sakarya.barrier_right"
	)
	_add_kenney_prop(
		_textures.BLOCK_TREE_GREEN_TEXTURE, Vector2(1160, 1190),
		Vector2(0.96, 0.96), Color(0.50, 0.60, 0.40, 0.70),
		true, "sakarya.battle_tree"
	)
	_add_kenney_prop(
		_textures.BLOCK_BUSH_LARGE_TEXTURE, Vector2(250, 1180),
		Vector2(0.84, 0.84), Color(0.50, 0.40, 0.30, 0.56),
		true, "sakarya.scrub_left"
	)
	_add_kenney_prop(
		_textures.BLOCK_BUSH_SMALL_TEXTURE, Vector2(480, 1210),
		Vector2(1.00, 1.00), Color(0.45, 0.55, 0.35, 0.60),
		true, "sakarya.scrub_mid"
	)
	_add_kenney_prop(
		_textures.BLOCK_CART_TOP_TEXTURE, Vector2(920, 1160),
		Vector2(1.00, 1.00), Color(0.60, 0.50, 0.35, 0.56),
		true, "sakarya.supply_cart"
	)

	# NPC'ler — askerler
	_add_kenney_npc(
		_textures.BLOCK_CHARACTER_MAN_TEXTURE, Vector2(650, 1210),
		Vector2(0.82, 0.82), Color(0.70, 0.65, 0.55, 0.56),
		"sakarya.soldier_a", "izle"
	)
	_add_kenney_npc(
		_textures.BLOCK_CHARACTER_MAN_TEXTURE, Vector2(798, 1218),
		Vector2(0.82, 0.82), Color(0.65, 0.70, 0.60, 0.56),
		"sakarya.soldier_b", "dinle"
	)
	_add_kenney_npc(
		_textures.BLOCK_CHARACTER_HORSE_TEXTURE, Vector2(470, 1280),
		Vector2(0.78, 0.78), Color(0.60, 0.55, 0.45, 0.42),
		"sakarya.cavalry_horse", ""
	)

	# Asset slot prop'lari
	_add_asset_slot_prop(
		"sakarya.hq_map", Vector2(970, 622),
		Vector2(150, 118), Color(0.60, 0.50, 0.35, 0.86),
		Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.42),
		"Harp Plani", true
	)
	_add_asset_slot_prop(
		"sakarya.telegraph_tent", Vector2(370, 1470),
		Vector2(170, 98), Color(0.50, 0.40, 0.25, 0.86),
		Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.38),
		"Telgraf", true
	)
	_add_asset_slot_prop(
		"sakarya.cephe_karargah", Vector2(625, 1048),
		Vector2(178, 104), Color(0.60, 0.45, 0.28, 0.62),
		Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.45),
		"Cephe", true
	)

	# Strateji kartlari
	_add_strategy_card(
		_textures.BOARD_CARD_RED_TEXTURE, Vector2(860, 1040),
		Vector2(0.42, 0.42), Color(0.90, 0.70, 0.60, 0.76),
		"Taarruz", "sakarya.attack_card"
	)
	_add_strategy_token(
		_textures.BOARD_CHIP_RED_TEXTURE, Vector2(990, 672),
		Vector2(0.42, 0.42), Color(0.86, 0.60, 0.50, 0.84),
		"sakarya.victory_token"
	)

	# Yon oklari
	_add_way_arrow(
		Vector2(900, 820), deg_to_rad(-52),
		Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.72),
		"karargah", "sakarya.to_hq_arrow"
	)
	_add_way_arrow(
		Vector2(575, 1415), deg_to_rad(154),
		Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.70),
		"cephe", "sakarya.to_front_arrow"
	)

	# Kesif rozeti
	_add_discovery_badge(
		_textures.GAME_INFO_TEXTURE, Vector2(720, 940),
		Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.86),
		"karargah", "sakarya.hq_badge"
	)

	# Hikaye banner'i
	_add_story_banner(
		Vector2(510, 420), Vector2(460, 128),
		Color(0.60, 0.40, 0.25, 0.86),
		Color(0.36, 0.24, 0.14, 0.80),
		"Sakarya ve Zafer"
	)


func _add_sakarya_environment() -> void:
	"""Sakarya cevresel detaylar — savas bulutlari, speckles, sketch strip."""
	_add_decorative_speckles(
		Rect2(Vector2(240, 520), Vector2(1120, 1100)),
		Color(0.60, 0.20, 0.10, 0.07), 22
	)
	_add_sprite_prop(
		_textures.CLOUD_TEXTURE, Vector2(310, 250),
		Vector2(0.98, 0.98), Color(0.60, 0.50, 0.40, 0.18)
	)
	_add_sprite_prop(
		_textures.CLOUD_TEXTURE_ALT, Vector2(1240, 280),
		Vector2(0.88, 0.88), Color(0.50, 0.40, 0.30, 0.14)
	)

	# Sketch strip — battle grass
	_add_sketch_strip(
		_textures.SKETCH_GRASS_TEXTURE, Vector2(260, 360),
		8, Vector2(118, 0), Color(0.60, 0.50, 0.40, 0.70)
	)
	_add_sketch_strip(
		_textures.SKETCH_GRASS_TEXTURE, Vector2(320, 470),
		7, Vector2(118, 0), Color(0.55, 0.45, 0.35, 0.68)
	)
	_add_sketch_strip(
		_textures.SKETCH_GRASS_TEXTURE, Vector2(270, 1280),
		8, Vector2(118, 0), Color(0.55, 0.45, 0.35, 0.68)
	)

	# Sketch path tiles
	_add_sketch_tile(
		_textures.SKETCH_PATH_TEXTURE, Vector2(450, 1540),
		Color(0.70, 0.60, 0.50), Vector2(0.74, 0.74)
	)
	_add_sketch_tile(
		_textures.SKETCH_PATH_TEXTURE, Vector2(920, 1040),
		Color(0.70, 0.60, 0.50), Vector2(0.74, 0.74)
	)

	# Battlefield building debris
	_add_havza_building(
		Vector2(790, 560), 4,
		_textures.SKETCH_BUILDING_DOOR_TEXTURE,
		_textures.SKETCH_BUILDING_WINDOWS_TEXTURE,
		_textures.SKETCH_BUILDING_CENTER_TEXTURE,
		Color(0.60, 0.50, 0.40, 0.92)
	)
	_add_havza_building(
		Vector2(300, 680), 3,
		_textures.SKETCH_BUILDING_WINDOW_TEXTURE,
		_textures.SKETCH_BUILDING_WINDOW_TEXTURE,
		_textures.SKETCH_BUILDING_CENTER_TEXTURE,
		Color(0.55, 0.45, 0.35, 0.78)
	)
	_add_kenney_building(
		Vector2(930, 620), Vector2(1.02, 1.02),
		_textures.BLOCK_BUILDING_ROOF_RED_TEXTURE,
		Color(0.70, 0.50, 0.35, 0.58)
	)
	_add_kenney_building(
		Vector2(310, 790), Vector2(0.88, 0.88),
		_textures.BLOCK_BUILDING_ROOF_BLUE_TEXTURE,
		Color(0.50, 0.55, 0.60, 0.48)
	)


# ============================================================
# FINAL BUILDER — Cumhuriyet / Zafer (Events 28-30)
# ============================================================

func _build_final_world(world_root: Node) -> void:
	"""Final zafer / Cumhuriyet sahnesini paper cutout asset'lerle kur."""
	# Base background — dawn victory tones
	_add_final_paper_asset_layer(world_root)
	_add_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color(0.12, 0.08, 0.06))
	_add_rect(world_root, Vector2(80, 150), Vector2(1440, 1880), Color(0.20, 0.16, 0.10))
	_add_rect(world_root, Vector2(200, 300), Vector2(1200, 1500), Color(0.30, 0.24, 0.14))
	_add_rect(world_root, Vector2(300, 440), Vector2(1000, 340), Color(0.40, 0.32, 0.18), "Meydan Alani")
	_add_rect(world_root, Vector2(260, 960), Vector2(1080, 500), Color(0.36, 0.28, 0.16), "Kutlama Alani")
	_add_rect(world_root, Vector2(340, 1620), Vector2(920, 120), Color(0.50, 0.42, 0.26), "Zafer Yolu")
	_add_rect(world_root, Vector2(300, 440), Vector2(1000, 4), Color(0.90, 0.75, 0.30, 0.24), "hat_altin_1")
	_add_rect(world_root, Vector2(300, 780), Vector2(1000, 4), Color(0.90, 0.75, 0.30, 0.18), "hat_altin_2")
	_add_rect(world_root, Vector2(300, 1120), Vector2(1000, 4), Color(0.90, 0.75, 0.30, 0.14), "hat_altin_3")
	_add_soft_blob(world_root, Vector2(800, 1080), Vector2(740, 740), Color(0.90, 0.75, 0.30, 0.06))
	_add_soft_blob(world_root, Vector2(800, 1080), Vector2(900, 900), Color(0.80, 0.60, 0.20, 0.06))
	_decorate_final(world_root)


func _decorate_final(world_root: Node) -> void:
	"""Final dekorasyonu — zafer atmosferi, meclis, yol, landmarklar."""
	_add_final_toy_world_frame()
	_add_final_dawn_backdrop(world_root)
	_add_final_location_sign()
	_add_final_cumhuriyet_landmark()
	_add_final_path_ribbon()
	_add_final_light_pools(world_root)
	_add_final_victory_props()
	_add_final_environment()


# ============================================================
# FINAL YARDIMCI FONKSIYONLAR
# ============================================================

func _add_final_paper_asset_layer(world_root: Node) -> void:
	"""Final paper cutout asset'lerini diorama katmanina ekle."""
	# Sky — victory dawn
	_add_paper_cutout_asset(
		world_root, _textures.FINAL_PAPER_SKY_TEXTURE,
		Vector2(750, 360), Vector2(1.10, 1.10),
		Color(1, 1, 1, 0.92), -21, "final.depth.sky",
		Vector2.ZERO, -3.0
	)
	# Terrain — golden victory plains
	_add_paper_cutout_asset(
		world_root, _textures.FINAL_PAPER_TERRAIN_TEXTURE,
		Vector2(540, 1100), Vector2(0.82, 0.78),
		Color(1, 1, 1, 0.88), -14, "final.depth.terrain",
		Vector2.ZERO, -2.0
	)
	# Main path — victory path with star markers
	_add_paper_cutout_asset(
		world_root, _textures.FINAL_PAPER_MAIN_PATH_TEXTURE,
		Vector2(820, 980), Vector2(0.72, 0.72),
		Color(1, 1, 1, 0.86), -5, "final.path.main",
		Vector2.ZERO, -1.0
	)
	# Foreground frame — victory-themed edge ornaments
	_add_paper_cutout_asset(
		world_root, _textures.FINAL_PAPER_FOREGROUND_FRAME_TEXTURE,
		Vector2(800, 1850), Vector2(1.04, 0.70),
		Color(1, 1, 1, 0.72), 1, "final.foreground.frame",
		Vector2.ZERO, 1.0
	)
	# Cumhuriyet landmark — TBMM building with celebratory elements
	_add_paper_cutout_asset(
		world_root, _textures.FINAL_PAPER_CUMHURIYET_LANDMARK_TEXTURE,
		Vector2(360, 820), Vector2(0.60, 0.60),
		Color(1, 1, 1, 0.94), -4, "final.landmark.cumhuriyet",
		Vector2.ZERO, -1.5
	)
	# Victory arch — triumphal arch
	_add_paper_cutout_asset(
		world_root, _textures.FINAL_PAPER_VICTORY_ARCH_TEXTURE,
		Vector2(1040, 680), Vector2(0.50, 0.50),
		Color(1, 1, 1, 0.90), -3, "final.landmark.victory_arch",
		Vector2.ZERO, -1.2
	)


func _add_final_toy_world_frame() -> void:
	"""Final toy world frame — altin zafer tonlari."""
	_add_toy_world_frame(
		Color(0.35, 0.22, 0.08, 0.25),
		Color(0.90, 0.75, 0.30, 0.08)
	)


func _add_final_dawn_backdrop(world_root: Node) -> void:
	"""Final seher vakti arkaplani — sicak tepe siluetleri."""
	_add_backdrop_band(
		[_textures.BG_FLAT_MOUNTAIN_1_TEXTURE, _textures.BG_FLAT_POINTY_MOUNTAINS_TEXTURE, _textures.BG_FLAT_MOUNTAIN_2_TEXTURE],
		460.0, Vector2(1.00, 1.00),
		Color(0.50, 0.35, 0.18, 0.15), "final.horizon"
	)
	_add_distant_town_band(
		600.0,
		Color(0.55, 0.40, 0.22, 0.10), "final.distant_town"
	)


func _add_final_location_sign() -> void:
	"""Final lokasyon tabelasi."""
	_add_location_sign(
		"Cumhuriyet", "29 Ekim 1923",
		Vector2(556, 260), 480.0,
		Color(0.85, 0.70, 0.20, 0.82),
		"final.location_sign"
	)


func _add_final_cumhuriyet_landmark() -> void:
	"""Cumhuriyet landmark'i etrafinda atmosferik efektler."""
	var landmark_center := Vector2(360, 820)

	# Altin isilti
	_add_soft_blob(
		_cached_world_root, landmark_center + Vector2(0, 40),
		Vector2(220, 140), Color(0.90, 0.75, 0.30, 0.18),
		22, 0.08, false, -3
	)
	_add_soft_blob(
		_cached_world_root, landmark_center + Vector2(0, 20),
		Vector2(140, 100), Color(1.0, 0.85, 0.40, 0.12),
		18, 0.10, false, -2
	)

	# Bayrak isiltisi — kirmizi vurgu
	_add_soft_blob(
		_cached_world_root, landmark_center + Vector2(0, -120),
		Vector2(80, 80), Color(0.85, 0.20, 0.14, 0.12),
		16, 0.12, false, -1
	)


func _add_final_path_ribbon() -> void:
	"""Final ana yol ribbon'i — altin zafer rengi."""
	_add_path_ribbon(
		[
			Vector2(520, 1400),
			Vector2(680, 1120),
			Vector2(840, 980),
			Vector2(960, 860),
			Vector2(1080, 780),
		],
		32.0, Color(0.85, 0.70, 0.20, 0.24), -2
	)


func _add_final_light_pools(world_root: Node) -> void:
	"""Final isik havuzlari — meclis cevresi aydinlatma."""
	_add_light_pool(
		world_root, Vector2(360, 820),
		Vector2(320, 200), Color(0.90, 0.70, 0.20, 0.12)
	)
	_add_light_pool(
		world_root, Vector2(800, 1120),
		Vector2(360, 220), Color(0.85, 0.65, 0.18, 0.09)
	)
	_add_light_pool(
		world_root, Vector2(600, 1420),
		Vector2(280, 180), Color(0.80, 0.60, 0.15, 0.08)
	)


func _add_final_victory_props() -> void:
	"""Final zafer dekoratif prop'lari — kenney asset'leriyle."""
	# Kutlama barikatlari
	_add_kenney_prop(
		_textures.BLOCK_FENCE_SINGLE_TEXTURE, Vector2(710, 1086),
		Vector2(1.12, 1.12), Color(0.80, 0.70, 0.50, 0.82),
		true, "final.barrier_left"
	)
	_add_kenney_prop(
		_textures.BLOCK_FENCE_SINGLE_TEXTURE, Vector2(1008, 724),
		Vector2(1.08, 1.08), Color(0.80, 0.70, 0.50, 0.70),
		true, "final.barrier_right"
	)
	_add_kenney_prop(
		_textures.BLOCK_TREE_GREEN_TEXTURE, Vector2(1160, 1190),
		Vector2(0.96, 0.96), Color(0.40, 0.60, 0.35, 0.70),
		true, "final.celebration_tree"
	)
	_add_kenney_prop(
		_textures.BLOCK_BUSH_LARGE_TEXTURE, Vector2(250, 1180),
		Vector2(0.84, 0.84), Color(0.50, 0.50, 0.30, 0.56),
		true, "final.scrub_left"
	)
	_add_kenney_prop(
		_textures.BLOCK_BUSH_SMALL_TEXTURE, Vector2(480, 1210),
		Vector2(1.00, 1.00), Color(0.50, 0.55, 0.30, 0.60),
		true, "final.scrub_mid"
	)
	_add_kenney_prop(
		_textures.BLOCK_MARKET_STALL_RED_TEXTURE, Vector2(920, 1160),
		Vector2(1.00, 1.00), Color(0.80, 0.60, 0.40, 0.56),
		true, "final.celebration_stall"
	)

	# NPC'ler — kutlama yapan halk
	_add_kenney_npc(
		_textures.BLOCK_CHARACTER_MAN_TEXTURE, Vector2(650, 1210),
		Vector2(0.82, 0.82), Color(0.75, 0.70, 0.60, 0.56),
		"final.citizen_a", "kutla"
	)
	_add_kenney_npc(
		_textures.BLOCK_CHARACTER_WOMAN_TEXTURE, Vector2(798, 1218),
		Vector2(0.82, 0.82), Color(0.70, 0.75, 0.65, 0.56),
		"final.citizen_b", "kutla"
	)

	# Asset slot prop'lari
	_add_asset_slot_prop(
		"final.cumhuriyet_banner", Vector2(970, 622),
		Vector2(160, 120), Color(0.80, 0.70, 0.40, 0.86),
		Color(0.90, 0.75, 0.30, 0.42),
		"Cumhuriyet", true
	)
	_add_asset_slot_prop(
		"final.victory_bell", Vector2(370, 1470),
		Vector2(170, 98), Color(0.70, 0.60, 0.30, 0.86),
		Color(0.85, 0.65, 0.18, 0.38),
		"Zafer", true
	)
	_add_asset_slot_prop(
		"final.celebration_plaza", Vector2(625, 1048),
		Vector2(178, 104), Color(0.80, 0.65, 0.35, 0.62),
		Color(0.90, 0.75, 0.30, 0.45),
		"Meydan", true
	)

	# Strateji kartlari
	_add_strategy_card(
		_textures.BOARD_CARD_GREEN_TEXTURE, Vector2(860, 1040),
		Vector2(0.42, 0.42), Color(0.70, 0.85, 0.65, 0.76),
		"Zafer", "final.victory_card"
	)
	_add_strategy_token(
		_textures.BOARD_CHIP_GREEN_TEXTURE, Vector2(990, 672),
		Vector2(0.42, 0.42), Color(0.70, 0.85, 0.65, 0.84),
		"final.victory_token"
	)

	# Yon oklari
	_add_way_arrow(
		Vector2(900, 820), deg_to_rad(-52),
		Color(0.90, 0.75, 0.30, 0.72),
		"meclis", "final.to_meclis_arrow"
	)
	_add_way_arrow(
		Vector2(575, 1415), deg_to_rad(154),
		Color(0.85, 0.65, 0.18, 0.70),
		"kutlama", "final.to_celebration_arrow"
	)

	# Kesif rozeti
	_add_discovery_badge(
		_textures.GAME_STAR_TEXTURE, Vector2(720, 940),
		Color(0.90, 0.75, 0.30, 0.86),
		"cumhuriyet", "final.cumhuriyet_badge"
	)

	# Hikaye banner'i
	_add_story_banner(
		Vector2(510, 420), Vector2(480, 128),
		Color(0.80, 0.65, 0.30, 0.86),
		Color(0.50, 0.40, 0.18, 0.80),
		"Cumhuriyet ve Zafer"
	)


func _add_final_environment() -> void:
	"""Final cevresel detaylar — altin isiltilar, speckles, sketch strip."""
	_add_decorative_speckles(
		Rect2(Vector2(240, 520), Vector2(1120, 1100)),
		Color(0.90, 0.75, 0.30, 0.08), 22
	)
	_add_sprite_prop(
		_textures.CLOUD_TEXTURE, Vector2(310, 250),
		Vector2(0.98, 0.98), Color(0.90, 0.85, 0.70, 0.18)
	)
	_add_sprite_prop(
		_textures.CLOUD_TEXTURE_ALT, Vector2(1240, 280),
		Vector2(0.88, 0.88), Color(0.85, 0.80, 0.65, 0.14)
	)

	# Sketch strip — celebration grass
	_add_sketch_strip(
		_textures.SKETCH_GRASS_TEXTURE, Vector2(260, 360),
		8, Vector2(118, 0), Color(0.70, 0.60, 0.40, 0.70)
	)
	_add_sketch_strip(
		_textures.SKETCH_GRASS_TEXTURE, Vector2(320, 470),
		7, Vector2(118, 0), Color(0.65, 0.55, 0.35, 0.68)
	)
	_add_sketch_strip(
		_textures.SKETCH_GRASS_TEXTURE, Vector2(270, 1280),
		8, Vector2(118, 0), Color(0.65, 0.55, 0.35, 0.68)
	)

	# Sketch path tiles
	_add_sketch_tile(
		_textures.SKETCH_PATH_TEXTURE, Vector2(450, 1540),
		Color(0.75, 0.65, 0.45), Vector2(0.74, 0.74)
	)
	_add_sketch_tile(
		_textures.SKETCH_PATH_TEXTURE, Vector2(920, 1040),
		Color(0.75, 0.65, 0.45), Vector2(0.74, 0.74)
	)

	# Decorative buildings
	_add_kenney_building(
		Vector2(790, 560), Vector2(1.02, 1.02),
		_textures.BLOCK_BUILDING_ROOF_RED_TEXTURE,
		Color(0.80, 0.60, 0.40, 0.58)
	)
	_add_kenney_building(
		Vector2(310, 790), Vector2(0.88, 0.88),
		_textures.BLOCK_BUILDING_ROOF_BLUE_TEXTURE,
		Color(0.55, 0.60, 0.65, 0.48)
	)


# ============================================================
# SHIP DEKORASYON
# ============================================================

func _decorate_ship(world_root: Node) -> void:
	_add_toy_world_frame(Color(0.08, 0.24, 0.32, 0.22), Color(0.72, 0.88, 1.0, 0.09))
	_add_backdrop_band([_textures.BG_FLAT_MOUNTAIN_1_TEXTURE, _textures.BG_FLAT_MOUNTAIN_2_TEXTURE, _textures.BG_FLAT_POINTY_MOUNTAINS_TEXTURE], 540.0, Vector2(1.08, 1.08), Color(0.55, 0.86, 0.94, 0.17), "ship.horizon_mountains", -8)
	_add_location_sign("Bandırma", "Rotayı oku", Vector2(535, 280), 440.0, Color(_colors.POP_DEEP_TURQUOISE.r, _colors.POP_DEEP_TURQUOISE.g, _colors.POP_DEEP_TURQUOISE.b, 0.82), "ship.location_sign")
	_add_soft_blob(world_root, Vector2(1260, 350), Vector2(150, 150), Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.24), 24, 0.02, false, -6)
	_add_soft_blob(world_root, Vector2(1260, 350), Vector2(245, 190), Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.10), 24, 0.06, false, -7)
	_add_path_ribbon([Vector2(120, 920), Vector2(450, 900), Vector2(820, 910), Vector2(1460, 880)], 10.0, Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.16), -4)
	_add_light_pool(world_root, Vector2(830, 1260), Vector2(340, 140), Color(1.0, 0.78, 0.42, 0.13))
	_add_light_pool(world_root, Vector2(1160, 1300), Vector2(230, 460), Color(0.42, 0.76, 0.94, 0.12))
	_add_water_glints(Vector2(1090, 1120), 8, Vector2(12, 68), Color(0.78, 0.98, 1.0, 0.26))
	_add_rift_shard_cluster(Vector2(1210, 1120), 6, 160.0)
	_add_path_ribbon([Vector2(420, 650), Vector2(700, 860), Vector2(860, 1240), Vector2(1160, 1470)], 28.0, Color(0.92, 0.68, 0.38, 0.26), -1)
	_add_story_banner(Vector2(470, 910), Vector2(390, 126), Color(0.94, 0.86, 0.66, 0.84), Color(0.52, 0.34, 0.20, 0.82), "Rotayı oku, acele etme")
	_add_asset_slot_prop("ship.map_table", Vector2(690, 1170), Vector2(330, 154), Color(0.78, 0.56, 0.30, 0.92), Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.60), "Harita", true)
	_add_asset_slot_prop("ship.uniform_stand", Vector2(455, 535), Vector2(112, 154), Color(0.18, 0.32, 0.48, 0.88), Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.46), "", true)
	_add_asset_slot_prop("ship.compass", Vector2(1020, 1370), Vector2(128, 96), Color(_colors.POP_CREAM.r, _colors.POP_CREAM.g, _colors.POP_CREAM.b, 0.80), Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.64), "", true)
	_add_asset_slot_prop("ship.dock_glow", Vector2(1110, 1510), Vector2(180, 72), Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.20), Color(1.0, 1.0, 1.0, 0.18), "Samsun", true)
	_add_kenney_prop(_textures.BLOCK_TILE_WOOD_TEXTURE, Vector2(855, 1214), Vector2(1.60, 0.92), Color(1.0, 0.76, 0.46, 0.74), true, "ship.map_table_surface")
	_add_kenney_prop(_textures.BLOCK_BOX_TEXTURE, Vector2(420, 1460), Vector2(1.02, 1.02), Color(0.92, 0.76, 0.54, 0.70), true, "ship.deck_crate_left")
	_add_kenney_prop(_textures.BLOCK_BOX_WIDE_TEXTURE, Vector2(525, 1486), Vector2(1.05, 1.05), Color(0.96, 0.80, 0.58, 0.66), true, "ship.deck_crate_stack")
	_add_kenney_prop(_textures.BLOCK_CART_TOP_TEXTURE, Vector2(1016, 1380), Vector2(0.86, 0.86), Color(1.0, 0.90, 0.64, 0.74), true, "ship.compass_case")
	_add_kenney_prop(_textures.BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(380, 1120), Vector2(1.18, 1.18), Color(0.72, 0.92, 1.0, 0.34), true, "ship.rail_left")
	_add_kenney_prop(_textures.BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(1060, 1120), Vector2(1.18, 1.18), Color(0.72, 0.92, 1.0, 0.34), true, "ship.rail_right")
	_add_kenney_npc(_textures.BLOCK_CHARACTER_MAN_TEXTURE, Vector2(520, 1188), Vector2(0.92, 0.92), Color(0.92, 0.96, 1.0, 0.62), "ship.deck_helper", "rota")
	_add_kenney_npc(_textures.BLOCK_CHARACTER_WOMAN_TEXTURE, Vector2(1180, 1248), Vector2(0.86, 0.86), Color(0.90, 1.0, 0.96, 0.56), "ship.watch_helper", "liman")
	_add_strategy_card(_textures.BOARD_CARD_GREEN_TEXTURE, Vector2(730, 1130), Vector2(0.44, 0.44), Color(0.92, 1.0, 0.88, 0.76), "Harita", "ship.route_card")
	_add_strategy_token(_textures.BOARD_CHIP_BLUE_TEXTURE, Vector2(1114, 1390), Vector2(0.44, 0.44), Color(0.84, 0.98, 1.0, 0.80), "ship.navigation_token")
	_add_decorative_speckles(Rect2(Vector2(250, 420), Vector2(1040, 1140)), Color(1.0, 0.86, 0.55, 0.06), 20)
	_add_sprite_prop(_textures.CLOUD_TEXTURE, Vector2(300, 150), Vector2(0.96, 0.96), Color(1, 1, 1, 0.22))
	_add_sprite_prop(_textures.CLOUD_TEXTURE_ALT, Vector2(1220, 170), Vector2(0.88, 0.88), Color(1, 1, 1, 0.22))
	_add_sprite_prop(_textures.CLOUD_TEXTURE, Vector2(840, 120), Vector2(0.74, 0.74), Color(1, 1, 1, 0.18))
	_add_rect(world_root, Vector2(1030, 1015), Vector2(120, 600), Color(0.08, 0.28, 0.36))
	_add_rect(world_root, Vector2(1180, 1015), Vector2(105, 600), Color(0.10, 0.31, 0.40))
	_add_rect(world_root, Vector2(270, 1090), Vector2(980, 52), Color(0.58, 0.44, 0.30))
	_add_rect(world_root, Vector2(270, 1230), Vector2(980, 52), Color(0.58, 0.44, 0.30))
	_add_rect(world_root, Vector2(270, 1370), Vector2(980, 52), Color(0.58, 0.44, 0.30))
	_add_ship_planks(Vector2(360, 1094), 8, 102.0, Color(1, 1, 1, 0.42), Vector2(0.62, 0.62))
	_add_ship_planks(Vector2(360, 1234), 8, 102.0, Color(1, 1, 1, 0.42), Vector2(0.62, 0.62))
	_add_ship_planks(Vector2(360, 1374), 8, 102.0, Color(1, 1, 1, 0.42), Vector2(0.62, 0.62))
	_add_sprite_prop(_textures.SHIP_HULL_TEXTURE, Vector2(680, 1500), Vector2(1.30, 1.30), Color(1, 1, 1, 0.30))
	_add_sprite_prop(_textures.SHIP_HULL_ALT_TEXTURE, Vector2(950, 1515), Vector2(1.18, 1.18), Color(1, 1, 1, 0.26))
	_add_sprite_prop(_textures.SHIP_MAST_TEXTURE, Vector2(820, 900), Vector2(1.26, 1.26), Color(1, 1, 1, 0.42), true)
	_add_sprite_prop(_textures.SHIP_MAST_TEXTURE, Vector2(1040, 980), Vector2(0.92, 0.92), Color(1, 1, 1, 0.34), true)
	_add_sprite_prop(_textures.SHIP_SAIL_TEXTURE, Vector2(885, 840), Vector2(0.92, 0.92), Color(1, 1, 1, 0.30), true)
	_add_sprite_prop(_textures.SHIP_SMALL_SAIL_TEXTURE, Vector2(1080, 980), Vector2(0.72, 0.72), Color(1, 1, 1, 0.28), true)
	_add_sprite_prop(_textures.SHIP_FLAG_TEXTURE, Vector2(905, 610), Vector2(0.78, 0.78), Color(1, 1, 1, 0.88), true)
	_add_sprite_prop(_textures.SHIP_FLAG_ALT_TEXTURE, Vector2(1090, 760), Vector2(0.62, 0.62), Color(1, 1, 1, 0.78), true)
	_add_crimson_flag(Vector2(960, 650), 0.86, true)
	_add_crimson_flag(Vector2(1160, 820), 0.64, true)
	_add_sprite_prop(_textures.SHIP_NEST_TEXTURE, Vector2(820, 720), Vector2(0.78, 0.78), Color(1, 1, 1, 0.45), true)
	_add_sprite_prop(_textures.SHIP_CANNON_TEXTURE, Vector2(1140, 1320), Vector2(0.70, 0.70), Color(1, 1, 1, 0.72), true)
	_add_sprite_prop(_textures.SHIP_CANNON_TEXTURE, Vector2(420, 1330), Vector2(-0.66, 0.66), Color(1, 1, 1, 0.54), true)
	_add_sprite_prop(_textures.SHIP_CREW_TEXTURE, Vector2(1180, 980), Vector2(0.72, 0.72), Color(1, 1, 1, 0.38), true)
	_add_sprite_prop(_textures.SHIP_CREW_ALT_TEXTURE, Vector2(540, 1110), Vector2(0.60, 0.60), Color(1, 1, 1, 0.34), true)
	_add_sprite_prop(_textures.SMOKE_TEXTURE, Vector2(1010, 450), Vector2(0.78, 0.78), Color(0.85, 0.92, 1.0, 0.22))
	_add_sprite_prop(_textures.SMOKE_TEXTURE, Vector2(1180, 1460), Vector2(0.56, 0.56), Color(0.88, 0.94, 1.0, 0.18))
	_add_mote_cluster(Vector2(1140, 1160), Color(0.78, 0.92, 1.0, 0.14), 6)


# ============================================================
# SAMSUN RIFT DEKORASYON
# ============================================================

func _decorate_samsun_diorama_pilot(world_root: Node) -> void:
	_add_backdrop_band([_textures.BG_FLAT_HILLS_1_TEXTURE, _textures.BG_FLAT_MOUNTAIN_1_TEXTURE, _textures.BG_FLAT_HILLS_2_TEXTURE], 430.0, Vector2(1.02, 1.02), Color(0.58, 0.92, 1.0, 0.17), "samsun.diorama_horizon", -7)
	_add_distant_town_band(590.0, Color(0.96, 0.94, 0.78, 0.16), "samsun.diorama_town")
	_add_location_sign("Samsun", "Patikayı izle", Vector2(556, 300), 488.0, Color(_colors.POP_DEEP_TURQUOISE.r, _colors.POP_DEEP_TURQUOISE.g, _colors.POP_DEEP_TURQUOISE.b, 0.78), "samsun.location_sign")

	_add_samsun_paper_asset_layer()
	_add_samsun_atmosphere_washes()
	_add_samsun_light_pools()
	_add_samsun_landmark_pads()
	_add_samsun_path_ribbon()
	_add_samsun_support_paths()
	_add_samsun_discovery_spots()
	_add_samsun_wave_gate()
	_add_samsun_environment_clusters()
	_add_samsun_harbor_identity()
	_add_samsun_node_identity_details()
	_add_samsun_node_shadow(Vector2(800, 1000), Vector2(170, 46), "fx.rift_core_shadow")
	_add_rift_shard_cluster(Vector2(800, 1000), 6, 210.0)

	_add_samsun_node_shadow(Vector2(360, 820), Vector2(140, 38), "samsun.harbor_node_shadow")
	_add_samsun_node_shadow(Vector2(1190, 820), Vector2(140, 38), "samsun.telegraph_node_shadow")
	_add_samsun_node_shadow(Vector2(530, 1500), Vector2(150, 42), "samsun.people_node_shadow")

	_add_asset_slot_prop("interactables.companion_reaction_spot", Vector2(730, 1160), Vector2(150, 86), Color(1.0, 0.90, 0.62, 0.34), Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.30), "Fark et", true)

	_add_mote_cluster(Vector2(800, 1000), Color(0.72, 0.92, 1.0, 0.14), 6)
	_add_decorative_speckles(Rect2(Vector2(250, 520), Vector2(1080, 1120)), Color(1.0, 0.92, 0.58, 0.045), 14)
	_add_sprite_prop(_textures.CLOUD_TEXTURE, Vector2(320, 260), Vector2(1.00, 1.00), Color(0.96, 0.86, 1.0, 0.15))
	_add_sprite_prop(_textures.CLOUD_TEXTURE_ALT, Vector2(1260, 340), Vector2(0.92, 0.92), Color(0.72, 0.98, 1.0, 0.12))
	_add_samsun_foreground_silhouettes()

	# Harbor landmark — başlangıç noktası (POP_GOLD)
	_add_soft_blob(_cached_world_root, Vector2(360, 760), Vector2(100, 60), _colors.POP_GOLD, 20, 0.0, false, -2)
	# Telegraph landmark — durak noktası (RIFT_BLUE)
	_add_soft_blob(_cached_world_root, Vector2(1190, 770), Vector2(100, 60), _colors.RIFT_BLUE, 20, 0.0, false, -2)
	# People plaza — görev noktası (POP_CRIMSON)
	_add_soft_blob(_cached_world_root, Vector2(530, 1455), Vector2(110, 65), _colors.POP_CRIMSON, 20, 0.0, false, -2)


func _decorate_samsun_rift(world_root: Node) -> void:
	_decorate_samsun_diorama_pilot(world_root)
	# Rift core ışıltısı — paper_rift_core.svg konumu (800, 980), statik glow
	_add_soft_blob(_cached_world_root, Vector2(800, 980), Vector2(120, 80), _colors.RIFT_BLUE, 20, 0.0, false, -2)


# ============================================================
# HAVZA DEKORASYON
# ============================================================

func _decorate_havza(world_root: Node) -> void:
	_add_toy_world_frame(Color(0.34, 0.48, 0.25, 0.22), Color(0.96, 0.82, 0.42, 0.09))
	_add_backdrop_band([_textures.BG_FLAT_HILLS_1_TEXTURE, _textures.BG_FLAT_HILLS_2_TEXTURE, _textures.BG_FLAT_MOUNTAIN_2_TEXTURE], 500.0, Vector2(1.00, 1.00), Color(0.82, 0.98, 0.64, 0.16), "havza.horizon")
	_add_distant_town_band(640.0, Color(0.98, 0.92, 0.72, 0.16), "havza.distant_town")
	_add_location_sign("Havza", "Ortak ses kur", Vector2(550, 300), 460.0, Color(0.56, 0.72, 0.32, 0.82), "havza.location_sign")
	_add_soft_blob(world_root, Vector2(780, 1120), Vector2(410, 260), Color(0.50, 0.62, 0.32, 0.20), 20, 0.10)
	_add_rift_shard_cluster(Vector2(1160, 1480), 5, 140.0)
	_add_path_ribbon([Vector2(520, 1400), Vector2(700, 1120), Vector2(970, 980), Vector2(1080, 860)], 36.0, Color(0.92, 0.74, 0.42, 0.28), -1)
	_add_breadcrumb_trail([Vector2(520, 1400), Vector2(700, 1120), Vector2(970, 980), Vector2(1080, 860)], _textures.BOARD_CHIP_GREEN_TEXTURE, Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.80), "havza.breadcrumb", 150.0, 0.50)
	_add_light_pool(world_root, Vector2(700, 1120), Vector2(290, 180), Color(1.0, 0.86, 0.40, 0.11))
	_add_story_banner(Vector2(510, 420), Vector2(420, 128), Color(0.96, 0.92, 0.70, 0.86), Color(0.56, 0.72, 0.32, 0.80), "Ortak ses kur")
	_add_asset_slot_prop("havza.notice_board", Vector2(970, 622), Vector2(150, 118), Color(0.96, 0.88, 0.62, 0.86), Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.42), "Genelge", true)
	_add_asset_slot_prop("havza.telegraph_table", Vector2(370, 1470), Vector2(170, 98), Color(0.80, 0.62, 0.36, 0.86), Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.38), "Telgraf", true)
	_add_asset_slot_prop("havza.town_square", Vector2(625, 1048), Vector2(178, 104), Color(0.96, 0.82, 0.48, 0.62), Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.45), "Meydan", true)
	_add_kenney_prop(_textures.BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(1008, 724), Vector2(1.08, 1.08), Color(1.0, 0.88, 0.62, 0.70), true, "havza.notice_board_legs")
	_add_kenney_prop(_textures.BLOCK_TILE_WOOD_TEXTURE, Vector2(452, 1510), Vector2(1.05, 0.82), Color(1.0, 0.80, 0.54, 0.74), true, "havza.telegraph_table_surface")
	_add_kenney_prop(_textures.BLOCK_MARKET_STALL_BLUE_TEXTURE, Vector2(710, 1086), Vector2(1.12, 1.12), Color(0.90, 1.0, 1.0, 0.82), true, "havza.square_stall")
	_add_kenney_prop(_textures.BLOCK_CART_TEXTURE, Vector2(560, 1200), Vector2(0.90, 0.90), Color(0.96, 0.82, 0.62, 0.70), true, "havza.square_cart")
	_add_kenney_prop(_textures.BLOCK_FENCE_SINGLE_TEXTURE, Vector2(868, 1210), Vector2(1.05, 1.05), Color(0.90, 0.96, 1.0, 0.52), true, "havza.square_fence")
	_add_strategy_card(_textures.BOARD_CARD_GREEN_TEXTURE, Vector2(860, 1040), Vector2(0.42, 0.42), Color(0.90, 1.0, 0.86, 0.76), "Ses", "havza.voice_card")
	_add_strategy_token(_textures.BOARD_CHIP_GREEN_TEXTURE, Vector2(990, 672), Vector2(0.42, 0.42), Color(0.86, 1.0, 0.76, 0.84), "havza.notice_token")
	_add_kenney_npc(_textures.BLOCK_CHARACTER_MAN_TEXTURE, Vector2(650, 1210), Vector2(0.82, 0.82), Color(0.96, 0.94, 0.86, 0.56), "havza.citizen_a", "oku")
	_add_kenney_npc(_textures.BLOCK_CHARACTER_WOMAN_TEXTURE, Vector2(798, 1218), Vector2(0.82, 0.82), Color(0.96, 1.0, 0.94, 0.56), "havza.citizen_b", "paylaş")
	_add_kenney_npc(_textures.BLOCK_CHARACTER_HORSE_TEXTURE, Vector2(470, 1280), Vector2(0.78, 0.78), Color(1.0, 0.92, 0.76, 0.42), "havza.carrier_horse", "")
	_add_way_arrow(Vector2(900, 820), deg_to_rad(-52), Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.72), "genelge", "havza.to_notice_arrow")
	_add_way_arrow(Vector2(575, 1415), deg_to_rad(154), Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.70), "telgraf", "havza.to_telegraph_arrow")
	_add_discovery_badge(_textures.GAME_INFO_TEXTURE, Vector2(720, 940), Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.86), "meydan", "havza.square_badge")
	_add_decorative_speckles(Rect2(Vector2(240, 520), Vector2(1120, 1100)), Color(1.0, 0.92, 0.54, 0.07), 22)
	_add_sprite_prop(_textures.CLOUD_TEXTURE, Vector2(310, 250), Vector2(0.98, 0.98), Color(1, 1, 1, 0.18))
	_add_sprite_prop(_textures.CLOUD_TEXTURE_ALT, Vector2(1240, 280), Vector2(0.88, 0.88), Color(1, 1, 1, 0.14))
	_add_sketch_strip(_textures.SKETCH_GRASS_TEXTURE, Vector2(260, 360), 8, Vector2(118, 0), Color(1, 1, 1, 0.70))
	_add_sketch_strip(_textures.SKETCH_GRASS_TEXTURE, Vector2(320, 470), 7, Vector2(118, 0), Color(1, 1, 1, 0.68))
	_add_sketch_strip(_textures.SKETCH_GRASS_TEXTURE, Vector2(270, 1280), 8, Vector2(118, 0), Color(1, 1, 1, 0.68))
	_add_sketch_strip(_textures.SKETCH_GRASS_TEXTURE, Vector2(340, 1380), 7, Vector2(118, 0), Color(1, 1, 1, 0.66))
	_add_sketch_strip(_textures.SKETCH_PATH_TEXTURE, Vector2(450, 1540), 6, Vector2(84, -82), Color(1, 1, 1, 0.95), Vector2(0.74, 0.74))
	_add_sketch_strip(_textures.SKETCH_PATH_TEXTURE, Vector2(920, 1040), 3, Vector2(0, -102), Color(1, 1, 1, 0.95), Vector2(0.74, 0.74))
	_add_sketch_tile(_textures.SKETCH_PATH_CROSS_TEXTURE, Vector2(960, 920), Color.WHITE, Vector2(0.82, 0.82))
	_add_sketch_tile(_textures.SKETCH_PATH_CORNER_TEXTURE, Vector2(780, 1120), Color.WHITE, Vector2(0.74, 0.74))
	_add_sketch_tile(_textures.SKETCH_PATH_END_TEXTURE, Vector2(1080, 720), Color.WHITE, Vector2(0.74, 0.74))
	_add_sketch_tile(_textures.SKETCH_RIVER_TEXTURE, Vector2(330, 1500), Color(0.92, 1.0, 1.0, 0.88), Vector2(0.78, 0.78))
	_add_sketch_tile(_textures.SKETCH_RIVER_TEXTURE, Vector2(260, 1588), Color(0.92, 1.0, 1.0, 0.88), Vector2(0.78, 0.78))
	_add_sketch_tile(_textures.SKETCH_RIVER_BEND_TEXTURE, Vector2(398, 1676), Color(0.92, 1.0, 1.0, 0.88), Vector2(0.78, 0.78))
	_add_sketch_tile(_textures.SKETCH_RIVER_BRIDGE_TEXTURE, Vector2(520, 1424), Color.WHITE, Vector2(0.78, 0.78))
	_add_havza_building(Vector2(790, 560), 4, _textures.SKETCH_BUILDING_DOOR_TEXTURE, _textures.SKETCH_BUILDING_WINDOWS_TEXTURE, _textures.SKETCH_BUILDING_CENTER_TEXTURE, Color(1, 1, 1, 0.92))
	_add_havza_building(Vector2(300, 680), 3, _textures.SKETCH_BUILDING_WINDOW_TEXTURE, _textures.SKETCH_BUILDING_WINDOW_TEXTURE, _textures.SKETCH_BUILDING_CENTER_TEXTURE, Color(1, 1, 1, 0.78))
	_add_havza_building(Vector2(1120, 760), 2, _textures.SKETCH_BUILDING_DOOR_TEXTURE, _textures.SKETCH_BUILDING_WINDOW_TEXTURE, _textures.SKETCH_BUILDING_CENTER_TEXTURE, Color(1, 1, 1, 0.74))
	_add_kenney_building(Vector2(930, 620), Vector2(1.02, 1.02), _textures.BLOCK_BUILDING_ROOF_RED_TEXTURE, Color(1.0, 0.94, 0.78, 0.58))
	_add_kenney_building(Vector2(310, 790), Vector2(0.88, 0.88), _textures.BLOCK_BUILDING_ROOF_BLUE_TEXTURE, Color(0.94, 1.0, 1.0, 0.48))
	_add_kenney_prop(_textures.BLOCK_TREE_GREEN_TEXTURE, Vector2(1160, 1190), Vector2(0.96, 0.96), Color(0.86, 1.0, 0.74, 0.70), true, "havza.square_tree")
	_add_kenney_prop(_textures.BLOCK_TREE_ORANGE_TEXTURE, Vector2(250, 1180), Vector2(0.84, 0.84), Color(1.0, 0.90, 0.56, 0.56), true, "havza.warm_tree")
	_add_sprite_prop(_textures.HOUSE_TEXTURE, Vector2(350, 640), Vector2(0.82, 0.82), Color(1, 1, 1, 0.22))
	_add_sprite_prop(_textures.HOUSE_TEXTURE_ALT, Vector2(1190, 620), Vector2(0.92, 0.92), Color(1, 1, 1, 0.18))
	_add_crimson_flag(Vector2(1110, 700), 0.54, true)
	_add_sprite_prop(_textures.TREE_TEXTURE, Vector2(1040, 1220), Vector2(0.82, 0.82), Color(0.96, 1.0, 0.92, 0.50), true)
	_add_sprite_prop(_textures.TREE_TEXTURE_ALT, Vector2(260, 1290), Vector2(0.74, 0.74), Color(0.96, 1.0, 0.92, 0.46), true)
	_add_sprite_prop(_textures.TREE_TEXTURE_ALT, Vector2(1320, 1360), Vector2(0.70, 0.70), Color(0.96, 1.0, 0.92, 0.42), true)
	_add_sprite_prop(_textures.FENCE_TEXTURE, Vector2(790, 1340), Vector2(1.18, 1.18), Color(1, 1, 1, 0.26))
	_add_sprite_prop(_textures.FENCE_TEXTURE, Vector2(610, 1000), Vector2(0.92, 0.92), Color(1, 1, 1, 0.34))
	_add_sprite_prop(_textures.FENCE_TEXTURE, Vector2(1110, 1000), Vector2(0.92, 0.92), Color(1, 1, 1, 0.34))
	_add_sprite_prop(_textures.SHIP_CREW_TEXTURE, Vector2(680, 1080), Vector2(0.50, 0.50), Color(1, 1, 1, 0.30), true)
	_add_sprite_prop(_textures.SHIP_CREW_TEXTURE, Vector2(890, 1160), Vector2(0.46, 0.46), Color(1, 1, 1, 0.26), true)
	_add_mote_cluster(Vector2(780, 1100), Color(0.96, 0.86, 0.44, 0.13), 6)


# ============================================================
# AMASYA DEKORASYON
# ============================================================

func _decorate_amasya(world_root: Node) -> void:
	_add_toy_world_frame(Color(0.42, 0.34, 0.42, 0.20), Color(0.92, 0.78, 1.0, 0.08))
	_add_backdrop_band([_textures.BG_FLAT_MOUNTAIN_1_TEXTURE, _textures.BG_FLAT_POINTY_MOUNTAINS_TEXTURE, _textures.BG_FLAT_MOUNTAIN_2_TEXTURE], 490.0, Vector2(1.02, 1.02), Color(0.86, 0.82, 1.0, 0.16), "amasya.horizon")
	_add_distant_town_band(650.0, Color(1.0, 0.90, 0.74, 0.14), "amasya.distant_town")
	_add_location_sign("Amasya", "Kararı anla", Vector2(555, 300), 460.0, Color(0.58, 0.42, 0.28, 0.82), "amasya.location_sign")
	_add_soft_blob(world_root, Vector2(800, 1240), Vector2(420, 260), Color(0.44, 0.36, 0.30, 0.18), 20, 0.08)
	_add_rift_shard_cluster(Vector2(1240, 1460), 5, 140.0)
	_add_path_ribbon([Vector2(620, 1500), Vector2(800, 1450), Vector2(980, 1180), Vector2(860, 980), Vector2(620, 620)], 34.0, Color(0.94, 0.78, 0.44, 0.28), -1)
	_add_breadcrumb_trail([Vector2(620, 1500), Vector2(800, 1450), Vector2(980, 1180), Vector2(860, 980), Vector2(620, 620)], _textures.BOARD_CHIP_RED_TEXTURE, Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.78), "amasya.breadcrumb", 150.0, 0.50)
	_add_light_pool(world_root, Vector2(800, 1180), Vector2(300, 190), Color(1.0, 0.78, 0.44, 0.11))
	_add_story_banner(Vector2(520, 820), Vector2(430, 128), Color(0.95, 0.88, 0.72, 0.86), Color(0.58, 0.42, 0.28, 0.82), "Milletin kararı")
	_add_asset_slot_prop("amasya.meeting_table", Vector2(570, 1070), Vector2(220, 110), Color(0.74, 0.50, 0.30, 0.86), Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.44), "Toplantı", true)
	_add_asset_slot_prop("amasya.statement_draft", Vector2(920, 1125), Vector2(154, 96), Color(0.98, 0.92, 0.74, 0.88), Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.36), "Bildiri", true)
	_add_asset_slot_prop("amasya.river_marker", Vector2(306, 1580), Vector2(220, 70), Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.18), Color(1.0, 1.0, 1.0, 0.18), "", true)
	_add_kenney_prop(_textures.BLOCK_TILE_WOOD_TEXTURE, Vector2(682, 1122), Vector2(1.32, 0.86), Color(1.0, 0.76, 0.48, 0.76), true, "amasya.meeting_table_surface")
	_add_kenney_prop(_textures.BLOCK_BOX_WIDE_TEXTURE, Vector2(958, 1160), Vector2(0.86, 0.86), Color(1.0, 0.92, 0.72, 0.74), true, "amasya.statement_stack")
	_add_kenney_prop(_textures.BLOCK_TILE_WATER_TEXTURE, Vector2(386, 1606), Vector2(1.48, 1.12), Color(0.60, 0.98, 1.0, 0.72), true, "amasya.river_water")
	_add_kenney_prop(_textures.BLOCK_TILE_BRIDGE_TEXTURE, Vector2(520, 1560), Vector2(1.05, 1.05), Color(1.0, 0.86, 0.58, 0.78), true, "amasya.river_bridge")
	_add_kenney_prop(_textures.BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(650, 1235), Vector2(1.08, 1.08), Color(1.0, 0.88, 0.70, 0.46), true, "amasya.meeting_fence")
	_add_strategy_card(_textures.BOARD_CARD_RED_TEXTURE, Vector2(1050, 1100), Vector2(0.42, 0.42), Color(1.0, 0.88, 0.76, 0.76), "Bildiri", "amasya.statement_card")
	_add_strategy_token(_textures.BOARD_CHIP_BLUE_TEXTURE, Vector2(428, 1575), Vector2(0.42, 0.42), Color(0.82, 0.98, 1.0, 0.80), "amasya.river_token")
	_add_kenney_npc(_textures.BLOCK_CHARACTER_MAN_TEXTURE, Vector2(590, 1220), Vector2(0.82, 0.82), Color(0.98, 0.94, 0.86, 0.46), "amasya.delegate_a", "görüş")
	_add_kenney_npc(_textures.BLOCK_CHARACTER_WOMAN_TEXTURE, Vector2(980, 1265), Vector2(0.80, 0.80), Color(0.96, 1.0, 0.96, 0.44), "amasya.delegate_b", "not")
	_add_way_arrow(Vector2(725, 980), deg_to_rad(78), Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.72), "toplantı", "amasya.to_meeting_arrow")
	_add_way_arrow(Vector2(900, 1495), deg_to_rad(-24), Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.68), "bildiri", "amasya.to_statement_arrow")
	_add_discovery_badge(_textures.GAME_CHECK_TEXTURE, Vector2(825, 1310), Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.84), "karar", "amasya.decision_badge")
	_add_decorative_speckles(Rect2(Vector2(260, 520), Vector2(1100, 1140)), Color(1.0, 0.84, 0.48, 0.06), 20)
	_add_sprite_prop(_textures.CLOUD_TEXTURE, Vector2(280, 210), Vector2(0.92, 0.92), Color(1, 1, 1, 0.16))
	_add_sprite_prop(_textures.CLOUD_TEXTURE_ALT, Vector2(1240, 250), Vector2(0.82, 0.82), Color(1, 1, 1, 0.12))
	_add_sketch_strip(_textures.SKETCH_PATH_TEXTURE, Vector2(420, 1700), 6, Vector2(94, 0), Color(1, 1, 1, 0.96), Vector2(0.78, 0.78))
	_add_sketch_tile(_textures.SKETCH_PATH_CROSS_TEXTURE, Vector2(800, 1450), Color.WHITE, Vector2(0.82, 0.82))
	_add_sketch_tile(_textures.SKETCH_PATH_END_TEXTURE, Vector2(1090, 1180), Color.WHITE, Vector2(0.76, 0.76))
	_add_havza_building(Vector2(360, 540), 5, _textures.SKETCH_BUILDING_DOOR_TEXTURE, _textures.SKETCH_BUILDING_WINDOWS_TEXTURE, _textures.SKETCH_BUILDING_CENTER_TEXTURE, Color(1, 1, 1, 0.88))
	_add_havza_building(Vector2(980, 620), 2, _textures.SKETCH_BUILDING_WINDOW_TEXTURE, _textures.SKETCH_BUILDING_WINDOW_TEXTURE, _textures.SKETCH_BUILDING_CENTER_TEXTURE, Color(1, 1, 1, 0.72))
	_add_kenney_building(Vector2(1130, 720), Vector2(0.92, 0.92), _textures.BLOCK_BUILDING_ROOF_RED_TEXTURE, Color(1.0, 0.94, 0.82, 0.48))
	_add_sprite_prop(_textures.HOUSE_TEXTURE, Vector2(1180, 590), Vector2(0.86, 0.86), Color(1, 1, 1, 0.18))
	_add_crimson_flag(Vector2(1010, 760), 0.50, true)
	_add_sprite_prop(_textures.TREE_TEXTURE, Vector2(260, 1260), Vector2(0.86, 0.86), Color(0.96, 1.0, 0.92, 0.34), true)
	_add_sprite_prop(_textures.TREE_TEXTURE_ALT, Vector2(1340, 1290), Vector2(0.80, 0.80), Color(0.96, 1.0, 0.92, 0.30), true)
	_add_sprite_prop(_textures.FENCE_TEXTURE, Vector2(790, 870), Vector2(1.04, 1.04), Color(1, 1, 1, 0.28))
	_add_sprite_prop(_textures.FENCE_TEXTURE, Vector2(790, 1600), Vector2(1.12, 1.12), Color(1, 1, 1, 0.24))
	_add_sprite_prop(_textures.SHIP_CREW_ALT_TEXTURE, Vector2(620, 1160), Vector2(0.48, 0.48), Color(1, 1, 1, 0.22), true)
	_add_sprite_prop(_textures.SHIP_CREW_TEXTURE, Vector2(980, 1220), Vector2(0.44, 0.44), Color(1, 1, 1, 0.20), true)
	_add_mote_cluster(Vector2(820, 1180), Color(0.96, 0.76, 0.42, 0.13), 6)


# ============================================================
# KONGRELER DEKORASYON
# ============================================================

func _decorate_kongreler(world_root: Node) -> void:
	_add_toy_world_frame(Color(0.48, 0.34, 0.26, 0.20), Color(0.98, 0.74, 0.44, 0.08))
	_add_backdrop_band([_textures.BG_FLAT_HILLS_2_TEXTURE, _textures.BG_FLAT_MOUNTAIN_2_TEXTURE, _textures.BG_FLAT_HILLS_1_TEXTURE], 500.0, Vector2(1.00, 1.00), Color(1.0, 0.78, 0.54, 0.14), "kongre.horizon")
	_add_distant_town_band(660.0, Color(1.0, 0.88, 0.66, 0.14), "kongre.distant_town")
	_add_location_sign("Kongreler", "Birlikte güçlen", Vector2(530, 292), 520.0, Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.74), "kongre.location_sign")
	_add_soft_blob(world_root, Vector2(800, 1180), Vector2(440, 280), Color(0.52, 0.40, 0.28, 0.18), 20, 0.08)
	_add_rift_shard_cluster(Vector2(1240, 1460), 5, 140.0)
	_add_path_ribbon([Vector2(620, 1500), Vector2(780, 1220), Vector2(860, 980), Vector2(980, 1500)], 34.0, Color(0.96, 0.70, 0.38, 0.26), -1)
	_add_breadcrumb_trail([Vector2(620, 1500), Vector2(780, 1220), Vector2(860, 980), Vector2(980, 1500)], _textures.BOARD_CHIP_RED_TEXTURE, Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.76), "kongre.breadcrumb", 150.0, 0.50)
	_add_light_pool(world_root, Vector2(820, 1160), Vector2(320, 200), Color(1.0, 0.74, 0.38, 0.10))
	_add_story_banner(Vector2(510, 790), Vector2(430, 128), Color(0.96, 0.86, 0.68, 0.86), Color(0.72, 0.44, 0.26, 0.82), "Birlikte güçlen")
	_add_asset_slot_prop("kongre.delegate_table", Vector2(560, 1080), Vector2(220, 110), Color(0.72, 0.48, 0.28, 0.86), Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.42), "Temsil", true)
	_add_asset_slot_prop("kongre.unity_stage", Vector2(900, 1030), Vector2(176, 128), Color(0.86, 0.54, 0.30, 0.76), Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.46), "Birlik", true)
	_add_asset_slot_prop("kongre.shared_goal_banner", Vector2(610, 560), Vector2(270, 84), Color(0.98, 0.88, 0.62, 0.78), Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.40), "Ortak Hedef", true)
	_add_kenney_prop(_textures.BLOCK_TILE_WOOD_TEXTURE, Vector2(672, 1130), Vector2(1.36, 0.86), Color(1.0, 0.74, 0.44, 0.74), true, "kongre.delegate_table_surface")
	_add_kenney_prop(_textures.BLOCK_MARKET_STALL_RED_TEXTURE, Vector2(982, 1094), Vector2(1.08, 1.08), Color(1.0, 0.82, 0.60, 0.78), true, "kongre.unity_stage_canopy")
	_add_kenney_prop(_textures.BLOCK_BOX_WIDE_TEXTURE, Vector2(760, 610), Vector2(0.98, 0.98), Color(1.0, 0.90, 0.64, 0.72), true, "kongre.banner_base")
	_add_kenney_prop(_textures.BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(560, 1270), Vector2(1.08, 1.08), Color(1.0, 0.88, 0.64, 0.42), true, "kongre.front_fence_left")
	_add_kenney_prop(_textures.BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(980, 1270), Vector2(1.08, 1.08), Color(1.0, 0.88, 0.64, 0.42), true, "kongre.front_fence_right")
	_add_strategy_card(_textures.BOARD_CARD_GREEN_TEXTURE, Vector2(650, 1018), Vector2(0.42, 0.42), Color(0.90, 1.0, 0.86, 0.76), "Temsil", "kongre.delegate_card")
	_add_strategy_card(_textures.BOARD_CARD_RED_TEXTURE, Vector2(940, 985), Vector2(0.42, 0.42), Color(1.0, 0.88, 0.76, 0.76), "Birlik", "kongre.unity_card")
	_add_strategy_token(_textures.BOARD_CHIP_GREEN_TEXTURE, Vector2(830, 1150), Vector2(0.44, 0.44), Color(0.90, 1.0, 0.76, 0.84), "kongre.shared_goal_token")
	_add_kenney_npc(_textures.BLOCK_CHARACTER_MAN_TEXTURE, Vector2(605, 1230), Vector2(0.80, 0.80), Color(0.98, 0.94, 0.86, 0.40), "kongre.delegate_a", "temsil")
	_add_kenney_npc(_textures.BLOCK_CHARACTER_WOMAN_TEXTURE, Vector2(1025, 1230), Vector2(0.80, 0.80), Color(0.96, 1.0, 0.94, 0.40), "kongre.delegate_b", "birlik")
	_add_way_arrow(Vector2(770, 930), deg_to_rad(72), Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.72), "temsil", "kongre.to_delegate_arrow")
	_add_way_arrow(Vector2(1010, 900), deg_to_rad(105), Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.70), "birlik", "kongre.to_unity_arrow")
	_add_discovery_badge(_textures.GAME_CHECK_TEXTURE, Vector2(830, 1318), Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.80), "ortak hedef", "kongre.goal_badge")
	_add_decorative_speckles(Rect2(Vector2(260, 520), Vector2(1100, 1140)), Color(1.0, 0.80, 0.44, 0.06), 22)
	_add_sprite_prop(_textures.CLOUD_TEXTURE, Vector2(300, 220), Vector2(0.94, 0.94), Color(1, 1, 1, 0.14))
	_add_sprite_prop(_textures.CLOUD_TEXTURE_ALT, Vector2(1230, 260), Vector2(0.84, 0.84), Color(1, 1, 1, 0.10))
	_add_havza_building(Vector2(360, 520), 5, _textures.SKETCH_BUILDING_DOOR_TEXTURE, _textures.SKETCH_BUILDING_WINDOWS_TEXTURE, _textures.SKETCH_BUILDING_CENTER_TEXTURE, Color(1, 1, 1, 0.86))
	_add_havza_building(Vector2(1060, 620), 2, _textures.SKETCH_BUILDING_WINDOW_TEXTURE, _textures.SKETCH_BUILDING_WINDOW_TEXTURE, _textures.SKETCH_BUILDING_CENTER_TEXTURE, Color(1, 1, 1, 0.70))
	_add_kenney_building(Vector2(1120, 745), Vector2(0.90, 0.90), _textures.BLOCK_BUILDING_ROOF_BLUE_TEXTURE, Color(0.94, 1.0, 1.0, 0.44))
	_add_crimson_flag(Vector2(1040, 790), 0.52, true)
	_add_sketch_strip(_textures.SKETCH_PATH_TEXTURE, Vector2(430, 1660), 5, Vector2(96, 0), Color(1, 1, 1, 0.96), Vector2(0.78, 0.78))
	_add_sketch_tile(_textures.SKETCH_PATH_CROSS_TEXTURE, Vector2(780, 1220), Color.WHITE, Vector2(0.82, 0.82))
	_add_sketch_tile(_textures.SKETCH_PATH_END_TEXTURE, Vector2(1090, 980), Color.WHITE, Vector2(0.76, 0.76))
	_add_sprite_prop(_textures.TREE_TEXTURE, Vector2(250, 1290), Vector2(0.84, 0.84), Color(0.96, 1.0, 0.92, 0.32), true)
	_add_sprite_prop(_textures.TREE_TEXTURE_ALT, Vector2(1350, 1330), Vector2(0.78, 0.78), Color(0.96, 1.0, 0.92, 0.28), true)
	_add_sprite_prop(_textures.FENCE_TEXTURE, Vector2(790, 840), Vector2(1.04, 1.04), Color(1, 1, 1, 0.26))
	_add_sprite_prop(_textures.FENCE_TEXTURE, Vector2(790, 1560), Vector2(1.12, 1.12), Color(1, 1, 1, 0.22))
	_add_sprite_prop(_textures.SHIP_CREW_TEXTURE, Vector2(620, 1140), Vector2(0.46, 0.46), Color(1, 1, 1, 0.18), true)
	_add_sprite_prop(_textures.SHIP_CREW_ALT_TEXTURE, Vector2(980, 1180), Vector2(0.42, 0.42), Color(1, 1, 1, 0.16), true)
	_add_mote_cluster(Vector2(820, 1160), Color(0.98, 0.70, 0.38, 0.13), 7)


# ============================================================
# UTILITY FONKSİYONLAR
# ============================================================

func _scaled_points(points: PackedVector2Array, scale_value: float) -> PackedVector2Array:
	var scaled := PackedVector2Array()
	for point in points:
		scaled.append(point * scale_value)
	return scaled


func _ellipse_points(radius: Vector2, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		points.append(Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return points


func _rounded_rect_points(size: Vector2, radius: float, segments: int) -> PackedVector2Array:
	var r: float = min(radius, min(size.x, size.y) * 0.5)
	var w := size.x
	var h := size.y
	var points := PackedVector2Array()
	
	# Top-right corner
	for index in range(segments):
		var angle := TAU * float(index) / (4.0 * float(segments))
		points.append(Vector2(w - r + cos(angle) * r, r + sin(angle) * r))
	# Bottom-right corner
	for index in range(segments):
		var angle := TAU * float(index) / (4.0 * float(segments)) + TAU * 0.25
		points.append(Vector2(w - r + cos(angle) * r, h - r + sin(angle) * r))
	# Bottom-left corner
	for index in range(segments):
		var angle := TAU * float(index) / (4.0 * float(segments)) + TAU * 0.5
		points.append(Vector2(r + cos(angle) * r, h - r + sin(angle) * r))
	# Top-left corner
	for index in range(segments):
		var angle := TAU * float(index) / (4.0 * float(segments)) + TAU * 0.75
		points.append(Vector2(r + cos(angle) * r, r + sin(angle) * r))
	return points


# ============================================================
# BASİT PROP FONKSİYONLARI
# ============================================================

func _add_sprite_prop(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint: Color, to_foreground := false) -> void:
	var target := _get_foreground(_cached_world_root) if to_foreground else _get_props(_cached_world_root)
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = scale_value
	sprite.modulate = tint
	sprite.z_index = 5 if to_foreground else -2
	target.add_child(sprite)


func _add_paper_shadow(center: Vector2, radius: Vector2, alpha := 0.20, to_foreground := false) -> void:
	_add_soft_blob(_cached_world_root, center + Vector2(0, 22), radius, Color(0.03, 0.05, 0.08, alpha), 18, 0.05, to_foreground, -3)


func _add_crimson_flag(pos: Vector2, scale_value := 1.0, to_foreground := true) -> void:
	var target := _get_foreground(_cached_world_root) if to_foreground else _get_props(_cached_world_root)
	var pole := Polygon2D.new()
	pole.position = pos
	pole.color = Color(0.18, 0.16, 0.14, 0.92)
	pole.z_index = 10
	pole.polygon = PackedVector2Array([
		Vector2(-4, -72) * scale_value,
		Vector2(4, -72) * scale_value,
		Vector2(4, 54) * scale_value,
		Vector2(-4, 54) * scale_value,
	])
	var flag := Polygon2D.new()
	flag.position = pos + Vector2(6, -64) * scale_value
	flag.color = Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.92)
	flag.z_index = 11
	flag.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(82, 10) * scale_value,
		Vector2(74, 52) * scale_value,
		Vector2(0, 42) * scale_value,
	])
	var shine := Polygon2D.new()
	shine.position = pos + Vector2(18, -46) * scale_value
	shine.color = Color(1.0, 0.80, 0.70, 0.34)
	shine.z_index = 12
	shine.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(34, 4) * scale_value,
		Vector2(30, 10) * scale_value,
		Vector2(-2, 7) * scale_value,
	])
	target.add_child(pole)
	target.add_child(flag)
	target.add_child(shine)


func _add_path_ribbon(points: Array, width: float, color: Color, z_index := -2) -> void:
	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.z_index = z_index
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	for point in points:
		line.add_point(point)
	_get_props(_cached_world_root).add_child(line)


func _add_rift_shard(pos: Vector2, size: Vector2, color: Color, phase: float) -> void:
	var shard := Polygon2D.new()
	shard.position = pos
	shard.color = color
	shard.z_index = 12
	shard.polygon = PackedVector2Array([
		Vector2(0, -size.y * 0.5),
		Vector2(size.x * 0.44, 0),
		Vector2(0, size.y * 0.5),
		Vector2(-size.x * 0.44, 0),
	])
	shard.set_meta("visual_fx", true)
	shard.set_meta("base_pos", pos)
	shard.set_meta("base_alpha", color.a)
	shard.set_meta("drift", Vector2(12.0, 18.0))
	shard.set_meta("phase", phase)
	_get_foreground(_cached_world_root).add_child(shard)


func _add_rift_shard_cluster(center: Vector2, count := 7, radius := 160.0) -> void:
	for index in range(count):
		var angle := TAU * float(index) / float(max(count, 1))
		var offset := Vector2(cos(angle) * radius, sin(angle) * radius * 0.62)
		var alpha := 0.18 + float(index % 3) * 0.04
		_add_rift_shard(center + offset, Vector2(26 + (index % 2) * 10, 70 + (index % 3) * 12), Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, alpha), float(index) * 0.61)


func _add_water_glints(start: Vector2, count: int, step: Vector2, color: Color) -> void:
	for index in range(count):
		var glint := Line2D.new()
		glint.width = 5.0 + float(index % 3)
		glint.default_color = color
		glint.z_index = -1
		var base := start + (step * index)
		glint.add_point(base)
		glint.add_point(base + Vector2(70 + (index % 2) * 34, -8 + (index % 3) * 6))
		_get_props(_cached_world_root).add_child(glint)


func _add_ship_planks(start: Vector2, count: int, step_x: float, tint := Color.WHITE, scale_value := Vector2(0.68, 0.68), to_foreground := false) -> void:
	for index in range(count):
		_add_sprite_prop(_textures.SHIP_WOOD_TEXTURE, start + Vector2(step_x * index, 0), scale_value, tint, to_foreground)


func _add_light_mote(pos: Vector2, radius: float, color: Color, drift: Vector2) -> void:
	var mote := Polygon2D.new()
	var points := PackedVector2Array()
	for index in range(12):
		var angle := TAU * float(index) / 12.0
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	mote.position = pos
	mote.color = color
	mote.polygon = points
	mote.z_index = 7
	mote.set_meta("visual_fx", true)
	mote.set_meta("base_pos", pos)
	mote.set_meta("base_alpha", color.a)
	mote.set_meta("drift", drift)
	mote.set_meta("phase", float(_get_foreground(_cached_world_root).get_child_count() % 19) * 0.47)
	_get_foreground(_cached_world_root).add_child(mote)


func _add_mote_cluster(center: Vector2, color: Color, count := 6) -> void:
	for index in range(count):
		var angle := TAU * float(index) / float(max(count, 1))
		var offset := Vector2(cos(angle), sin(angle)) * (70.0 + (float(index % 3) * 34.0))
		var drift := Vector2(10.0 + float(index % 2) * 8.0, 7.0 + float(index % 3) * 5.0)
		_add_light_mote(center + offset, 8.0 + float(index % 3) * 2.0, color, drift)


# ============================================================
# KOMPLEKS PROP FONKSİYONLARI
# ============================================================

func _add_kenney_prop(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint := Color.WHITE, to_foreground := false, slot_id := "") -> Sprite2D:
	var target := _get_foreground(_cached_world_root) if to_foreground else _get_props(_cached_world_root)
	var base_z := 8 if to_foreground else -1

	var outline := Sprite2D.new()
	outline.texture = texture
	outline.position = pos
	outline.scale = scale_value * Vector2(1.10, 1.10)
	outline.modulate = Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.34)
	outline.z_index = base_z - 1
	target.add_child(outline)

	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = scale_value
	sprite.modulate = tint
	sprite.z_index = base_z
	if slot_id != "":
		sprite.set_meta("asset_slot", slot_id)
		sprite.set_meta("kenney_fallback", true)
	target.add_child(sprite)
	return sprite


func _add_kenney_building(pos: Vector2, scale_value: Vector2, roof: Texture2D, tint := Color.WHITE) -> void:
	_add_kenney_prop(_textures.BLOCK_BUILDING_SAND_TEXTURE, pos + Vector2(0, 42) * scale_value.y, scale_value, tint)
	_add_kenney_prop(_textures.BLOCK_BUILDING_FRAME_TEXTURE, pos + Vector2(0, 2) * scale_value.y, scale_value, tint)
	_add_kenney_prop(roof, pos + Vector2(0, -42) * scale_value.y, scale_value, tint)
	_add_kenney_prop(_textures.BLOCK_DOOR_TEXTURE, pos + Vector2(-22, 52) * scale_value, scale_value * Vector2(0.72, 0.72), tint, true)
	_add_kenney_prop(_textures.BLOCK_WINDOW_TEXTURE, pos + Vector2(34, 10) * scale_value, scale_value * Vector2(0.64, 0.64), tint, true)


func _add_kenney_npc(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint := Color.WHITE, slot_id := "", label_text := "") -> Node2D:
	var root := Node2D.new()
	root.position = pos
	root.z_index = 9
	root.set_meta("ambient_bob", true)
	root.set_meta("base_pos", pos)
	root.set_meta("phase", fmod(pos.x + pos.y, 360.0) * 0.017)
	root.set_meta("bob_amount", 3.0)
	if slot_id != "":
		root.set_meta("asset_slot", slot_id)
		root.set_meta("kenney_fallback", true)

	var shadow := Polygon2D.new()
	shadow.position = Vector2(0, 36) * scale_value
	shadow.color = Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.18)
	shadow.polygon = PackedVector2Array([
		Vector2(-28, -7) * scale_value,
		Vector2(28, -7) * scale_value,
		Vector2(36, 4) * scale_value,
		Vector2(-36, 4) * scale_value,
	])
	root.add_child(shadow)

	var outline := Sprite2D.new()
	outline.texture = texture
	outline.scale = scale_value * Vector2(1.12, 1.12)
	outline.modulate = Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.38)
	outline.z_index = 0
	root.add_child(outline)

	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.scale = scale_value
	sprite.modulate = tint
	sprite.z_index = 1
	root.add_child(sprite)

	if label_text != "":
		var label_bg := Polygon2D.new()
		label_bg.position = Vector2(-66, -76) * scale_value
		label_bg.color = Color(_colors.POP_CREAM.r, _colors.POP_CREAM.g, _colors.POP_CREAM.b, 0.78)
		label_bg.polygon = PackedVector2Array([
			Vector2.ZERO,
			Vector2(132, 0) * scale_value,
			Vector2(132, 38) * scale_value,
			Vector2(0, 38) * scale_value,
		])
		root.add_child(label_bg)

		var label := Label.new()
		label.position = Vector2(-58, -73) * scale_value
		label.custom_minimum_size = Vector2(116, 34) * scale_value
		label.text = label_text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color(0.15, 0.15, 0.18, _colors.DECORATIVE_LABEL_ALPHA))
		root.add_child(label)

	_get_foreground(_cached_world_root).add_child(root)
	return root


func _add_strategy_token(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint := Color.WHITE, slot_id := "") -> void:
	var sprite := _add_kenney_prop(texture, pos, scale_value, tint, true, slot_id)
	sprite.set_meta("ambient_bob", true)
	sprite.set_meta("base_pos", pos)
	sprite.set_meta("phase", fmod(pos.x * 0.31 + pos.y * 0.17, TAU))
	sprite.set_meta("bob_amount", 5.0)


func _add_strategy_card(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint: Color, label_text: String, slot_id := "") -> void:
	_add_paper_shadow(pos, Vector2(62, 86) * scale_value, 0.16, true)
	var card := _add_kenney_prop(texture, pos, scale_value, tint, true, slot_id)
	card.rotation_degrees = -4.0 + fmod(pos.x, 9.0)
	var label := Label.new()
	label.position = pos + Vector2(-70, 66) * scale_value
	label.custom_minimum_size = Vector2(140, 36) * scale_value
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.15, 0.16, 0.22, _colors.DECORATIVE_LABEL_ALPHA))
	label.z_index = 11
	_get_foreground(_cached_world_root).add_child(label)


func _add_location_sign(title: String, subtitle: String, pos: Vector2, width: float, accent: Color, slot_id := "") -> void:
	var root := Node2D.new()
	root.position = pos
	root.z_index = 10
	root.set_meta("ambient_bob", true)
	root.set_meta("base_pos", pos)
	root.set_meta("phase", fmod(pos.x + pos.y, TAU))
	root.set_meta("bob_amount", 1.4)
	if slot_id != "":
		root.set_meta("asset_slot", slot_id)
		root.set_meta("kenney_fallback", true)

	var shadow := Polygon2D.new()
	shadow.position = Vector2(10, 16)
	shadow.color = Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.24)
	shadow.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(width, 0),
		Vector2(width, 92),
		Vector2(0, 92),
	])
	root.add_child(shadow)

	var outline := Polygon2D.new()
	outline.position = Vector2(-6, -6)
	outline.color = Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.44)
	outline.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(width + 12, 0),
		Vector2(width + 12, 104),
		Vector2(0, 104),
	])
	root.add_child(outline)

	var plate := Polygon2D.new()
	plate.color = Color(_colors.POP_CREAM.r, _colors.POP_CREAM.g, _colors.POP_CREAM.b, 0.92)
	plate.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(width, 0),
		Vector2(width, 92),
		Vector2(0, 92),
	])
	root.add_child(plate)

	var stripe := Polygon2D.new()
	stripe.position = Vector2(0, 62)
	stripe.color = accent
	stripe.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(width, 0),
		Vector2(width, 16),
		Vector2(0, 16),
	])
	root.add_child(stripe)

	var title_label := Label.new()
	title_label.position = Vector2(18, 12)
	title_label.custom_minimum_size = Vector2(width - 36, 34)
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 25)
	title_label.add_theme_color_override("font_color", Color(0.13, 0.14, 0.18, 0.92))
	root.add_child(title_label)

	var subtitle_label := Label.new()
	subtitle_label.position = Vector2(18, 45)
	subtitle_label.custom_minimum_size = Vector2(width - 36, 24)
	subtitle_label.text = subtitle
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 16)
	subtitle_label.add_theme_color_override("font_color", Color(0.18, 0.19, 0.23, 0.68))
	root.add_child(subtitle_label)

	_get_foreground(_cached_world_root).add_child(root)


func _add_way_arrow(pos: Vector2, rotation: float, tint: Color, label_text := "", slot_id := "") -> void:
	var root := Node2D.new()
	root.position = pos
	root.rotation = rotation
	root.z_index = 10
	root.set_meta("ambient_bob", true)
	root.set_meta("base_pos", pos)
	root.set_meta("phase", fmod(pos.x * 0.27 + pos.y * 0.13, TAU))
	root.set_meta("bob_amount", 2.2)
	if slot_id != "":
		root.set_meta("asset_slot", slot_id)
		root.set_meta("kenney_fallback", true)

	var plate := Polygon2D.new()
	plate.color = Color(tint.r, tint.g, tint.b, 0.72)
	plate.polygon = PackedVector2Array([
		Vector2(-54, -34),
		Vector2(34, -34),
		Vector2(58, 0),
		Vector2(34, 34),
		Vector2(-54, 34),
	])
	root.add_child(plate)

	var icon := Sprite2D.new()
	icon.texture = _textures.GAME_ARROW_RIGHT_TEXTURE
	icon.scale = Vector2(0.55, 0.55)
	icon.modulate = Color(1, 1, 1, 0.92)
	icon.z_index = 1
	root.add_child(icon)
	_get_foreground(_cached_world_root).add_child(root)

	if label_text != "":
		var label := Label.new()
		label.position = pos + Vector2(-88, 42)
		label.custom_minimum_size = Vector2(176, 30)
		label.text = label_text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 17)
		label.add_theme_color_override("font_color", Color(0.12, 0.14, 0.18, _colors.DECORATIVE_LABEL_ALPHA))
		label.z_index = 11
		_get_foreground(_cached_world_root).add_child(label)


func _add_discovery_badge(texture: Texture2D, pos: Vector2, tint: Color, label_text: String, slot_id := "") -> void:
	_add_soft_blob(_cached_world_root, pos, Vector2(78, 54), Color(tint.r, tint.g, tint.b, 0.16), 14, 0.04, true, 7)
	var badge := _add_kenney_prop(texture, pos, Vector2(0.58, 0.58), Color(1, 1, 1, 0.86), true, slot_id)
	badge.set_meta("ambient_bob", true)
	badge.set_meta("base_pos", pos)
	badge.set_meta("phase", fmod(pos.x + pos.y, TAU))
	badge.set_meta("bob_amount", 4.0)
	var label := Label.new()
	label.position = pos + Vector2(-82, 50)
	label.custom_minimum_size = Vector2(164, 28)
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.12, 0.14, 0.18, _colors.DECORATIVE_LABEL_ALPHA))
	label.z_index = 11
	_get_foreground(_cached_world_root).add_child(label)


func _add_breadcrumb_dot(texture: Texture2D, pos: Vector2, tint: Color, scale_value: float, slot_id := "") -> void:
	var root := Node2D.new()
	root.position = pos
	root.z_index = 8
	root.set_meta("ambient_bob", true)
	root.set_meta("base_pos", pos)
	root.set_meta("phase", fmod(pos.x * 0.19 + pos.y * 0.11, TAU))
	root.set_meta("bob_amount", 2.5)
	if slot_id != "":
		root.set_meta("asset_slot", slot_id)
		root.set_meta("kenney_fallback", true)

	var glow := Polygon2D.new()
	glow.color = Color(tint.r, tint.g, tint.b, 0.18)
	glow.polygon = PackedVector2Array([
		Vector2(-28, -18) * scale_value,
		Vector2(28, -18) * scale_value,
		Vector2(36, 0) * scale_value,
		Vector2(28, 18) * scale_value,
		Vector2(-28, 18) * scale_value,
		Vector2(-36, 0) * scale_value,
	])
	root.add_child(glow)

	var outline := Sprite2D.new()
	outline.texture = texture
	outline.scale = Vector2(scale_value * 0.46, scale_value * 0.46)
	outline.modulate = Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.26)
	outline.z_index = 0
	root.add_child(outline)

	var icon := Sprite2D.new()
	icon.texture = texture
	icon.scale = Vector2(scale_value * 0.38, scale_value * 0.38)
	icon.modulate = Color(1, 1, 1, 0.90)
	icon.z_index = 1
	root.add_child(icon)
	_get_foreground(_cached_world_root).add_child(root)


func _add_breadcrumb_trail(points: Array, texture: Texture2D, tint: Color, slot_prefix: String, spacing := 155.0, scale_value := 0.72) -> void:
	var dot_index := 0
	for index in range(points.size() - 1):
		var start: Vector2 = points[index]
		var finish: Vector2 = points[index + 1]
		var distance: float = start.distance_to(finish)
		var steps: int = max(2, int(distance / spacing))
		for step in range(1, steps):
			var t: float = float(step) / float(steps)
			var pos: Vector2 = start.lerp(finish, t)
			_add_breadcrumb_dot(texture, pos, tint, scale_value, "%s.%02d" % [slot_prefix, dot_index])
			dot_index += 1


func _add_story_banner(pos: Vector2, size: Vector2, fill: Color, accent: Color, text: String) -> void:
	_add_paper_shadow(pos + (size * 0.5), Vector2(size.x * 0.56, size.y * 0.40), 0.18, true)
	_add_soft_blob(_cached_world_root, pos + (size * 0.5), Vector2(size.x * 0.52, size.y * 0.36), fill, 16, 0.04, true, 8)
	var stripe := Polygon2D.new()
	stripe.position = pos + Vector2(size.x * 0.18, size.y * 0.56)
	stripe.color = accent
	stripe.z_index = 9
	stripe.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x * 0.64, 0),
		Vector2(size.x * 0.64, 10),
		Vector2.ZERO + Vector2(0, 10),
	])
	_get_foreground(_cached_world_root).add_child(stripe)
	var label := Label.new()
	label.position = pos + Vector2(size.x * 0.12, size.y * 0.22)
	label.custom_minimum_size = Vector2(size.x * 0.76, size.y * 0.46)
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(0.18, 0.18, 0.24, 0.92))
	label.z_index = 10
	_get_foreground(_cached_world_root).add_child(label)


func _add_asset_slot_prop(slot_id: String, pos: Vector2, size: Vector2, fill: Color, accent: Color, label_text := "", to_foreground := false) -> Node2D:
	var root := Node2D.new()
	root.name = slot_id.replace(".", "_")
	root.position = pos
	root.set_meta("asset_slot", slot_id)
	root.set_meta("replacement_ready", true)
	root.z_index = 7 if to_foreground else -1

	var shadow := Polygon2D.new()
	shadow.position = Vector2(8, 14)
	shadow.color = Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.24)
	shadow.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0),
		size,
		Vector2(0, size.y),
	])
	root.add_child(shadow)

	var outline := Polygon2D.new()
	outline.position = Vector2(-5, -5)
	outline.color = Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.54)
	outline.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x + 10, 0),
		Vector2(size.x + 10, size.y + 10),
		Vector2(0, size.y + 10),
	])
	root.add_child(outline)

	var body := Polygon2D.new()
	body.color = fill
	body.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0),
		size,
		Vector2(0, size.y),
	])
	root.add_child(body)

	var accent_band := Polygon2D.new()
	accent_band.position = Vector2(0, size.y * 0.62)
	accent_band.color = accent
	accent_band.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0),
		Vector2(size.x, max(8.0, size.y * 0.12)),
		Vector2(0, max(8.0, size.y * 0.12)),
	])
	root.add_child(accent_band)

	var highlight := Polygon2D.new()
	highlight.position = Vector2(size.x * 0.12, size.y * 0.12)
	highlight.color = Color(1, 1, 1, 0.20)
	highlight.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x * 0.48, 0),
		Vector2(size.x * 0.42, max(8.0, size.y * 0.10)),
		Vector2(0, max(8.0, size.y * 0.12)),
	])
	root.add_child(highlight)

	if label_text != "":
		var label := Label.new()
		label.position = Vector2(size.x * 0.08, size.y * 0.24)
		label.custom_minimum_size = Vector2(size.x * 0.84, size.y * 0.34)
		label.text = label_text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(0.12, 0.13, 0.17, _colors.DECORATIVE_LABEL_ALPHA))
		root.add_child(label)

	if to_foreground:
		_get_foreground(_cached_world_root).add_child(root)
	else:
		_get_props(_cached_world_root).add_child(root)
	return root


func _add_decorative_speckles(area: Rect2, color: Color, count := 14, to_foreground := false) -> void:
	for index in range(count):
		var x := area.position.x + fmod(float(index * 137), area.size.x)
		var y := area.position.y + fmod(float(index * 89), area.size.y)
		var radius := 4.0 + float(index % 3) * 2.0
		_add_soft_blob(_cached_world_root, Vector2(x, y), Vector2(radius, radius * 0.76), color, 10, 0.05, to_foreground, -1)


func _add_toy_world_frame(accent: Color, glow: Color) -> void:
	_add_soft_blob(_cached_world_root, Vector2(180, 310), Vector2(220, 160), glow, 18, 0.10)
	_add_soft_blob(_cached_world_root, Vector2(1420, 360), Vector2(190, 140), glow.darkened(0.12), 18, 0.10)
	_add_soft_blob(_cached_world_root, Vector2(230, 1900), Vector2(260, 130), accent, 18, 0.08)
	_add_soft_blob(_cached_world_root, Vector2(1360, 1840), Vector2(240, 150), accent.lightened(0.10), 18, 0.08)


func _add_foreground_paper_cutout_asset(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint: Color, z_index: int, slot_id := "", parallax_strength := 0.0) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = scale_value
	sprite.modulate = tint
	sprite.z_index = z_index
	sprite.set_meta("paperworld_asset", true)
	sprite.set_meta("ambient_bob", true)
	sprite.set_meta("base_pos", pos)
	sprite.set_meta("phase", fmod(pos.x * 0.013 + pos.y * 0.019, TAU))
	sprite.set_meta("bob_amount", 0.55)
	if parallax_strength != 0.0:
		sprite.set_meta("paper_parallax_strength", parallax_strength)
	if slot_id != "":
		sprite.set_meta("asset_slot", slot_id)
		sprite.set_meta("replacement_ready", true)
	_get_foreground(_cached_world_root).add_child(sprite)
	return sprite


func _add_backdrop_prop(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint: Color, z_index := -6, slot_id := "") -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = scale_value
	sprite.modulate = tint
	sprite.z_index = z_index
	sprite.set_meta("ambient_bob", true)
	sprite.set_meta("base_pos", pos)
	sprite.set_meta("phase", fmod(pos.x * 0.07 + pos.y * 0.03, TAU))
	sprite.set_meta("bob_amount", 1.0)
	if slot_id != "":
		sprite.set_meta("asset_slot", slot_id)
		sprite.set_meta("kenney_fallback", true)
	_get_props(_cached_world_root).add_child(sprite)
	return sprite


func _add_backdrop_band(textures: Array, y: float, scale_value: Vector2, tint: Color, slot_prefix: String, z_index := -6) -> void:
	var x_positions := [220.0, 600.0, 980.0, 1360.0]
	for index in range(x_positions.size()):
		var texture: Texture2D = textures[index % textures.size()]
		_add_backdrop_prop(texture, Vector2(x_positions[index], y + float(index % 2) * 24.0), scale_value, tint, z_index, "%s.%02d" % [slot_prefix, index])


func _add_distant_town_band(y: float, tint: Color, slot_prefix: String) -> void:
	_add_backdrop_prop(_textures.BG_FLAT_HOUSE_SHORT_TEXTURE, Vector2(330, y), Vector2(0.78, 0.78), tint, -5, "%s.house_short_a" % slot_prefix)
	_add_backdrop_prop(_textures.BG_FLAT_HOUSE_TALL_TEXTURE, Vector2(495, y - 20), Vector2(0.82, 0.82), tint, -5, "%s.house_tall_a" % slot_prefix)
	_add_backdrop_prop(_textures.BG_FLAT_HOUSE_SHORT_TEXTURE, Vector2(1110, y + 10), Vector2(0.74, 0.74), tint, -5, "%s.house_short_b" % slot_prefix)
	_add_backdrop_prop(_textures.BG_FLAT_HOUSE_TALL_TEXTURE, Vector2(1280, y - 18), Vector2(0.80, 0.80), tint, -5, "%s.house_tall_b" % slot_prefix)
	_add_backdrop_prop(_textures.BG_FLAT_TREE_03_TEXTURE, Vector2(225, y + 28), Vector2(0.62, 0.62), tint, -4, "%s.tree_a" % slot_prefix)
	_add_backdrop_prop(_textures.BG_FLAT_TREE_08_TEXTURE, Vector2(1370, y + 30), Vector2(0.60, 0.60), tint, -4, "%s.tree_b" % slot_prefix)


func _add_sketch_tile(texture: Texture2D, pos: Vector2, tint := Color.WHITE, scale_value := Vector2(0.72, 0.72), to_foreground := false) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = scale_value
	sprite.modulate = tint
	sprite.z_index = 6 if to_foreground else -1
	if to_foreground:
		_get_foreground(_cached_world_root).add_child(sprite)
	else:
		_get_props(_cached_world_root).add_child(sprite)


func _add_sketch_strip(texture: Texture2D, start: Vector2, count: int, step: Vector2, tint := Color.WHITE, scale_value := Vector2(0.72, 0.72), to_foreground := false) -> void:
	for index in range(count):
		_add_sketch_tile(texture, start + (step * index), tint, scale_value, to_foreground)


func _add_havza_building(origin: Vector2, columns: int, front_texture: Texture2D, fill_texture: Texture2D, accent_texture: Texture2D, tint := Color.WHITE) -> void:
	_add_sketch_tile(_textures.SKETCH_BUILDING_CORNER_TEXTURE, origin, tint, Vector2(0.88, 0.88), true)
	for column in range(columns):
		var offset := Vector2(88 * (column + 1), 0)
		var texture := fill_texture if column < columns - 1 else front_texture
		_add_sketch_tile(texture, origin + offset, tint, Vector2(0.88, 0.88), true)
	_add_sketch_tile(accent_texture, origin + Vector2(88 * max(columns - 1, 0), -56), Color(1, 1, 1, 0.92), Vector2(0.74, 0.74), true)


# ============================================================
# PUBLIC API FONKSİYONLARI
# ============================================================

func add_diorama_ground_blob(center: Vector2, radius: Vector2, fill: Color, edge: Color, slot_id := "") -> void:
	_add_soft_blob(_cached_world_root, center + Vector2(0, 34), radius * Vector2(1.05, 0.94), Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.18), 24, 0.08, false, -6)
	_add_soft_blob(_cached_world_root, center, radius * Vector2(1.03, 1.02), edge, 24, 0.09, false, -5)
	_add_soft_blob(_cached_world_root, center + Vector2(0, -8), radius, fill, 24, 0.08, false, -4)
	if slot_id != "":
		_get_props(_cached_world_root).get_child(_get_props(_cached_world_root).get_child_count() - 1).set_meta("asset_slot", slot_id)


func add_paper_path(points: Array, width: float, fill: Color, edge: Color, slot_id := "") -> void:
	_add_path_ribbon(points, width + 26.0, Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.15), -3)
	_add_path_ribbon(points, width + 12.0, edge, -2)
	_add_path_ribbon(points, width, fill, -1)
	if slot_id != "":
		_get_props(_cached_world_root).get_child(_get_props(_cached_world_root).get_child_count() - 1).set_meta("asset_slot", slot_id)


func add_foreground_frame(side: String, tint: Color, slot_id := "") -> void:
	var x := 120.0 if side == "left" else 1480.0
	var mirror := -1.0 if side == "right" else 1.0
	_add_soft_blob(_cached_world_root, Vector2(x, 1620), Vector2(240, 520), tint, 18, 0.12, true, 18)
	_add_soft_blob(_cached_world_root, Vector2(x + (80.0 * mirror), 1320), Vector2(140, 230), tint.lightened(0.08), 18, 0.10, true, 19)
	_add_sprite_prop(_textures.TREE_TEXTURE, Vector2(x + (54.0 * mirror), 1470), Vector2(0.96 * mirror, 0.96), Color(1, 1, 1, 0.30), true)
	_add_sprite_prop(_textures.TREE_TEXTURE_ALT, Vector2(x - (38.0 * mirror), 1760), Vector2(0.82 * mirror, 0.82), Color(1, 1, 1, 0.24), true)
	if slot_id != "":
		_get_foreground(_cached_world_root).get_child(_get_foreground(_cached_world_root).get_child_count() - 1).set_meta("asset_slot", slot_id)


func add_prop_cluster(center: Vector2, kind: String, slot_id := "") -> void:
	match kind:
		"harbor":
			var crate_a := _add_kenney_prop(_textures.BLOCK_BOX_TEXTURE, center + Vector2(-110, 76), Vector2(0.76, 0.76), Color(0.96, 0.82, 0.58, 0.72), false, "%s.crate_a" % slot_id)
			var crate_b := _add_kenney_prop(_textures.BLOCK_BOX_WIDE_TEXTURE, center + Vector2(-34, 94), Vector2(0.76, 0.76), Color(1.0, 0.86, 0.62, 0.70), false, "%s.crate_b" % slot_id)
			var water_tile := _add_kenney_prop(_textures.BLOCK_TILE_WATER_TEXTURE, center + Vector2(92, 62), Vector2(1.08, 0.86), Color(0.58, 0.98, 1.0, 0.62), false, "%s.water" % slot_id)
			crate_a.z_index = 0
			crate_b.z_index = 0
			water_tile.z_index = 0
		"telegraph":
			var fence := _add_kenney_prop(_textures.BLOCK_FENCE_DOUBLE_TEXTURE, center + Vector2(-86, 78), Vector2(0.82, 0.82), Color(1.0, 0.88, 0.62, 0.62), false, "%s.fence" % slot_id)
			var sign_post := _add_kenney_prop(_textures.BLOCK_TILE_WOOD_TEXTURE, center + Vector2(92, 70), Vector2(0.50, 0.72), Color(1.0, 0.82, 0.56, 0.68), false, "%s.sign_post" % slot_id)
			fence.z_index = 0
			sign_post.z_index = 0
		"people":
			var citizen_a := _add_kenney_npc(_textures.BLOCK_CHARACTER_MAN_TEXTURE, center + Vector2(-112, 88), Vector2(0.74, 0.74), Color(0.96, 0.94, 0.86, 0.58), "%s.citizen_a" % slot_id, "")
			var citizen_b := _add_kenney_npc(_textures.BLOCK_CHARACTER_WOMAN_TEXTURE, center + Vector2(108, 88), Vector2(-0.72, 0.72), Color(0.94, 1.0, 0.96, 0.58), "%s.citizen_b" % slot_id, "")
			citizen_a.z_index = 0
			citizen_b.z_index = 0
		"discovery":
			_add_asset_slot_prop(slot_id, center + Vector2(-70, -46), Vector2(140, 86), Color(0.98, 0.90, 0.62, 0.82), Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.36), "İz", true)
			_add_mote_cluster(center, Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.16), 4)


func add_historical_landmark(center: Vector2, kind: String, title: String, slot_id := "") -> void:
	var fill := Color(0.96, 0.88, 0.66, 0.84)
	var accent := Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.46)
	if kind == "harbor":
		fill = Color(0.78, 0.94, 1.0, 0.72)
		accent = Color(_colors.POP_DEEP_TURQUOISE.r, _colors.POP_DEEP_TURQUOISE.g, _colors.POP_DEEP_TURQUOISE.b, 0.62)
	elif kind == "telegraph":
		fill = Color(0.78, 0.90, 1.0, 0.72)
		accent = Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.50)
	elif kind == "people":
		fill = Color(1.0, 0.87, 0.56, 0.74)
		accent = Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.46)
	_add_asset_slot_prop(slot_id, center + Vector2(-88, -78), Vector2(176, 108), fill, accent, title, true)


func add_strategy_node(center: Vector2, title: String, accent: Color, slot_id := "") -> void:
	_add_soft_blob(_cached_world_root, center, Vector2(185, 126), Color(accent.r, accent.g, accent.b, 0.18), 22, 0.10, false, 0)
	_add_soft_blob(_cached_world_root, center, Vector2(94, 62), Color(1.0, 0.96, 0.76, 0.26), 18, 0.06, false, 1)
	var label_text := title
	if _state.current_zone == "samsun_rift" and title != "Milli İrade":
		label_text = ""
	_add_asset_slot_prop(slot_id, center + Vector2(-88, -58), Vector2(176, 116), Color(accent.r, accent.g, accent.b, 0.20), Color(_colors.POP_GOLD.r, _colors.POP_GOLD.g, _colors.POP_GOLD.b, 0.36), label_text, true)
	_add_mote_cluster(center, Color(accent.r, accent.g, accent.b, 0.13), 5)


func add_companion_reaction_spot(center: Vector2, radius: float, text: String, slot_id := "") -> void:
	companion_reaction_spot_registered.emit(center, radius, text, slot_id)
	_add_soft_blob(_cached_world_root, center, Vector2(radius * 0.42, radius * 0.20), Color(1.0, 0.95, 0.66, 0.07), 16, 0.04, false, -1)


# ============================================================
# SAMSUN BÖLGESİ FONKSİYONLARI
# ============================================================

func _add_samsun_foreground_silhouettes() -> void:
	var silhouette := Color("#1A2A3A")
	_add_samsun_silhouette_rect(Vector2(0, 0), Vector2(90, WORLD_SIZE.y), silhouette, "world_props.samsun_left_frame")
	_add_samsun_silhouette_rect(Vector2(WORLD_SIZE.x - 90, 0), Vector2(90, WORLD_SIZE.y), silhouette, "world_props.samsun_right_frame")
	_add_samsun_silhouette_rect(Vector2(0, 0), Vector2(200, 60), silhouette, "world_props.samsun_top_left_frame")
	_add_samsun_silhouette_rect(Vector2(WORLD_SIZE.x - 200, 0), Vector2(200, 60), silhouette, "world_props.samsun_top_right_frame")
	_add_samsun_silhouette_ellipse(Vector2(42, 108), Vector2(72, 54), silhouette, "world_props.samsun_left_crown_a")
	_add_samsun_silhouette_ellipse(Vector2(84, 178), Vector2(58, 46), silhouette, "world_props.samsun_left_crown_b")
	_add_samsun_silhouette_ellipse(Vector2(WORLD_SIZE.x - 42, 108), Vector2(72, 54), silhouette, "world_props.samsun_right_crown_a")
	_add_samsun_silhouette_ellipse(Vector2(WORLD_SIZE.x - 84, 178), Vector2(58, 46), silhouette, "world_props.samsun_right_crown_b")
	_add_samsun_silhouette_ellipse(Vector2(70, 1840), Vector2(190, 110), Color(0.10, 0.17, 0.22, 0.86), "world_props.samsun_front_left_hill")
	_add_samsun_silhouette_ellipse(Vector2(WORLD_SIZE.x - 70, 1805), Vector2(210, 130), Color(0.10, 0.17, 0.22, 0.78), "world_props.samsun_front_right_hill")
	_add_samsun_silhouette_ellipse(Vector2(230, 1950), Vector2(260, 104), Color(0.10, 0.17, 0.22, 0.70), "world_props.samsun_front_left_ground")
	_add_samsun_silhouette_ellipse(Vector2(1320, 1960), Vector2(300, 115), Color(0.10, 0.17, 0.22, 0.68), "world_props.samsun_front_right_ground")
	_add_samsun_edge_reeds(Vector2(118, 1520), -1.0, "world_props.samsun_left_reeds")
	_add_samsun_edge_reeds(Vector2(WORLD_SIZE.x - 126, 1480), 1.0, "world_props.samsun_right_reeds")
	_add_samsun_edge_reeds(Vector2(165, 1870), -1.0, "world_props.samsun_front_left_reeds")
	_add_samsun_edge_reeds(Vector2(WORLD_SIZE.x - 174, 1885), 1.0, "world_props.samsun_front_right_reeds")
	_add_soft_blob(_cached_world_root, Vector2(70, 1220), Vector2(142, 360), Color(0.07, 0.12, 0.16, 0.18), 22, 0.03, true, 4)
	_add_soft_blob(_cached_world_root, Vector2(WORLD_SIZE.x - 70, 1260), Vector2(150, 390), Color(0.07, 0.12, 0.16, 0.16), 22, 0.03, true, 4)


func _add_samsun_silhouette_rect(pos: Vector2, size: Vector2, color: Color, slot_id := "") -> void:
	var rect := Polygon2D.new()
	rect.position = pos
	rect.color = color
	rect.z_index = 5
	rect.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0),
		size,
		Vector2(0, size.y),
	])
	if slot_id != "":
		rect.set_meta("asset_slot", slot_id)
	_get_foreground(_cached_world_root).add_child(rect)


func _add_samsun_silhouette_ellipse(center: Vector2, radius: Vector2, color: Color, slot_id := "") -> void:
	var ellipse := Polygon2D.new()
	ellipse.position = center
	ellipse.color = color
	ellipse.z_index = 5
	ellipse.polygon = _ellipse_points(radius, 24)
	if slot_id != "":
		ellipse.set_meta("asset_slot", slot_id)
	_get_foreground(_cached_world_root).add_child(ellipse)


func _add_samsun_edge_reeds(origin: Vector2, direction: float, slot_id: String) -> void:
	var reed_color := Color(0.08, 0.16, 0.17, 0.58)
	for index in range(5):
		var reed := Polygon2D.new()
		var height := 82.0 + (float(index % 3) * 18.0)
		var width := 12.0 + float(index % 2) * 4.0
		reed.position = origin + Vector2(direction * float(index) * 18.0, float(index % 2) * 18.0)
		reed.color = reed_color
		reed.z_index = 5
		reed.polygon = PackedVector2Array([
			Vector2(-width * 0.5, 0),
			Vector2(width * 0.5, 0),
			Vector2(direction * 18.0, -height),
		])
		reed.set_meta("asset_slot", "%s_%02d" % [slot_id, index])
		_get_foreground(_cached_world_root).add_child(reed)


func _add_samsun_path_ribbon() -> void:
	var path_points := [
		Vector2(800, 1740),
		Vector2(710, 1600),
		Vector2(590, 1490),
		Vector2(640, 1320),
		Vector2(760, 1190),
		Vector2(875, 1080),
		Vector2(800, 1000),
	]
	_add_path_ribbon(path_points, 52.0, Color("#7A5A42"), -12)
	_add_path_ribbon(path_points, 48.0, Color(0.96, 0.91, 0.83, 0.70), -12)
	_add_samsun_path_cap(Vector2(800, 1740), Vector2(116, 42), Color(0.96, 0.91, 0.83, 0.50), "world_tiles.samsun_path_entrance")
	_add_samsun_path_cap(Vector2(800, 1000), Vector2(132, 50), Color(0.62, 0.83, 0.78, 0.42), "world_tiles.samsun_path_rift_cap")
	_add_samsun_path_glint(path_points, "world_tiles.samsun_resource_main_path_glint")


func _add_samsun_path_glint(points: Array, slot_id: String) -> void:
	var glint := Line2D.new()
	glint.width = 7.0
	glint.default_color = Color(1.0, 0.92, 0.64, 0.12)
	glint.z_index = -9
	glint.joint_mode = Line2D.LINE_JOINT_ROUND
	glint.begin_cap_mode = Line2D.LINE_CAP_ROUND
	glint.end_cap_mode = Line2D.LINE_CAP_ROUND
	for index in range(points.size()):
		if index % 2 == 0:
			glint.add_point(points[index])
	glint.set_meta("asset_slot", slot_id)
	glint.set_meta("base_color", glint.default_color)
	goal_visual_registered.emit(slot_id, glint)
	_get_props(_cached_world_root).add_child(glint)


func _add_samsun_support_paths() -> void:
	_add_samsun_path_branch([
		Vector2(800, 1000),
		Vector2(640, 930),
		Vector2(500, 850),
		Vector2(360, 820),
	], "world_tiles.samsun_path_to_harbor")
	_add_samsun_path_branch([
		Vector2(800, 1000),
		Vector2(930, 940),
		Vector2(1050, 860),
		Vector2(1190, 820),
	], "world_tiles.samsun_path_to_telegraph")
	_add_samsun_path_branch([
		Vector2(800, 1000),
		Vector2(690, 1170),
		Vector2(580, 1340),
		Vector2(530, 1500),
	], "world_tiles.samsun_path_to_people")


func _add_samsun_path_branch(points: Array, slot_id: String) -> void:
	var border := Line2D.new()
	border.width = 36.0
	border.default_color = Color(0.48, 0.32, 0.22, 0.15)
	border.z_index = -11
	border.joint_mode = Line2D.LINE_JOINT_ROUND
	border.begin_cap_mode = Line2D.LINE_CAP_ROUND
	border.end_cap_mode = Line2D.LINE_CAP_ROUND
	for point in points:
		border.add_point(point)
	border.set_meta("asset_slot", "%s.edge" % slot_id)
	border.set_meta("base_color", border.default_color)
	goal_visual_registered.emit(slot_id, border)
	_get_props(_cached_world_root).add_child(border)

	var fill := Line2D.new()
	fill.width = 30.0
	fill.default_color = Color(0.96, 0.91, 0.83, 0.34)
	fill.z_index = -10
	fill.joint_mode = Line2D.LINE_JOINT_ROUND
	fill.begin_cap_mode = Line2D.LINE_CAP_ROUND
	fill.end_cap_mode = Line2D.LINE_CAP_ROUND
	for point in points:
		fill.add_point(point)
	fill.set_meta("asset_slot", slot_id)
	fill.set_meta("base_color", fill.default_color)
	goal_visual_registered.emit(slot_id, fill)
	_get_props(_cached_world_root).add_child(fill)


func _add_samsun_landmark_pads() -> void:
	_add_samsun_paper_pad(Vector2(360, 820), Vector2(245, 116), Color(0.96, 0.91, 0.83, 0.30), Color(0.35, 0.55, 0.58, 0.18), "world_tiles.samsun_harbor_pad")
	_add_samsun_paper_pad(Vector2(1190, 820), Vector2(245, 116), Color(0.96, 0.91, 0.83, 0.28), Color(0.24, 0.42, 0.52, 0.18), "world_tiles.samsun_telegraph_pad")
	_add_samsun_paper_pad(Vector2(530, 1500), Vector2(265, 122), Color(0.96, 0.91, 0.83, 0.30), Color(0.60, 0.38, 0.24, 0.16), "world_tiles.samsun_people_pad")
	_add_samsun_paper_pad(Vector2(800, 1000), Vector2(280, 176), Color(0.62, 0.83, 0.78, 0.18), Color(0.96, 0.91, 0.83, 0.16), "world_tiles.samsun_rift_pad")


func _add_samsun_discovery_spots() -> void:
	_add_samsun_resource_spot(Vector2(360, 620), Color(0.95, 0.75, 0.39, 0.24), "world_tiles.samsun_resource_leadership")
	_add_samsun_resource_spot(Vector2(1210, 1550), Color(0.74, 0.95, 0.38, 0.22), "world_tiles.samsun_resource_courage")


func _add_samsun_resource_spot(center: Vector2, accent: Color, slot_id: String) -> void:
	_add_samsun_paper_pad(center, Vector2(150, 70), Color(0.96, 0.91, 0.83, 0.20), Color(accent.r, accent.g, accent.b, 0.18), slot_id)
	for index in range(3):
		var angle := (-0.85 + (float(index) * 0.85))
		var offset := Vector2(cos(angle) * 72.0, sin(angle) * 34.0)
		var sparkle := Polygon2D.new()
		sparkle.position = center + offset
		sparkle.color = Color(accent.r, accent.g, accent.b, 0.32)
		sparkle.z_index = -1
		sparkle.polygon = PackedVector2Array([
			Vector2(0, -13),
			Vector2(8, 0),
			Vector2(0, 13),
			Vector2(-8, 0),
		])
		sparkle.set_meta("asset_slot", "%s.sparkle_%02d" % [slot_id, index])
		sparkle.set_meta("base_color", sparkle.color)
		sparkle.set_meta("ambient_bob", true)
		sparkle.set_meta("base_pos", sparkle.position)
		sparkle.set_meta("phase", float(index) * 0.7)
		sparkle.set_meta("bob_amount", 1.4)
		goal_visual_registered.emit(slot_id, sparkle)
		_get_props(_cached_world_root).add_child(sparkle)


func _add_samsun_paper_pad(center: Vector2, radius: Vector2, fill: Color, edge: Color, slot_id := "") -> void:
	var pad := Polygon2D.new()
	pad.position = center
	pad.color = fill
	pad.z_index = -12
	pad.polygon = _ellipse_points(radius, 32)
	if slot_id != "":
		pad.set_meta("asset_slot", slot_id)
		pad.set_meta("base_color", fill)
		goal_visual_registered.emit(slot_id, pad)
	_get_props(_cached_world_root).add_child(pad)

	var rim := Line2D.new()
	rim.width = 7.0
	rim.default_color = edge
	rim.z_index = -11
	rim.joint_mode = Line2D.LINE_JOINT_ROUND
	rim.begin_cap_mode = Line2D.LINE_CAP_ROUND
	rim.end_cap_mode = Line2D.LINE_CAP_ROUND
	for index in range(33):
		var angle := TAU * float(index) / 32.0
		rim.add_point(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	if slot_id != "":
		rim.set_meta("asset_slot", "%s.rim" % slot_id)
		rim.set_meta("base_color", edge)
		goal_visual_registered.emit(slot_id, rim)
	_get_props(_cached_world_root).add_child(rim)


func _add_samsun_light_pools() -> void:
	_add_soft_blob(_cached_world_root, Vector2(360, 820), Vector2(200, 150), Color(0.95, 0.75, 0.39, 0.06), 28, 0.03, false, -11)
	_add_soft_blob(_cached_world_root, Vector2(800, 1000), Vector2(150, 118), Color(0.62, 0.83, 0.78, 0.10), 28, 0.03, false, -11)
	_add_soft_blob(_cached_world_root, Vector2(530, 1500), Vector2(120, 92), Color(0.96, 0.91, 0.83, 0.07), 26, 0.03, false, -11)


func _add_samsun_wave_gate() -> void:
	var center := Vector2(820, 1500)
	_add_samsun_paper_pad(center, Vector2(188, 78), Color(0.62, 0.83, 0.78, 0.15), Color(0.68, 0.40, 1.0, 0.18), "world_tiles.samsun_wave_start_pad")
	for index in range(2):
		var ring := Line2D.new()
		ring.width = 5.0 - float(index)
		ring.default_color = Color(0.68, 0.40, 1.0, 0.15 - (float(index) * 0.04))
		ring.z_index = -9
		ring.joint_mode = Line2D.LINE_JOINT_ROUND
		ring.begin_cap_mode = Line2D.LINE_CAP_ROUND
		ring.end_cap_mode = Line2D.LINE_CAP_ROUND
		var radius := Vector2(148 + (index * 34), 54 + (index * 18))
		for point_index in range(30):
			var angle := TAU * float(point_index) / 29.0
			ring.add_point(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
		ring.set_meta("asset_slot", "fx.samsun_wave_start_ring_%02d" % index)
		ring.set_meta("base_color", ring.default_color)
		goal_visual_registered.emit("fx.samsun_wave_start_ring", ring)
		_get_props(_cached_world_root).add_child(ring)
	for index in range(4):
		var shard := Polygon2D.new()
		var offset := Vector2(-72 + (index * 48), -48 + (abs(1.5 - float(index)) * 12.0))
		shard.position = center + offset
		shard.color = Color(0.62, 0.83, 0.78, 0.26)
		shard.z_index = 1
		shard.polygon = PackedVector2Array([
			Vector2(0, -18),
			Vector2(10, 0),
			Vector2(0, 18),
			Vector2(-10, 0),
		])
		shard.set_meta("asset_slot", "fx.samsun_wave_start_shard_%02d" % index)
		shard.set_meta("base_color", shard.color)
		shard.set_meta("ambient_bob", true)
		shard.set_meta("base_pos", shard.position)
		shard.set_meta("phase", float(index) * 0.5)
		shard.set_meta("bob_amount", 1.8)
		goal_visual_registered.emit("fx.samsun_wave_start_shard", shard)
		_get_props(_cached_world_root).add_child(shard)


func _add_samsun_paper_cut_edges() -> void:
	_add_samsun_soft_edge_line([
		Vector2(80, 872),
		Vector2(300, 840),
		Vector2(560, 884),
		Vector2(840, 850),
		Vector2(1120, 888),
		Vector2(1520, 852),
	], 18.0, Color(0.96, 0.91, 0.83, 0.18), -12, "world_tiles.samsun_harbor_foam_edge")
	_add_samsun_soft_edge_line([
		Vector2(160, 1472),
		Vector2(420, 1448),
		Vector2(720, 1480),
		Vector2(1040, 1454),
		Vector2(1420, 1478),
	], 14.0, Color(0.48, 0.32, 0.22, 0.15), -12, "world_tiles.samsun_civic_front_edge")


func _add_samsun_soft_edge_line(points: Array, width: float, color: Color, z_index: int, slot_id := "") -> void:
	var edge := Line2D.new()
	edge.width = width
	edge.default_color = color
	edge.z_index = z_index
	edge.joint_mode = Line2D.LINE_JOINT_ROUND
	edge.begin_cap_mode = Line2D.LINE_CAP_ROUND
	edge.end_cap_mode = Line2D.LINE_CAP_ROUND
	for point in points:
		edge.add_point(point)
	if slot_id != "":
		edge.set_meta("asset_slot", slot_id)
	if slot_id.contains("wake") or slot_id.contains("foam"):
		edge.set_meta("ambient_bob", true)
		edge.set_meta("base_pos", Vector2.ZERO)
		edge.set_meta("phase", fmod(points[0].x + points[0].y, TAU))
		edge.set_meta("bob_amount", 0.8)
		edge.set_meta("line_pulse", true)
		edge.set_meta("base_alpha", color.a)
		edge.set_meta("pulse_amount", 0.012)
	_get_props(_cached_world_root).add_child(edge)


func _add_samsun_harbor_wave_bands() -> void:
	for index in range(3):
		var y := 190.0 + float(index) * 185.0
		var wave := Line2D.new()
		wave.width = 18.0
		wave.default_color = Color(0.75, 0.93, 1.0, 0.11)
		wave.z_index = -14
		wave.joint_mode = Line2D.LINE_JOINT_ROUND
		wave.begin_cap_mode = Line2D.LINE_CAP_ROUND
		wave.end_cap_mode = Line2D.LINE_CAP_ROUND
		for step in range(8):
			var x := -80.0 + float(step) * 260.0
			wave.add_point(Vector2(x, y + sin(float(step) * 0.88 + float(index)) * 16.0))
		wave.set_meta("asset_slot", "world_tiles.samsun_harbor_wave_%02d" % index)
		wave.set_meta("ambient_bob", true)
		wave.set_meta("base_pos", Vector2.ZERO)
		wave.set_meta("phase", float(index) * 0.75)
		wave.set_meta("bob_amount", 1.2)
		wave.set_meta("line_pulse", true)
		wave.set_meta("base_alpha", wave.default_color.a)
		wave.set_meta("pulse_amount", 0.014)
		_get_props(_cached_world_root).add_child(wave)


func _add_samsun_atmosphere_washes() -> void:
	_add_soft_blob(_cached_world_root, Vector2(800, 490), Vector2(760, 170), Color(0.96, 0.91, 0.83, 0.055), 28, 0.02, false, -13)
	_add_soft_blob(_cached_world_root, Vector2(815, 1070), Vector2(470, 260), Color(0.62, 0.83, 0.78, 0.045), 28, 0.03, false, -9)
	_add_soft_blob(_cached_world_root, Vector2(535, 1540), Vector2(360, 170), Color(0.95, 0.75, 0.39, 0.040), 28, 0.03, false, -9)


func _add_samsun_path_cap(center: Vector2, radius: Vector2, color: Color, slot_id := "") -> void:
	var cap := Polygon2D.new()
	cap.position = center
	cap.color = color
	cap.z_index = -10
	cap.polygon = _ellipse_points(radius, 28)
	if slot_id != "":
		cap.set_meta("asset_slot", slot_id)
	_get_props(_cached_world_root).add_child(cap)


func _add_samsun_node_shadow(center: Vector2, radius: Vector2, slot_id := "") -> void:
	var shadow := Polygon2D.new()
	shadow.position = center + Vector2(0, 54)
	shadow.color = Color(0.05, 0.06, 0.07, 0.14)
	shadow.z_index = -2
	shadow.polygon = _ellipse_points(radius, 24)
	if slot_id != "":
		shadow.set_meta("asset_slot", slot_id)
	_get_props(_cached_world_root).add_child(shadow)


func _add_samsun_environment_clusters() -> void:
	var foliage_tint := Color(0.72, 0.94, 0.70, 0.34)
	var warm_foliage_tint := Color(0.94, 0.76, 0.46, 0.28)
	_add_samsun_env_prop(_textures.BLOCK_BUSH_SMALL_TEXTURE, Vector2(215, 1060), Vector2(0.78, 0.78), foliage_tint, "world_props.samsun_bush_left_a")
	_add_samsun_env_prop(_textures.BLOCK_BUSH_LARGE_TEXTURE, Vector2(1380, 1100), Vector2(0.86, 0.86), foliage_tint, "world_props.samsun_bush_right_a")
	_add_samsun_env_prop(_textures.BLOCK_TREE_GREEN_TEXTURE, Vector2(250, 1650), Vector2(0.80, 0.80), Color(0.78, 0.98, 0.76, 0.26), "world_props.samsun_tree_front_left")
	_add_samsun_env_prop(_textures.BLOCK_TREE_ORANGE_TEXTURE, Vector2(1320, 1640), Vector2(-0.74, 0.74), warm_foliage_tint, "world_props.samsun_tree_front_right")
	_add_samsun_env_prop(_textures.BLOCK_FENCE_SINGLE_TEXTURE, Vector2(1080, 1460), Vector2(0.72, 0.72), Color(1.0, 0.86, 0.62, 0.30), "world_props.samsun_small_fence_a")
	_add_samsun_env_prop(_textures.BLOCK_FENCE_SINGLE_TEXTURE, Vector2(440, 1090), Vector2(-0.68, 0.68), Color(1.0, 0.86, 0.62, 0.26), "world_props.samsun_small_fence_b")


func _add_samsun_env_prop(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint: Color, slot_id := "") -> void:
	var sprite := _add_kenney_prop(texture, pos, scale_value, tint, false, slot_id)
	sprite.z_index = -1


func _add_samsun_paper_asset_layer() -> void:
	# Dawn sky backdrop (rift energy glow, sunrise) — en arka katman
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_SKY_SAMSUN_TEXTURE, Vector2(800, 380), Vector2(1.0, 1.0), Color(1, 1, 1, 0.50), -18, "paperworld.samsun_sky_backdrop", Vector2(0.5, 0.1), -20.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_SKY_LIFE_TEXTURE, Vector2(800, 360), Vector2(1.08, 1.08), Color(1, 1, 1, 0.62), -17, "paperworld.samsun_sky_life", Vector2(8.0, 0.4), -18.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_DISTANT_TOWN_TEXTURE, Vector2(800, 565), Vector2(1.05, 1.05), Color(1, 1, 1, 0.62), -16, "paperworld.samsun_distant_town", Vector2.ZERO, -13.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_SKYLINE_DEPTH_TEXTURE, Vector2(805, 615), Vector2(1.08, 1.08), Color(1, 1, 1, 0.70), -15, "paperworld.samsun_skyline_depth", Vector2(1.0, 0.1), -10.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_HARBOR_WATER_TEXTURE, Vector2(390, 760), Vector2(0.84, 0.84), Color(1, 1, 1, 0.76), -14, "paperworld.samsun_harbor_water", Vector2.ZERO, -8.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_COAST_DETAILS_TEXTURE, Vector2(790, 825), Vector2(1.0, 1.0), Color(1, 1, 1, 0.66), -13, "paperworld.samsun_coast_details", Vector2(2.2, 0.4), -6.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_HARBOR_DOCK_PROPS_TEXTURE, Vector2(392, 820), Vector2(0.96, 0.96), Color(1, 1, 1, 0.78), -7, "paperworld.samsun_harbor_dock_props", Vector2(0.8, 0.2), 2.5)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_COASTAL_LIFE_TEXTURE, Vector2(940, 1015), Vector2(1.02, 1.02), Color(1, 1, 1, 0.66), -7, "paperworld.samsun_coastal_life", Vector2(1.2, 0.2), 3.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_TERRAIN_TEXTURE, Vector2(794, 1114), Vector2(1.18, 1.18), Color(1, 1, 1, 0.94), -15, "paperworld.samsun_terrain_island", Vector2.ZERO, -3.5)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_SIDE_PATHS_TEXTURE, Vector2(760, 1160), Vector2(1.06, 1.06), Color(1, 1, 1, 0.64), -12, "paperworld.samsun_side_paths", Vector2.ZERO, -2.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_MAIN_PATH_TEXTURE, Vector2(726, 1370), Vector2(0.78, 0.78), Color(1, 1, 1, 0.86), -13, "paperworld.samsun_main_path", Vector2.ZERO, -1.5)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_ROUTE_BEADS_TEXTURE, Vector2(775, 1250), Vector2(1.02, 1.02), Color(1, 1, 1, 0.72), -9, "paperworld.samsun_route_beads", Vector2(1.1, 0.2), 1.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_SAFE_CLEARINGS_TEXTURE, Vector2(805, 1335), Vector2(1.0, 1.0), Color(1, 1, 1, 0.66), -8, "paperworld.samsun_safe_clearings", Vector2.ZERO, 1.5)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_CIVIC_CLUSTER_TEXTURE, Vector2(1015, 1360), Vector2(0.58, 0.58), Color(1, 1, 1, 0.72), -6, "paperworld.samsun_civic_cluster", Vector2.ZERO, 2.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_DISCOVERY_PROPS_TEXTURE, Vector2(795, 1110), Vector2(0.92, 0.92), Color(1, 1, 1, 0.72), -4, "paperworld.samsun_discovery_props", Vector2.ZERO, 3.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_HARBOR_BOATS_TEXTURE, Vector2(360, 650), Vector2(0.82, 0.82), Color(1, 1, 1, 0.72), -5, "paperworld.samsun_harbor_boats", Vector2.ZERO, 3.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_SIGNAL_RIDGE_TEXTURE, Vector2(1130, 660), Vector2(0.78, 0.78), Color(1, 1, 1, 0.62), -6, "paperworld.samsun_signal_ridge", Vector2.ZERO, -5.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_VISTA_FLAGS_TEXTURE, Vector2(800, 900), Vector2(0.98, 0.98), Color(1, 1, 1, 0.76), -4, "paperworld.samsun_vista_flags", Vector2(1.4, 0.25), 4.5)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_HARBOR_TEXTURE, Vector2(360, 760), Vector2(0.86, 0.86), Color(1, 1, 1, 0.90), -3, "paperworld.samsun_harbor_landmark", Vector2.ZERO, 4.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_TELEGRAPH_TEXTURE, Vector2(1190, 770), Vector2(0.78, 0.78), Color(1, 1, 1, 0.88), -3, "paperworld.samsun_telegraph_landmark", Vector2.ZERO, 4.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_PEOPLE_TEXTURE, Vector2(530, 1455), Vector2(0.78, 0.78), Color(1, 1, 1, 0.90), -3, "paperworld.samsun_people_plaza", Vector2.ZERO, 5.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_RIFT_TEXTURE, Vector2(800, 980), Vector2(0.72, 0.72), Color(1, 1, 1, 0.90), -2, "paperworld.samsun_rift_core", Vector2.ZERO, 5.0)
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_WAVE_GATE_TEXTURE, Vector2(820, 1478), Vector2(0.76, 0.76), Color(1, 1, 1, 0.86), -2, "paperworld.samsun_wave_gate", Vector2.ZERO, 5.0)
	# Dekoratif pusula — sağ üst köşede harita hissi
	_add_paper_cutout_asset(_cached_world_root, _textures.SAMSUN_PAPER_MAP_COMPASS_TEXTURE, Vector2(1280, 240), Vector2(0.48, 0.48), Color(1, 1, 1, 0.34), 2, "paperworld.samsun_map_compass", Vector2(-0.6, 0.2), 12.0)
	_add_foreground_paper_cutout_asset(_textures.SAMSUN_PAPER_FOREGROUND_FRAME_TEXTURE, Vector2(800, 1835), Vector2(1.34, 1.34), Color(1, 1, 1, 0.88), 4, "paperworld.samsun_foreground_frame", 18.0)


func _add_samsun_harbor_identity() -> void:
	_add_samsun_arrival_glow(Vector2(360, 690))
	_add_samsun_ship_silhouette(Vector2(328, 570), 0.74, "landmarks.samsun_bandirma_silhouette")
	_add_samsun_pier(Vector2(300, 742), "landmarks.samsun_harbor_pier")
	_add_samsun_soft_edge_line([
		Vector2(190, 760),
		Vector2(300, 742),
		Vector2(430, 768),
		Vector2(520, 740),
	], 10.0, Color(0.96, 0.91, 0.83, 0.22), -8, "landmarks.samsun_harbor_wake")


func _add_samsun_node_identity_details() -> void:
	_add_samsun_landmark_symbols()
	_add_samsun_telegraph_detail(Vector2(1190, 820))
	_add_samsun_people_plaza(Vector2(530, 1500))
	_add_samsun_rift_focus_rings(Vector2(800, 1000))


func _add_samsun_landmark_symbols() -> void:
	_add_samsun_harbor_symbol(Vector2(360, 820))
	_add_samsun_people_symbol(Vector2(530, 1500))
	_add_samsun_signal_symbol(Vector2(1190, 820))


func _add_samsun_harbor_symbol(center: Vector2) -> void:
	var ink := Color(0.10, 0.15, 0.18, 0.28)
	_add_room_rect(_cached_world_root, center + Vector2(-170, -18), Vector2(12, 96), ink, -1, "landmarks.samsun_harbor_bollard_a")
	_add_room_rect(_cached_world_root, center + Vector2(-126, 4), Vector2(12, 74), ink, -1, "landmarks.samsun_harbor_bollard_b")
	_add_samsun_soft_edge_line([
		center + Vector2(-164, -4),
		center + Vector2(-144, 24),
		center + Vector2(-120, 18),
	], 6.0, Color(0.96, 0.91, 0.83, 0.20), -1, "landmarks.samsun_harbor_rope")
	var pennant := Polygon2D.new()
	pennant.position = center + Vector2(112, -72)
	pennant.color = Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.42)
	pennant.z_index = -1
	pennant.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(72, 12),
		Vector2(8, 34),
	])
	pennant.set_meta("asset_slot", "landmarks.samsun_harbor_pennant")
	_get_props(_cached_world_root).add_child(pennant)


func _add_samsun_people_symbol(center: Vector2) -> void:
	var dot_color := Color(0.12, 0.16, 0.19, 0.22)
	var points := [
		Vector2(-64, -24),
		Vector2(-22, -44),
		Vector2(24, -42),
		Vector2(68, -18),
		Vector2(0, -4),
	]
	for index in range(points.size()):
		var dot := Polygon2D.new()
		dot.position = center + points[index]
		dot.color = dot_color
		dot.z_index = -1
		dot.polygon = _ellipse_points(Vector2(13, 13), 16)
		dot.set_meta("asset_slot", "landmarks.samsun_people_silhouette_%02d" % index)
		_get_props(_cached_world_root).add_child(dot)
	_add_samsun_soft_edge_line([
		center + Vector2(-78, 10),
		center + Vector2(-22, 32),
		center + Vector2(34, 30),
		center + Vector2(86, 8),
	], 8.0, Color(0.12, 0.16, 0.19, 0.14), -1, "landmarks.samsun_people_listening_arc")


func _add_samsun_signal_symbol(center: Vector2) -> void:
	_add_samsun_ring(center + Vector2(0, -124), Vector2(62, 24), 5.0, Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.16), -1, "landmarks.samsun_telegraph_signal_a")
	_add_samsun_ring(center + Vector2(0, -124), Vector2(104, 42), 4.0, Color(_colors.RIFT_BLUE.r, _colors.RIFT_BLUE.g, _colors.RIFT_BLUE.b, 0.10), -1, "landmarks.samsun_telegraph_signal_b")


func _add_samsun_telegraph_detail(center: Vector2) -> void:
	var wire_color := Color(0.10, 0.15, 0.18, 0.34)
	for x_offset in [-120.0, 118.0]:
		var pole := Polygon2D.new()
		pole.position = center + Vector2(x_offset, -18)
		pole.color = wire_color
		pole.z_index = -1
		pole.polygon = PackedVector2Array([
			Vector2(-6, -92),
			Vector2(6, -92),
			Vector2(6, 62),
			Vector2(-6, 62),
		])
		pole.set_meta("asset_slot", "landmarks.samsun_telegraph_pole")
		_get_props(_cached_world_root).add_child(pole)
	_add_samsun_soft_edge_line([
		center + Vector2(-128, -105),
		center + Vector2(-32, -132),
		center + Vector2(44, -126),
		center + Vector2(126, -104),
	], 5.0, wire_color, -1, "landmarks.samsun_telegraph_wire")
	_add_samsun_soft_edge_line([
		center + Vector2(-118, -72),
		center + Vector2(-22, -98),
		center + Vector2(54, -92),
		center + Vector2(118, -70),
	], 4.0, Color(0.10, 0.15, 0.18, 0.22), -1, "landmarks.samsun_telegraph_wire_low")


func _add_samsun_people_plaza(center: Vector2) -> void:
	_add_samsun_ring(center + Vector2(0, 30), Vector2(205, 86), 13.0, Color(0.96, 0.91, 0.83, 0.18), -10, "landmarks.samsun_people_plaza_ring")
	_add_samsun_soft_edge_line([
		center + Vector2(-130, -26),
		center + Vector2(-54, -54),
		center + Vector2(36, -54),
		center + Vector2(124, -22),
	], 9.0, Color(0.95, 0.75, 0.39, 0.16), -1, "landmarks.samsun_people_banner_line")


func _add_samsun_rift_focus_rings(center: Vector2) -> void:
	_add_samsun_ring(center, Vector2(220, 142), 8.0, Color(0.62, 0.83, 0.78, 0.16), -9, "fx.samsun_rift_outer_ring")
	_add_samsun_ring(center + Vector2(0, 4), Vector2(128, 82), 7.0, Color(0.96, 0.91, 0.83, 0.14), -8, "fx.samsun_rift_inner_ring")


func _add_samsun_ring(center: Vector2, radius: Vector2, width: float, color: Color, z_index: int, slot_id := "") -> void:
	var ring := Line2D.new()
	ring.width = width
	ring.default_color = color
	ring.z_index = z_index
	ring.joint_mode = Line2D.LINE_JOINT_ROUND
	ring.begin_cap_mode = Line2D.LINE_CAP_ROUND
	ring.end_cap_mode = Line2D.LINE_CAP_ROUND
	for index in range(33):
		var angle := TAU * float(index) / 32.0
		ring.add_point(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	if slot_id != "":
		ring.set_meta("asset_slot", slot_id)
	ring.set_meta("line_pulse", true)
	ring.set_meta("base_alpha", color.a)
	ring.set_meta("phase", fmod(center.x * 0.01 + center.y * 0.013, TAU))
	ring.set_meta("pulse_amount", 0.018)
	_get_props(_cached_world_root).add_child(ring)


func _add_samsun_arrival_glow(center: Vector2) -> void:
	_add_soft_blob(_cached_world_root, center, Vector2(250, 88), Color(0.95, 0.75, 0.39, 0.055), 28, 0.02, false, -9)
	_add_soft_blob(_cached_world_root, center + Vector2(0, 28), Vector2(145, 46), Color(0.96, 0.91, 0.83, 0.050), 24, 0.02, false, -8)


func _add_samsun_ship_silhouette(pos: Vector2, scale_value: float, slot_id := "") -> void:
	var root := Node2D.new()
	root.position = pos
	root.z_index = -7
	root.set_meta("ambient_bob", true)
	root.set_meta("base_pos", pos)
	root.set_meta("phase", 0.4)
	root.set_meta("bob_amount", 1.4)
	if slot_id != "":
		root.set_meta("asset_slot", slot_id)

	var ink := Color(0.12, 0.16, 0.19, 0.54)
	var hull := Polygon2D.new()
	hull.color = ink
	hull.polygon = _scaled_points(PackedVector2Array([
		Vector2(-170, 16),
		Vector2(145, 16),
		Vector2(92, 58),
		Vector2(-118, 62),
	]), scale_value)
	root.add_child(hull)

	var cabin := Polygon2D.new()
	cabin.position = Vector2(-56, -28) * scale_value
	cabin.color = Color(0.12, 0.16, 0.19, 0.42)
	cabin.polygon = _scaled_points(PackedVector2Array([
		Vector2.ZERO,
		Vector2(112, 0),
		Vector2(126, 44),
		Vector2(-12, 44),
	]), scale_value)
	root.add_child(cabin)

	var mast := Polygon2D.new()
	mast.position = Vector2(18, -104) * scale_value
	mast.color = ink
	mast.polygon = _scaled_points(PackedVector2Array([
		Vector2(-4, 0),
		Vector2(4, 0),
		Vector2(4, 124),
		Vector2(-4, 124),
	]), scale_value)
	root.add_child(mast)

	var flag := Polygon2D.new()
	flag.position = Vector2(26, -102) * scale_value
	flag.color = Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.62)
	flag.polygon = _scaled_points(PackedVector2Array([
		Vector2.ZERO,
		Vector2(54, 8),
		Vector2(48, 32),
		Vector2(0, 26),
	]), scale_value)
	root.add_child(flag)

	_get_props(_cached_world_root).add_child(root)


func _add_samsun_pier(center: Vector2, slot_id := "") -> void:
	_add_samsun_soft_edge_line([
		center + Vector2(-112, 16),
		center + Vector2(-34, -6),
		center + Vector2(42, 16),
		center + Vector2(126, -2),
	], 18.0, Color(0.48, 0.32, 0.22, 0.30), -8, "%s.deck" % slot_id)
	for index in range(4):
		var post := Polygon2D.new()
		post.position = center + Vector2(-92 + index * 72, 10 + (index % 2) * 12)
		post.color = Color(0.24, 0.19, 0.16, 0.38)
		post.z_index = -7
		post.polygon = PackedVector2Array([
			Vector2(-7, -32),
			Vector2(7, -32),
			Vector2(7, 34),
			Vector2(-7, 34),
		])
		post.set_meta("asset_slot", "%s.post_%02d" % [slot_id, index])
		_get_props(_cached_world_root).add_child(post)
