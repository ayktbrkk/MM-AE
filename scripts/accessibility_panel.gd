extends Panel
class_name AccessibilityPanel

# ---------------------------------------------------------------------------
# accessibility_panel.gd — P10: Erisilebilirlik ayarlari paneli
# Ana menüde kullanilir. SaveManager uzerinden kalici ayarlari yonetir.
# ---------------------------------------------------------------------------

const _ui_text := preload("res://scripts/ui_text.gd")

@onready var _colors := preload("res://scripts/colors.gd")

@onready var _title_label: Label = %Title
@onready var _slow_btn: Button = %SlowBtn
@onready var _normal_btn: Button = %NormalBtn
@onready var _fast_btn: Button = %FastBtn
@onready var _large_text_check: CheckButton = %LargeTextCheck
@onready var _high_contrast_check: CheckButton = %HighContrastCheck
@onready var _large_text_desc: Label = %LargeTextDesc
@onready var _high_contrast_desc: Label = %HighContrastDesc


var _save_manager: Node = null


func _ready() -> void:
	if Engine.has_singleton("SaveManager"):
		_save_manager = Engine.get_singleton("SaveManager")
		_load_current_settings()
	else:
		push_warning("AccessibilityPanel: SaveManager singleton not found — running in headless/test mode")
	_connect_signals()
	_update_texts()


func _load_current_settings() -> void:
	"""SaveManager'dan mevcut ayarlari yukle ve UI'a yansit."""
	if _save_manager == null:
		return
	match _save_manager.text_speed:
		"slow":
			_slow_btn.button_pressed = true
		"normal":
			_normal_btn.button_pressed = true
		"fast":
			_fast_btn.button_pressed = true
	_large_text_check.button_pressed = _save_manager.large_text
	_high_contrast_check.button_pressed = _save_manager.high_contrast


func _connect_signals() -> void:
	"""UI elemanlarinin sinyallerini bagla."""
	_slow_btn.pressed.connect(_on_speed_selected.bind("slow"))
	_normal_btn.pressed.connect(_on_speed_selected.bind("normal"))
	_fast_btn.pressed.connect(_on_speed_selected.bind("fast"))
	_large_text_check.toggled.connect(_on_large_text_toggled)
	_high_contrast_check.toggled.connect(_on_high_contrast_toggled)


func _on_speed_selected(speed: String) -> void:
	"""Hiz butonuna basildiginda SaveManager'i guncelle."""
	if _save_manager == null:
		return
	_save_manager.text_speed = speed


func _on_large_text_toggled(enabled: bool) -> void:
	"""Buyuk metin toggle'i degistiginde SaveManager'i guncelle."""
	if _save_manager == null:
		return
	_save_manager.large_text = enabled


func _on_high_contrast_toggled(enabled: bool) -> void:
	"""Yuksek kontrast toggle'i degistiginde SaveManager'i guncelle."""
	if _save_manager == null:
		return
	_save_manager.high_contrast = enabled


func _update_texts() -> void:
	"""UI metinlerini localization ile guncelle."""
	_title_label.text = _ui_text.text(_ui_text.ACCESSIBILITY_TITLE, "Erişilebilirlik")
	_slow_btn.text = _ui_text.text(_ui_text.ACCESSIBILITY_TEXT_SPEED_SLOW, "Yavaş")
	_normal_btn.text = _ui_text.text(_ui_text.ACCESSIBILITY_TEXT_SPEED_NORMAL, "Normal")
	_fast_btn.text = _ui_text.text(_ui_text.ACCESSIBILITY_TEXT_SPEED_FAST, "Hızlı")
	_large_text_check.text = _ui_text.text(_ui_text.ACCESSIBILITY_LARGE_TEXT, "Büyük Metin")
	_high_contrast_check.text = _ui_text.text(_ui_text.ACCESSIBILITY_HIGH_CONTRAST, "Yüksek Kontrast")
	_large_text_desc.text = tr("ui.accessibility.large_text.desc")
	_high_contrast_desc.text = tr("ui.accessibility.high_contrast.desc")
