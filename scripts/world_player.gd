## MMAE - Oyuncu ve Companion Yönetimi Modülü
## =============================================
## R5 refactoring: world.gd'den ayrıştırıldı.
## Karakter seçimi, oyuncu hareketi, companion takibi ve görsel feedback.
##
## Kullanım: world.gd tarafından preload edilip initialize() ile kurulur.
##
## @onready var _player_mod: WorldPlayer
## _player_mod = WorldPlayer.new()
## add_child(_player_mod)
## _player_mod.initialize(self)

class_name WorldPlayer
extends Node

const PLAYER_SPEED := 430.0
const INTERACT_DISTANCE := 150.0

var _world: Node2D

# Karakter state
var hero_name := "Arda"
var target_position := Vector2.ZERO
var has_target := false
var player_velocity := Vector2.ZERO
var _player_idle_bob: float = 0.0
var _companion_idle_bob: float = 0.0
var nearby_marker: Node2D

# Companion reaction
var companion_reaction_label: Label
var companion_reaction_spots: Array[Dictionary] = []
var active_companion_reaction := ""

# Karakter görsel referansları
var player_outline: Sprite2D
var companion_outline: Sprite2D
var player_accessory: Node2D
var companion_accessory: Node2D

# Texture/colors sabitleri (merkezi dosyalardan)
const _textures := preload("res://scripts/textures.gd")
const _colors := preload("res://scripts/colors.gd")


func initialize(world: Node2D) -> void:
	"""World referansını al ve karakter görsellerini kur."""
	_world = world
	_build_companion_reaction_label()
	_setup_character_outlines()
	_enforce_world_character_z_index()


# ---------------------------------------------------------------------------
# KARAKTER SEÇİM AKIŞI
# ---------------------------------------------------------------------------

func choose_hero(choice: String) -> void:
	"""Karakter seçimi: texture'ları değiştir, UI'yi gizle, diyalog başlat."""
	var state: Node = _world.get_node("WorldState")
	var player_sprite: Sprite2D = _world.get_node("Player/PlayerSprite")
	var companion_sprite: Sprite2D = _world.get_node("Companion/CompanionSprite")

	state.selected_character = choice
	hero_name = "Eda" if choice == "eda" else "Arda"
	var companion_name := "Arda" if choice == "eda" else "Eda"
	player_sprite.texture = _textures.EDA_TEXTURE if choice == "eda" else _textures.ARDA_TEXTURE
	companion_sprite.texture = _textures.ARDA_TEXTURE if choice == "eda" else _textures.EDA_TEXTURE
	_remove_duplicate_character_sprites()
	_sync_character_outline_textures()
	_free_character_choice_identity_row()
	_set_character_choice_visible(false)

	# initialize companion reaction spots with correct companion name
	_update_companion_reaction_spots_text(companion_name)

	# Diyalog gösterimi için world._ui_mod.show_dialogue çağrılacak
	# world.gd aracılığıyla (orchestrator)
	var world_script = _world
	if world_script.has_method("_on_hero_chosen"):
		world_script._on_hero_chosen(hero_name, companion_name)


func reset_panel_for_character_choice() -> void:
	"""Karakter seçim panelini sıfırla."""
	var character_title: Label = _world.get_node("CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/CharacterTitle")
	var character_text: Label = _world.get_node("CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/CharacterText")
	var arda_btn: Button = _world.get_node("CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/ArdaButton")
	var eda_btn: Button = _world.get_node("CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/EdaButton")

	character_title.text = "Kimin rüyasına girelim?"
	character_text.text = "Seçtiğin öğrenci sınav gecesi kitaptaki tarih dünyasına uyanacak."
	arda_btn.text = "Arda ile başla"
	eda_btn.text = "Eda ile başla"


