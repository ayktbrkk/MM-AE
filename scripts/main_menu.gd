extends Control

signal start_pressed
signal continue_pressed
signal settings_pressed

const WORLD_SCENE_PATH := "res://scenes/world.tscn"

@onready var _colors := preload("res://scripts/colors.gd")
@onready var _textures := preload("res://scripts/textures.gd")

const MIN_PRIMARY_BUTTON_HEIGHT := 104.0
const MIN_TOUCH_SIZE := 88.0
const SAFE_MARGIN := 28.0

@onready var dream_intro_overlay: Node = $DreamIntroOverlay

# AudioManager autoload — P2-12 ses ayarlari icin
@onready var _audio_manager: AudioManager = AudioManager

var backdrop: MenuBackdrop
var safe_area: MarginContainer
var layout: VBoxContainer
var title_label: Label
var subtitle_label: Label
var character_layer: Control
var arda_sprite: TextureRect
var eda_sprite: TextureRect
var start_button: Button
var continue_button: Button
var settings_button: Button
var exit_button: Button
var settings_overlay: Control
var settings_panel: PanelContainer
var settings_container: VBoxContainer
var settings_close_button: Button
var is_transitioning := false
var _exit_dialog: CanvasLayer
var _arda_base_y: float
var _eda_base_y: float

