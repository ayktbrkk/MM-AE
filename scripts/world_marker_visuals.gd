# scripts/world_marker_visuals.gd
# Marker görsel inşa helper'ları — world_marker.gd'den ayrıştırıldı.
# Statik fonksiyonlar — her yerden çağrılabilir.
# ============================================
# MMAE - Bandırma Yolculuğu
# Godot 4.6 · GDScript 2.0 · Static Typing
# ============================================
extends Node
class_name MarkerVisuals


# -----------------------------------------------------------------------------
# Renk sistemi (colors.gd merkezi dosyadan)
# -----------------------------------------------------------------------------
const _Colors := preload("res://scripts/colors.gd")

static var POP_GOLD: Color:
	get: return _Colors.POP_GOLD
static var POP_TURQUOISE: Color:
	get: return _Colors.POP_TURQUOISE
static var POP_CRIMSON: Color:
	get: return _Colors.POP_CRIMSON
static var RIFT_BLUE: Color:
	get: return _Colors.RIFT_BLUE
static var DESIGN_CREAM_PAPER: Color:
	get: return _Colors.DESIGN_CREAM_PAPER
static var CEL_OUTLINE: Color:
	get: return _Colors.CEL_OUTLINE


# -----------------------------------------------------------------------------
# Texture sabitleri (marker iconlari icin) — procedural olusturulur
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
# Public API — marker visual oluşturma
# -----------------------------------------------------------------------------

## Creates a complete marker visual node structure with all children.
## zone_id parametresi, zone-specific setpiece ve stil uygulamaları içindir;
## boş string ("") gönderilirse zone stilleri uygulanmaz.
static func create_marker_visual(
	kind: String,
	title: String,
	position: Vector2,
	zone_id: String = ""
) -> Node2D:
	var marker := Node2D.new()
	marker.name = title
	marker.position = position

	# Gölge
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

	# Aktif işaret (parlama alanı)
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

	# Dış çerçeve (cel outline)
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

	# Işıltı halkası
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

	# Sol ışıltı
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

	# Sağ ışıltı
	var sparkle_right := Polygon2D.new()
	sparkle_right.position = Vector2(42, -22)
	sparkle_right.color = Color(1, 1, 1, 0.18)
	sparkle_right.polygon = sparkle_left.polygon
	marker.add_child(sparkle_right)

	# Etiket dış çerçevesi
	var label_outline := Polygon2D.new()
	label_outline.position = Vector2(-174, 36)
	label_outline.color = Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.48)
	label_outline.polygon = _rounded_rect_points(Vector2(348, 104), 18.0)
	marker.add_child(label_outline)
	marker.set_meta("label_outline_node", label_outline)
	marker.set_meta("tooltip_base_pos", label_outline.position)

	# Etiket zemini
	var label_plate := Polygon2D.new()
	label_plate.position = Vector2(-170, 40)
	label_plate.color = Color(DESIGN_CREAM_PAPER.r, DESIGN_CREAM_PAPER.g, DESIGN_CREAM_PAPER.b, 0.985)
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
	label_icon.add_theme_color_override("font_color", Color(_Colors.DESIGN_STORY_INK.r, _Colors.DESIGN_STORY_INK.g, _Colors.DESIGN_STORY_INK.b, 0.98))
	marker.add_child(label_icon)
	marker.set_meta("label_icon_node", label_icon)

	# Marker isim etiketi
	var label := Label.new()
	label.position = Vector2(-88, 54)
	label.custom_minimum_size = Vector2(232, 70)
	label.text = title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", Color(_Colors.DESIGN_STORY_INK.r, _Colors.DESIGN_STORY_INK.g, _Colors.DESIGN_STORY_INK.b, 0.98))
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
	status_label.add_theme_color_override("font_color", Color(_Colors.DESIGN_CREAM_PAPER.r, _Colors.DESIGN_CREAM_PAPER.g, _Colors.DESIGN_CREAM_PAPER.b, 0.98))
	status_label.add_theme_color_override("font_outline_color", Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.88))
	status_label.add_theme_constant_override("outline_size", 2)
	marker.add_child(status_label)
	marker.set_meta("status_label_node", status_label)

	# Zone-specific setpiece ve stil uygulamaları
	if zone_id != "":
		_add_marker_setpiece(marker, kind, title, zone_id)
		if zone_id == "room":
			_apply_opening_marker_style(marker, kind)
		if zone_id == "samsun_rift":
			_apply_samsun_marker_style(marker, kind)

	return marker


