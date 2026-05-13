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
const DEFAULT_TITLE := "Bandırma Yolculuğu"
const THREADED_TYPE_HINT := "PackedScene"
const THREADED_INITIAL_PROGRESS := 0.05
const THREADED_CACHE_MODE := ResourceLoader.CACHE_MODE_IGNORE
const _overlay_tween_helper := preload("res://scripts/overlay_tween_helper.gd")


# Node referanslari
@onready var _dimmer: ColorRect = $Dimmer
@onready var _panel: PanelContainer = $CenterContainer/Panel
@onready var _progress_bar: TextureProgressBar = $CenterContainer/Panel/Margin/VBox/ProgressBar
@onready var _hint_label: Label = $CenterContainer/Panel/Margin/VBox/HintLabel
@onready var _title_label: Label = $CenterContainer/Panel/Margin/VBox/TitleLabel
@onready var _loading_spinner: TextureRect = $CenterContainer/Panel/Margin/VBox/SpinnerRow/Spinner

var _target_scene: String = ""
var _pending_entry_action := ""
var _overlay_title := DEFAULT_TITLE
var _staged_hint_text := ""
var _is_loading := false
var _threaded_status := ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
var _threaded_progress := 0.0
var _transition_tween: Tween
var _progress_tween: Tween


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Yükleme ekranını gösterir ve hedef sahneyi yüklemeye başlar.
## target_scene: "res://scenes/world.tscn" gibi tam path.
func present(target_scene: String) -> void:
	present_request({"target_scene": target_scene})


func present_request(request: Dictionary) -> void:
	if not stage_request(request):
		return
	_cancel_transition_tween()
	show()

	_progress_bar.value = 0
	_title_label.text = _overlay_title
	_hint_label.text = _staged_hint_text if not _staged_hint_text.is_empty() else hints.pick_random()

	# Fade-in animasyonu
	_transition_tween = _overlay_tween_helper.replace(self, _transition_tween, Callable(self, "_clear_transition_tween"))
	_transition_tween.set_parallel(true)
	_overlay_tween_helper.fade_color_alpha(_transition_tween, _dimmer, 0.70, TRANSITION_DURATION)
	_overlay_tween_helper.fade_modulate_alpha(_transition_tween, _panel, 1.0, TRANSITION_DURATION)
	_overlay_tween_helper.fade_modulate_alpha(_transition_tween, _loading_spinner, 1.0, TRANSITION_DURATION)
	_overlay_tween_helper.fade_modulate_alpha(_transition_tween, _hint_label, 1.0, TRANSITION_DURATION)
	_transition_tween.tween_callback(Callable(self, "_start_loading"))


func show_overlay(config: Dictionary = {}) -> void:
	present_request(config)


func stage_request(request: Dictionary) -> bool:
	var target_scene := String(request.get("target_scene", "")).strip_edges()
	if target_scene.is_empty():
		push_error("[LoadingOverlay] target_scene bos birakilamaz.")
		return false
	_target_scene = target_scene
	_pending_entry_action = String(request.get("entry_action", "")).strip_edges()
	_overlay_title = String(request.get("title", DEFAULT_TITLE)).strip_edges()
	if _overlay_title.is_empty():
		_overlay_title = DEFAULT_TITLE
	_staged_hint_text = String(request.get("hint_text", "")).strip_edges()
	return true


func get_loading_request() -> Dictionary:
	return {
		"target_scene": _target_scene,
		"entry_action": _pending_entry_action,
		"title": _overlay_title,
		"hint_text": _staged_hint_text,
	}


## Yükleme ekranını kapatır.
func dismiss() -> void:
	_cancel_transition_tween()
	_transition_tween = _overlay_tween_helper.replace(self, _transition_tween, Callable(self, "_clear_transition_tween"))
	_transition_tween.set_parallel(true)
	_overlay_tween_helper.fade_color_alpha(_transition_tween, _dimmer, 0.0, TRANSITION_DURATION)
	_overlay_tween_helper.fade_modulate_alpha(_transition_tween, _panel, 0.0, TRANSITION_DURATION)
	_overlay_tween_helper.fade_modulate_alpha(_transition_tween, _loading_spinner, 0.0, TRANSITION_DURATION)
	_overlay_tween_helper.fade_modulate_alpha(_transition_tween, _hint_label, 0.0, TRANSITION_DURATION)
	_transition_tween.tween_callback(Callable(self, "hide"))


func hide_overlay() -> void:
	dismiss()


# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

