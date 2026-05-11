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


# ---------------------------------------------------------------------------
# @ONREADY — SAHNE AĞACI REFERANSLARI
# ---------------------------------------------------------------------------
@onready var _colors := preload("res://scripts/colors.gd")
@onready var _textures := preload("res://scripts/textures.gd")
@onready var dimmer: ColorRect = $Dimmer
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
	visible = false


# ---------------------------------------------------------------------------
# GÖSTER / GİZLE
# ---------------------------------------------------------------------------
func show_overlay() -> void:
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


# ---------------------------------------------------------------------------
# STİL
# ---------------------------------------------------------------------------
func _apply_styles() -> void:
	# Panel stili
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = _colors.DESIGN_CREAM_PAPER
	panel_style.border_color = _colors.DESIGN_DEEP_NAVY
	panel_style.set_border_width_all(4)
	panel_style.set_corner_radius_all(28)
	panel_style.shadow_color = Color(0.02, 0.03, 0.05, 0.30)
	panel_style.shadow_size = 12
	panel_style.shadow_offset = Vector2(0, 8)
	panel.add_theme_stylebox_override("panel", panel_style)

	# Buton stilleri
	_style_button(confirm_button, _colors.DESIGN_SUNSET_GOLD, _colors.DESIGN_STORY_INK)
	_style_button(cancel_button, _colors.DESIGN_MUTED_TEAL, _colors.DESIGN_CREAM_PAPER)


func _style_button(button: Button, base_color: Color, font_color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = base_color
	normal.set_corner_radius_all(22)
	normal.shadow_color = Color(0.02, 0.03, 0.05, 0.20)
	normal.shadow_size = 6
	normal.shadow_offset = Vector2(0, 4)
	button.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = base_color.lightened(0.08)
	hover.set_corner_radius_all(22)
	hover.shadow_color = Color(0.02, 0.03, 0.05, 0.26)
	hover.shadow_size = 8
	hover.shadow_offset = Vector2(0, 5)
	button.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = base_color.darkened(0.10)
	pressed.set_corner_radius_all(22)
	button.add_theme_stylebox_override("pressed", pressed)

	button.add_theme_color_override("font_color", font_color)
	button.add_theme_font_size_override("font_size", 30)