func build_character_choice_identity_row() -> void:
	"""Karakter seçim kartlarını oluştur (Arda/Eda portre + isim + descriptor)."""
	var character_content: VBoxContainer = _world.get_node("CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent")
	if character_content.has_node("CharacterIdentityRow"):
		return

	var row := HBoxContainer.new()
	row.name = "CharacterIdentityRow"
	row.custom_minimum_size = Vector2(0, 220)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 24)
	character_content.add_child(row)

	var arda_btn: Button = _world.get_node("CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/ArdaButton")
	character_content.move_child(row, arda_btn.get_index())

	row.add_child(_create_character_identity_card("ArdaIdentityCard", "ARDA", "Cesur, Meraklı", _textures.ARDA_PORTRAIT_IDLE_TEXTURE, Color(0.84, 0.40, 0.29, 0.40)))
	row.add_child(_create_character_identity_card("EdaIdentityCard", "EDA", "Akıllı, Sakin", _textures.EDA_PORTRAIT_IDLE_TEXTURE, Color(0.26, 0.54, 0.53, 0.40)))


func _create_character_identity_card(card_name: String, character_name: String, descriptor: String, texture: Texture2D, accent: Color) -> PanelContainer:
	"""Tek bir karakter kimlik kartı oluştur."""
	var card := PanelContainer.new()
	card.name = card_name
	card.custom_minimum_size = Vector2(0, 220)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.set_meta("identity_accent", accent)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)

	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)

	var circle := PanelContainer.new()
	circle.name = "IdentityCircle"
	circle.custom_minimum_size = Vector2(156, 156)
	circle.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	circle.set_meta("identity_accent", accent)
	column.add_child(circle)

	var circle_margin := MarginContainer.new()
	circle_margin.add_theme_constant_override("margin_left", 8)
	circle_margin.add_theme_constant_override("margin_top", 8)
	circle_margin.add_theme_constant_override("margin_right", 8)
	circle_margin.add_theme_constant_override("margin_bottom", 8)
	circle.add_child(circle_margin)

	var portrait := TextureRect.new()
	portrait.name = "Portrait"
	portrait.texture = texture
	portrait.custom_minimum_size = Vector2(140, 140)
	portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.set_meta("character_choice_portrait", true)
	circle_margin.add_child(portrait)

	var name_label := Label.new()
	name_label.name = "Name"
	name_label.text = character_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", Color(0.13, 0.15, 0.20, 0.96))
	column.add_child(name_label)

	var descriptor_label := Label.new()
	descriptor_label.name = "Descriptor"
	descriptor_label.text = descriptor
	descriptor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	descriptor_label.add_theme_font_size_override("font_size", 20)
	descriptor_label.add_theme_color_override("font_color", Color(0.20, 0.26, 0.30, 0.78))
	column.add_child(descriptor_label)

	return card


func _free_character_choice_identity_row() -> void:
	"""Karakter seçim kartlarını temizle."""
	var character_content: VBoxContainer = _world.get_node("CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent")
	var row := character_content.get_node_or_null("CharacterIdentityRow")
	if row == null:
		return
	for portrait in row.find_children("*", "TextureRect", true, false):
		portrait.queue_free()
	row.hide()
	row.queue_free()


func set_character_choice_visible(visible: bool) -> void:
	"""Karakter seçim panelini göster/gizle."""
	var character_panel: PanelContainer = _world.get_node("CanvasLayer/HUD/CharacterPanel")
	var interact_btn: Button = _world.get_node("CanvasLayer/HUD/InteractButton")

	if visible:
		build_character_choice_identity_row()
		_apply_character_identity_styles()
		reset_panel_for_character_choice()
	else:
		_free_character_choice_identity_row()
	character_panel.visible = visible
	interact_btn.visible = not visible


func _set_character_choice_visible(visible: bool) -> void:
	set_character_choice_visible(visible)


func _update_companion_reaction_spots_text(companion_name: String) -> void:
	"""Companion reaction metinlerindeki isimleri güncelle."""
	for spot in companion_reaction_spots:
		var text: String = spot.get("text", "")
		text = text.replace("Arda", companion_name).replace("Eda", companion_name)
		spot["text"] = text


# ---------------------------------------------------------------------------
# KARAKTER GÖRSEL YÖNETİMİ
# ---------------------------------------------------------------------------

func setup_character_outlines() -> void:
	_setup_character_outlines()


