extends Node

# Room Builder — world_builder.gd'den ayrıştırılmış room zone inşa kodu
# build_room(world_root, builder) ile çağrılır
# Ortak yardımcı fonksiyonlar _builder (world_builder) üzerinden çağrılır

@onready var _colors := preload("res://scripts/colors.gd")
@onready var _textures := preload("res://scripts/textures.gd")

const WORLD_SIZE := Vector2(1600, 2200)

# world_builder referansı — build_room() tarafından set edilir
var _builder: Node


# ============================================================
# PUBLIC API
# ============================================================

# Ana giriş noktası — world_builder build_world() içindeki "room" case'inden çağrılır
func build_room(world_root: Node, builder: Node) -> void:
	_builder = builder
	_add_open_world_start_depth_pass(world_root)
	_add_open_world_start_asset_layer(world_root)
	_add_room_paper_asset_layer(world_root)
	_add_room_depth_pass(world_root)
	_snap_room_characters_to_floor(world_root)
	_decorate_room(world_root)


# ============================================================
# ROOM FLOOR & SHAPE YARDIMCILARI
# ============================================================

# Room floor rect
func _add_room_floor_rect(world_root: Node, floor_top_y: float) -> void:
	var floor_height := WORLD_SIZE.y - floor_top_y
	_builder._add_room_rect(world_root, Vector2(0, floor_top_y), Vector2(WORLD_SIZE.x, floor_height), _colors.DESIGN_ROOM_FLOOR, -9, "room.depth.floor")


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
	return _builder._add_room_polygon(world_root, pos, points, color, z_index, slot_id)


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
	_builder._get_props(world_root).add_child(glow)


# ============================================================
# ROOM DERİNLİK KATMANLARI
# ============================================================

func _get_room_floor_top_y() -> float:
	return 1580.0


func _add_room_depth_pass(world_root: Node) -> void:
	var floor_top_y := _get_room_floor_top_y()
	_builder._add_room_rect(world_root, Vector2.ZERO, WORLD_SIZE, _colors.DESIGN_DEEP_NAVY, -10, "room.depth.wall")
	_add_room_floor_rect(world_root, floor_top_y)
	_builder._add_room_rect(world_root, Vector2(980, 1200), Vector2(280, 120), _colors.DESIGN_WEATHERED_WALNUT, -8, "room.depth.desk_zone")
	_builder._add_room_rect(world_root, Vector2(0, 0), Vector2(80, floor_top_y), _colors.DESIGN_ROOM_FOREGROUND, -7, "room.depth.bookshelf_silhouette")
	_add_room_bottom_rounded_rect(world_root, Vector2(WORLD_SIZE.x - 140, 270), Vector2(100, 200), 20.0, Color(_colors.DESIGN_ROOM_FOREGROUND.r, _colors.DESIGN_ROOM_FOREGROUND.g, _colors.DESIGN_ROOM_FOREGROUND.b, 0.60), -7, "room.depth.window_curtain")
	_add_room_lamp_glow(world_root, Vector2(860, 1278))


# ============================================================
# ROOM PAPER CUTOUT KATMANLARI
# ============================================================

func _add_open_world_start_depth_pass(world_root: Node) -> void:
	_builder._add_room_rect(world_root, Vector2(-220, -620), Vector2(WORLD_SIZE.x + 440, 650), Color("#ecdabe"), -21, "paperopening.depth.sky_overscan")
	_builder._add_room_rect(world_root, Vector2(-220, WORLD_SIZE.y - 10), Vector2(WORLD_SIZE.x + 440, 640), Color("#F5E8D3"), -21, "paperopening.depth.paper_overscan")
	_builder._add_room_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color("#ecdabe"), -20, "paperopening.depth.sky")
	_builder._add_room_rect(world_root, Vector2(0, 660), Vector2(WORLD_SIZE.x, 400), Color("#d1b996"), -19, "paperopening.depth.distant_hills")
	_builder._add_room_rect(world_root, Vector2(0, 980), Vector2(WORLD_SIZE.x, 320), Color("#9a875c"), -18, "paperopening.depth.mid_ground")
	_builder._add_room_rect(world_root, Vector2(0, 1240), Vector2(WORLD_SIZE.x, 440), Color("#685934"), -17, "paperopening.depth.near_ground")
	_builder._add_room_rect(world_root, Vector2(0, 1530), Vector2(WORLD_SIZE.x, 670), Color("#F5E8D3"), -17, "paperopening.depth.paper_base")
	_builder._add_room_rect(world_root, Vector2(0, 950), Vector2(WORLD_SIZE.x, 8), Color("#F5E8D3"), -16, "paperopening.depth.horizon_cut_1")
	_builder._add_room_rect(world_root, Vector2(0, 1050), Vector2(WORLD_SIZE.x, 8), Color("#F5E8D3"), -16, "paperopening.depth.horizon_cut_2")
	_builder._add_room_rect(world_root, Vector2(0, 1150), Vector2(WORLD_SIZE.x, 8), Color("#ddd1be"), -16, "paperopening.depth.horizon_cut_3")
	_builder._add_room_rect(world_root, Vector2(0, 1220), Vector2(WORLD_SIZE.x, 8), Color("#c5b59f"), -16, "paperopening.depth.horizon_cut_4")
	_builder._add_room_rect(world_root, Vector2(0, 1370), Vector2(WORLD_SIZE.x, 8), Color("#b09c82"), -16, "paperopening.depth.horizon_cut_5")