## Updates marker visual state based on collection status.
static func update_collection_visual(marker_node: Node2D, collected: bool) -> void:
	if collected:
		marker_node.modulate = Color(0.5, 0.5, 0.5, 0.5)
	else:
		marker_node.modulate = Color.WHITE


## Sets up marker metadata for guidance system.
static func set_marker_metadata(marker_node: Node2D, marker_kind: String, title_key: String, text_key: String) -> void:
	marker_node.set_meta("kind", marker_kind)
	marker_node.set_meta("title_key", title_key)
	marker_node.set_meta("text_key", text_key)


# -----------------------------------------------------------------------------
# Setpiece dekorasyonu — zone'a göre marker görüntüsü
# -----------------------------------------------------------------------------

static func _add_marker_setpiece(marker: Node2D, kind: String, marker_name: String, zone_id: String) -> void:
	if zone_id == "room":
		if kind == "portal":
			_add_marker_quad(marker, Vector2(-52, 4), Vector2(44, 54), Color(0.94, 0.89, 0.72, 0.88))
			_add_marker_quad(marker, Vector2(8, 4), Vector2(44, 54), Color(0.98, 0.93, 0.76, 0.88))
			_add_marker_quad(marker, Vector2(-8, -2), Vector2(16, 60), Color(0.72, 0.56, 0.34, 0.92))
		elif kind == "unit":
			_add_marker_quad(marker, Vector2(-34, 2), Vector2(68, 52), Color(0.96, 0.92, 0.80, 0.86))
			_add_marker_quad(marker, Vector2(-24, -8), Vector2(48, 8), Color(0.85, 0.66, 0.28, 0.90))
	elif zone_id == "ship":
		if marker_name == "Üniforma":
			_add_marker_quad(marker, Vector2(-6, -26), Vector2(12, 62), Color(0.48, 0.34, 0.22, 0.92))
			_add_marker_quad(marker, Vector2(-36, 8), Vector2(72, 44), Color(0.24, 0.34, 0.46, 0.92))
		elif marker_name == "Harita Masası":
			_add_marker_quad(marker, Vector2(-54, 4), Vector2(108, 46), Color(0.58, 0.44, 0.30, 0.92))
			_add_marker_quad(marker, Vector2(-36, -12), Vector2(72, 26), Color(0.92, 0.84, 0.60, 0.92))
		elif kind == "decision":
			_add_marker_quad(marker, Vector2(-8, -32), Vector2(12, 74), Color(0.42, 0.30, 0.20, 0.94))
			_add_marker_triangle(marker, Vector2(12, -26), Vector2(58, 20), Color(0.95, 0.58, 0.28, 0.92))
	elif zone_id == "havza":
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
	elif zone_id == "amasya":
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
	elif zone_id == "kongreler":
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
	elif zone_id == "samsun_rift":
		if kind == "build_spot":
			_add_marker_quad(marker, Vector2(-18, -12), Vector2(36, 48), Color(0.46, 0.58, 0.72, 0.86))
			_add_marker_triangle(marker, Vector2(0, -34), Vector2(54, 32), Color(0.70, 0.84, 0.95, 0.82))
		elif kind == "wave_start":
			_add_marker_triangle(marker, Vector2(0, -24), Vector2(92, 54), Color(0.74, 0.42, 0.90, 0.28))
	elif zone_id == "ankara":
		if marker_name == "Meclis Notu":
			_add_marker_quad(marker, Vector2(-44, 4), Vector2(88, 42), Color(0.94, 0.88, 0.76, 0.92))
			_add_marker_quad(marker, Vector2(-18, -14), Vector2(36, 10), Color(0.72, 0.48, 0.26, 0.90))
		elif marker_name == "Telgraf Defteri":
			_add_marker_quad(marker, Vector2(-48, 8), Vector2(96, 28), Color(0.46, 0.34, 0.22, 0.94))
			_add_marker_quad(marker, Vector2(-26, -10), Vector2(52, 26), Color(0.94, 0.90, 0.80, 0.90))
		elif kind == "ankara_decision":
			_add_marker_quad(marker, Vector2(-20, -16), Vector2(40, 52), Color(0.64, 0.48, 0.30, 0.92))
			_add_marker_triangle(marker, Vector2(0, -34), Vector2(78, 30), Color(0.95, 0.72, 0.30, 0.90))
		elif kind == "build_spot":
			_add_marker_quad(marker, Vector2(-40, 18), Vector2(80, 14), Color(0.66, 0.50, 0.30, 0.90))
			_add_marker_quad(marker, Vector2(-8, -18), Vector2(16, 46), Color(0.60, 0.44, 0.26, 0.84))
	elif zone_id == "sakarya":
		if marker_name == "Karargah Notu":
			_add_marker_quad(marker, Vector2(-44, 4), Vector2(88, 42), Color(0.92, 0.86, 0.74, 0.92))
			_add_marker_quad(marker, Vector2(-18, -14), Vector2(36, 10), Color(0.68, 0.50, 0.28, 0.90))
		elif marker_name == "Cephe Telgrafı":
			_add_marker_quad(marker, Vector2(-48, 8), Vector2(96, 28), Color(0.48, 0.36, 0.24, 0.94))
			_add_marker_quad(marker, Vector2(-26, -10), Vector2(52, 26), Color(0.94, 0.90, 0.80, 0.90))
		elif kind == "sakarya_decision":
			_add_marker_quad(marker, Vector2(-20, -16), Vector2(40, 52), Color(0.62, 0.46, 0.28, 0.92))
			_add_marker_triangle(marker, Vector2(0, -34), Vector2(80, 32), Color(0.93, 0.68, 0.34, 0.90))
		elif kind == "build_spot":
			_add_marker_quad(marker, Vector2(-40, 18), Vector2(80, 14), Color(0.64, 0.48, 0.28, 0.90))
			_add_marker_quad(marker, Vector2(-8, -18), Vector2(16, 46), Color(0.60, 0.44, 0.26, 0.84))
	elif zone_id == "final":
		if marker_name == "Cumhuriyet Notu":
			_add_marker_quad(marker, Vector2(-44, 4), Vector2(88, 42), Color(0.96, 0.92, 0.82, 0.92))
			_add_marker_quad(marker, Vector2(-18, -14), Vector2(36, 10), Color(0.88, 0.60, 0.22, 0.90))
		elif marker_name == "Gelecek Defteri":
			_add_marker_quad(marker, Vector2(-48, 8), Vector2(96, 28), Color(0.50, 0.38, 0.24, 0.94))
			_add_marker_quad(marker, Vector2(-26, -10), Vector2(52, 26), Color(0.96, 0.92, 0.84, 0.92))
		elif kind == "final_decision":
			_add_marker_quad(marker, Vector2(-20, -16), Vector2(40, 52), Color(0.66, 0.50, 0.30, 0.92))
			_add_marker_triangle(marker, Vector2(0, -34), Vector2(84, 32), Color(0.98, 0.72, 0.28, 0.90))
		elif kind == "build_spot":
			_add_marker_quad(marker, Vector2(-40, 18), Vector2(80, 14), Color(0.68, 0.52, 0.32, 0.90))
			_add_marker_quad(marker, Vector2(-8, -18), Vector2(16, 46), Color(0.62, 0.46, 0.28, 0.84))