func _setup_character_outlines() -> void:
	"""Karakter outline'larını ve aksesuarlarını kur."""
	player_outline = null
	companion_outline = null
	_remove_duplicate_character_sprites()
	var player_node: Node2D = _world.get_node("Player")
	var companion_node: Node2D = _world.get_node("Companion")
	player_accessory = _create_period_accessory(player_node, true)
	companion_accessory = _create_period_accessory(companion_node, false)
	_sync_character_outline_textures()


func _remove_duplicate_character_sprites() -> void:
	_remove_duplicate_character_sprites_in(_world)


func _remove_duplicate_character_sprites_in(root: Node) -> void:
	"""Karakter texture'ı kullanan yinelenen Sprite2D'leri temizle."""
	var player_sprite: Sprite2D = _world.get_node("Player/PlayerSprite")
	var companion_sprite: Sprite2D = _world.get_node("Companion/CompanionSprite")

	for child in root.get_children():
		if child is Sprite2D:
			var sprite := child as Sprite2D
			var is_gameplay_character := sprite == player_sprite or sprite == companion_sprite
			var uses_character_texture := sprite.texture == _textures.ARDA_TEXTURE or sprite.texture == _textures.EDA_TEXTURE
			if uses_character_texture and not is_gameplay_character:
				sprite.queue_free()
				continue
		_remove_duplicate_character_sprites_in(child)


func _create_character_outline(parent: Node2D, sprite: Sprite2D, scale_boost: float, alpha: float) -> Sprite2D:
	"""Karakter için outline (silüet) Sprite2D oluştur."""
	var outline := Sprite2D.new()
	outline.name = "%sOutline" % sprite.name
	outline.texture = sprite.texture
	outline.scale = sprite.scale * scale_boost
	outline.modulate = Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, alpha)
	outline.z_index = sprite.z_index - 1
	parent.add_child(outline)
	parent.move_child(outline, sprite.get_index())
	return outline


func _create_period_accessory(parent: Node2D, is_player: bool) -> Node2D:
	"""Dönem aksesuarı (kasket + atkı) oluştur."""
	var accessory := Node2D.new()
	accessory.name = "PeriodAccessory"
	accessory.z_index = 4
	parent.add_child(accessory)

	var cap_outline := Polygon2D.new()
	cap_outline.position = Vector2(0, -74)
	cap_outline.color = Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.72)
	cap_outline.polygon = PackedVector2Array([
		Vector2(-26, -6),
		Vector2(18, -12),
		Vector2(34, 2),
		Vector2(4, 12),
		Vector2(-30, 8),
	])
	accessory.add_child(cap_outline)

	var cap := Polygon2D.new()
	cap.position = Vector2(0, -76)
	cap.color = Color(0.16, 0.24, 0.34, 0.96) if is_player else Color(0.18, 0.38, 0.42, 0.96)
	cap.polygon = PackedVector2Array([
		Vector2(-22, -4),
		Vector2(14, -9),
		Vector2(28, 1),
		Vector2(2, 9),
		Vector2(-26, 6),
	])
	accessory.add_child(cap)

	var scarf_outline := Polygon2D.new()
	scarf_outline.position = Vector2(0, -8)
	scarf_outline.color = Color(_colors.CEL_OUTLINE.r, _colors.CEL_OUTLINE.g, _colors.CEL_OUTLINE.b, 0.68)
	scarf_outline.polygon = PackedVector2Array([
		Vector2(-26, -6),
		Vector2(24, -8),
		Vector2(28, 8),
		Vector2(-20, 14),
	])
	accessory.add_child(scarf_outline)

	var scarf := Polygon2D.new()
	scarf.position = Vector2(0, -9)
	scarf.color = Color(_colors.POP_CRIMSON.r, _colors.POP_CRIMSON.g, _colors.POP_CRIMSON.b, 0.94) if is_player else Color(_colors.POP_DEEP_TURQUOISE.r, _colors.POP_DEEP_TURQUOISE.g, _colors.POP_DEEP_TURQUOISE.b, 0.94)
	scarf.polygon = PackedVector2Array([
		Vector2(-22, -4),
		Vector2(20, -6),
		Vector2(23, 6),
		Vector2(-18, 11),
	])
	accessory.add_child(scarf)
	return accessory