func _add_open_world_start_asset_layer(world_root: Node) -> void:
	_builder._add_paper_cutout_asset(world_root, _textures.OPENING_PAPER_BENCHMARK_TEXTURE, Vector2(800, 1130), Vector2(1.09, 1.09), Color(1, 1, 1, 0.96), -14, "paperopening.benchmark_world", Vector2.ZERO, -3.0)


func _add_room_paper_asset_layer(world_root: Node) -> void:
	# Duvar arka planı — en uzak katman
	_builder._add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_WALL_TEXTURE,
		Vector2(800, 410), Vector2(1.0, 1.0), Color(1, 1, 1, 0.86), -6,
		"paperroom.wall_window", Vector2.ZERO, -2.0)
	# Duvar hikaye çerçeveleri
	_builder._add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_WALL_STORY_TEXTURE,
		Vector2(460, 320), Vector2(0.90, 0.90), Color(1, 1, 1, 0.78), -5,
		"paperroom.wall_story", Vector2.ZERO, -1.8)
	# Zemin yüzeyi
	_builder._add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_TERRAIN_TEXTURE,
		Vector2(800, 1580), Vector2(1.05, 1.05), Color(1, 1, 1, 0.88), -9,
		"paperroom.terrain", Vector2.ZERO, -3.0)
	# Kitaplık — sol kenar
	_builder._add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_SHELF_TEXTURE,
		Vector2(60, 900), Vector2(0.82, 0.82), Color(1, 1, 1, 0.84), -7,
		"paperroom.shelf", Vector2.ZERO, -1.5)
	# Masa eşyaları
	_builder._add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_DESK_CLUTTER_TEXTURE,
		Vector2(1100, 1260), Vector2(0.78, 0.78), Color(1, 1, 1, 0.82), -4,
		"paperroom.desk_clutter", Vector2.ZERO, -1.0)
	# Çalışma köşesi
	_builder._add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_STUDY_NOOK_TEXTURE,
		Vector2(860, 1280), Vector2(0.80, 0.80), Color(1, 1, 1, 0.86), -3,
		"paperroom.study_nook", Vector2.ZERO, -0.8)
	# Yatak
	_builder._add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_BED_TEXTURE,
		Vector2(340, 1380), Vector2(0.84, 0.84), Color(1, 1, 1, 0.88), -4,
		"paperroom.bed", Vector2.ZERO, -1.2)
	# Halı
	_builder._add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_FLOOR_RUG_TEXTURE,
		Vector2(800, 1620), Vector2(0.92, 0.92), Color(1, 1, 1, 0.76), -8,
		"paperroom.floor_rug", Vector2.ZERO, -2.5)
	# Kitap portalı — zaman yolculuğu geçiş noktası
	_builder._add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_BOOK_PORTAL_TEXTURE,
		Vector2(800, 1100), Vector2(0.72, 0.72), Color(1, 1, 1, 0.92), -2,
		"paperroom.book_portal", Vector2.ZERO, 0.5)
	# Ön plan çerçeve — en yakın katman
	_builder._add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_FOREGROUND_FRAME_TEXTURE,
		Vector2(800, 1850), Vector2(1.10, 1.10), Color(1, 1, 1, 0.88), 4,
		"paperroom.foreground_frame", Vector2.ZERO, 2.0)


# ============================================================
# ROOM DEKORASYON
# ============================================================

func _decorate_room(world_root: Node) -> void:
	# Sıcak gün batımı ışığı - sahne 1.png referansı (%73 turuncu)
	_builder._add_soft_blob(world_root, Vector2(700, 600), Vector2(600, 400), Color(1.0, 0.76, 0.42, 0.06), 24, 0.02, true, 5)
	_builder._add_soft_blob(world_root, Vector2(1180, 1320), Vector2(240, 170), Color(1.0, 0.84, 0.46, 0.10), 24, 0.03, true, 5)
	_builder._add_soft_blob(world_root, Vector2(360, 1470), Vector2(170, 110), Color(0.42, 0.58, 0.88, 0.08), 22, 0.03, true, 5)
	_builder._add_soft_blob(world_root, Vector2(690, 1310), Vector2(190, 120), Color(1.0, 0.76, 0.38, 0.08), 22, 0.03, true, 5)
	# Sıcak ışık havuzu - merkez alan aydınlatması
	_builder._add_light_pool(world_root, Vector2(800, 1100), Vector2(360, 180), Color(1.0, 0.78, 0.42, 0.08))
	# Altın tozu parçacıkları - rüya atmosferi
	_builder._add_mote_cluster(Vector2(1180, 1320), Color(1.0, 0.84, 0.46, 0.13), 5)
	_builder._add_mote_cluster(Vector2(720, 1300), Color(0.72, 0.92, 1.0, 0.10), 5)
	_builder._add_mote_cluster(Vector2(500, 900), Color(1.0, 0.80, 0.50, 0.06), 8)
	_builder._add_mote_cluster(Vector2(1100, 800), Color(0.92, 0.88, 0.70, 0.05), 6)
	# Yumuşak kenar ışığı - sıcak atmosfer katmanı
	_builder._add_soft_blob(world_root, Vector2(400, 500), Vector2(250, 100), Color(0.92, 0.72, 0.50, 0.04), 24, 0.01, true, 4)
	_builder._add_soft_blob(world_root, Vector2(1200, 500), Vector2(250, 100), Color(0.92, 0.72, 0.50, 0.04), 24, 0.01, true, 4)


# ============================================================
# ROOM KARAKTER KONUMLARI
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
