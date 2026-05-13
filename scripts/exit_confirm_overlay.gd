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

const _ui_styles := preload("res://scripts/ui_style_factory.gd")
const _ui_tokens := preload("res://scripts/ui_tokens.gd")


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
