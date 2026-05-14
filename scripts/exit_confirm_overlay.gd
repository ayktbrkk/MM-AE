## MMAE - Çıkış Onay Diyalogu
## ==============================
## P2-13: Android geri tuşu ve çıkış butonu için onay overlay'i.
## Çocuk dostu, büyük butonlu, anlaşılır metin.

extends CanvasLayer

# ---------------------------------------------------------------------------
# SİNYALLER
# ---------------------------------------------------------------------------
signal exit_confirmed
signal exit_cancelled

const _gui_frame := preload("res://scripts/gui_frame.gd")
const _ui_styles := preload("res://scripts/ui_style_factory.gd")
const _ui_tokens := preload("res://scripts/ui_tokens.gd")


# ---------------------------------------------------------------------------
# @ONREADY — SAHNE AĞACI REFERANSLARI
# ---------------------------------------------------------------------------
@onready var _colors := preload("res://scripts/colors.gd")
@onready var dimmer: ColorRect = $Dimmer
@onready var center: CenterContainer = $Center
@onready var panel: PanelContainer = $Center/Panel
@onready var confirm_button: Button = $Center/Panel/Margin/VBox/ConfirmButton
@onready var cancel_button: Button = $Center/Panel/Margin/VBox/CancelButton


# ---------------------------------------------------------------------------
# _ready
# ---------------------------------------------------------------------------
func _ready() -> void:
	_apply_styles()
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	get_viewport().size_changed.connect(_sync_layout)
	_sync_layout()
	visible = false


# ---------------------------------------------------------------------------
# GÖSTER / GİZLE
# ---------------------------------------------------------------------------
func show_overlay(_config: Dictionary = {}) -> void:
	visible = true
	confirm_button.grab_focus()


func hide_overlay() -> void:
	visible = false


# ---------------------------------------------------------------------------
# SİNYAL YÖNLENDİRME
# ---------------------------------------------------------------------------
func _on_confirm_pressed() -> void:
	exit_confirmed.emit()
	get_tree().quit()


func _on_cancel_pressed() -> void:
	exit_cancelled.emit()
	hide_overlay()


func _exit_tree() -> void:
	if get_viewport().size_changed.is_connected(_sync_layout):
		get_viewport().size_changed.disconnect(_sync_layout)


func _sync_layout() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	dimmer.offset_left = 0.0
	dimmer.offset_top = 0.0
	dimmer.offset_right = viewport_size.x
	dimmer.offset_bottom = viewport_size.y
	var safe_rect := _gui_frame.apply_safe_area_offsets(center, viewport_size)
	var panel_width := minf(maxf(420.0, safe_rect.size.x), 680.0)
	var panel_height := minf(maxf(300.0, safe_rect.size.y * 0.30), 460.0)
	panel.custom_minimum_size = Vector2(panel_width, panel_height)


# ---------------------------------------------------------------------------
# STİL
# ---------------------------------------------------------------------------
func _apply_styles() -> void:
	# Panel stili
	panel.add_theme_stylebox_override(
		"panel",
		_ui_styles.panel_style(_colors.DESIGN_CREAM_PAPER, _colors.DESIGN_DEEP_NAVY, _ui_tokens.RADIUS_2XL, _ui_tokens.BORDER_BOLD, Color(0.02, 0.03, 0.05, 0.30), _ui_tokens.SHADOW_SIZE_XL, _ui_tokens.SHADOW_OFFSET_XL)
	)

	# Buton stilleri
	_style_button(confirm_button, _colors.DESIGN_SUNSET_GOLD, _colors.DESIGN_STORY_INK)
	_style_button(cancel_button, _colors.DESIGN_MUTED_TEAL, _colors.DESIGN_CREAM_PAPER)


func _style_button(button: Button, base_color: Color, font_color: Color) -> void:
	var normal := _ui_styles.button_state_style(base_color, _ui_tokens.RADIUS_LG, Color(0, 0, 0, 0), 0, Color(0.02, 0.03, 0.05, 0.20), _ui_tokens.SHADOW_SIZE_MD, _ui_tokens.SHADOW_OFFSET_MD)
	var hover := _ui_styles.button_state_style(base_color.lightened(0.08), _ui_tokens.RADIUS_LG, Color(0, 0, 0, 0), 0, Color(0.02, 0.03, 0.05, 0.26), _ui_tokens.SHADOW_SIZE_LG, Vector2(0, 5))
	var pressed := _ui_styles.button_state_style(base_color.darkened(0.10), _ui_tokens.RADIUS_LG)
	_ui_styles.apply_button_style(button, normal, pressed, hover, null, font_color, Color(1, 1, 1, 0.62), _ui_tokens.FONT_BODY_2XL)
