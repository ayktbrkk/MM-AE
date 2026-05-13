extends CanvasLayer
class_name LoadingOverlay

# ---------------------------------------------------------------------------
# loading_overlay.gd — P2-14: Yükleme Ekranı
# ---------------------
# Scene geçişlerinde gösterilen yükleme overlay'i.
# Basit iskelet: Threaded loading entegrasyonu ileride detaylandırılacak.
# ---------------------------------------------------------------------------

# Sinyaller
signal loading_finished

# Sabitler
const TRANSITION_DURATION := 0.3
const _overlay_tween_helper := preload("res://scripts/overlay_tween_helper.gd")


# Node referanslari
@onready var _dimmer: ColorRect = $Dimmer
@onready var _panel: PanelContainer = $CenterContainer/Panel
@onready var _progress_bar: TextureProgressBar = $CenterContainer/Panel/Margin/VBox/ProgressBar
@onready var _hint_label: Label = $CenterContainer/Panel/Margin/VBox/HintLabel
@onready var _title_label: Label = $CenterContainer/Panel/Margin/VBox/TitleLabel
@onready var _loading_spinner: TextureRect = $CenterContainer/Panel/Margin/VBox/SpinnerRow/Spinner

var _target_scene: String = ""
var _is_loading := false
var _transition_tween: Tween
var _progress_tween: Tween


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Yükleme ekranını gösterir ve hedef sahneyi yüklemeye başlar.
## target_scene: "res://scenes/world.tscn" gibi tam path.
func present(target_scene: String) -> void:
	_cancel_transition_tween()
	_target_scene = target_scene
	show()

	# Rastgele ipucu göster
	_hint_label.text = hints.pick_random()

	_progress_bar.value = 0
	_title_label.text = "Bandırma Yolculuğu"

	# Fade-in animasyonu
	_transition_tween = _overlay_tween_helper.replace(self, _transition_tween, Callable(self, "_clear_transition_tween"))
	_transition_tween.set_parallel(true)
	_transition_tween.tween_property(_dimmer, "color", Color(0.0, 0.0, 0.0, 0.70), TRANSITION_DURATION)
	_transition_tween.tween_property(_panel, "modulate", Color.WHITE, TRANSITION_DURATION)
	_transition_tween.tween_property(_loading_spinner, "modulate", Color.WHITE, TRANSITION_DURATION)
	_transition_tween.tween_property(_hint_label, "modulate", Color.WHITE, TRANSITION_DURATION)
	_transition_tween.tween_callback(Callable(self, "_start_loading"))


func show_overlay(config: Dictionary = {}) -> void:
	present(String(config.get("target_scene", "")))


## Yükleme ekranını kapatır.
func dismiss() -> void:
	_cancel_transition_tween()
	_transition_tween = _overlay_tween_helper.replace(self, _transition_tween, Callable(self, "_clear_transition_tween"))
	_transition_tween.set_parallel(true)
	_transition_tween.tween_property(_dimmer, "color", Color(0.0, 0.0, 0.0, 0.0), TRANSITION_DURATION)
	_transition_tween.tween_property(_panel, "modulate", Color.TRANSPARENT, TRANSITION_DURATION)
	_transition_tween.tween_property(_loading_spinner, "modulate", Color.TRANSPARENT, TRANSITION_DURATION)
	_transition_tween.tween_property(_hint_label, "modulate", Color.TRANSPARENT, TRANSITION_DURATION)
	_transition_tween.tween_callback(Callable(self, "hide"))


func hide_overlay() -> void:
	dismiss()


# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

func _ready() -> void:
	hide()
	_panel.modulate = Color.TRANSPARENT
	_loading_spinner.modulate = Color.TRANSPARENT
	_hint_label.modulate = Color.TRANSPARENT
	_dimmer.color = Color(0.0, 0.0, 0.0, 0.0)


func _exit_tree() -> void:
	_cancel_transition_tween()
	_cancel_progress_tween()


func _start_loading() -> void:
	if _is_loading:
		return
	_is_loading = true

	# Progress simülasyonu (threaded loading entegrasyonu gelene kadar)
	_simulate_progress()

	# Gerçek yükleme basit: change_scene_to_file
	var result := get_tree().change_scene_to_file(_target_scene)
	if result != OK:
		push_error("[LoadingOverlay] Sahne yuklenemedi: %s (error %d)" % [_target_scene, result])

	_is_loading = false
	loading_finished.emit()


func _simulate_progress() -> void:
	"""Yükleme çubuğunu göstermelik doldurur.
	Not: Threaded loading gelince ResourceLoader.load_threaded_request ile
	gerçek progress takibi yapılacak."""
	_cancel_progress_tween()
	_progress_tween = _overlay_tween_helper.replace(self, _progress_tween, Callable(self, "_clear_progress_tween"))
	_progress_tween.set_parallel(false)
	_progress_tween.tween_property(_progress_bar, "value", 0.3, 0.15)
	_progress_tween.tween_property(_progress_bar, "value", 0.6, 0.20)
	_progress_tween.tween_property(_progress_bar, "value", 0.85, 0.25)
	_progress_tween.tween_property(_progress_bar, "value", 1.0, 0.30)


func _cancel_transition_tween() -> void:
	_transition_tween = _overlay_tween_helper.cancel(_transition_tween)


func _cancel_progress_tween() -> void:
	_progress_tween = _overlay_tween_helper.cancel(_progress_tween)


func _clear_transition_tween() -> void:
	_transition_tween = null


func _clear_progress_tween() -> void:
	_progress_tween = null


# ---------------------------------------------------------------------------
# İpuçları (tarih bilgileri)
# ---------------------------------------------------------------------------
var hints: Array[String] = [
	"Bandırma Vapuru 19 Mayıs 1919'da Samsun'a doğru yola çıktı!",
	"Mustafa Kemal, halkı bilinçlendirmek için kongreler düzenledi.",
	"Havza Genelgesi ile milli mücadele başladı.",
	"Amasya Genelgesi'nde milletin istiklalini yine milletin azim ve kararı kurtaracaktır denildi.",
	"Erzurum Kongresi'nde vatanın bütünlüğü korunacağı kararlaştırıldı.",
	"Sivas Kongresi'nde tüm direniş güçleri tek çatı altında toplandı.",
	"23 Nisan 1920'de Büyük Millet Meclisi açıldı.",
	"Mustafa Kemal'e 1921'de Başkomutanlık yetkisi verildi.",
	"Sakarya Meydan Muharebesi 22 gün 22 gece sürdü.",
	"30 Ağustos 1922'de Başkomutanlık Meydan Muharebesi kazanıldı.",
]