class MenuBackdrop:
	extends Control

	var elapsed := 0.0
	const _MC := preload("res://scripts/colors.gd")

	func _process(delta: float) -> void:
		elapsed += delta
		queue_redraw()

	func _draw() -> void:
		var viewport_size := size
		var horizon_y := viewport_size.y * 0.40
		var ocean_top := viewport_size.y * 0.46

		draw_rect(Rect2(Vector2.ZERO, viewport_size), _MC.DESIGN_DEEP_NAVY)
		_draw_soft_cloud(Vector2(viewport_size.x * 0.16, viewport_size.y * 0.15), Vector2(150, 58), Color(_MC.DESIGN_CREAM_PAPER.r, _MC.DESIGN_CREAM_PAPER.g, _MC.DESIGN_CREAM_PAPER.b, 0.18))
		_draw_soft_cloud(Vector2(viewport_size.x * 0.84, viewport_size.y * 0.18), Vector2(176, 64), Color(_MC.DESIGN_CREAM_PAPER.r, _MC.DESIGN_CREAM_PAPER.g, _MC.DESIGN_CREAM_PAPER.b, 0.16))
		_draw_soft_cloud(Vector2(viewport_size.x * 0.10, viewport_size.y * 0.25), Vector2(124, 50), Color(_MC.DESIGN_MUTED_TEAL.r, _MC.DESIGN_MUTED_TEAL.g, _MC.DESIGN_MUTED_TEAL.b, 0.12))

		draw_rect(Rect2(Vector2(0, ocean_top), Vector2(viewport_size.x, viewport_size.y - ocean_top)), _MC.DESIGN_OCEAN_SLATE)
		for index in range(3):
			var y := ocean_top + 78.0 + float(index) * 118.0 + sin(elapsed * (1.20 + float(index) * 0.18) + float(index)) * 3.0
			_draw_wave_band(y, 10.0, Color(_MC.DESIGN_CREAM_PAPER.r, _MC.DESIGN_CREAM_PAPER.g, _MC.DESIGN_CREAM_PAPER.b, 0.30), float(index) * 0.75)

		var ship_center := Vector2(viewport_size.x * 0.50, horizon_y + sin(elapsed * TAU / 4.0) * 2.0)
		_draw_bandirma_ship(ship_center, min(viewport_size.x * 0.46, 460.0))

		var front_y := viewport_size.y * 0.66
		_draw_character_zone(Vector2(viewport_size.x * 0.31, front_y), "ARDA", _MC.ARDA_CORAL)
		_draw_character_zone(Vector2(viewport_size.x * 0.69, front_y), "EDA", _MC.EDA_TEAL)

	func _draw_soft_cloud(center: Vector2, radius: Vector2, color: Color) -> void:
		draw_set_transform(center, 0.0, Vector2(radius.x, radius.y) / 64.0)
		draw_circle(Vector2.ZERO, 64.0, color)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	func _draw_wave_band(y: float, band_height: float, color: Color, phase: float) -> void:
		var center := Vector2(size.x * 0.5 + sin(elapsed * 0.8 + phase) * 10.0, y)
		draw_set_transform(center, 0.0, Vector2(size.x / 128.0, band_height / 128.0))
		draw_circle(Vector2.ZERO, 64.0, color)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	func _draw_bandirma_ship(center: Vector2, width: float) -> void:
		var hull_height := width * 0.14
		var hull := PackedVector2Array([
			center + Vector2(-width * 0.47, 0),
			center + Vector2(width * 0.47, 0),
			center + Vector2(width * 0.34, hull_height),
			center + Vector2(width * 0.08, hull_height * 1.45),
			center + Vector2(-width * 0.30, hull_height),
		])
		draw_colored_polygon(hull, _MC.DESIGN_STORY_INK)
		draw_line(center + Vector2(-width * 0.18, 0), center + Vector2(-width * 0.18, -width * 0.52), _MC.DESIGN_STORY_INK, 10.0)
		draw_line(center + Vector2(width * 0.14, 0), center + Vector2(width * 0.14, -width * 0.42), _MC.DESIGN_STORY_INK, 8.0)
		var sail := PackedVector2Array([
			center + Vector2(-width * 0.08, -width * 0.56),
			center + Vector2(-width * 0.25, -width * 0.08),
			center + Vector2(width * 0.10, -width * 0.08),
		])
		draw_colored_polygon(sail, Color(_MC.DESIGN_STORY_INK.r, _MC.DESIGN_STORY_INK.g, _MC.DESIGN_STORY_INK.b, 0.86))
		var small_sail := PackedVector2Array([
			center + Vector2(width * 0.18, -width * 0.44),
			center + Vector2(width * 0.04, -width * 0.08),
			center + Vector2(width * 0.32, -width * 0.08),
		])
		draw_colored_polygon(small_sail, Color(_MC.DESIGN_STORY_INK.r, _MC.DESIGN_STORY_INK.g, _MC.DESIGN_STORY_INK.b, 0.72))
		draw_circle(center + Vector2(-width * 0.25, hull_height * 0.42), 7.0, Color(_MC.DESIGN_CREAM_PAPER.r, _MC.DESIGN_CREAM_PAPER.g, _MC.DESIGN_CREAM_PAPER.b, 0.45))
		draw_circle(center + Vector2(-width * 0.05, hull_height * 0.54), 7.0, Color(_MC.DESIGN_CREAM_PAPER.r, _MC.DESIGN_CREAM_PAPER.g, _MC.DESIGN_CREAM_PAPER.b, 0.40))
		draw_circle(center + Vector2(width * 0.16, hull_height * 0.48), 7.0, Color(_MC.DESIGN_CREAM_PAPER.r, _MC.DESIGN_CREAM_PAPER.g, _MC.DESIGN_CREAM_PAPER.b, 0.35))

	func _draw_character_zone(center: Vector2, label_text: String, chip_color: Color) -> void:
		draw_circle(center, 122.0, Color(chip_color.r, chip_color.g, chip_color.b, 0.40))
		var label_pos := center + Vector2(-54, 170)
		draw_string(ThemeDB.fallback_font, label_pos, label_text, HORIZONTAL_ALIGNMENT_CENTER, 108.0, 30, Color.WHITE)