# -----------------------------------------------------------------------------
# Zone stil uygulayıcıları
# -----------------------------------------------------------------------------

static func _apply_opening_marker_style(marker: Node2D, kind: String) -> void:
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


static func _apply_samsun_marker_style(marker: Node2D, kind: String) -> void:
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
# Setpiece yardımcı fonksiyonları
# -----------------------------------------------------------------------------

static func _add_marker_quad(marker: Node2D, pos: Vector2, size: Vector2, color: Color) -> void:
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


static func _add_marker_triangle(marker: Node2D, center: Vector2, size: Vector2, color: Color) -> void:
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
# Geometri yardımcıları
# -----------------------------------------------------------------------------

static func _rounded_rect_points(size: Vector2, radius: float, segments := 6) -> PackedVector2Array:
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


static func _ellipse_points(radius: Vector2, segments := 24) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		points.append(Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return points


# -----------------------------------------------------------------------------
# Renk / Icon / Metin yardımcıları
# -----------------------------------------------------------------------------

static func _tooltip_icon_text(kind: String) -> String:
	match kind:
		"unit", "ship_clue", "havza_clue", "amasya_clue", "kongre_clue", "resource":
			return "\u2605"  # ★
		_:
			return "\u279C"  # ➜


static func _marker_color(kind: String) -> Color:
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
			return Color(_Colors.POP_TURQUOISE.r, _Colors.POP_TURQUOISE.g, _Colors.POP_TURQUOISE.b, 1.0)
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


static func _marker_icon(kind: String) -> Texture2D:
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