func _sync_character_outline_textures() -> void:
	"""Outline texture'larını sprite texture'ları ile senkronize et."""
	if player_outline != null:
		var player_sprite: Sprite2D = _world.get_node("Player/PlayerSprite")
		player_outline.texture = player_sprite.texture
	if companion_outline != null:
		var companion_sprite: Sprite2D = _world.get_node("Companion/CompanionSprite")
		companion_outline.texture = companion_sprite.texture


func enforce_world_character_z_index() -> void:
	_enforce_world_character_z_index()


func _enforce_world_character_z_index() -> void:
	"""Karakter Z-index'lerini sabitler."""
	var player_node: Node2D = _world.get_node("Player")
	var companion_node: Node2D = _world.get_node("Companion")
	var player_sprite: Sprite2D = _world.get_node("Player/PlayerSprite")
	var companion_sprite: Sprite2D = _world.get_node("Companion/CompanionSprite")
	var player_shadow: Polygon2D = _world.get_node("Player/PlayerShadow")
	var companion_shadow: Polygon2D = _world.get_node("Companion/CompanionShadow")

	player_node.z_index = 0
	companion_node.z_index = 0
	player_sprite.z_index = 0
	companion_sprite.z_index = 0
	player_shadow.z_index = -1
	companion_shadow.z_index = -1
	if player_outline != null:
		player_outline.z_index = -1
	if companion_outline != null:
		companion_outline.z_index = -1
	if player_accessory != null:
		player_accessory.z_index = 1
	if companion_accessory != null:
		companion_accessory.z_index = 1


# ---------------------------------------------------------------------------
# OYUNCU HAREKETİ
# ---------------------------------------------------------------------------

func move_to(position: Vector2) -> void:
	"""Oyuncuyu belirtilen dünya pozisyonuna hareket ettir (set target)."""
	_set_target(position)


func get_active_character() -> String:
	"""Aktif karakter adını döndür."""
	return hero_name


func handle_unhandled_input(event: InputEvent) -> void:
	"""Touch/mouse input ile hedef belirleme.
	
	Not: Overlay görünürlük kontrolleri world.gd._unhandled_input() tarafından
	zaten yapılır (is_any_overlay_visible()). Burada sadece panel kontrolleri
	kalır çünkü OverlayManager overlay node'larını reparent eder ve
	CanvasLayer/HUD/ altındaki yollar geçersiz olur.
	"""
	var character_panel: PanelContainer = _world.get_node("CanvasLayer/HUD/CharacterPanel")
	var dialogue_panel: PanelContainer = _world.get_node("CanvasLayer/HUD/DialoguePanel")

	if character_panel.visible or dialogue_panel.visible:
		return

	if event is InputEventScreenTouch and event.pressed:
		_set_target(_world.get_global_mouse_position())
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_set_target(_world.get_global_mouse_position())


func _set_target(world_position: Vector2) -> void:
	"""Hedef pozisyonu dünya sınırları içinde clamp et."""
	var world_size := Vector2(1600, 2200)
	target_position = world_position.clamp(Vector2(120, 180), world_size - Vector2(120, 180))
	has_target = true


func move_player(delta: float) -> void:
	"""Oyuncuyu hedefe doğru veya input yönünde hareket ettir."""
	var world_size := Vector2(1600, 2200)
	var player_node: Node2D = _world.get_node("Player")

	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_vector.length() > 0.01:
		has_target = false
		player_velocity = input_vector * PLAYER_SPEED
		player_node.position += player_velocity * delta
	elif has_target:
		var direction := target_position - player_node.position
		if direction.length() < 18.0:
			has_target = false
			player_velocity = Vector2.ZERO
		else:
			player_velocity = direction.normalized() * PLAYER_SPEED
			player_node.position += player_velocity * delta
	else:
		player_velocity = Vector2.ZERO

	player_node.position = player_node.position.clamp(Vector2(120, 180), world_size - Vector2(120, 180))


# ---------------------------------------------------------------------------
# COMPANION TAKİBİ
# ---------------------------------------------------------------------------