func _ready() -> void:
	_build_scene()
	_apply_styles()
	_sync_responsive_layout()
	_build_settings_ui()
	# Kayitli ses ayarlarini yukle
	_load_volume_settings()
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	settings_close_button.pressed.connect(_hide_settings_overlay)
	dream_intro_overlay.intro_finished.connect(_open_world)
	# P2-13: Çıkış onay diyalogu
	exit_button.pressed.connect(_on_exit_pressed)
	_exit_dialog = preload("res://scenes/exit_confirm_overlay.tscn").instantiate()
	add_child(_exit_dialog)
	_exit_dialog.exit_confirmed.connect(func() -> void: get_tree().quit())
	_exit_dialog.exit_cancelled.connect(func() -> void: _exit_dialog.hide_overlay())
	# P1.3: Ana menü BGM'sini başlat
	AudioManager.play_bgm("BGM_MENU")
	_start_idle_animations()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_sync_responsive_layout()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _exit_dialog.visible:
			_exit_dialog.hide_overlay()
			get_viewport().set_input_as_handled()
			return
		if settings_overlay.visible:
			_hide_settings_overlay()
			get_viewport().set_input_as_handled()
			return
		# Hiçbir overlay açık değilken geri tuşu — çıkış diyalogu göster
		_exit_dialog.show_overlay()
		get_viewport().set_input_as_handled()
		return

func _build_scene() -> void:
	backdrop = MenuBackdrop.new()
	backdrop.name = "ProceduralMenuBackdrop"
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	move_child(backdrop, 0)

	_build_character_sprites()
	_build_menu_layout()
	_build_settings_overlay()

func _build_character_sprites() -> void:
	character_layer = Control.new()
	character_layer.name = "CharacterSpriteLayer"
	character_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	character_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(character_layer)

	arda_sprite = _make_character_sprite(_textures.ARDA_TEXTURE)
	eda_sprite = _make_character_sprite(_textures.EDA_TEXTURE)
	character_layer.add_child(arda_sprite)
	character_layer.add_child(eda_sprite)

func _make_character_sprite(texture: Texture2D) -> TextureRect:
	var sprite := TextureRect.new()
	sprite.texture = texture
	sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.custom_minimum_size = Vector2(180, 220)
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return sprite

func _build_menu_layout() -> void:
	safe_area = MarginContainer.new()
	safe_area.name = "SafeArea"
	safe_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(safe_area)

	layout = VBoxContainer.new()
	layout.name = "Layout"
	layout.add_theme_constant_override("separation", 18)
	safe_area.add_child(layout)

	var top_spacer := Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 96)
	layout.add_child(top_spacer)

	var title_group := VBoxContainer.new()
	title_group.name = "TitleGroup"
	title_group.add_theme_constant_override("separation", 8)
	layout.add_child(title_group)

	title_label = Label.new()
	title_label.text = "Zaman Yolcuları"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 66)
	title_group.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.text = "Bandırma'dan başlayan tarih yolculuğu"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 28)
	title_group.add_child(subtitle_label)

	var middle_spacer := Control.new()
	middle_spacer.name = "MiddleSpacer"
	middle_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(middle_spacer)

	var button_stack := VBoxContainer.new()
	button_stack.name = "ButtonStack"
	button_stack.add_theme_constant_override("separation", 16)
	layout.add_child(button_stack)

	start_button = Button.new()
	start_button.text = "Oyuna Başla"
	start_button.custom_minimum_size = Vector2(0, 112)
	start_button.add_theme_font_size_override("font_size", 34)
	button_stack.add_child(start_button)

	continue_button = Button.new()
	continue_button.text = "Devam Et"
	continue_button.custom_minimum_size = Vector2(0, MIN_PRIMARY_BUTTON_HEIGHT)
	continue_button.add_theme_font_size_override("font_size", 28)
	button_stack.add_child(continue_button)

	settings_button = Button.new()
	settings_button.text = "Ayarlar"
	settings_button.custom_minimum_size = Vector2(0, MIN_PRIMARY_BUTTON_HEIGHT)
	settings_button.add_theme_font_size_override("font_size", 28)
	button_stack.add_child(settings_button)

	exit_button = Button.new()
	exit_button.text = "Çıkış"
	exit_button.custom_minimum_size = Vector2(0, MIN_PRIMARY_BUTTON_HEIGHT)
	exit_button.add_theme_font_size_override("font_size", 28)
	button_stack.add_child(exit_button)

