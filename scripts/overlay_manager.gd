## MMAE - Merkezi Overlay Yönetim Sistemi
## =========================================
## Her overlay kendi CanvasLayer'ına sahiptir.
## Stack mantığı: yeni overlay açıldığında eskisi stack'e push'lanır,
## kapatıldığında stack'teki bir önceki overlay geri gösterilir.
##
## Layer Mapping:
##   DIALOGUE           → layer 50
##   DECISION           → layer 60
##   INFO_CARD          → layer 70
##   CHAPTER_TRANSITION → layer 80
##   DREAM_INTRO        → layer 90

class_name OverlayManager
extends Node


# ---------------------------------------------------------------------------
# ENUM
# ---------------------------------------------------------------------------
enum OverlayType {
	DIALOGUE,
	DECISION,
	INFO_CARD,
	CHAPTER_TRANSITION,
	DREAM_INTRO,
	EXIT_CONFIRM,
	LOADING,  # layer 110 — en üstte
}


# ---------------------------------------------------------------------------
# SABİTLER
# ---------------------------------------------------------------------------
const HUD_LAYER: int = 10
const LAYER_BASE: int = 50
const LAYER_STEP: int = 10
const OVERLAY_HOST_NAME := "UIOverlayHost"


# ---------------------------------------------------------------------------
# DEĞİŞKENLER
# ---------------------------------------------------------------------------
var _overlay_stack: Array[OverlayType] = []
var _active_overlay: int = -1
var _overlay_nodes: Dictionary = {}     # OverlayType → Node
var _canvas_layers: Dictionary = {}     # OverlayType → CanvasLayer


# ---------------------------------------------------------------------------
# PUBLIC API
# ---------------------------------------------------------------------------

## Overlay'i sisteme kaydeder, CanvasLayer'ını oluşturur ve reparent eder.
func register_overlay(type: OverlayType, node: Node) -> void:
	_overlay_nodes[type] = node
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_STOP

	var canvas: CanvasLayer = _create_canvas_layer(type)
	canvas.visible = false
	add_child(canvas)
	_canvas_layers[type] = canvas

	# Node'u mevcut parent'ından alıp CanvasLayer altına reparent et
	var old_parent: Node = node.get_parent()
	if old_parent != null:
		old_parent.remove_child(node)
	canvas.add_child(node)


## Overlay'i gösterir, stack'i yönetir.
## Eğer aynı tip zaten açıksa replace yapmaz (zaten görünür).
## Eğer farklı tip açıksa, eskisini gizler ama stack'te tutar.
func show(type: OverlayType, _data: Dictionary = {}) -> void:
	# Aynı tip zaten aktifse — sadece görünür olduğundan emin ol
	if _active_overlay == type:
		if _canvas_layers.has(type):
			_canvas_layers[type].visible = true
		_show_overlay_node(type, _data)
		return

	# Farklı bir overlay aktif — önce onu stack'e push'la ve gizle
	if _active_overlay >= 0:
		var prev_type: OverlayType = _active_overlay as OverlayType
		_overlay_stack.append(prev_type)
		if _canvas_layers.has(prev_type):
			_canvas_layers[prev_type].visible = false

	# Yeni overlay'i göster
	_active_overlay = type
	if _canvas_layers.has(type):
		_canvas_layers[type].visible = true
	_show_overlay_node(type, _data)


## Overlay'i gizler, stack'ten pop'la.
## Stack'te önceki overlay varsa onu geri gösterir.
func hide(type: OverlayType) -> void:
	_hide_overlay_node(type)
	if _canvas_layers.has(type):
		_canvas_layers[type].visible = false

	# Stack'ten temizle
	_overlay_stack.erase(type)

	# Eğer bu aktif overlay ise, stack'teki bir öncekini geri getir
	if _active_overlay == type:
		if _overlay_stack.size() > 0:
			var prev_type: OverlayType = _overlay_stack.pop_back()
			_active_overlay = prev_type
			if _canvas_layers.has(prev_type):
				# P10: Sadece overlay node'u hala görünür durumdaysa CanvasLayer'ı göster.
				# (Bazı overlay'ler — örn. chapter_transition — kendi tween'leri bitince
				# node.visible=false yapar, ama CanvasLayer.visible true kalırsa
				# is_any_overlay_visible() yanlış pozitif döner ve oyuncu input'u bloke olur.)
				var overlay_node: Node = _overlay_nodes.get(prev_type)
				if overlay_node != null and overlay_node.visible:
					_canvas_layers[prev_type].visible = true
				else:
					_canvas_layers[prev_type].visible = false
		else:
			_active_overlay = -1


## Tüm overlay'leri gizler, stack'i temizler.
func hide_all() -> void:
	for type_key in _overlay_nodes.keys():
		var overlay_type: OverlayType = type_key as OverlayType
		_hide_overlay_node(overlay_type)
		if _canvas_layers.has(overlay_type):
			_canvas_layers[overlay_type].visible = false
	_overlay_stack.clear()
	_active_overlay = -1


## Aktif overlay tipini döndürür. -1 = hiçbiri.
func get_active() -> int:
	return _active_overlay


## Belirtilen overlay görünür mü?
func is_visible(type: OverlayType) -> bool:
	if _canvas_layers.has(type):
		return _canvas_layers[type].visible
	return false


## Overlay'in kendisini (Node) döndürür.
func get_overlay_node(type: OverlayType) -> Node:
	if _overlay_nodes.has(type):
		return _overlay_nodes[type] as Node
	return null


## Overlay'in CanvasLayer'ını döndürür.
func get_canvas_layer(type: OverlayType) -> CanvasLayer:
	if _canvas_layers.has(type):
		return _canvas_layers[type] as CanvasLayer
	return null


static func layer_for(type: OverlayType) -> int:
	return LAYER_BASE + int(type) * LAYER_STEP


static func canvas_name_for(type: OverlayType) -> String:
	return "CanvasLayer_%d" % int(type)


# ---------------------------------------------------------------------------
# PRIVATE
# ---------------------------------------------------------------------------

func _create_canvas_layer(type: OverlayType) -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.layer = layer_for(type)
	layer.name = canvas_name_for(type)
	return layer


func _show_overlay_node(type: OverlayType, data: Dictionary) -> void:
	var node: Node = _overlay_nodes.get(type)
	if node == null:
		return
	if node.has_method("show_overlay"):
		node.call("show_overlay", data)
	elif node is CanvasItem:
		(node as CanvasItem).visible = true


func _hide_overlay_node(type: OverlayType) -> void:
	var node: Node = _overlay_nodes.get(type)
	if node == null:
		return
	if node.has_method("hide_overlay"):
		node.call("hide_overlay")
	elif node is CanvasItem:
		(node as CanvasItem).visible = false