func update_companion(delta: float) -> void:
	"""Companion'ın oyuncuyu takip etmesini sağla."""
	var player_node: Node2D = _world.get_node("Player")
	var companion_node: Node2D = _world.get_node("Companion")

	var facing_direction := Vector2(1, 0)
	if player_velocity.length() > 4.0:
		facing_direction = player_velocity.normalized()
	elif has_target and player_node.position.distance_to(target_position) > 8.0:
		facing_direction = (target_position - player_node.position).normalized()
	var follow_offset := Vector2(-facing_direction.x * 95.0, 92.0)
	var desired_position := player_node.position + follow_offset
	var distance := companion_node.position.distance_to(desired_position)
	if distance > 520.0:
		companion_node.position = player_node.position + Vector2(105, 96)
	else:
		var speed_factor: float = clamp(distance / 160.0, 0.35, 1.0)
		companion_node.position = companion_node.position.lerp(desired_position, min(delta * (3.0 + speed_factor * 3.4), 1.0))


# ---------------------------------------------------------------------------
# COMPANION REAKSİYON
# ---------------------------------------------------------------------------

func build_companion_reaction_label() -> void:
	_build_companion_reaction_label()


func _build_companion_reaction_label() -> void:
	"""Companion üzerinde reaksiyon etiketi oluştur."""
	var companion_node: Node2D = _world.get_node("Companion")
	companion_reaction_label = Label.new()
	companion_reaction_label.name = "CompanionReaction"
	companion_reaction_label.position = Vector2(-185, -150)
	companion_reaction_label.custom_minimum_size = Vector2(370, 86)
	companion_reaction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	companion_reaction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	companion_reaction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	companion_reaction_label.add_theme_font_size_override("font_size", 21)
	companion_reaction_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.78, 0.94))
	companion_reaction_label.add_theme_color_override("font_shadow_color", Color(0.03, 0.05, 0.08, 0.62))
	companion_reaction_label.add_theme_constant_override("shadow_offset_x", 2)
	companion_reaction_label.add_theme_constant_override("shadow_offset_y", 2)
	companion_reaction_label.z_index = 35
	companion_reaction_label.visible = false
	companion_node.add_child(companion_reaction_label)


func update_companion_reaction() -> void:
	"""Oyuncunun bulunduğu bölgeye göre companion reaksiyon metnini göster."""
	if companion_reaction_label == null:
		return
	var selected_text := ""
	var player_node: Node2D = _world.get_node("Player")
	for spot in companion_reaction_spots:
		var center: Vector2 = spot["center"]
		var radius := float(spot["radius"])
		if player_node.position.distance_to(center) <= radius:
			selected_text = String(spot["text"])
			break
	active_companion_reaction = selected_text
	if active_companion_reaction == "":
		companion_reaction_label.visible = false
		return
	var character_panel: PanelContainer = _world.get_node_or_null("CanvasLayer/HUD/CharacterPanel")
	var dialogue_panel: PanelContainer = _world.get_node_or_null("CanvasLayer/HUD/DialoguePanel")
	var world_ui := _world.get_node_or_null("WorldUI")
	var overlay_manager = world_ui.get("_overlay_manager") if world_ui != null else null
	var decision_overlay: Node = overlay_manager.get_overlay_node(OverlayManager.OverlayType.DECISION) if overlay_manager != null else null
	var dialogue_overlay: Node = overlay_manager.get_overlay_node(OverlayManager.OverlayType.DIALOGUE) if overlay_manager != null else null
	var info_card_overlay: Node = overlay_manager.get_overlay_node(OverlayManager.OverlayType.INFO_CARD) if overlay_manager != null else null
	companion_reaction_label.text = active_companion_reaction
	companion_reaction_label.visible = not (
		(character_panel != null and character_panel.visible)
		or (dialogue_panel != null and dialogue_panel.visible)
		or (decision_overlay != null and decision_overlay.visible)
		or (dialogue_overlay != null and dialogue_overlay.visible)
		or (info_card_overlay != null and info_card_overlay.visible)
	)