func _build_settings_overlay() -> void:
	settings_overlay = Control.new()
	settings_overlay.name = "SettingsOverlay"
	settings_overlay.visible = false
	settings_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	settings_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(settings_overlay)

	var dimmer := ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.color = Color(0.04, 0.06, 0.10, 0.58)
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	settings_overlay.add_child(dimmer)

	settings_panel = PanelContainer.new()
	settings_panel.name = "Panel"
	settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	dimmer.add_child(settings_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_bottom", 28)
	settings_panel.add_child(margin)

	settings_container = VBoxContainer.new()
	settings_container.name = "SettingsContainer"
	settings_container.add_theme_constant_override("separation", 18)
	margin.add_child(settings_container)

	var title := Label.new()
	title.text = "Ayarlar ve Bilgi"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	settings_container.add_child(title)

	var body := Label.new()
	body.text = "Bu prototipte çocuk dostu, reklamsız ve hikaye odaklı bir tarih yolculuğu deneyimi kuruluyor.\n\nBaşlat ile Bandırma yolculuğuna geçebilir, Devam Et ile aynı dünyayı yeniden açabilirsin."
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 24)
	settings_container.add_child(body)

	settings_close_button = Button.new()
	settings_close_button.text = "Geri Dön"
	settings_close_button.custom_minimum_size = Vector2(0, MIN_TOUCH_SIZE)
	settings_close_button.add_theme_font_size_override("font_size", 28)
	settings_container.add_child(settings_close_button)

func _sync_responsive_layout() -> void:
	var viewport_size := get_viewport_rect().size

	var margin_x: float = max(SAFE_MARGIN, viewport_size.x * 0.045)
	safe_area.offset_left = margin_x
	safe_area.offset_right = -margin_x
	safe_area.offset_top = max(28.0, viewport_size.y * 0.018)
	safe_area.offset_bottom = -max(34.0, viewport_size.y * 0.022)

	var front_y := viewport_size.y * 0.66
	arda_sprite.size = Vector2(190, 236)
	eda_sprite.size = Vector2(184, 230)
	arda_sprite.position = Vector2(viewport_size.x * 0.31 - arda_sprite.size.x * 0.5, front_y - arda_sprite.size.y + 72.0)
	eda_sprite.position = Vector2(viewport_size.x * 0.69 - eda_sprite.size.x * 0.5, front_y - eda_sprite.size.y + 72.0)
	_arda_base_y = arda_sprite.position.y
	_eda_base_y = eda_sprite.position.y

	var panel_width: float = min(viewport_size.x - 64.0, 760.0)
	var panel_height: float = min(viewport_size.y - 220.0, 560.0)
	settings_panel.offset_left = -panel_width * 0.5
	settings_panel.offset_right = panel_width * 0.5
	settings_panel.offset_top = -panel_height * 0.5
	settings_panel.offset_bottom = panel_height * 0.5

func _apply_styles() -> void:
	title_label.add_theme_color_override("font_color", _colors.DESIGN_SUNSET_GOLD)
	subtitle_label.add_theme_color_override("font_color", Color(_colors.DESIGN_CREAM_PAPER.r, _colors.DESIGN_CREAM_PAPER.g, _colors.DESIGN_CREAM_PAPER.b, 0.88))
	_apply_primary_button_style(start_button)
	_apply_secondary_button_style(continue_button)
	_apply_secondary_button_style(settings_button)
	_apply_secondary_button_style(exit_button)
	_apply_primary_button_style(settings_close_button)
	_apply_panel_style(settings_panel, _colors.DESIGN_CREAM_PAPER, _colors.DESIGN_DEEP_NAVY, 28)

func _apply_primary_button_style(button: Button) -> void:
	var sunset := _colors.DESIGN_SUNSET_GOLD
	var normal := _make_button_style(sunset, sunset.lightened(0.12), 28, true)
	var hover := _make_button_style(sunset.lightened(0.06), sunset.lightened(0.18), 28, true)
	var pressed := _make_button_style(sunset.darkened(0.10), sunset, 28, true)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", _colors.DESIGN_STORY_INK)