func _ready() -> void:
	hide()
	set_process(false)
	_panel.modulate = Color.TRANSPARENT
	_loading_spinner.modulate = Color.TRANSPARENT
	_hint_label.modulate = Color.TRANSPARENT
	_dimmer.color = Color(0.0, 0.0, 0.0, 0.0)


func _exit_tree() -> void:
	set_process(false)
	_cancel_transition_tween()
	_cancel_progress_tween()


func _process(_delta: float) -> void:
	if not _is_loading:
		return
	_advance_threaded_loading()


func _start_loading() -> void:
	if _is_loading:
		return
	_is_loading = true
	_apply_entry_context()
	if not _begin_threaded_load_request():
		_fail_loading("[LoadingOverlay] Threaded load baslatilamadi: %s" % _target_scene)
		return
	set_process(true)


func _begin_threaded_load_request() -> bool:
	_cancel_progress_tween()
	_threaded_status = ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	_threaded_progress = 0.0
	var request_result := ResourceLoader.load_threaded_request(_target_scene, THREADED_TYPE_HINT, false, THREADED_CACHE_MODE)
	if request_result != OK:
		push_error("[LoadingOverlay] Threaded request baslatilamadi: %s (error %d)" % [_target_scene, request_result])
		return false
	_set_progress_value(THREADED_INITIAL_PROGRESS)
	return true


func _read_threaded_load_snapshot() -> Dictionary:
	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(_target_scene, progress)
	var sampled_progress := _threaded_progress
	if progress.size() > 0:
		sampled_progress = clampf(float(progress[0]), 0.0, 1.0)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		sampled_progress = 1.0
	_threaded_status = status
	_threaded_progress = maxf(_threaded_progress, sampled_progress)
	_set_progress_value(_threaded_progress)
	return {
		"status": status,
		"progress": _threaded_progress,
	}


func _consume_loaded_scene() -> PackedScene:
	if _threaded_status != ResourceLoader.THREAD_LOAD_LOADED:
		var snapshot := _read_threaded_load_snapshot()
		if int(snapshot.get("status", ResourceLoader.THREAD_LOAD_INVALID_RESOURCE)) != ResourceLoader.THREAD_LOAD_LOADED:
			return null
	var loaded_resource := ResourceLoader.load_threaded_get(_target_scene)
	if loaded_resource is PackedScene:
		return loaded_resource as PackedScene
	return null


func _advance_threaded_loading() -> void:
	var snapshot := _read_threaded_load_snapshot()
	var status := int(snapshot.get("status", ResourceLoader.THREAD_LOAD_INVALID_RESOURCE))
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		return
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed_scene := _consume_loaded_scene()
		if packed_scene == null:
			_fail_loading("[LoadingOverlay] Threaded load tamamlandi ama PackedScene okunamadi: %s" % _target_scene)
			return
		_complete_scene_change(packed_scene)
		return
	_fail_loading("[LoadingOverlay] Threaded load basarisiz: %s (status %d)" % [_target_scene, status])


func _complete_scene_change(packed_scene: PackedScene) -> void:
	_set_progress_value(1.0)
	var result := get_tree().change_scene_to_packed(packed_scene)
	if result != OK:
		_fail_loading("[LoadingOverlay] PackedScene degisimi basarisiz: %s (error %d)" % [_target_scene, result])
		return
	_finish_loading_cycle(true)


func _fail_loading(message: String) -> void:
	push_error(message)
	dismiss()
	_finish_loading_cycle(false)


func _finish_loading_cycle(_success: bool) -> void:
	_is_loading = false
	set_process(false)
	loading_finished.emit()
	_clear_request_state()


func _set_progress_value(progress_ratio: float) -> void:
	_progress_bar.value = clampf(progress_ratio, 0.0, 1.0)


func _cancel_transition_tween() -> void:
	_transition_tween = _overlay_tween_helper.cancel(_transition_tween)


func _cancel_progress_tween() -> void:
	_progress_tween = _overlay_tween_helper.cancel(_progress_tween)


func _clear_transition_tween() -> void:
	_transition_tween = null


func _clear_progress_tween() -> void:
	_progress_tween = null


func _apply_entry_context() -> void:
	if not _pending_entry_action.is_empty():
		var save_manager := get_node_or_null("/root/SaveManager")
		if save_manager != null:
			save_manager.set("pending_entry_action", _pending_entry_action)
		else:
			push_warning("[LoadingOverlay] SaveManager autoload bulunamadi; entry_action uygulanamadi.")


func _clear_request_state() -> void:
	_target_scene = ""
	_pending_entry_action = ""
	_staged_hint_text = ""
	_overlay_title = DEFAULT_TITLE
	_threaded_status = ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	_threaded_progress = 0.0


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