func add_companion_reaction_spot(center: Vector2, radius: float, text: String, slot_id := "") -> void:
	"""Companion reaksiyon bölgesi ekle."""
	companion_reaction_spots.append({
		"center": center,
		"radius": radius,
		"text": text,
		"slot_id": slot_id,
	})
	var props: Node2D = _world.get_node("Props")
	# Görsel ipucu olarak yumuşak blob ekle
	var blob := Polygon2D.new()
	blob.position = center
	blob.color = Color(1.0, 0.95, 0.66, 0.07)
	blob.z_index = -1
	var points := PackedVector2Array()
	var point_count := 16
	var radius_v := Vector2(radius * 0.42, radius * 0.20)
	for index in range(point_count):
		var angle := TAU * float(index) / float(point_count)
		var wave := 1.0 + (sin(float(index) * 1.73) * 0.04) + (cos(float(index) * 0.91) * 0.04 * 0.55)
		points.append(Vector2(cos(angle) * radius_v.x, sin(angle) * radius_v.y) * wave)
	blob.polygon = points
	props.add_child(blob)


# ---------------------------------------------------------------------------
# GÖRSEL FEEDBACK
# ---------------------------------------------------------------------------

func update_movement_feedback() -> void:
	"""Hareket animasyonu feedback: sprite bob, outline, gölge, atmosphere."""
	var player_node: Node2D = _world.get_node("Player")
	var companion_node: Node2D = _world.get_node("Companion")
	var player_sprite: Sprite2D = _world.get_node("Player/PlayerSprite")
	var companion_sprite: Sprite2D = _world.get_node("Companion/CompanionSprite")
	var player_shadow: Polygon2D = _world.get_node("Player/PlayerShadow")
	var companion_shadow: Polygon2D = _world.get_node("Companion/CompanionShadow")
	var atmosphere_top_glow: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/TopGlow")
	var atmosphere_horizon_glow: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/HorizonGlow")
	var atmosphere_bottom_fog: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/BottomFog")
	var rift_edge_left: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/RiftEdgeLeft")
	var rift_edge_right: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/RiftEdgeRight")
	var crimson_accent: ColorRect = _world.get_node("CanvasLayer/AtmosphereLayer/CrimsonAccent")

	var move_amount: float = clamp(player_velocity.length() / PLAYER_SPEED, 0.0, 1.0)
	player_sprite.position.y = _player_idle_bob - (move_amount * 4.0)
	if player_outline != null:
		player_outline.position = player_sprite.position
		player_outline.scale = player_sprite.scale * 1.12
		player_outline.flip_h = player_sprite.flip_h
	if player_accessory != null:
		player_accessory.position.y = player_sprite.position.y
		player_accessory.scale.x = -1.0 if player_sprite.flip_h else 1.0
	player_shadow.scale = Vector2(1.0 + (move_amount * 0.12), 1.0 - (move_amount * 0.10))
	player_shadow.modulate.a = 0.18 + (move_amount * 0.08)
	if abs(player_velocity.x) > 4.0:
		player_sprite.flip_h = player_velocity.x < 0.0
		if player_outline != null:
			player_outline.flip_h = player_sprite.flip_h

	var companion_offset := companion_node.position - player_node.position
	companion_sprite.position.y = _companion_idle_bob
	if companion_outline != null:
		companion_outline.position = companion_sprite.position
		companion_outline.scale = companion_sprite.scale * 1.12
		companion_outline.flip_h = companion_sprite.flip_h
	if companion_accessory != null:
		companion_accessory.position.y = companion_sprite.position.y
		companion_accessory.scale.x = -1.0 if companion_sprite.flip_h else 1.0
	companion_shadow.scale = Vector2(0.96 + (move_amount * 0.08), 0.96 - (move_amount * 0.06))
	if abs(companion_offset.x) > 8.0:
		companion_sprite.flip_h = companion_offset.x < 0.0
		if companion_outline != null:
			companion_outline.flip_h = companion_sprite.flip_h

	# Room zone'da atmosfer efektlerini sıfırla
	var state: Node = _world.get_node("WorldState")
	if state.current_zone == "room":
		atmosphere_top_glow.color.a = 0.0
		atmosphere_horizon_glow.color.a = 0.0
		atmosphere_bottom_fog.color.a = 0.0
		rift_edge_left.color.a = 0.0
		rift_edge_right.color.a = 0.0
		crimson_accent.color.a = 0.0