func _apply_secondary_button_style(button: Button) -> void:
	var cream := _colors.DESIGN_CREAM_PAPER
	var sunset2 := _colors.DESIGN_SUNSET_GOLD
	var normal := _make_button_style(Color(0, 0, 0, 0.12), cream, 26, false)
	var hover := _make_button_style(Color(cream.r, cream.g, cream.b, 0.12), cream, 26, false)
	var pressed := _make_button_style(Color(cream.r, cream.g, cream.b, 0.20), sunset2, 26, false)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", cream)

func _make_button_style(fill: Color, border: Color, radius: int, shadow: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(4)
	style.set_corner_radius_all(radius)
	if shadow:
		style.shadow_color = Color(0.02, 0.03, 0.05, 0.26)
		style.shadow_size = 10
		style.shadow_offset = Vector2(0, 7)
	return style

func _apply_panel_style(panel: PanelContainer, fill: Color, border: Color, radius: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(4)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.02, 0.03, 0.05, 0.30)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 8)
	panel.add_theme_stylebox_override("panel", style)

func _on_start_pressed() -> void:
	if is_transitioning:
		return
	AudioManager.play_sfx("SFX_CLICK")
	start_pressed.emit()
	_begin_dream_intro("Kitap Açılıyor", "Arda ve Eda'nın gözleri ağırlaşır. Sayfalar dalga sesine dönüşürken Bandırma gecesi yaklaşır.")

func _on_continue_pressed() -> void:
	if is_transitioning:
		return
	AudioManager.play_sfx("SFX_CLICK")
	continue_pressed.emit()
	_begin_dream_intro("Rüya Yeniden Başlıyor", "Bandırma Vapuru sislerin arasından yeniden beliriyor. Tarih yolculuğu kaldığın duygudan devam ediyor.")

func _on_settings_pressed() -> void:
	AudioManager.play_sfx("SFX_CLICK")
	settings_pressed.emit()
	_sync_responsive_layout()
	settings_overlay.visible = true
	settings_close_button.grab_focus()

func _hide_settings_overlay() -> void:
	settings_overlay.visible = false

func _on_exit_pressed() -> void:
	"""Çıkış butonuna basıldı — onay diyalogunu göster."""
	AudioManager.play_sfx("SFX_CLICK")
	_exit_dialog.show_overlay()


func _begin_dream_intro(title: String, body: String) -> void:
	is_transitioning = true
	_set_menu_enabled(false)
	dream_intro_overlay.present(title, body)

func _set_menu_enabled(enabled: bool) -> void:
	start_button.disabled = not enabled
	continue_button.disabled = not enabled
	settings_button.disabled = not enabled
	settings_close_button.disabled = not enabled
	exit_button.disabled = not enabled

func _open_world() -> void:
	get_tree().change_scene_to_file(WORLD_SCENE_PATH)

func _start_idle_animations() -> void:
	# Karakter bob animasyonu — sinüs dalgası ile yumuşak salınım
	var char_tween: Tween = create_tween().set_loops()
	char_tween.tween_method(_animate_menu_characters, 0.0, TAU, PI)

	# Start butonu pulse animasyonu — modülasyon alpha
	var btn_tween: Tween = create_tween().set_loops()
	btn_tween.tween_method(_animate_menu_button, 0.0, TAU, PI)

func _animate_menu_characters(phase: float) -> void:
	arda_sprite.position.y = _arda_base_y + sin(phase) * 3.0
	eda_sprite.position.y = _eda_base_y + sin(phase + 0.6) * 3.0

func _animate_menu_button(phase: float) -> void:
	start_button.modulate = Color(1, 1, 1, 0.96 + sin(phase) * 0.025)


# ---------------------------------------------------------------------------
# P2-12: Settings — Ses Kontrolü
# ---------------------------------------------------------------------------
func _build_settings_ui() -> void:
	"""Settings paneline BGM ve SFX slider'larini ekler."""
	# BGM slider satiri
	var bgm_box := HBoxContainer.new()
	bgm_box.name = "BGMSliderRow"
	bgm_box.add_theme_constant_override("separation", 12)
	bgm_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var bgm_label := Label.new()
	bgm_label.text = "🎵 Müzik:"
	bgm_label.add_theme_font_size_override("font_size", 24)
	bgm_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	bgm_box.add_child(bgm_label)

	var bgm_slider := HSlider.new()
	bgm_slider.name = "BGMSlider"
	bgm_slider.min_value = 0.0
	bgm_slider.max_value = 1.0
	bgm_slider.step = 0.01
	bgm_slider.value = _audio_manager.bgm_volume
	bgm_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bgm_slider.custom_minimum_size = Vector2(120, 0)
	bgm_slider.value_changed.connect(_on_bgm_volume_changed)
	bgm_box.add_child(bgm_slider)

	var bgm_value_label := Label.new()
	bgm_value_label.name = "BGMValueLabel"
	bgm_value_label.text = "%.1f" % _audio_manager.bgm_volume
	bgm_value_label.add_theme_font_size_override("font_size", 22)
	bgm_value_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	bgm_value_label.custom_minimum_size = Vector2(36, 0)
	bgm_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	bgm_box.add_child(bgm_value_label)

	# Slider deger degistikce label'i guncelle
	bgm_slider.value_changed.connect(func(v: float) -> void:
		bgm_value_label.text = "%.1f" % v
	)

	# SFX slider satiri
	var sfx_box := HBoxContainer.new()
	sfx_box.name = "SFXSliderRow"
	sfx_box.add_theme_constant_override("separation", 12)
	sfx_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var sfx_label := Label.new()
	sfx_label.text = "🔊 Ses:"
	sfx_label.add_theme_font_size_override("font_size", 24)
	sfx_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	sfx_box.add_child(sfx_label)

	var sfx_slider := HSlider.new()
	sfx_slider.name = "SFXSlider"
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.01
	sfx_slider.value = _audio_manager.sfx_volume
	sfx_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_slider.custom_minimum_size = Vector2(120, 0)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	sfx_box.add_child(sfx_slider)

	var sfx_value_label := Label.new()
	sfx_value_label.name = "SFXValueLabel"
	sfx_value_label.text = "%.1f" % _audio_manager.sfx_volume
	sfx_value_label.add_theme_font_size_override("font_size", 22)
	sfx_value_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	sfx_value_label.custom_minimum_size = Vector2(36, 0)
	sfx_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sfx_box.add_child(sfx_value_label)

	sfx_slider.value_changed.connect(func(v: float) -> void:
		sfx_value_label.text = "%.1f" % v
	)

	# Slider'lari body'den sonra, kapatma butonundan once ekle
	var close_button_index := settings_container.get_child_count() - 1
	settings_container.add_child(bgm_box)
	settings_container.move_child(bgm_box, close_button_index)
	settings_container.add_child(sfx_box)
	settings_container.move_child(sfx_box, close_button_index + 1)

	# Stil
	bgm_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	sfx_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	bgm_value_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.70))
	sfx_value_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.70))


func _load_volume_settings() -> void:
	"""Kayitli ses ayarlarini yukle ve AudioManager'a uygula."""
	var saved_bgm: Variant = SaveManager.load_setting("bgm_volume", null)
	if saved_bgm != null:
		_audio_manager.bgm_volume = float(saved_bgm)
	var saved_sfx: Variant = SaveManager.load_setting("sfx_volume", null)
	if saved_sfx != null:
		_audio_manager.sfx_volume = float(saved_sfx)


func _on_bgm_volume_changed(value: float) -> void:
	"""BGM slider degeri degistiginde."""
	_audio_manager.bgm_volume = value
	SaveManager.save_setting("bgm_volume", value)


func _on_sfx_volume_changed(value: float) -> void:
	"""SFX slider degeri degistiginde."""
	_audio_manager.sfx_volume = value
	SaveManager.save_setting("sfx_volume", value)