func update_nearby_marker() -> void:
	"""Yakındaki marker'ı tespit et ve interact butonunu güncelle."""
	var player_node: Node2D = _world.get_node("Player")
	var markers: Node2D = _world.get_node("Markers")
	var marker_mod: Node = _world.get_node("WorldMarker")
	var interact_btn: Button = _world.get_node("CanvasLayer/HUD/InteractButton")

	nearby_marker = marker_mod.update_nearby(player_node.position, markers, INTERACT_DISTANCE)
	if nearby_marker == null:
		interact_btn.disabled = true
		interact_btn.text = "Yaklaş"
	else:
		interact_btn.disabled = false
		interact_btn.text = marker_mod.get_interact_text(nearby_marker)


# ---------------------------------------------------------------------------
# KARAKTER POZİSYON AYARLARI
# ---------------------------------------------------------------------------

func snap_room_characters_to_floor() -> void:
	"""Karakterleri oda zeminine konumlandır."""
	var world_size := Vector2(1600, 2200)
	var player_node: Node2D = _world.get_node("Player")
	var companion_node: Node2D = _world.get_node("Companion")
	var player_sprite: Sprite2D = _world.get_node("Player/PlayerSprite")
	var companion_sprite: Sprite2D = _world.get_node("Companion/CompanionSprite")

	var opening_ground_y := world_size.y * 0.55
	player_node.position = Vector2(930, opening_ground_y - _get_sprite_half_height(player_sprite))
	companion_node.position = Vector2(800, opening_ground_y - _get_sprite_half_height(companion_sprite))
	_enforce_world_character_z_index()


func _get_sprite_half_height(sprite: Sprite2D) -> float:
	if sprite.texture == null:
		return 0.0
	return sprite.texture.get_height() * abs(sprite.scale.y) * 0.5


# ---------------------------------------------------------------------------
# KARAKTER STILLERİ (identity card styles)
# ---------------------------------------------------------------------------

func apply_character_identity_styles() -> void:
	_apply_character_identity_styles()


func _apply_character_identity_styles() -> void:
	"""Karakter kimlik kartlarına stil uygula."""
	var character_content: VBoxContainer = _world.get_node("CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent")
	var row := character_content.get_node_or_null("CharacterIdentityRow")
	if row == null:
		return
	for card_node in row.get_children():
		if card_node is PanelContainer:
			var card := card_node as PanelContainer
			var accent: Color = card.get_meta("identity_accent", Color(1, 1, 1, 0.35))
			var card_style := StyleBoxFlat.new()
			card_style.bg_color = Color(1.0, 0.96, 0.86, 0.70)
			card_style.border_color = Color(accent.r, accent.g, accent.b, 0.68)
			card_style.set_border_width_all(3)
			card_style.set_corner_radius_all(18)
			card.add_theme_stylebox_override("panel", card_style)

			var circle := card.find_child("IdentityCircle", true, false)
			if circle is PanelContainer:
				var circle_style := StyleBoxFlat.new()
				circle_style.bg_color = accent
				circle_style.border_color = Color(accent.r, accent.g, accent.b, 0.86)
				circle_style.set_border_width_all(4)
				circle_style.set_corner_radius_all(999)
				(circle as PanelContainer).add_theme_stylebox_override("panel", circle_style)


# ---------------------------------------------------------------------------
# IDLE ANİMASYON
# ---------------------------------------------------------------------------

func start_idle_animations() -> void:
	"""Karakter idle bob animasyonu."""
	var char_tween: Tween = create_tween().set_loops()
	char_tween.tween_method(_animate_idle_bob, 0.0, TAU, TAU / 4.0)


func _animate_idle_bob(phase: float) -> void:
	_player_idle_bob = sin(phase * 4.0) * 4.0
	_companion_idle_bob = sin((phase * 4.0) + 0.9) * 3.0


# ---------------------------------------------------------------------------
# COMPANION REACTION ALPHA ANİMASYONU
# ---------------------------------------------------------------------------

func _animate_companion_reaction_alpha(phase: float) -> void:
	if companion_reaction_label == null or not companion_reaction_label.visible:
		return
	companion_reaction_label.modulate.a = 0.86 + (0.10 * sin(phase * 3.0))
